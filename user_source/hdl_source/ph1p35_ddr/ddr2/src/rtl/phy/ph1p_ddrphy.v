`timescale 1ps/1ps

module ph1p_ddrphy #(

    parameter BK_NUM     = 2 ,
    parameter AC_NUM     = 4 ,
    parameter DX_NUM     = 4 ,

    parameter CK_WIDTH   = 1 ,
    parameter CS_WIDTH   = 1 ,
    parameter CKE_WIDTH  = 1 ,
    parameter ODT_WIDTH  = 1 ,
    parameter BG_WIDTH   = 3 ,
    parameter BA_WIDTH   = 3 ,
    parameter ADR_WIDTH  = 14, 

    parameter MDL_MODE   = "FULL",

    parameter AC_DRV     = "48",
    parameter DX_DRV     = "48",
    parameter DX_ODT     = "60"
)(
    // clock & reset
    input                         dhi_clk         ,
    input   [BK_NUM    *1-1 : 0]  ctl_clk         ,
    input   [BK_NUM    *1-1 : 0]  ddr_clk         ,

    input                         ddrphy_rst_n    ,
    input                         dx_fifo_rst_n   ,
    input   [DX_NUM    *1-1 : 0]  dx_fifo_en      ,

    // ddrphy host interface - ac
    input                         dhi_rst_n    ,
    input   [           4-1 : 0]  dhi_cke      ,
    input   [           4-1 : 0]  dhi_odt      ,
    input   [           4-1 : 0]  dhi_cs_n     ,
    input   [           4-1 : 0]  dhi_act_n    ,
    input   [           4-1 : 0]  dhi_ras_n    ,
    input   [           4-1 : 0]  dhi_cas_n    ,
    input   [           4-1 : 0]  dhi_we_n     ,
    input   [BG_WIDTH  *4-1 : 0]  dhi_bg       ,
    input   [BA_WIDTH  *4-1 : 0]  dhi_ba       ,
    input   [ADR_WIDTH *4-1 : 0]  dhi_addr     ,
    input   [           4-1 : 0]  dhi_parity   ,

    // ddrphy host interface - dx
    input   [DX_NUM*    8-1 : 0]  dhi_oe       ,
    input   [DX_NUM*    8-1 : 0]  dhi_te       ,
    input   [DX_NUM*    8-1 : 0]  dhi_pdr      ,
    input   [DX_NUM*    8-1 : 0]  dhi_wdqs     ,
    input   [DX_NUM*   64-1 : 0]  dhi_wdq      ,
    input   [DX_NUM*    8-1 : 0]  dhi_wdm      ,
    input   [DX_NUM*    8-1 : 0]  dhi_rdq_en   ,
    output  [DX_NUM      -1 : 0]  dhi_rdq_vld  ,
    output  [DX_NUM*   64-1 : 0]  dhi_rdq      ,

    // APB
    input                      apb_pclk        ,
    input                      apb_prst_n      ,
    input                      apb_psel        ,
    input                      apb_penable     ,
    input                      apb_pwrite      ,
    input   [         15 : 0]  apb_paddr       ,
    input   [         31 : 0]  apb_pwdata      ,
    output                     apb_pready      ,
    output  [         31 : 0]  apb_prdata      ,

    // delayline configuration port
    input                      ac_dcp_psel     ,
    input   [         5  : 0]  ac_dcp_paddr    ,
    input   [         8  : 0]  ac_dcp_pdata    ,
    input                      ac_dcp_gate     ,

    input   [DX_NUM* 1-1 : 0]  dx_dcp_psel     ,
    input   [DX_NUM* 6-1 : 0]  dx_dcp_paddr    ,
    input   [DX_NUM* 9-1 : 0]  dx_dcp_pdata    ,
    input   [DX_NUM* 1-1 : 0]  dx_dcp_gate     ,

    // misc - mdl
    input   [DX_NUM* 1-1 : 0]  cal_clk_en      ,
    input   [DX_NUM* 1-1 : 0]  cal_mode        ,
    input   [DX_NUM* 1-1 : 0]  cal_en          ,
    output  [DX_NUM* 1-1 : 0]  cal_en_out      ,
    output  [DX_NUM* 1-1 : 0]  cal_out         ,

    // misc
    input                      lb_enb          ,
    input                      wrlvl_en        ,
    input                      dqs_pupd_en     ,
    output  [DX_NUM* 2-1 : 0]  dqs_gate_status ,
    output  [DX_NUM* 8-1 : 0]  dx_indd         ,
    output  [DX_NUM*16-1 : 0]  dx_debug        ,

    // io
    output  [AC_NUM*13-1 : 0]  ac_byte_io      ,
    output  [DX_NUM*13-1 : 0]  dx_byte_io
);

//*****************************************************************************************************************************
//    Local Parameter
//*****************************************************************************************************************************
`ifdef PH1P_DDRPHY_SIM
`include "ph1p_ddrphy_pad_type.vh"
`else
`include "./include/ph1p_ddrphy_pad_type.vh"
`endif

localparam [4*13*4-1 : 0] AC_PAD_TYPE = {AC3_PAD_TYPE, AC2_PAD_TYPE, AC1_PAD_TYPE, AC0_PAD_TYPE};
localparam [9*13*4-1 : 0] DX_PAD_TYPE = {DX8_PAD_TYPE, DX7_PAD_TYPE, DX6_PAD_TYPE, DX5_PAD_TYPE, DX4_PAD_TYPE, DX3_PAD_TYPE, DX2_PAD_TYPE, DX1_PAD_TYPE, DX0_PAD_TYPE};

localparam DQ_WIDTH = DX_NUM*8;
localparam DM_WIDTH = DX_NUM;

`ifdef DRAM_DDR2
    localparam DRAM_TYPE = "DDR2";
    `ifdef PH1P_VCCIO_1V80
    localparam VCCIO   =  "1V80";
    localparam IOTYPE  =  "SSTL18_I";
    `elsif PH1P_VCCIO_1V50
    localparam VCCIO   =  "1V50";
    localparam IOTYPE  =  "SSTL15";
    `endif
`elsif DRAM_DDR3
    localparam DRAM_TYPE = "DDR3";
    `ifdef PH1P_VCCIO_1V50
    localparam VCCIO   =  "1V50";
    localparam IOTYPE  =  "SSTL15";
    `elsif PH1P_VCCIO_1V35
    localparam VCCIO   =  "1V35";
    localparam IOTYPE  =  "SSTL135";
    `endif
`elsif DRAM_DDR4
    localparam DRAM_TYPE = "DDR4";
    localparam VCCIO     = "1V20";
    localparam IOTYPE    = "POD12";
`endif

//*****************************************************************************************************************************
//    Internal Signals
//*****************************************************************************************************************************
// APB - AC
wire             ac_apb_pclk   ;
wire             ac_apb_prst_n ;
wire  [4* 1-1:0] ac_apb_psel   ;
wire             ac_apb_penable;
wire             ac_apb_pwrite ;
wire  [   8-1:0] ac_apb_paddr  ;
wire  [  32-1:0] ac_apb_pwdata ;
wire  [4* 1-1:0] ac_apb_pready ;
wire  [4*32-1:0] ac_apb_prdata ;

// APB - DX
wire             dx_apb_pclk   ;
wire             dx_apb_prst_n ;
wire  [9* 1-1:0] dx_apb_psel   ;
wire             dx_apb_penable;
wire             dx_apb_pwrite ;
wire  [   8-1:0] dx_apb_paddr  ;
wire  [  32-1:0] dx_apb_pwdata ;
wire  [9* 1-1:0] dx_apb_pready ;
wire  [9*32-1:0] dx_apb_prdata ;

// APB - BANKREF
wire             bk_apb_pclk   ;
wire             bk_apb_prst_n ;
wire  [3* 1-1:0] bk_apb_psel   ;
wire             bk_apb_penable;
wire             bk_apb_pwrite ;
wire  [   8-1:0] bk_apb_paddr  ;
wire  [   8-1:0] bk_apb_pwdata ;
wire  [3* 1-1:0] bk_apb_pready ;
wire  [3* 8-1:0] bk_apb_prdata ;

// IOCLK
wire  [AC_NUM-1:0] ctl_clk_ac;
wire  [DX_NUM-1:0] ctl_clk_dx;
wire  [AC_NUM-1:0] ddr_clk_ac;
wire  [DX_NUM-1:0] ddr_clk_dx;

// CTL_WDATA - AC
wire  [  13*8-1:0] ac0_wdata     ;
wire  [  13*8-1:0] ac1_wdata     ;
wire  [  13*8-1:0] ac2_wdata     ;
wire  [  13*8-1:0] ac3_wdata     ;
wire  [  13*8-1:0] dx0_wdata     ;
wire  [  13*8-1:0] dx1_wdata     ;
wire  [  13*8-1:0] dx2_wdata     ;
wire  [  13*8-1:0] dx3_wdata     ;
wire  [  13*8-1:0] dx4_wdata     ;
wire  [  13*8-1:0] dx5_wdata     ;
wire  [  13*8-1:0] dx6_wdata     ;
wire  [  13*8-1:0] dx7_wdata     ;
wire  [  13*8-1:0] dx8_wdata     ;

wire  [     8-1:0] dx0_rdqs_gate ;
wire  [     8-1:0] dx1_rdqs_gate ;
wire  [     8-1:0] dx2_rdqs_gate ;
wire  [     8-1:0] dx3_rdqs_gate ;
wire  [     8-1:0] dx4_rdqs_gate ;
wire  [     8-1:0] dx5_rdqs_gate ;
wire  [     8-1:0] dx6_rdqs_gate ;
wire  [     8-1:0] dx7_rdqs_gate ;
wire  [     8-1:0] dx8_rdqs_gate ;

wire  [4*13*8-1:0] ac_wdata = {ac3_wdata, ac2_wdata, ac1_wdata, ac0_wdata};
wire  [9*13*8-1:0] dx_wdata = {dx8_wdata, dx7_wdata, dx6_wdata, dx5_wdata, dx4_wdata, dx3_wdata, dx2_wdata, dx1_wdata, dx0_wdata};

wire  [9*   8-1:0] dx_rdqs_gate = {dx8_rdqs_gate, dx7_rdqs_gate, dx6_rdqs_gate, dx5_rdqs_gate, dx4_rdqs_gate, dx3_rdqs_gate, dx2_rdqs_gate, dx1_rdqs_gate, dx0_rdqs_gate};
wire  [9*   1-1:0] dx_rdata_vld ;
wire  [9*13*8-1:0] dx_rdata     ;

wire  [  13*8-1:0] dx0_rdata     = dx_rdata[0*13*8 +: 13*8];
wire  [  13*8-1:0] dx1_rdata     = dx_rdata[1*13*8 +: 13*8];
wire  [  13*8-1:0] dx2_rdata     = dx_rdata[2*13*8 +: 13*8];
wire  [  13*8-1:0] dx3_rdata     = dx_rdata[3*13*8 +: 13*8];
wire  [  13*8-1:0] dx4_rdata     = dx_rdata[4*13*8 +: 13*8];
wire  [  13*8-1:0] dx5_rdata     = dx_rdata[5*13*8 +: 13*8];
wire  [  13*8-1:0] dx6_rdata     = dx_rdata[6*13*8 +: 13*8];
wire  [  13*8-1:0] dx7_rdata     = dx_rdata[7*13*8 +: 13*8];
wire  [  13*8-1:0] dx8_rdata     = dx_rdata[8*13*8 +: 13*8];

wire  [DX_NUM*   13-1 : 0]  dx_indd_bit  ;

wire  [DX_NUM   *64-1 : 0]  dhi_wdq_bit   ;
wire  [DX_NUM*   64-1 : 0]  dhi_rdq_bit  ;

wire  [           8-1 : 0]  dhi_rst_n_x8 ;
wire  [CKE_WIDTH *8-1 : 0]  dhi_cke_x8   ;
wire  [ODT_WIDTH *8-1 : 0]  dhi_odt_x8   ;
wire  [CS_WIDTH  *8-1 : 0]  dhi_cs_n_x8  ;
wire  [           8-1 : 0]  dhi_act_n_x8 ;
wire  [           8-1 : 0]  dhi_ras_n_x8 ;
wire  [           8-1 : 0]  dhi_cas_n_x8 ;
wire  [           8-1 : 0]  dhi_we_n_x8  ;
wire  [BG_WIDTH  *8-1 : 0]  dhi_bg_x8    ;
wire  [BA_WIDTH  *8-1 : 0]  dhi_ba_x8    ;
wire  [ADR_WIDTH *8-1 : 0]  dhi_addr_x8  ;
wire  [           8-1 : 0]  dhi_parity_x8;

wire  [DX_NUM    *7-1 : 0]  cal_en_out_int;
wire  [DX_NUM    *7-1 : 0]  cal_out_int   ;

wire  [BK_NUM    *8-1 : 0]  vref1_ctrl    ;
wire  [BK_NUM    *8-1 : 0]  vref2_ctrl    ;

//*****************************************************************************************************************************
//    Function : APB MUX
//*****************************************************************************************************************************
// APB - AC
assign ac_apb_pclk    = apb_pclk   ;
assign ac_apb_prst_n  = apb_prst_n ;
assign ac_apb_penable = apb_penable;
assign ac_apb_pwrite  = apb_pwrite ;
assign ac_apb_paddr   = apb_paddr[7:0] ;
assign ac_apb_pwdata  = apb_pwdata ; 

assign ac_apb_psel[0] = (apb_paddr[15:8] == 8'h00) ? apb_psel : 1'b0; 
assign ac_apb_psel[1] = (apb_paddr[15:8] == 8'h01) ? apb_psel : 1'b0;
assign ac_apb_psel[2] = (apb_paddr[15:8] == 8'h02) ? apb_psel : 1'b0;
assign ac_apb_psel[3] = (apb_paddr[15:8] == 8'h03) ? apb_psel : 1'b0;

// APB - DX
assign dx_apb_pclk    = apb_pclk   ;
assign dx_apb_prst_n  = apb_prst_n ;
assign dx_apb_penable = apb_penable;
assign dx_apb_pwrite  = apb_pwrite ;
assign dx_apb_paddr   = apb_paddr[7:0];
assign dx_apb_pwdata  = apb_pwdata ; 
assign dx_apb_psel[0] = (apb_paddr[15:8] == 8'h10) ? apb_psel : 1'b0; 
assign dx_apb_psel[1] = (apb_paddr[15:8] == 8'h11) ? apb_psel : 1'b0; 
assign dx_apb_psel[2] = (apb_paddr[15:8] == 8'h12) ? apb_psel : 1'b0; 
assign dx_apb_psel[3] = (apb_paddr[15:8] == 8'h13) ? apb_psel : 1'b0; 
assign dx_apb_psel[4] = (apb_paddr[15:8] == 8'h14) ? apb_psel : 1'b0; 
assign dx_apb_psel[5] = (apb_paddr[15:8] == 8'h15) ? apb_psel : 1'b0; 
assign dx_apb_psel[6] = (apb_paddr[15:8] == 8'h16) ? apb_psel : 1'b0; 
assign dx_apb_psel[7] = (apb_paddr[15:8] == 8'h17) ? apb_psel : 1'b0; 
assign dx_apb_psel[8] = (apb_paddr[15:8] == 8'h18) ? apb_psel : 1'b0; 

// APB - BANKREF
assign bk_apb_pclk    = apb_pclk   ;
assign bk_apb_prst_n  = apb_prst_n ;
assign bk_apb_penable = apb_penable;
assign bk_apb_pwrite  = apb_pwrite ;
assign bk_apb_paddr   = apb_paddr [7:0];
assign bk_apb_pwdata  = apb_pwdata[7:0]; 
assign bk_apb_psel[0] = (apb_paddr[15:8] == 8'h20) ? apb_psel : 1'b0; 
assign bk_apb_psel[1] = (apb_paddr[15:8] == 8'h21) ? apb_psel : 1'b0; 
assign bk_apb_psel[2] = (apb_paddr[15:8] == 8'h22) ? apb_psel : 1'b0; 

// APB ACK
assign apb_pready = (apb_paddr[15:8] == 8'h00) ? ac_apb_pready[0] :
                    (apb_paddr[15:8] == 8'h01) ? ac_apb_pready[1] :
                    (apb_paddr[15:8] == 8'h02) ? ac_apb_pready[2] :
                    (apb_paddr[15:8] == 8'h03) ? ac_apb_pready[3] :
                    (apb_paddr[15:8] == 8'h10) ? dx_apb_pready[0] :
                    (apb_paddr[15:8] == 8'h11) ? dx_apb_pready[1] :
                    (apb_paddr[15:8] == 8'h12) ? dx_apb_pready[2] :
                    (apb_paddr[15:8] == 8'h13) ? dx_apb_pready[3] :
                    (apb_paddr[15:8] == 8'h14) ? dx_apb_pready[4] :
                    (apb_paddr[15:8] == 8'h15) ? dx_apb_pready[5] :
                    (apb_paddr[15:8] == 8'h16) ? dx_apb_pready[6] :
                    (apb_paddr[15:8] == 8'h17) ? dx_apb_pready[7] :
                    (apb_paddr[15:8] == 8'h18) ? dx_apb_pready[8] :
                    (apb_paddr[15:8] == 8'h20) ? bk_apb_pready[0] :
                    (apb_paddr[15:8] == 8'h21) ? bk_apb_pready[1] :
                    (apb_paddr[15:8] == 8'h22) ? bk_apb_pready[2] : 1'b1;

assign apb_prdata = (apb_paddr[15:8] == 8'h00) ? ac_apb_prdata[0*32 +: 32] :
                    (apb_paddr[15:8] == 8'h01) ? ac_apb_prdata[1*32 +: 32] :
                    (apb_paddr[15:8] == 8'h02) ? ac_apb_prdata[2*32 +: 32] :
                    (apb_paddr[15:8] == 8'h03) ? ac_apb_prdata[3*32 +: 32] :
                    (apb_paddr[15:8] == 8'h10) ? dx_apb_prdata[0*32 +: 32] :
                    (apb_paddr[15:8] == 8'h11) ? dx_apb_prdata[1*32 +: 32] :
                    (apb_paddr[15:8] == 8'h12) ? dx_apb_prdata[2*32 +: 32] :
                    (apb_paddr[15:8] == 8'h13) ? dx_apb_prdata[3*32 +: 32] :
                    (apb_paddr[15:8] == 8'h14) ? dx_apb_prdata[4*32 +: 32] :
                    (apb_paddr[15:8] == 8'h15) ? dx_apb_prdata[5*32 +: 32] :
                    (apb_paddr[15:8] == 8'h16) ? dx_apb_prdata[6*32 +: 32] :
                    (apb_paddr[15:8] == 8'h17) ? dx_apb_prdata[7*32 +: 32] :
                    (apb_paddr[15:8] == 8'h18) ? dx_apb_prdata[8*32 +: 32] :
                    (apb_paddr[15:8] == 8'h20) ? {24'h0, bk_apb_prdata[0*8 +: 8]} :
                    (apb_paddr[15:8] == 8'h21) ? {24'h0, bk_apb_prdata[1*8 +: 8]} :
                    (apb_paddr[15:8] == 8'h22) ? {24'h0, bk_apb_prdata[2*8 +: 8]} : 32'hdeadbeef;

//*****************************************************************************************************************************
//    Instantiation : DDRPHY_BANKREF
//*****************************************************************************************************************************
genvar n, b, p;

`ifdef PH1P35_HRIO_PAD
    `define PH1P_BKREF_HR_V2
`elsif PH1P50
    `define PH1P_BKREF_HR_V2
`elsif PH1P_FPSOC_HRIO_PAD
    `define PH1P_BKREF_HR_V2
`elsif PH1P35_DDRIO_PAD
    `define PH1P_BKREF_DDR
`elsif PH1P_FPSOC_HPIO_PAD
    `define PH1P_BKREF_DDR
`else // for PH1P100
    `define PH1P_BKREF_HR_V1
`endif

generate
for (n = 0; n <= 2; n = n+1) begin : bkref

    if (n <= BK_NUM-1) begin
`ifndef PH1P_DDRPHY_SIM

`ifdef PH1P_BKREF_HR_V1 // level2
         ph1p_ddrphy_bankref_cfg u_ddrphy_bankref_cfg (
            .apb_pclk     ( bk_apb_pclk           ),
            .apb_prst_n   ( bk_apb_prst_n         ),
            .apb_penable  ( bk_apb_penable        ),
            .apb_psel     ( bk_apb_psel  [n]      ),
            .apb_pwrite   ( bk_apb_pwrite         ),
            .apb_paddr    ( bk_apb_paddr          ), // input  [7:0]
            .apb_pwdata   ( bk_apb_pwdata         ), // input  [7:0]
            .apb_prdata   ( bk_apb_prdata[n*8+:8] ), // output [7:0]
            .apb_pready   ( bk_apb_pready[n]      ),
            .vref1_ctrl   ( vref1_ctrl   [n*8+:8] ),
            .vref2_ctrl   ( vref2_ctrl   [n*8+:8] )
        );

        PH1P_PHY_HR_BANKREF  #(
            .BYTE01_IOTYPE    ( IOTYPE   ),
            .BYTE23_IOTYPE    ( IOTYPE   ),
            .VREF             ( "INT"    ),
            .VREF1_RANK0_SEL  ( "SRAM"   ),
            .VREF1_RANK1_SEL  ( "SRAM"   ),
            .VREF2_RANK0_SEL  ( "SRAM"   ),
            .VREF2_RANK1_SEL  ( "SRAM"   )
        ) u_ddrphy_bankref    (
            .vref_sel         ( 2'b00                ),
            .vref1_rank0_ctrl ( vref1_ctrl[n*8 +: 8] ),
            .vref1_rank1_ctrl ( vref1_ctrl[n*8 +: 8] ),
            .vref2_rank0_ctrl ( vref2_ctrl[n*8 +: 8] ),
            .vref2_rank1_ctrl ( vref2_ctrl[n*8 +: 8] )
        );
//      assign bk_apb_pready[n]      = 1'b1;
//      assign bk_apb_prdata[n*8+:8] = 8'h0;
`elsif PH1P_BKREF_HR_V2 // level2
         ph1p_ddrphy_bankref_cfg u_ddrphy_bankref_cfg (
            .apb_pclk     ( bk_apb_pclk           ),
            .apb_prst_n   ( bk_apb_prst_n         ),
            .apb_penable  ( bk_apb_penable        ),
            .apb_psel     ( bk_apb_psel  [n]      ),
            .apb_pwrite   ( bk_apb_pwrite         ),
            .apb_paddr    ( bk_apb_paddr          ), // input  [7:0]
            .apb_pwdata   ( bk_apb_pwdata         ), // input  [7:0]
            .apb_prdata   ( bk_apb_prdata[n*8+:8] ), // output [7:0]
            .apb_pready   ( bk_apb_pready[n]      ),
            .vref1_ctrl   ( vref1_ctrl   [n*8+:8] ),
            .vref2_ctrl   ( vref2_ctrl   [n*8+:8] )
        );

        `ifdef PH1P_FPSOC
        DR1P_PHY_HR_BANKREF    #(
        `else
        PH1P_PHY_HR_BANKREF_V2 #(
        `endif
            .BYTE01_IOTYPE    ( IOTYPE   ),
            .BYTE23_IOTYPE    ( IOTYPE   ),
            .VREF             ( "INT"    ),
            .VREF1_RANK0_SEL  ( "SRAM"   ),
            .VREF1_RANK1_SEL  ( "SRAM"   ),
            .VREF2_RANK0_SEL  ( "SRAM"   ),
            .VREF2_RANK1_SEL  ( "SRAM"   )
        ) u_ddrphy_bankref    (
            .vref_sel         ( 2'b00                ),
            .vref1_rank0_ctrl ( vref1_ctrl[n*8 +: 8] ),
            .vref1_rank1_ctrl ( vref1_ctrl[n*8 +: 8] ),
            .vref2_rank0_ctrl ( vref2_ctrl[n*8 +: 8] ),
            .vref2_rank1_ctrl ( vref2_ctrl[n*8 +: 8] )
        );
//      assign bk_apb_pready[n]      = 1'b1;
//      assign bk_apb_prdata[n*8+:8] = 8'h0;
`elsif PH1P_BKREF_DDR // level2
        `ifdef PH1P_FPSOC
        DR1P_PHY_HP_BANKREF #(
        `else
        PH1P_PHY_DDRPHY_BANKREF #(
        `endif
            .VCCIO           ( VCCIO     ),
            .BYTE0_MODE      ("IN"       ), // "NONE", "IN"
            .BYTE1_MODE      ("IN"       ), // "NONE", "IN"
            .BYTE2_MODE      ("IN"       ), // "NONE", "IN"
            .BYTE3_MODE      ("IN"       ), // "NONE", "IN"
            .BYTE0_TYPE      ((DRAM_TYPE == "DDR4") ? "DDR4DX" : DRAM_TYPE ), // "DDR2", "DDR3", "DDR4DX"
            .BYTE1_TYPE      ((DRAM_TYPE == "DDR4") ? "DDR4DX" : DRAM_TYPE ), // "DDR2", "DDR3", "DDR4DX"
            .BYTE2_TYPE      ((DRAM_TYPE == "DDR4") ? "DDR4DX" : DRAM_TYPE ), // "DDR2", "DDR3", "DDR4DX"
            .BYTE3_TYPE      ((DRAM_TYPE == "DDR4") ? "DDR4DX" : DRAM_TYPE ), // "DDR2", "DDR3", "DDR4DX"
            .VREF            ("INT"      ), // "EXT", "INT", "VREF", "NONE"
            .VREF_BYTE0_SEL  ("SRAM"     ), // "SRAM", "DDR"
            .VREF_BYTE1_SEL  ("SRAM"     ), // "SRAM", "DDR"
            .VREF_BYTE2_SEL  ("SRAM"     ), // "SRAM", "DDR"
            .VREF_BYTE3_SEL  ("SRAM"     )  // "SRAM", "DDR"
        ) u_ddrphy_bankref (
            .i_pclk     ( bk_apb_pclk      ),
            .i_preset   (~bk_apb_prst_n    ),
            .i_penable  ( bk_apb_penable   ),
            .i_psel     ( bk_apb_psel  [n] ),
            .i_pwrite   ( bk_apb_pwrite    ),
            .i_paddr    ( bk_apb_paddr     ), // input  [7:0]
            .i_pwdata   ( bk_apb_pwdata    ), // input  [7:0]
            .o_prdata   ( bk_apb_prdata[n*8+:8] ), // output [7:0]
            .o_pready   ( bk_apb_pready[n] )
        );
`endif // level2
`else
        assign bk_apb_pready[n]      = 1'b1;
        assign bk_apb_prdata[n*8+:8] = 8'h0;
`endif
    end else begin
        assign bk_apb_pready[n]      = 1'b1;
        assign bk_apb_prdata[n*8+:8] = 8'h0;
    end // end of if (n <= BK_NUM-1)
end
endgenerate

//*****************************************************************************************************************************
//    Function : DDRPHY HOST Interface - AC Width Extend
//*****************************************************************************************************************************
assign dhi_rst_n_x8 = {8{dhi_rst_n}};

generate
for (p = 0; p <= 4-1; p = p+1) begin : dhi_phase_extend

    assign dhi_act_n_x8 [p*2 +: 2] = {2{dhi_act_n [p]}};
    assign dhi_ras_n_x8 [p*2 +: 2] = {2{dhi_ras_n [p]}};
    assign dhi_cas_n_x8 [p*2 +: 2] = {2{dhi_cas_n [p]}};
    assign dhi_we_n_x8  [p*2 +: 2] = {2{dhi_we_n  [p]}};
    assign dhi_parity_x8[p*2 +: 2] = {2{dhi_parity[p]}};

    for (n = 0; n <= CKE_WIDTH-1; n = n+1) begin : dhi_cke_extend
        assign dhi_cke_x8[n*8+p*2 +: 2] = {2{dhi_cke[p]}};
    end

    for (n = 0; n <= CS_WIDTH-1; n = n+1) begin : dhi_cs_extend
        assign dhi_cs_n_x8[n*8+p*2 +: 2] = {2{dhi_cs_n[p]}};
    end

    for (n = 0; n <= ODT_WIDTH-1; n = n+1) begin : dhi_odt_extend
        assign dhi_odt_x8[n*8+p*2 +: 2] = {2{dhi_odt[p]}};
    end

    for (n = 0; n <= BG_WIDTH-1; n = n+1) begin : dhi_bg_extend
        assign dhi_bg_x8[n*8+p*2 +: 2] = {2{dhi_bg[n*4+p]}};
    end

    for (n = 0; n <= BA_WIDTH-1; n = n+1) begin : dhi_ba_extend
        assign dhi_ba_x8[n*8+p*2 +: 2] = {2{dhi_ba[n*4+p]}};
    end

    for (n = 0; n <= ADR_WIDTH-1; n = n+1) begin : dhi_addr_extend
        assign dhi_addr_x8[n*8+p*2 +: 2] = {2{dhi_addr[n*4+p]}};
    end
end
endgenerate

//*****************************************************************************************************************************
//    Function : DDRPHY HOST Interface - Bus_Matrix (This part is generated by Script)
//*****************************************************************************************************************************
`ifdef PH1P_DDRPHY_SIM
`include "ph1p_ddrphy_bus_matrix.vh"
`else
`include "./include/ph1p_ddrphy_bus_matrix.vh"
`endif

for (n = 0; n <= DX_NUM-1; n = n+1) begin : byteIdx_0
    for (b = 0; b <= 8-1; b = b+1) begin : bitIdx_0
        for (p = 0; p <= 8-1; p = p+1) begin : pIdx_0
            assign dhi_wdq_bit[n*64+b*8+p] = dhi_wdq    [n*64+p*8+b];
            assign dhi_rdq    [n*64+p*8+b] = dhi_rdq_bit[n*64+b*8+p];
        end
    end
end

//*****************************************************************************************************************************
//    Instantiation : DDRPHY_BYTE_WRAPPER - AC
//*****************************************************************************************************************************
generate
for (n = 0; n <= 3; n = n+1) begin: ac_byte
    if (n <= AC_NUM-1) begin : ac_byte_used
        ph1p_ddrphy_byte_wrapper #(
            .BYTE_TYPE ("AC"),
            .PAD_TYPE  ( AC_PAD_TYPE[n*4*13 +: 4*13] )
        ) u_ddrphy_ac_byte_wrapper (
            // clock & reset
            .io_clk          ({2'b00, ddr_clk_ac[n], ctl_clk_ac[n]}), // input   [  3:0]
            .usr_clk         ( dhi_clk                        ), // input
        
            .ctl_rst_n       ( ddrphy_rst_n                   ), // input
            .dqs_rst_n       ( ddrphy_rst_n                   ), // input
            .ac_phy_rst_n    ( ddrphy_rst_n                   ), // input
            .dx_phy_rst_n    ( ddrphy_rst_n                   ), // input
            .dx_fifo_rst_n   ( ddrphy_rst_n                   ), // input
        
            // io ctrl
            .ctl_oe          ( 8'h00                          ), // input   [  7:0]
            .ctl_te          ( 8'h00                          ), // input   [  7:0]
            .ctl_pdr         ( 8'hff                          ), // input   [  7:0]
        
            // fifo ctrl
            .dx_rfifo_en     ( 1'b0                           ), // input
        
            // data port
            .ctl_wdata       ( ac_wdata      [n*13*8 +: 13*8] ), // input   [103:0]
            .ctl_rdqs_gate   ( 8'h00                          ), // input   [  7:0]
        
            // APB
            .apb_pclk        ( ac_apb_pclk                    ), // input
            .apb_prst_n      ( ac_apb_prst_n                  ), // input
            .apb_psel        ( ac_apb_psel   [n]              ), // input
            .apb_penable     ( ac_apb_penable                 ), // input
            .apb_pwrite      ( ac_apb_pwrite                  ), // input
            .apb_paddr       ( ac_apb_paddr                   ), // input   [  7:0]
            .apb_pwdata      ( ac_apb_pwdata                  ), // input   [ 31:0]
            .apb_pready      ( ac_apb_pready [n]              ), // output
            .apb_prdata      ( ac_apb_prdata [n*32 +: 32]     ), // output  [ 31:0]
        
            // delayline configuration port
            .dcp_psel        ( ac_dcp_psel                    ), // input
            .dcp_paddr       ( ac_dcp_paddr                   ), // input   [  5:0]
            .dcp_pdata       ( ac_dcp_pdata                   ), // input   [  8:0]
            .dcp_gate        ( ac_dcp_gate                    ), // input
        
            // misc - mdl
            .cal_clk_en      ( 7'h0                           ), // input
            .cal_mode        ( 1'b0                           ), // input
            .cal_en          ( 7'h0                           ), // input   [  6:0]
            .cal_out         (                                ), // output  [  6:0]
            .cal_en_out      (                                ), // output  [  6:0]
        
            // misc
            .lb_enb          ( 1'b1                           ), // input
            .wrlvl_mode      ( 1'b0                           ), // input
            .debug           (                                ), // output  [ 15:0]
        
            // io
            .byte_io         ( ac_byte_io    [n*13 +: 13]     )  // inout   [ 12:0]
        );
    end else begin : ac_byte_unused
        assign ac_apb_pready[n]          = 1'b1;
        assign ac_apb_prdata[n*32 +: 32] = 32'hdeadbeef;
    end
end
endgenerate

//*****************************************************************************************************************************
//    Instantiation : DDRPHY_BYTE_WRAPPER - DX
//*****************************************************************************************************************************
generate
for (n = 0; n <= 8; n = n+1) begin: dx_byte
    if (n <= DX_NUM-1) begin : dx_byte_used
        ph1p_ddrphy_byte_wrapper #(
            .BYTE_TYPE ("DX"                         ),
            .PAD_TYPE  ( DX_PAD_TYPE[n*4*13 +: 4*13] ),
            .MDL_MODE  ( MDL_MODE                    ),
            .AC_DRV    ( AC_DRV                      ),
            .DX_DRV    ( DX_DRV                      ),
            .DX_ODT    ( DX_ODT                      )
        ) u_ddrphy_dx_byte_wrapper (
            // clock & reset
            .io_clk          ({2'b00, ddr_clk_dx[n], ctl_clk_dx[n]}), // input   [  3:0]
            .usr_clk         ( dhi_clk                        ), // input
        
            .ctl_rst_n       ( ddrphy_rst_n                   ), // input
            .dqs_rst_n       ( ddrphy_rst_n                   ), // input
            .ac_phy_rst_n    ( ddrphy_rst_n                   ), // input
            .dx_phy_rst_n    ( ddrphy_rst_n                   ), // input
            .dx_fifo_rst_n   ( dx_fifo_rst_n                  ), // input
        
            // io ctrl
            .ctl_oe          ( dhi_oe        [n*8 +: 8]       ), // input   [  7:0]
            .ctl_te          ( dhi_te        [n*8 +: 8]       ), // input   [  7:0]
            .ctl_pdr         ( dhi_pdr       [n*8 +: 8]       ), // input   [  7:0]
        
            // fifo ctrl
            .dx_rfifo_en     ( dx_fifo_en                     ), // input
        
            // data port
            .ctl_wdata       ( dx_wdata      [n*13*8 +: 13*8] ), // input   [103:0]
            .ctl_rdata_vld   ( dx_rdata_vld  [n]              ), // output
            .ctl_rdata       ( dx_rdata      [n*13*8 +: 13*8] ), // output  [103:0]
            .ctl_rdqs_gate   ( dx_rdqs_gate  [n*   8 +:    8] ), // input   [  7:0]
        
            // APB
            .apb_pclk        ( dx_apb_pclk                    ), // input
            .apb_prst_n      ( dx_apb_prst_n                  ), // input
            .apb_psel        ( dx_apb_psel   [n]              ), // input
            .apb_penable     ( dx_apb_penable                 ), // input
            .apb_pwrite      ( dx_apb_pwrite                  ), // input
            .apb_paddr       ( dx_apb_paddr                   ), // input   [  7:0]
            .apb_pwdata      ( dx_apb_pwdata                  ), // input   [ 31:0]
            .apb_pready      ( dx_apb_pready [n]              ), // output
            .apb_prdata      ( dx_apb_prdata [n*32 +: 32]     ), // output  [ 31:0]
        
            // delayline configuration port
            .dcp_psel        ( dx_dcp_psel   [n]              ), // input
            .dcp_paddr       ( dx_dcp_paddr  [n*6 +: 6]       ), // input   [  5:0]
            .dcp_pdata       ( dx_dcp_pdata  [n*9 +: 9]       ), // input   [  8:0]
            .dcp_gate        ( dx_dcp_gate   [n]              ), // input
        
            // misc - mdl
            .cal_clk_en      ({6'h0, cal_clk_en [n]}          ), // input   [  6:0]
            .cal_mode        ( cal_mode         [n]           ), // input
            .cal_en          ({6'h0, cal_en     [n]}          ), // input   [  6:0]
            .cal_en_out      ( cal_en_out_int   [n*7 +: 7]    ), // output  [  6:0]
            .cal_out         ( cal_out_int      [n*7 +: 7]    ), // output  [  6:0]
        
            // misc
            .lb_enb          ( lb_enb                         ), // input
            .wrlvl_mode      ( wrlvl_en                       ), // input
            .dqs_pupd_en     ( dqs_pupd_en                    ), // input
            .dqs_gate_status ( dqs_gate_status[n*2 +: 2]      ), // output  [  1:0]
            .dqs_cnt         (                                ), // output  [  1:0]
            .debug           ( dx_debug       [n*16 +: 16]    ), // output  [ 15:0]
        
            // io
            .indd            ( dx_indd_bit    [n*13 +: 13]    ), // output  [ 12:0]
            .byte_io         ( dx_byte_io     [n*13 +: 13]    )  // inout   [ 12:0]
        );

        assign cal_en_out[n] = cal_en_out_int[n*7];
        assign cal_out   [n] = cal_out_int   [n*7];
    end else begin : dx_byte_unused
        assign dx_apb_pready[n]          = 1'b1;
        assign dx_apb_prdata[n*32 +: 32] = 32'hdeadbeef;
    end
end
endgenerate


endmodule

