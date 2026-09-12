
`timescale 1ps / 1ps

module ph1p_ddrphy_dcu_wrapper #(
    parameter integer DX_NUM  = 2
)(
// Clock & Reset
    input                     clk           ,
    input                     rst_n         ,

// DelayLine Configuration Port
    input   [DX_NUM*1-1 : 0]  dcp_vld       ,
    input   [DX_NUM*1-1 : 0]  dcp_inc       ,
    input   [DX_NUM*4-1 : 0]  dcp_type      ,
    input   [DX_NUM*9-1 : 0]  dcp_code      ,
    output  [DX_NUM*1-1 : 0]  dcp_rdy       ,

// DelayLine Status
    output  [DX_NUM*9-1 : 0]  dly_cur_gate  ,
    output  [DX_NUM*9-1 : 0]  dly_cur_wdqs  ,
    output  [DX_NUM*9-1 : 0]  dly_cur_wdq   ,
    output  [DX_NUM*9-1 : 0]  dly_cur_rdqsp ,
    output  [DX_NUM*9-1 : 0]  dly_cur_rdqsn ,
    output  [DX_NUM*9-1 : 0]  dly_cur_mdl   ,

// DelayLine Configuration Port to DX_GLUE
    output  [DX_NUM*1-1 : 0]  dcp_psel      ,
    output  [DX_NUM*6-1 : 0]  dcp_paddr     ,
    output  [DX_NUM*9-1 : 0]  dcp_pdata     ,
    output  [DX_NUM*1-1 : 0]  dcp_gate      ,

// MISC
    input   [DX_NUM*4-1 : 0]  rsl_i         ,
    output  [DX_NUM*4-1 : 0]  rsl_o         ,
    input   [DX_NUM*4-1 : 0]  wsl_i         ,
    output  [DX_NUM*4-1 : 0]  wsl_o         ,
    input   [DX_NUM*9-1 : 0]  ui
);

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************


//*****************************************************************************************************************************
//    Model instantiation
//*****************************************************************************************************************************
genvar n;
generate
    for (n = 0; n < DX_NUM; n = n+1) begin : byteIdx
        ph1p_ddrphy_dcu u_ddrphy_dcu (
            .clk           ( clk                      ),
            .rst_n         ( rst_n                    ),

            .dcp_vld       ( dcp_vld       [n]        ), // 1-cycle pulse
            .dcp_type      ( dcp_type      [4*n +: 4] ),
            .dcp_code      ( dcp_code      [9*n +: 9] ),
            .dcp_inc       ( dcp_inc       [n]        ),
            .dcp_rdy       ( dcp_rdy       [n]        ),

            .dly_cur_gate  ( dly_cur_gate  [n*9 +: 9] ),
            .dly_cur_wdq   ( dly_cur_wdq   [n*9 +: 9] ),
            .dly_cur_wdqs  ( dly_cur_wdqs  [n*9 +: 9] ),
            .dly_cur_rdqsn ( dly_cur_rdqsn [n*9 +: 9] ),
            .dly_cur_rdqsp ( dly_cur_rdqsp [n*9 +: 9] ),
            .dly_cur_mdl   ( dly_cur_mdl   [n*9 +: 9] ),

            .dcp_psel      ( dcp_psel      [n]        ),
            .dcp_paddr     ( dcp_paddr     [n*6 +: 6] ),
            .dcp_pdata     ( dcp_pdata     [n*9 +: 9] ),
            .dcp_gate      ( dcp_gate      [n]        ),

            .rsl_i         ( rsl_i         [n*4 +: 4] ),
            .rsl_o         ( rsl_o         [n*4 +: 4] ),
            .wsl_i         ( wsl_i         [n*4 +: 4] ),
            .wsl_o         ( wsl_o         [n*4 +: 4] ),
            .ui            ( ui            [n*9 +: 9] )
        );
    end
endgenerate


endmodule
