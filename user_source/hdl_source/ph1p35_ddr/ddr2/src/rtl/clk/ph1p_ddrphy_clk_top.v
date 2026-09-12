
`timescale 1ps / 1ps

module ph1p_ddrphy_clk_top #(
    parameter  BK_NUM           =  2   ,
    parameter  PLL0_REFCLK_FREQ = "100",
    parameter  PLL0_REFCLK_DIV  =  1   ,
    parameter  PLL0_FBKCLK_DIV  =  12  ,
    parameter  PLL0_FRAC        = "DISABLE",
    parameter  PLL0_FRAC_SDM    =  0   ,
    parameter  PLL0_CLK2_DIV    =  3   ,
    parameter  PLL0_CLK3_DIV    =  24  ,
    parameter  PLL1_REFCLK_FREQ = "100",
    parameter  PLL1_REFCLK_DIV  =  1   ,
    parameter  PLL1_CLK0_DIV    =  12
)(
    input                sys_rst    , 
    input                ref_clk    , 

    output               cfg_clk    ,
    output               dhi_clk    ,
    output  [BK_NUM-1:0] ctl_clk    ,
    output  [BK_NUM-1:0] ddr_clk    ,
    output               pll_lock
);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Local Parameter
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal Signals
///////////////////////////////////////////////////////////////////////////////////////////////////
wire  pll0_lock;
wire  pll1_lock;

wire  pll0_clk_0;
wire  pll0_clk_1;
wire  pll0_clk_2;
wire  pll0_clk_3;
wire  pll1_clk_0;

wire  pll0_mlclk_1;
wire  pll0_mlclk_2;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Instance : GPLL
///////////////////////////////////////////////////////////////////////////////////////////////////
ph1p_ddrphy_pll0 #(
    .REFCLK_FREQ  ( PLL0_REFCLK_FREQ ),
    .REFCLK_DIV   ( PLL0_REFCLK_DIV  ),
    .FBKCLK_DIV   ( PLL0_FBKCLK_DIV  ),
    .FRAC         ( PLL0_FRAC        ),
    .FRAC_SDM     ( PLL0_FRAC_SDM    ),
    .CLK2_DIV     ( PLL0_CLK2_DIV    ),
    .CLK3_DIV     ( PLL0_CLK3_DIV    )
) u_pll0 (
    .refclk       ( ref_clk    ),
    .reset        ( sys_rst    ),
    .clk0_out     ( pll0_clk_0 ),
    .clk1_out     ( pll0_clk_1 ),
    .clk2_out     ( pll0_clk_2 ),
    .clk3_out     ( pll0_clk_3 ),
    .lock         ( pll0_lock  )
);

ph1p_ddrphy_pll1 #(
    .REFCLK_FREQ  ( PLL1_REFCLK_FREQ ),
    .REFCLK_DIV   ( PLL1_REFCLK_DIV  ),
    .CLK0_DIV     ( PLL1_CLK0_DIV    )
) u_pll1 (
    .refclk       ( pll0_clk_0 ),
    .reset        (~pll0_lock  ),
    .clk0_out     ( pll1_clk_0 ),
    .lock         ( pll1_lock  )
);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Instance : Clock Buffer
///////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef PH1P_FPSOC
DR1P_PHY_MLCLK #(
`else
PH1P_PHY_MLCLK #(
`endif
//  .MODE ("HIGH_PERFORMANCE")
) u_mlclk_1 (
    .ce      ( 1'b1         ),
    .clkin   ( pll0_clk_1   ),
    .clkout  ( pll0_mlclk_1 )
);

`ifdef PH1P_FPSOC
DR1P_PHY_MLCLK #(
`else
PH1P_PHY_MLCLK #(
`endif
//  .MODE ("HIGH_PERFORMANCE")
) u_mlclk_2 (
    .ce      ( 1'b1         ),
    .clkin   ( pll0_clk_2   ),
    .clkout  ( pll0_mlclk_2 )
);

genvar n;
generate
for (n = 0; n <= BK_NUM-1; n = n+1) begin : ioclk
`ifdef PH1P_FPSOC
    DR1P_PHY_IOCLK #( 
`else
    PH1P_PHY_IOCLK #(
`endif
//      .MODE ("HIGH_PERFORMANCE")
    ) u_ioclk_0 (
        .clkin  ( pll0_mlclk_1 ),
        .clkout ( ctl_clk[n]   )
    );

`ifdef PH1P_FPSOC
    DR1P_PHY_IOCLK #(
`else
    PH1P_PHY_IOCLK #(
`endif
//      .MODE ("HIGH_PERFORMANCE")
    ) u_ioclk_1 (
        .clkin  ( pll0_mlclk_2 ),
        .clkout ( ddr_clk[n]   )
    );
end
endgenerate

///////////////////////////////////////////////////////////////////////////////////////////////////
// Output
///////////////////////////////////////////////////////////////////////////////////////////////////
assign pll_lock = pll1_lock;

assign cfg_clk  = pll0_clk_3;
assign dhi_clk  = pll1_clk_0;

endmodule

