`timescale 1ps/1ps

module ph1p_ddrphy_mdl_cal_wrapper #(
    parameter MDL_MODE = "FULL",
    parameter DX_NUM   = 2
)(
    input                   clk                    , 
    input                   rst_n                  , 

    input                   mdl_start              , 
    output reg              mdl_done               , 
    output [DX_NUM*9-1 : 0] mdl_tck                , 
    output [DX_NUM*9-1 : 0] mdl_ui                 , 

    input  [DX_NUM  -1 : 0] dly_full               , 

    input  [DX_NUM  -1 : 0] cal_en_in              , 
    input  [DX_NUM  -1 : 0] cal_in                 , 
    output [DX_NUM  -1 : 0] cal_clk_en             , 
    output [DX_NUM  -1 : 0] cal_en                 , 
    output [DX_NUM  -1 : 0] cal_mode               , 

    input  [DX_NUM  -1 : 0] dcp_rdy                , 
    output [DX_NUM  -1 : 0] dcp_inc                ,
    output [DX_NUM*9-1 : 0] dcp_code               , 
    output [DX_NUM*4-1 : 0] dcp_type               , 
    output [DX_NUM  -1 : 0] dcp_vld
);
//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
wire [DX_NUM -1 : 0] mdl_done_temp ;

//*****************************************************************************************************************************
//    Model Instantiation : MDL_CAL
//*****************************************************************************************************************************
genvar n;
generate
for (n = 0 ; n <= DX_NUM-1; n = n+1) begin: mdl_cal
ph1p_ddrphy_mdl_cal #(
    .MDL_MODE      ( MDL_MODE )
) u_ddrphy_mdl_cal (
    .clk                     ( clk                            ),
    .rst_n                   ( rst_n                          ),

    .mdl_start               ( mdl_start                      ),
    .mdl_done                ( mdl_done_temp     [n]          ),
    .mdl_tck                 ( mdl_tck           [n*9 +: 9]   ),
    .mdl_ui                  ( mdl_ui            [n*9 +: 9]   ),

    .dcp_rdy                 ( dcp_rdy           [n]          ),
    .dcp_inc                 ( dcp_inc           [n]          ),
    .dcp_code                ( dcp_code          [n*9 +: 9]   ),
    .dcp_type                ( dcp_type          [n*4 +: 4]   ),
    .dcp_vld                 ( dcp_vld           [n]          ),

    .cal_en_in               ( cal_en_in         [n]          ),
    .cal_in                  ( cal_in            [n]          ),
    .cal_en                  ( cal_en            [n]          ),
    .cal_clk_en              ( cal_clk_en        [n]          ),
    .cal_mode                ( cal_mode          [n]          )
);
end
endgenerate

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        mdl_done <= 1'b0;
    else
        mdl_done <= &mdl_done_temp;
end

endmodule
