`timescale 1ps/1ps

module ph1p_ddrphy_top #(
    parameter BK_NUM     = 2 ,
    parameter AC_NUM     = 4 ,
    parameter DX_NUM     = 4 ,

    parameter CK_WIDTH   = 1 ,
    parameter CS_WIDTH   = 1 ,
    parameter CKE_WIDTH  = 1 ,
    parameter ODT_WIDTH  = 1 ,
    parameter BG_WIDTH   = 1 ,
    parameter BA_WIDTH   = 3 ,
    parameter COL_WIDTH  = 10,
    parameter ROW_WIDTH  = 14,
    parameter ADR_WIDTH  = 14,
    parameter PAR_WIDTH  = 0 ,

    parameter MDL_MODE   = "FULL",

    parameter AC_DRV     = "48",
    parameter DX_DRV     = "48",
    parameter DX_ODT     = "60",

    parameter CWL        = 5 ,
    parameter CL         = 6 ,

    parameter PLL0_REFCLK_FREQ = "100",
    parameter PLL0_REFCLK_DIV  =  1   ,
    parameter PLL0_FBKCLK_DIV  =  12  ,
    parameter PLL0_CLK2_DIV    =  3   ,
    parameter PLL0_CLK3_DIV    =  24  ,
    parameter PLL0_FRAC        = "DISABLE",
    parameter PLL0_FRAC_SDM    =  0   ,
    parameter PLL1_REFCLK_FREQ = "100",
    parameter PLL1_REFCLK_DIV  =  1   ,
    parameter PLL1_CLK0_DIV    =  12  ,

    parameter DDRPHY_ROM_LEN   = 64,
    parameter DDRPHY_ROM_INIT  = ""
)(
    // clock & reset
    input                        ref_clk       ,
    output                       dhi_clk       ,
    output                       cfg_clk       ,

    output                       cfg_rst_n     ,
    output                       ddrphy_rst_n  ,
    output                       ddrphy_rdy    ,

    input                        sys_rst_n     ,
    input                        dx_fifo_rst_n ,

    // ddrphy host interface
    input   [          4-1 : 0]  dhi_cmd_vld   ,
    input   [       32*4-1 : 0]  dhi_cmd_code  ,

    output                       dhi_cmd_err   ,

    output                       dhi_wdata_en  ,
    input   [DX_NUM  *64-1 : 0]  dhi_wdata     ,
    input   [DX_NUM  * 8-1 : 0]  dhi_wmask     ,
    output  [DX_NUM     -1 : 0]  dhi_rdata_vld ,
    output  [DX_NUM  *64-1 : 0]  dhi_rdata     ,

    // DelayLine Configuration Port
    input   [DX_NUM*   1-1 : 0]  dcp_vld       ,
    input   [DX_NUM*   1-1 : 0]  dcp_inc       ,
    input   [DX_NUM*   4-1 : 0]  dcp_type      ,
    input   [DX_NUM*   9-1 : 0]  dcp_code      ,
    output  [DX_NUM*   1-1 : 0]  dcp_rdy       ,

    // DelayLine
    output  [DX_NUM*   9-1 : 0]  dly_cur_gate  ,
    output  [DX_NUM*   9-1 : 0]  dly_cur_wdqs  ,
    output  [DX_NUM*   9-1 : 0]  dly_cur_wdq   ,
    output  [DX_NUM*   9-1 : 0]  dly_cur_rdqsp ,
    output  [DX_NUM*   9-1 : 0]  dly_cur_rdqsn ,

    // APB
    input                        apb_pclk      ,
    input                        apb_prst_n    ,
    input                        apb_psel      ,
    input                        apb_penable   ,
    input                        apb_pwrite    ,
    input   [           15 : 0]  apb_paddr     ,
    input   [           31 : 0]  apb_pwdata    ,
    output                       apb_pready    ,
    output  [           31 : 0]  apb_prdata    ,


    // misc
    input   [DX_NUM     -1 : 0]  dx_fifo_en      ,
    input                        cal_done        ,
    input   [DX_NUM*   4-1 : 0]  wsl_i           ,
    input   [DX_NUM*   4-1 : 0]  rsl_i           ,
    output  [DX_NUM*   4-1 : 0]  wsl_o           ,
    output  [DX_NUM*   4-1 : 0]  rsl_o           ,
    input                        lb_enb          ,
    input                        wrlvl_en        ,
    input                        dqs_pupd_en     ,
    output  [DX_NUM*   2-1 : 0]  dqs_gate_status ,
    output  [DX_NUM*   8-1 : 0]  dx_indd         ,
    output  [DX_NUM*  16-1 : 0]  dx_debug        ,

    // ddrio
`ifdef DRAM_DDR4
    output  [CK_WIDTH  -1 : 0]  ddr_ck_t        ,
    output  [CK_WIDTH  -1 : 0]  ddr_ck_c        ,
    output  [        1 -1 : 0]  ddr_reset_n     ,
    output  [CKE_WIDTH -1 : 0]  ddr_cke         ,
    output  [ODT_WIDTH -1 : 0]  ddr_odt         ,
    output  [CS_WIDTH  -1 : 0]  ddr_cs_n        ,
    output  [        1 -1 : 0]  ddr_act_n       ,
    output  [BG_WIDTH  -1 : 0]  ddr_bg          ,
    output  [BA_WIDTH  -1 : 0]  ddr_ba          ,
    output  [ADR_WIDTH -1 : 0]  ddr_addr        ,
    output  [        1 -1 : 0]  ddr_parity      ,
    input   [        1 -1 : 0]  ddr_alert_n     ,
    inout   [DX_NUM    -1 : 0]  ddr_dqs_t       ,
    inout   [DX_NUM    -1 : 0]  ddr_dqs_c       ,
    inout   [DX_NUM  *8-1 : 0]  ddr_dq          ,
    inout   [DX_NUM    -1 : 0]  ddr_dm_n        ,
`else
    output  [CK_WIDTH  -1 : 0]  ddr_ck_p        ,
    output  [CK_WIDTH  -1 : 0]  ddr_ck_n        ,
`ifdef DRAM_DDR3
    output  [        1 -1 : 0]  ddr_reset_n     ,
`endif
    output  [CKE_WIDTH -1 : 0]  ddr_cke         ,
    output  [ODT_WIDTH -1 : 0]  ddr_odt         ,
    output  [CS_WIDTH  -1 : 0]  ddr_cs_n        ,
    output  [        1 -1 : 0]  ddr_ras_n       ,
    output  [        1 -1 : 0]  ddr_cas_n       ,
    output  [        1 -1 : 0]  ddr_we_n        ,
    output  [BA_WIDTH  -1 : 0]  ddr_ba          ,
    output  [ROW_WIDTH -1 : 0]  ddr_addr        ,
    inout   [DX_NUM    -1 : 0]  ddr_dqs_p       ,
    inout   [DX_NUM    -1 : 0]  ddr_dqs_n       ,
    inout   [DX_NUM  *8-1 : 0]  ddr_dq          ,
    inout   [DX_NUM    -1 : 0]  ddr_dm          ,
`endif

    // misc - mdl
    output  [DX_NUM*  9-1 : 0]  mdl_tck      ,
    output  [DX_NUM*  9-1 : 0]  mdl_ui
);

//*****************************************************************************************************************************
//    Local Parameter
//*****************************************************************************************************************************

//*****************************************************************************************************************************
//    Internal Signals
//*****************************************************************************************************************************
wire  [(AC_NUM+DX_NUM)*13-1:0] dummy_io;

// IOCLK
wire  [BK_NUM-1:0] ctl_clk ;
wire  [BK_NUM-1:0] ddr_clk ;

// APB - PHY
wire             phy_apb_psel   ;
wire             phy_apb_penable;
wire             phy_apb_pwrite ;
wire  [  16-1:0] phy_apb_paddr  ;
wire  [  32-1:0] phy_apb_pwdata ;
wire             phy_apb_pready ;
wire  [  32-1:0] phy_apb_prdata ;

// APB - CFG
wire             init_apb_psel   ;
wire             init_apb_penable;
wire             init_apb_pwrite ;
wire  [  16-1:0] init_apb_paddr  ;
wire  [  32-1:0] init_apb_pwdata ;
wire             init_apb_pready ;
wire  [  32-1:0] init_apb_prdata ;

// APB - CFG
wire             cfg_apb_psel   ;
wire             cfg_apb_penable;
wire             cfg_apb_pwrite ;
wire  [  16-1:0] cfg_apb_paddr  ;
wire  [  32-1:0] cfg_apb_pwdata ;
wire             cfg_apb_pready ;
wire  [  32-1:0] cfg_apb_prdata ;

// APB - FIU
wire             fiu_apb_psel   ;
wire             fiu_apb_penable;
wire             fiu_apb_pwrite ;
wire  [   8-1:0] fiu_apb_paddr  ;
wire  [  32-1:0] fiu_apb_pwdata ;
wire             fiu_apb_pready ;
wire  [  32-1:0] fiu_apb_prdata ;

// DCP_APB - CFG
wire                      cfg_dcp_psel    ;
wire   [         5  : 0]  cfg_dcp_paddr   ;
wire   [         8  : 0]  cfg_dcp_pdata   ;
wire                      cfg_dcp_gate    ;

// DCP_APB - DX
wire   [DX_NUM* 1-1 : 0]  dcu_dcp_psel    ;
wire   [DX_NUM* 6-1 : 0]  dcu_dcp_paddr   ;
wire   [DX_NUM* 9-1 : 0]  dcu_dcp_pdata   ;
wire   [DX_NUM* 1-1 : 0]  dcu_dcp_gate    ;

// DCP_APB - AC
wire                      ac_dcp_psel     ;
wire   [         5  : 0]  ac_dcp_paddr    ;
wire   [         8  : 0]  ac_dcp_pdata    ;
wire                      ac_dcp_gate     ;

// DCP_APB - DX
wire   [DX_NUM* 1-1 : 0]  dx_dcp_psel     ;
wire   [DX_NUM* 6-1 : 0]  dx_dcp_paddr    ;
wire   [DX_NUM* 9-1 : 0]  dx_dcp_pdata    ;
wire   [DX_NUM* 1-1 : 0]  dx_dcp_gate     ;
    
// DCP_DCU
wire  [DX_NUM*  1-1 : 0]  dcu_dcp_vld     ;
wire  [DX_NUM*  1-1 : 0]  dcu_dcp_inc     ;
wire  [DX_NUM*  4-1 : 0]  dcu_dcp_type    ;
wire  [DX_NUM*  9-1 : 0]  dcu_dcp_code    ;
wire  [DX_NUM*  1-1 : 0]  dcu_dcp_rdy     ;

// DCP_MDL
wire  [DX_NUM*  1-1 : 0]  mdl_dcp_vld     ;
wire  [DX_NUM*  1-1 : 0]  mdl_dcp_inc     ;
wire  [DX_NUM*  4-1 : 0]  mdl_dcp_type    ;
wire  [DX_NUM*  9-1 : 0]  mdl_dcp_code    ;
wire  [DX_NUM*  1-1 : 0]  mdl_dcp_rdy     ;

// DCP_FastInit
wire  [DX_NUM*  1-1 : 0]  fiu_dcp_vld     ;
wire  [DX_NUM*  1-1 : 0]  fiu_dcp_inc     ;
wire  [DX_NUM*  4-1 : 0]  fiu_dcp_type    ;
wire  [DX_NUM*  9-1 : 0]  fiu_dcp_code    ;
wire  [DX_NUM*  1-1 : 0]  fiu_dcp_rdy     ;

// misc - mdl
wire  [DX_NUM*  1-1 : 0]  mdl_clk_en      ;
wire  [DX_NUM*  1-1 : 0]  mdl_mode        ;
wire  [DX_NUM*  1-1 : 0]  mdl_en          ;
wire  [DX_NUM*  1-1 : 0]  mdl_en_out      ;
wire  [DX_NUM*  1-1 : 0]  mdl_out         ;
wire  [DX_NUM*  1-1 : 0]  mdl_done_int    ;

// misc
wire                      dx_fifo_rstn_int;
wire                      cfg_done        ;
wire                      mdl_done        ;
wire                      fiu_done        ;

reg                       mdl_start       ;
reg                       fiu_start       ;

// ddrphy host interface - ac
wire                        dhi_rst_n    ;
wire  [CKE_WIDTH *4-1 : 0]  dhi_cke      ;
wire  [CS_WIDTH  *4-1 : 0]  dhi_cs_n     ;
wire  [ODT_WIDTH *4-1 : 0]  dhi_odt      ;
wire  [           4-1 : 0]  dhi_act_n    ;
wire  [           4-1 : 0]  dhi_ras_n    ;
wire  [           4-1 : 0]  dhi_cas_n    ;
wire  [           4-1 : 0]  dhi_we_n     ;
wire  [BG_WIDTH  *4-1 : 0]  dhi_bg       ;
wire  [BA_WIDTH  *4-1 : 0]  dhi_ba       ;
wire  [ADR_WIDTH *4-1 : 0]  dhi_addr     ;
wire  [           4-1 : 0]  dhi_parity   ;

// ddrphy host interface - dx
wire  [DX_NUM*    8-1 : 0]  dhi_oe       ;
wire  [DX_NUM*    8-1 : 0]  dhi_te       ;
wire  [DX_NUM*    8-1 : 0]  dhi_pdr      ;
wire  [DX_NUM*    8-1 : 0]  dhi_wdqs     ;
wire  [DX_NUM*   64-1 : 0]  dhi_wdq      ;
wire  [DX_NUM*    8-1 : 0]  dhi_wdm      ;
wire  [DX_NUM*    8-1 : 0]  dhi_rdq_en   ;
wire  [DX_NUM      -1 : 0]  dhi_rdq_vld  ;
wire  [DX_NUM*   64-1 : 0]  dhi_rdq      ;

// system latency
wire  [DX_NUM*4-1 : 0] fiu_wsl ;
wire  [DX_NUM*4-1 : 0] fiu_rsl ;
wire  [DX_NUM*4-1 : 0] dcu_wsl ;
wire  [DX_NUM*4-1 : 0] dcu_rsl ;

//*****************************************************************************************************************************
//    Instance : GPLL
//*****************************************************************************************************************************
wire pll_lock;

`ifdef PH1P_DDRPHY_SINGLE_PLL
ph1p_ddrphy_clk_top #(
    .BK_NUM      ( BK_NUM           ),
    .REFCLK_FREQ ( PLL0_REFCLK_FREQ ),
    .REFCLK_DIV  ( PLL0_REFCLK_DIV  ),
    .FBKCLK_DIV  ( PLL0_FBKCLK_DIV  ),
    .CLK2_DIV    ( PLL0_CLK2_DIV    ),
    .CLK3_DIV    ( PLL0_CLK3_DIV    )
) u_ddrphy_clk (
    .sys_rst   (~sys_rst_n ),
    .ref_clk   ( ref_clk   ),
    .cfg_clk   ( cfg_clk   ),
    .dhi_clk   ( dhi_clk   ),
    .ctl_clk   ( ctl_clk   ),
    .ddr_clk   ( ddr_clk   ),
    .pll_lock  ( pll_lock  )
);
`else
ph1p_ddrphy_clk_top #(
    .BK_NUM           ( BK_NUM           ),
    .PLL0_REFCLK_FREQ ( PLL0_REFCLK_FREQ ),
    .PLL0_REFCLK_DIV  ( PLL0_REFCLK_DIV  ),
    .PLL0_FBKCLK_DIV  ( PLL0_FBKCLK_DIV  ),
    .PLL0_FRAC        ( PLL0_FRAC        ),
    .PLL0_FRAC_SDM    ( PLL0_FRAC_SDM    ),
    .PLL0_CLK2_DIV    ( PLL0_CLK2_DIV    ),
    .PLL0_CLK3_DIV    ( PLL0_CLK3_DIV    ),
    .PLL1_REFCLK_FREQ ( PLL1_REFCLK_FREQ ),
    .PLL1_REFCLK_DIV  ( PLL1_REFCLK_DIV  ),
    .PLL1_CLK0_DIV    ( PLL1_CLK0_DIV    )
) u_ddrphy_clk (
    .sys_rst   (~sys_rst_n ),
    .ref_clk   ( ref_clk   ),
    .cfg_clk   ( cfg_clk   ),
    .dhi_clk   ( dhi_clk   ),
    .ctl_clk   ( ctl_clk   ),
    .ddr_clk   ( ddr_clk   ),
    .pll_lock  ( pll_lock  )
);
`endif

ph1p_ddrphy_sync_rst_gen u_ddrphy_rst_gen (
    .clk        ( cfg_clk   ),
    .rst_async  (~pll_lock  ),
    .rst_sync_n ( cfg_rst_n )
);

assign ddrphy_rst_n = pll_lock;

//*****************************************************************************************************************************
//    Instance : DDRPHY Init
//*****************************************************************************************************************************
ph1p_ddrphy_init #(
    .ROM_LEN     ( DDRPHY_ROM_LEN  ),
    .ROM_INIT    ( DDRPHY_ROM_INIT )
) u_ddrphy_init  (
    .clk         ( cfg_clk        ),
    .rst_n       ( cfg_rst_n      ),
    .done        ( cfg_done       ),

    // DCP
    .dcp_psel    ( cfg_dcp_psel   ),
    .dcp_paddr   ( cfg_dcp_paddr  ),
    .dcp_pdata   ( cfg_dcp_pdata  ),
    .dcp_gate    ( cfg_dcp_gate   ),

    // APB
    .apb_psel    ( init_apb_psel   ),
    .apb_penable ( init_apb_penable),
    .apb_pwrite  ( init_apb_pwrite ),
    .apb_paddr   ( init_apb_paddr  ),
    .apb_pwdata  ( init_apb_pwdata ),
    .apb_prdata  ( init_apb_prdata ),
    .apb_pready  ( init_apb_pready )
);

//*****************************************************************************************************************************
//    Function : DCP & APB MUX
//*****************************************************************************************************************************
// DCP - AC
assign  ac_dcp_psel   = cfg_done ? 1'b0 : cfg_dcp_psel ;
assign  ac_dcp_paddr  = cfg_done ? 1'b0 : cfg_dcp_paddr;
assign  ac_dcp_pdata  = cfg_done ? 1'b0 : cfg_dcp_pdata;
assign  ac_dcp_gate   = cfg_done ? 1'b0 : cfg_dcp_gate ;

// DCP - DX
assign  dx_dcp_psel   = cfg_done ? dcu_dcp_psel  : {DX_NUM{cfg_dcp_psel }};
assign  dx_dcp_paddr  = cfg_done ? dcu_dcp_paddr : {DX_NUM{cfg_dcp_paddr}};
assign  dx_dcp_pdata  = cfg_done ? dcu_dcp_pdata : {DX_NUM{cfg_dcp_pdata}};
assign  dx_dcp_gate   = cfg_done ? dcu_dcp_gate  : {DX_NUM{cfg_dcp_gate }};

// DDRPHY APB
assign cfg_apb_psel    = cfg_done ? phy_apb_psel    : init_apb_psel    ;
assign cfg_apb_penable = cfg_done ? phy_apb_penable : init_apb_penable ;
assign cfg_apb_pwrite  = cfg_done ? phy_apb_pwrite  : init_apb_pwrite  ;
assign cfg_apb_paddr   = cfg_done ? phy_apb_paddr   : init_apb_paddr   ;
assign cfg_apb_pwdata  = cfg_done ? phy_apb_pwdata  : init_apb_pwdata  ;

assign init_apb_pready = cfg_apb_pready;
assign phy_apb_pready  = cfg_apb_pready;
assign init_apb_prdata = cfg_apb_prdata;
assign phy_apb_prdata  = cfg_apb_prdata;

// APB MUX
assign fiu_apb_penable = apb_penable;
assign fiu_apb_pwrite  = apb_pwrite;
assign fiu_apb_paddr   = apb_paddr[7:0];
assign fiu_apb_pwdata  = apb_pwdata;

assign phy_apb_penable = apb_penable;
assign phy_apb_pwrite  = apb_pwrite;
assign phy_apb_pwdata  = apb_pwdata;
assign phy_apb_paddr   = (apb_paddr[13:10] == 4'h4) ? {4'h0, 2'b00, apb_paddr[9:8], 2'b00, apb_paddr[7:2]} :
                         (apb_paddr[13:10] == 4'h5) ? {4'h1, 2'b00, apb_paddr[9:8], 2'b00, apb_paddr[7:2]} :
                         (apb_paddr[13:10] == 4'h6) ? {4'h1, 2'b01, apb_paddr[9:8], 2'b00, apb_paddr[7:2]} :
                         (apb_paddr[13:10] == 4'h7) ? {4'h1, 2'b10, apb_paddr[9:8], 2'b00, apb_paddr[7:2]} :
                         (apb_paddr[13:12] == 2'h2) ? {4'h2, 2'b00, apb_paddr[11:10], apb_paddr[9:2]} : 16'h0;

assign fiu_apb_psel    = (apb_paddr[15:12] == 4'h0) ? apb_psel : 1'b0;
assign phy_apb_psel    = (apb_paddr[15:12] == 4'h1) ? apb_psel :
                         (apb_paddr[15:12] == 4'h2) ? apb_psel : 1'b0;
assign apb_pready      = (apb_paddr[15:12] == 4'h0) ? fiu_apb_pready :
                         (apb_paddr[15:12] == 4'h1) ? phy_apb_pready :
                         (apb_paddr[15:12] == 4'h2) ? phy_apb_pready : 1'b1;
assign apb_prdata      = (apb_paddr[15:12] == 4'h0) ? fiu_apb_prdata :
                         (apb_paddr[15:12] == 4'h1) ? phy_apb_prdata :
                         (apb_paddr[15:12] == 4'h2) ? phy_apb_prdata : 32'hdeadbeef;

//*****************************************************************************************************************************
//    Function : DCP MUX
//*****************************************************************************************************************************
assign  dcu_dcp_vld   = (mdl_done == 1'b0) ? mdl_dcp_vld  : (fiu_done == 1'b0) ? fiu_dcp_vld  : (cal_done == 1'b0) ? dcp_vld  : fiu_dcp_vld;
assign  dcu_dcp_inc   = (mdl_done == 1'b0) ? mdl_dcp_inc  : (fiu_done == 1'b0) ? fiu_dcp_inc  : (cal_done == 1'b0) ? dcp_inc  : fiu_dcp_inc;
assign  dcu_dcp_type  = (mdl_done == 1'b0) ? mdl_dcp_type : (fiu_done == 1'b0) ? fiu_dcp_type : (cal_done == 1'b0) ? dcp_type : fiu_dcp_type;
assign  dcu_dcp_code  = (mdl_done == 1'b0) ? mdl_dcp_code : (fiu_done == 1'b0) ? fiu_dcp_code : (cal_done == 1'b0) ? dcp_code : fiu_dcp_code;

assign  mdl_dcp_rdy   = (mdl_done == 1'b0) ? dcu_dcp_rdy : {DX_NUM{1'b1}};
assign  dcp_rdy       = (cal_done == 1'b0) ? dcu_dcp_rdy : {DX_NUM{1'b1}};
assign  fiu_dcp_rdy   = dcu_dcp_rdy;

//*****************************************************************************************************************************
//    Instance : MDL Calibration
//*****************************************************************************************************************************
always @ (posedge dhi_clk or negedge ddrphy_rst_n)
begin
    if (ddrphy_rst_n == 1'b0)
        mdl_start <= 1'b0;
    else
        mdl_start <= cfg_done;
end

`ifdef PH1P_DDRPHY_SKIP_MDL
assign  mdl_clk_en = {DX_NUM{1'b0}};
assign  mdl_mode   = {DX_NUM{1'b0}};
assign  mdl_en     = {DX_NUM{1'b0}};
assign  mdl_tck    = {DX_NUM{9'hFA}};
assign  mdl_done   = cfg_done;
`else
ph1p_ddrphy_mdl_cal_wrapper #(
    .MDL_MODE ( MDL_MODE ),
    .DX_NUM   ( DX_NUM   )
) u_ddrphy_mdl_cal_wrapper (
    .clk           ( dhi_clk       ), 
    .rst_n         ( ddrphy_rst_n  ), 

    .mdl_start     ( mdl_start     ), 
    .mdl_done      ( mdl_done      ), 
    .mdl_tck       ( mdl_tck       ), 
    .mdl_ui        ( mdl_ui        ), 

    .cal_en_in     ( mdl_en_out    ), 
    .cal_in        ( mdl_out       ), 
    .cal_clk_en    ( mdl_clk_en    ), 
    .cal_en        ( mdl_en        ), 
    .cal_mode      ( mdl_mode      ), 

    .dcp_rdy       ( mdl_dcp_rdy   ), 
    .dcp_inc       ( mdl_dcp_inc   ),
    .dcp_code      ( mdl_dcp_code  ), 
    .dcp_type      ( mdl_dcp_type  ), 
    .dcp_vld       ( mdl_dcp_vld   )
);
`endif

//*****************************************************************************************************************************
//    Instance : Fast Init Unit
//*****************************************************************************************************************************
always @ (posedge dhi_clk or negedge ddrphy_rst_n)
begin
    if (ddrphy_rst_n == 1'b0)
        fiu_start <= 1'b0;
    else
        fiu_start <= mdl_done;
end

ph1p_ddrphy_fast_init_wrapper #(
    .DX_NUM  ( DX_NUM )
) u_ddrphy_fiu_wrapper ( 
// Clock & Reset
    .clk         ( dhi_clk      ), // input 
    .rst_n       ( ddrphy_rst_n ), // input 

// User APB : used for Training Force, Async Port
    .apb_pclk    ( apb_pclk        ), // input 
    .apb_prst_n  ( apb_prst_n      ), // input 
    .apb_psel    ( fiu_apb_psel    ), // input 
    .apb_penable ( fiu_apb_penable ), // input 
    .apb_pwrite  ( fiu_apb_pwrite  ), // input 
    .apb_paddr   ( fiu_apb_paddr   ), // input   [ 7:0] 
    .apb_pwdata  ( fiu_apb_pwdata  ), // input   [31:0] 
    .apb_prdata  ( fiu_apb_prdata  ), // output  [31:0] 
    .apb_pready  ( fiu_apb_pready  ), // output         

// Delayline Control Port
    .dcp_inc     ( fiu_dcp_inc  ), // output  [DX_NUM*1-1 : 0] 
    .dcp_vld     ( fiu_dcp_vld  ), // output  [DX_NUM*1-1 : 0] 
    .dcp_type    ( fiu_dcp_type ), // output  [DX_NUM*4-1 : 0] 
    .dcp_code    ( fiu_dcp_code ), // output  [DX_NUM*9-1 : 0] 
    .dcp_rdy     ( fiu_dcp_rdy  ), // input   [DX_NUM*1-1 : 0] 

// DelayLine Current Status
    .dly_cur_gate  ( dly_cur_gate   ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_wdqs  ( dly_cur_wdqs   ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_wdq   ( dly_cur_wdq    ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_rdqsp ( dly_cur_rdqsp  ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_rdqsn ( dly_cur_rdqsn  ), // output  [DX_NUM*9-1 : 0]
    .wsl_i         ( wsl_o          ), // output  [DX_NUM*4-1 : 0] 
    .rsl_i         ( rsl_o          ), // output  [DX_NUM*4-1 : 0] 
    .gate_status   ( dqs_gate_status),

// MISC
    .lb_en       (~lb_enb      ),
    .start       ( fiu_start   ), // input
    .done        ( fiu_done    ), // output                   
    .wsl         ( fiu_wsl     ), // output  [DX_NUM*4-1 : 0] 
    .rsl         ( fiu_rsl     ), // output  [DX_NUM*4-1 : 0] 
    .phy_rst_n   ( dx_fifo_rstn_int ), // output  [DX_NUM*1-1 : 0] 

    .mdl_ui      ( mdl_ui      )  // input   [DX_NUM*9-1 : 0] 
);

assign ddrphy_rdy = fiu_done;

//*****************************************************************************************************************************
//    Instance : DelayLine Configuration Unit
//*****************************************************************************************************************************
ph1p_ddrphy_dcu_wrapper #(
    .DX_NUM  ( DX_NUM )
) u_ddrphy_dcu_wrapper (
// Clock & Reset
    .clk           ( dhi_clk        ), // input
    .rst_n         ( ddrphy_rst_n   ), // input

// DelayLine Configuration Port
    .dcp_vld       ( dcu_dcp_vld    ), // input   [DX_NUM*1-1 : 0]
    .dcp_inc       ( dcu_dcp_inc    ), // input   [DX_NUM*1-1 : 0]
    .dcp_type      ( dcu_dcp_type   ), // input   [DX_NUM*4-1 : 0]
    .dcp_code      ( dcu_dcp_code   ), // input   [DX_NUM*9-1 : 0]
    .dcp_rdy       ( dcu_dcp_rdy    ), // output  [DX_NUM*1-1 : 0]

// DelayLine Status
    .dly_cur_gate  ( dly_cur_gate   ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_wdqs  ( dly_cur_wdqs   ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_wdq   ( dly_cur_wdq    ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_rdqsp ( dly_cur_rdqsp  ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_rdqsn ( dly_cur_rdqsn  ), // output  [DX_NUM*9-1 : 0]
    .dly_cur_mdl   (                ), // output  [DX_NUM*9-1 : 0]

// DelayLine Configuration Port to DX_GLUE
    .dcp_psel      ( dcu_dcp_psel   ), // output  [DX_NUM*1-1 : 0]
    .dcp_paddr     ( dcu_dcp_paddr  ), // output  [DX_NUM*6-1 : 0]
    .dcp_pdata     ( dcu_dcp_pdata  ), // output  [DX_NUM*9-1 : 0]
    .dcp_gate      ( dcu_dcp_gate   ), // output  [DX_NUM*1-1 : 0]

// MISC
    .ui            ( mdl_ui             ), // input   [DX_NUM*9-1 : 0]
    .rsl_i         ( dcu_rsl            ), // input   [DX_NUM*4-1 : 0]
    .rsl_o         ( rsl_o              ), // output  [DX_NUM*4-1 : 0]
    .wsl_i         ( dcu_wsl            ), // input   [DX_NUM*4-1 : 0]
    .wsl_o         ( wsl_o              )  // output  [DX_NUM*4-1 : 0]
);

assign dcu_wsl = (fiu_done == 1'b0) ? fiu_wsl : (cal_done == 1'b0) ? wsl_i : fiu_wsl;
assign dcu_rsl = (fiu_done == 1'b0) ? fiu_rsl : (cal_done == 1'b0) ? rsl_i : fiu_rsl;

//*****************************************************************************************************************************
//    Instance : command execution unit
//*****************************************************************************************************************************
ph1p_ddrphy_cmd_wrapper #(
    .DX_NUM        ( DX_NUM    ),
    .COL_WIDTH     ( COL_WIDTH ),
    .ROW_WIDTH     ( ROW_WIDTH ),
    .ADR_WIDTH     ( ADR_WIDTH ),
    .BG_WIDTH      ( BG_WIDTH  ),
    .BA_WIDTH      ( BA_WIDTH  ),
    .CWL           ( CWL       ),
    .CL            ( CL        )
) u_ddrphy_cmd_wrapper (
    .clk           ( dhi_clk       ),
    .rst_n         ( ddrphy_rst_n  ),

    .lb_en         (~lb_enb        ),
    .wrlvl_en      ( wrlvl_en      ),
    .wsl           ( wsl_o         ),
    .rsl           ( rsl_o         ),

// from User
    .dhi_cmd_vld   ( dhi_cmd_vld   ),
    .dhi_cmd_code  ( dhi_cmd_code  ),
    .dhi_wdata_en  ( dhi_wdata_en  ),
    .dhi_wdata     ( dhi_wdata     ),
    .dhi_wmask     ( dhi_wmask     ),
    .dhi_rdata_vld ( dhi_rdata_vld ),
    .dhi_rdata     ( dhi_rdata     ),

// to PHY
    .dhi_rst_n     ( dhi_rst_n     ),
    .dhi_cke       ( dhi_cke       ),
    .dhi_odt       ( dhi_odt       ),
    .dhi_cs_n      ( dhi_cs_n      ),
    .dhi_act_n     ( dhi_act_n     ),
    .dhi_ras_n     ( dhi_ras_n     ),
    .dhi_cas_n     ( dhi_cas_n     ),
    .dhi_we_n      ( dhi_we_n      ),
`ifdef DRAM_DDR4
    .dhi_bg        ( dhi_bg        ),
`endif
    .dhi_ba        ( dhi_ba        ),
    .dhi_addr      ( dhi_addr      ),
    .dhi_parity    ( dhi_parity    ),

    .dhi_oe        ( dhi_oe        ),
    .dhi_te        ( dhi_te        ),
    .dhi_pdr       ( dhi_pdr       ),
    .dhi_wdqs      ( dhi_wdqs      ),
    .dhi_wdq       ( dhi_wdq       ),
    .dhi_wdm       ( dhi_wdm       ),
    .dhi_rdq_en    ( dhi_rdq_en    ),
    .dhi_rdq_vld   ( dhi_rdq_vld   ),
    .dhi_rdq       ( dhi_rdq       )
);

`ifndef DRAM_DDR4
assign dhi_bg = 4'b0000;
`endif
//*****************************************************************************************************************************
//    Instance : DDRPHY
//*****************************************************************************************************************************
ph1p_ddrphy #(
    .BK_NUM     ( BK_NUM     ),
    .AC_NUM     ( AC_NUM     ),
    .DX_NUM     ( DX_NUM     ),
    .CK_WIDTH   ( CK_WIDTH   ),
    .CS_WIDTH   ( CS_WIDTH   ),
    .CKE_WIDTH  ( CKE_WIDTH  ),
    .ODT_WIDTH  ( ODT_WIDTH  ),
    .BA_WIDTH   ( BA_WIDTH   ),
    .ADR_WIDTH  ( ADR_WIDTH  ),
    .MDL_MODE   ( MDL_MODE   ),
    .AC_DRV     ( AC_DRV     ),
    .DX_DRV     ( DX_DRV     ),
    .DX_ODT     ( DX_ODT     )
) u_ddrphy (
    // clock & reset
    .dhi_clk                        ( dhi_clk         ), //    input
    .ctl_clk                        ( ctl_clk         ), //    input
    .ddr_clk                        ( ddr_clk         ), //    input

    .ddrphy_rst_n                   ( ddrphy_rst_n    ), //    input
    .dx_fifo_rst_n                  ( dx_fifo_rstn_int & dx_fifo_rst_n ), // input [DX_NUM*1-1 : 0]

    // ddrphy host interface - ac
    .dhi_rst_n                      ( dhi_rst_n       ), //    input
    .dhi_cke                        ( dhi_cke         ), //    input   [CKE_WIDTH *4-1 : 0]
    .dhi_cs_n                       ( dhi_cs_n        ), //    input   [CS_WIDTH  *4-1 : 0]
    .dhi_odt                        ( dhi_odt         ), //    input   [ODT_WIDTH *4-1 : 0]
    .dhi_act_n                      ( dhi_act_n       ), //    input   [           4-1 : 0]
    .dhi_ras_n                      ( dhi_ras_n       ), //    input   [           4-1 : 0]
    .dhi_cas_n                      ( dhi_cas_n       ), //    input   [           4-1 : 0]
    .dhi_we_n                       ( dhi_we_n        ), //    input   [           4-1 : 0]
`ifdef DRAM_DDR4
    .dhi_bg                         ( dhi_bg          ), //    input   [BA_WIDTH  *4-1 : 0]
`endif
    .dhi_ba                         ( dhi_ba          ), //    input   [BA_WIDTH  *4-1 : 0]
    .dhi_addr                       ( dhi_addr        ), //    input   [ROW_WIDTH *4-1 : 0]
    .dhi_parity                     ( dhi_parity      ), //    input   [ROW_WIDTH *4-1 : 0]

    // ddrphy host interface - dx
    .dhi_oe                         ( dhi_oe          ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_te                         ( dhi_te          ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_pdr                        ( dhi_pdr         ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_wdqs                       ( dhi_wdqs        ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_wdq                        ( dhi_wdq         ), //    input   [DX_NUM*   64-1 : 0]
    .dhi_wdm                        ( dhi_wdm         ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_rdq_en                     ( dhi_rdq_en      ), //    input   [DX_NUM*    8-1 : 0]
    .dhi_rdq_vld                    ( dhi_rdq_vld     ), //    output  [DX_NUM      -1 : 0]
    .dhi_rdq                        ( dhi_rdq         ), //    output  [DX_NUM*   64-1 : 0]

    // APB
    .apb_pclk                       ( cfg_clk         ), //    input
    .apb_prst_n                     ( cfg_rst_n       ), //    input
    .apb_psel                       ( cfg_apb_psel    ), //    input
    .apb_penable                    ( cfg_apb_penable ), //    input
    .apb_pwrite                     ( cfg_apb_pwrite  ), //    input
    .apb_paddr                      ( cfg_apb_paddr   ), //    input   [         15 : 0]
    .apb_pwdata                     ( cfg_apb_pwdata  ), //    input   [         31 : 0]
    .apb_pready                     ( cfg_apb_pready  ), //    output
    .apb_prdata                     ( cfg_apb_prdata  ), //    output  [         31 : 0]

    // delayline configuration port
    .ac_dcp_psel                    ( ac_dcp_psel     ), //    input
    .ac_dcp_paddr                   ( ac_dcp_paddr    ), //    input   [         5  : 0]
    .ac_dcp_pdata                   ( ac_dcp_pdata    ), //    input   [         8  : 0]
    .ac_dcp_gate                    ( ac_dcp_gate     ), //    input

    .dx_dcp_psel                    ( dx_dcp_psel     ), //    input   [DX_NUM* 1-1 : 0]
    .dx_dcp_paddr                   ( dx_dcp_paddr    ), //    input   [DX_NUM* 6-1 : 0]
    .dx_dcp_pdata                   ( dx_dcp_pdata    ), //    input   [DX_NUM* 9-1 : 0]
    .dx_dcp_gate                    ( dx_dcp_gate     ), //    input   [DX_NUM* 1-1 : 0]

    // misc - mdl
    .cal_clk_en                     ( mdl_clk_en      ), //    input   [DX_NUM* 1-1 : 0]
    .cal_mode                       ( mdl_mode        ), //    input   [DX_NUM* 1-1 : 0]
    .cal_en                         ( mdl_en          ), //    input   [DX_NUM* 1-1 : 0]
    .cal_en_out                     ( mdl_en_out      ), //    output  [DX_NUM* 1-1 : 0]
    .cal_out                        ( mdl_out         ), //    output  [DX_NUM* 1-1 : 0]

    // misc
    .dx_fifo_en                     ( dx_fifo_en      ), //    input   [DX_NUM* 1-1 : 0]
    .lb_enb                         ( lb_enb          ), //    input
    .wrlvl_en                       ( wrlvl_en        ), //    input   [DX_NUM* 1-1 : 0]
    .dqs_pupd_en                    ( dqs_pupd_en     ), //    input
    .dqs_gate_status                ( dqs_gate_status ), //    output  [DX_NUM* 2-1 : 0]
    .dx_indd                        ( dx_indd         ), //    output  [DX_NUM* 8-1 : 0]
    .dx_debug                       ( dx_debug        ), //    output  [DX_NUM*16-1 : 0]

    // io - Generated By Script
`ifdef PH1P_DDRPHY_SIM
    `include "ph1p_ddrphy_ddrio.vh"
`else
    `include "./include/ph1p_ddrphy_ddrio.vh"
`endif
);

///////////////////////////////////////////////////////////////////////////////////////////////////
//  MISC
///////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef DRAM_DDR4
assign dhi_cmd_err = ~ddr_alert_n;
`endif

endmodule

