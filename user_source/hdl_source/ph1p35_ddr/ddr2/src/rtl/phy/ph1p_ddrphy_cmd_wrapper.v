`timescale 1ps/1ps

module ph1p_ddrphy_cmd_wrapper #(
    parameter DX_NUM       = 2  ,
    parameter COL_WIDTH    = 10 ,
    parameter ROW_WIDTH    = 15 ,
    parameter ADR_WIDTH    = 15 ,
    parameter BG_WIDTH     = 0  ,
    parameter BA_WIDTH     = 3  ,
    parameter CWL          = 5  ,
    parameter CL           = 6
)(
    input                        clk           ,
    input                        rst_n         ,

    input                        lb_en         ,
    input                        wrlvl_en      ,
    input   [DX_NUM  * 4-1 : 0]  wsl           ,
    input   [DX_NUM  * 4-1 : 0]  rsl           ,

// from User
    input   [          4-1 : 0]  dhi_cmd_vld   ,
    input   [       32*4-1 : 0]  dhi_cmd_code  ,

    output  [DX_NUM     -1 : 0]  dhi_wdata_en  ,
    input   [DX_NUM  *64-1 : 0]  dhi_wdata     ,
    input   [DX_NUM  * 8-1 : 0]  dhi_wmask     ,
    output  [DX_NUM     -1 : 0]  dhi_rdata_vld ,
    output  [DX_NUM  *64-1 : 0]  dhi_rdata     ,

// to PHY
    output                       dhi_rst_n     ,
    output  [            3 : 0]  dhi_cke       ,
    output  [            3 : 0]  dhi_odt       ,
    output  [            3 : 0]  dhi_cs_n      ,
    output  [            3 : 0]  dhi_act_n     ,
    output  [            3 : 0]  dhi_ras_n     ,
    output  [            3 : 0]  dhi_cas_n     ,
    output  [            3 : 0]  dhi_we_n      ,
`ifdef DRAM_DDR4
    output  [ BG_WIDTH*4-1 : 0]  dhi_bg        ,
`endif
    output  [ BA_WIDTH*4-1 : 0]  dhi_ba        ,
    output  [ADR_WIDTH*4-1 : 0]  dhi_addr      ,
    output  [            3 : 0]  dhi_parity    ,

    output  [DX_NUM  * 8-1 : 0]  dhi_oe        ,
    output  [DX_NUM  * 8-1 : 0]  dhi_te        ,
    output  [DX_NUM  * 8-1 : 0]  dhi_pdr       ,
    output  [DX_NUM  * 8-1 : 0]  dhi_wdqs      ,
    output  [DX_NUM  *64-1 : 0]  dhi_wdq       ,
    output  [DX_NUM  * 8-1 : 0]  dhi_wdm       ,
    output  [DX_NUM  * 8-1 : 0]  dhi_rdq_en    ,
    input   [DX_NUM     -1 : 0]  dhi_rdq_vld   ,
    input   [DX_NUM  *64-1 : 0]  dhi_rdq
);

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
localparam  BANK_WIDTH = BA_WIDTH + BG_WIDTH;

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
wire [             3 : 0] cmd_wr;
wire [             3 : 0] cmd_rd;

wire [BANK_WIDTH*4-1 : 0]  dhi_bank;

//*****************************************************************************************************************************
//    Function Definition
//*****************************************************************************************************************************

//*****************************************************************************************************************************
//  Command Execution Unit 
//*****************************************************************************************************************************
ph1p_ddrphy_cmd_execution #(
    .COL_WIDTH    ( COL_WIDTH  ),
    .ROW_WIDTH    ( ROW_WIDTH  ),
    .ADR_WIDTH    ( ADR_WIDTH  ),
    .BA_WIDTH     ( BANK_WIDTH )
) u_ddrphy_cmd_execution (
    .clk          ( clk             ),
    .rst_n        ( rst_n           ),
    .wrlvl_en     ( wrlvl_en        ),
    .cmd_vld      ( dhi_cmd_vld     ),
    .cmd_code     ( dhi_cmd_code    ),
    .cmd_wr       ( cmd_wr          ),
    .cmd_rd       ( cmd_rd          ),
    .dhi_rst_n    ( dhi_rst_n       ),
    .dhi_cke      ( dhi_cke         ),
    .dhi_cs_n     ( dhi_cs_n        ),
    .dhi_act_n    ( dhi_act_n       ),
    .dhi_ras_n    ( dhi_ras_n       ),
    .dhi_cas_n    ( dhi_cas_n       ),
    .dhi_we_n     ( dhi_we_n        ),
    .dhi_odt      ( dhi_odt         ),
    .dhi_ba       ( dhi_bank        ),
    .dhi_addr     ( dhi_addr        ),
    .dhi_parity   ( dhi_parity      )
);

assign dhi_ba = dhi_bank[0          +: BA_WIDTH*4];
`ifdef DRAM_DDR4
assign dhi_bg = dhi_bank[BA_WIDTH*4 +: BG_WIDTH*4];
`endif

//*****************************************************************************************************************************
//    Instance : write path phase ctrl
//*****************************************************************************************************************************
genvar n, p;
generate
for (n = 0; n <= DX_NUM-1; n= n+1) begin : wphase
    ph1p_ddrphy_wphase_ctl #(
        .CWL   ( CWL )
    ) u_ddrphy_wphase_ctl (
    // clock & reset
        .clk          ( clk                       ),
        .rst_n        ( rst_n                     ),
    
    // misc ctrl 
        .lb_en        ( lb_en                     ),
        .wsl          ( wsl          [n* 4 +:  4] ),
        .wrlvl_en     ( wrlvl_en                  ),
        .wr_en        ( cmd_wr                    ),
    
    // wdata ctrl
        .wdq_en       ( dhi_wdata_en [n]          ),
        .wdq_data     ( dhi_wdata    [n*64 +: 64] ),
        .wdq_mask     ( dhi_wmask    [n* 8 +:  8] ),
    
    // output to GLUE   
        .oe           ( dhi_oe       [n* 8 +:  8] ),
        .wdq          ( dhi_wdq      [n*64 +: 64] ),
        .wdm          ( dhi_wdm      [n* 8 +:  8] ),
        .wdqs         ( dhi_wdqs     [n* 8 +:  8] )
    );
end
endgenerate

//*****************************************************************************************************************************
//    Instance : read path phase ctrl
//*****************************************************************************************************************************
generate 
for (n = 0; n <= DX_NUM-1; n = n+1) begin : rphase
ph1p_ddrphy_rphase_ctl #(
    .CL  ( CL )
) u_ddrphy_rphase_ctl (
// clock & reset
    .clk          ( clk                   ),
    .rst_n        ( rst_n                 ),

// misc ctrl 
    .lb_en        ( lb_en                 ),
    .rsl          ( rsl        [n*4 +: 4] ),
    .rd_en        ( cmd_rd                ),

// rdata output
    .rdq_vld      (),
    .rdq_data     (),

// output to GLUE   
    .te           ( dhi_te     [n*8 +: 8] ),
    .pdr          ( dhi_pdr    [n*8 +: 8] ),
    .gate         ( dhi_rdq_en [n*8 +: 8] )
);
end
endgenerate


//*****************************************************************************************************************************
// IN/OUT Ctl
//*****************************************************************************************************************************
assign dhi_rdata_vld = dhi_rdq_vld;
assign dhi_rdata     = dhi_rdq    ;

endmodule
