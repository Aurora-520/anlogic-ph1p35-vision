///////////////////////////////////////////////////////////////////////////////
//      C0          | DDR_SPEED/8
//      C1          | DDR_SPEED/8
//      C2          | DDR_SPEED/2
//      C3          | 50MHz, fixed, low priority
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 fs

module ph1p_ddrphy_pll0 #(
    parameter  REFCLK_FREQ = "100",
    parameter  REFCLK_DIV  = 3 ,
    parameter  FBKCLK_DIV  = 48,
    parameter  FRAC        = "DISABLE",
    parameter  FRAC_SDM    = 0 ,
    parameter  CLK2_DIV    = 4 ,
    parameter  CLK3_DIV    = 32
)(
    input   refclk  ,
    input   reset   ,
    output  clk0_out,
    output  clk1_out,
    output  clk2_out,
    output  clk3_out,
    output  lock
);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Local Parameter
///////////////////////////////////////////////////////////////////////////////////////////////////
localparam  CLK0_DIV  = CLK2_DIV*4;
localparam  CLK1_DIV  = CLK2_DIV*4;

localparam  FAST_LOOP = "DISABLE";
localparam  LPF_RES   = 3; // 0~3
localparam  ICP_CUR   = 0; 
localparam  LPF_CAP   = ((FBKCLK_DIV >=   1) && (FBKCLK_DIV <   60)) ?  0 :
                        ((FBKCLK_DIV >=  60) && (FBKCLK_DIV <   80)) ?  6 :
                        ((FBKCLK_DIV >=  80) && (FBKCLK_DIV <  128)) ? 16 :
                        ((FBKCLK_DIV >= 128) && (FBKCLK_DIV <= 160)) ? 28 : 0;

// HighBW        LPF_CAP, ICP_CUR, LPF_RES, FASTLOOP
// 1_2_high       3        1       0        Enable 
// 2_4_high       3        3       0        Enable
// 4_8_high       3        7       0        Enable
// 8_15_high      3       15       0        Enable
// 15_20_high     5       20       0        Enable
// 20_30_high     5       29       0        Enable
// 30_40_high    13       29       0        Enable
// 40_60_high    25       29       0        Enable
// 60_80_high    31       31       0        Enable
// 80_128_high   31       31       0        Enable
// 128_160_high  31       31       0        Enable

// LowBW  LPF_CAP, ICP_CUR, LPF_RES, FASTLOOP
// 8_15         0       0        3   Disable     
// 15_20        0       0        3   Disable     
// 20_30        0       0        3   Disable     
// 30_40        0       0        3   Disable     
// 40_60        0       0        3   Disable     
// 60_80        6       0        3   Disable     
// 80_128      16       0        3   Disable     
// 128_160     28       0        3   Disable     

///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal Signals
///////////////////////////////////////////////////////////////////////////////////////////////////
wire  [6:0] clkc   ;
wire  [6:0] clkc_en;
wire        fbclk  ;

assign clkc_en  = 7'b000_1111;
assign clk0_out = clkc[0];
assign clk1_out = clkc[1];
assign clk2_out = clkc[2];
assign clk3_out = clkc[3];

assign fbclk = 1'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Intance : GPLL Primitie
///////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef PH1P100
PH1P_PHY_PLL #(
`elsif PH1P35
PH1P_PHY_PLL_V2 #(
`elsif PH1P50
PH1P_PHY_PLL_V2 #(
`elsif PH1P_FPSOC
DR1P_PHY_PLL #(
`endif
// refclk
    .FIN                          ( REFCLK_FREQ  ), 

// feedback set
    .PLL_FEED_TYPE                ( "INTERNAL"   ), // "INTERNAL", "EXTERNAL"
    .FEEDBK_MODE                  ( "NOCOMP"     ), // "NORMAL", "NOCOMP"
    .FBKCLK                       ( "VCO_PHASE0" ),
    .FBKCLK_INT                   ( "VCO_PHASE0" ),

// vco divider
    .REFCLK_DIV                   ( REFCLK_DIV   ), // 1~128
    .FBCLK_DIV                    ( FBKCLK_DIV   ), // 1~128

// clock enable
    .CLKC0_ENABLE                 ( "ENABLE"     ), // "ENABLE", "DISABLE"
    .CLKC1_ENABLE                 ( "ENABLE"     ), // "ENABLE", "DISABLE"
    .CLKC2_ENABLE                 ( "ENABLE"     ), // "ENABLE", "DISABLE"
    .CLKC3_ENABLE                 ( "ENABLE"     ), // "ENABLE", "DISABLE"
    .CLKC4_ENABLE                 ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .CLKC5_ENABLE                 ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .CLKC6_ENABLE                 ( "DISABLE"    ), // "ENABLE", "DISABLE"

// output divider
    .CLKC0_DIV                    ( CLK0_DIV     ), // 1~128
    .CLKC1_DIV                    ( CLK1_DIV     ), // 1~128
    .CLKC2_DIV                    ( CLK2_DIV     ), // 1~128
    .CLKC3_DIV                    ( CLK3_DIV     ), // 1~128
    .CLKC4_DIV                    ( 1            ), // 1~128
    .CLKC5_DIV                    ( 1            ), // 1~128
    .CLKC6_DIV                    ( 1            ), // 1~128

// duty
    .CLKC0_DUTY_INT               ((CLK0_DIV+1)/2), // 1~127
    .CLKC1_DUTY_INT               ((CLK1_DIV+1)/2), // 1~127
    .CLKC2_DUTY_INT               ((CLK2_DIV+1)/2), // 1~127
    .CLKC3_DUTY_INT               ((CLK3_DIV+1)/2), // 1~127
    .CLKC4_DUTY_INT               ( 1            ), // 1~127
    .CLKC5_DUTY_INT               ( 1            ), // 1~127
    .CLKC6_DUTY_INT               ( 1            ), // 1~127

// loop parameter
    .LPF_RES                      ( LPF_RES      ), // 0~3
    .LPF_CAP                      ( LPF_CAP      ), // 0~31
    .ICP_CUR                      ( ICP_CUR      ), // 0~31

// fine phase shift
    .CLKC0_FPHASE                 ( 0            ), // 0~7
    .CLKC1_FPHASE                 ( 0            ), // 0~7
    .CLKC2_FPHASE                 ( 0            ), // 0~7
    .CLKC3_FPHASE                 ( 0            ), // 0~7
    .CLKC4_FPHASE                 ( 0            ), // 0~7
    .CLKC5_FPHASE                 ( 0            ), // 0~7
    .CLKC6_FPHASE                 ( 0            ), // 0~7

    .CLKC0_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC1_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC2_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC3_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC4_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC5_FPHASE_RSTSEL          ( 0            ), // 0, 1
    .CLKC6_FPHASE_RSTSEL          ( 0            ), // 0, 1

// coarse phase shift
    .CLKC0_CPHASE                 ( CLK0_DIV-1   ), // 0~127
    .CLKC1_CPHASE                 ( CLK1_DIV-1   ), // 0~127
    .CLKC2_CPHASE                 ( CLK2_DIV-1   ), // 0~127
    .CLKC3_CPHASE                 ( CLK3_DIV-1   ), // 0~127
    .CLKC4_CPHASE                 ( 0            ), // 0~127
    .CLKC5_CPHASE                 ( 0            ), // 0~127
    .CLKC6_CPHASE                 ( 0            ), // 0~127

// clk output path sel
    .PREDIV_MUXC0                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC1                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC2                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC3                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC4                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC5                 ( "VCO"        ), // "VCO", "REFCLK"
    .PREDIV_MUXC6                 ( "VCO"        ), // "VCO", "REFCLK"

    .DIVOUT_MUXC0                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC1                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC2                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC3                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC4                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC5                 ( "DIV"        ), // "DIV", "REFCLK"
    .DIVOUT_MUXC6                 ( "DIV"        ), // "DIV", "REFCLK"

// lock detector
    .REFCLK_DET_BYP               ( "DISABLE"    ), // "ENABLE", "DISABLE"

// frac-N
    .FRAC_ENABLE                  ( FRAC         ), // "ENABLE", "DISABLE"
    .SDM_FRAC                     ( FRAC_SDM     ), // 0~(2^24-1)

// fine phase shift
    .PHASE_PATH_SEL               ( 0            ), // 0~7
    .DYN_PHASE_PATH_SEL           ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .DYN_FPHASE_EN                ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .DYN_CPHASE_EN                ( "DISABLE"    ), // "ENABLE", "DISABLE"

    .PLL_FASTLOOP                 ( FAST_LOOP    ),
    .CLKC0_FRAC_EN                ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .CLKC0_FRAC                   ( 0            ), // 0~7
    .PI_OUT_SEL                   ( "NORMAL"     ), // "NORMAL", "PI"
    .PI_FRAC_EN                   ( "DISABLE"    ), // "ENABLE", "DISABLE"
    .CLKC0_PI_SHIFT_EN            ( "DISABLE"    )  // "ENABLE", "DISABLE"
) u_pll_inst (
// RefClk
    .refclk      ( refclk      ), // input
    .refclk_rst  ( 1'b0        ), // input

// Reset
    .pllreset    ( reset       ), // input
    .pllpd       ( 1'b0        ), // input
    .wakeup      ( 1'b1        ), // input

// Clock
    .fbclk       ( fbclk       ), // input
    .clkc_rst    ( 2'b00       ), // input  [1:0]
    .clkc_en     ( clkc_en     ), // input  [6:0]
    .clkc        ( clkc        ), // output [6:0]

// Status
    .lock        ( lock        ), // output

// DRP
    .drp_clk     ( 1'b0        ), // input
    .drp_rstn    ( 1'b1        ), // input
    .drp_sel     ( 1'b0        ), // input
    .drp_rd      ( 1'b0        ), // input
    .drp_wr      ( 1'b0        ), // input
    .drp_addr    ( 8'h00       ), // input  [7:0]
    .drp_wdata   ( 8'h00       ), // input  [7:0]
    .drp_err     (             ), // output
    .drp_rdy     (             ), // output
    .drp_rdata   (             ), // output [7:0]

// Dynamic Phase Ctrl
    .psdone      (             ), // output
    .psclk       ( 1'b0        ), // input
    .psdown      ( 1'b0        ), // input
    .psstep      ( 1'b0        ), // input
    .psclksel    ( 3'b000      ), // input  [2:0]
    .cps_step    ( 1'b0        ), // input

// SSC
    .ssc_reset   ( 1'b1        ), // input

// SCAN
    .scan_clk    ( 1'b0        ), // input
    .scan_enable ( 1'b1        ), // input
    .scan_mode   ( 1'b0        ), // input
    .scan_resetn ( 1'b0        )  // input
);


endmodule
