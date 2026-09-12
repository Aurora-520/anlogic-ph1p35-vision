/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Jun 14 2025 22:20:07
**	TD version	:	6.1.155545
************************************************************/
///////////////////////////////////////////////////////////////////////////////
//	Input frequency:                50.000000000 MHz
//	Clock multiplication factor: 3
//	Clock division factor:       2
//	Clock information:
//		Clock name	| Frequency 	| Phase shift 
//		C0        	| 75.000000   MHz	    |  0.0000 DEG 
//		C1        	| 375.000000   MHz	    |  0.0000 DEG 
//		C2        	| 70.312500   MHz		|  0.0000 DEG 
//		C3        	| 23.936170   MHz		|  0.0000 DEG 
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 fs 

module pll_hdmi
(
  input                         refclk,
  output                        clk0_out,
  output                        clk1_out,
  output                        clk2_out,
  output                        clk3_out,
  output                        lock
);
  wire							  clk0_buf;
PH1P_LOGIC_BUFG bufg_feedback (
 .i(clk0_buf), 
 .o(clk0_out) 
 ); 

 
  wire							  clk2_buf;
PH1P_LOGIC_BUFG bufg_c2 (
 .i(clk2_buf), 
 .o(clk2_out) 
 ); 

  wire							  clk3_buf;
PH1P_PHY_MLCLK mlclk_c3 (
 .ce(1'b1), 
 .clkin(clk3_buf), 
 .clkout(clk3_out) 
 ); 





  ph1p_phy_pll_wrapper_27c53fedd344
  #(
      .FBKCLK("CLKC0_EXT"),
      .FBKCLK_INT("CLKC0_EXT"),
      .FIN("50.000000000"),
      .REFCLK_DIV(2),
      .FBCLK_DIV(3),
      .CLKC0_ENABLE("ENABLE"),
      .CLKC0_DIV(15),
      .CLKC0_CPHASE(14),
      .CLKC0_FPHASE(0),
      .CLKC0_FPHASE_RSTSEL(0),
      .CLKC0_DUTY50("ENABLE"),
      .CLKC0_DUTY_INT(8),
      .CLKC1_ENABLE("ENABLE"),
      .CLKC1_DIV(3),
      .CLKC1_CPHASE(2),
      .CLKC1_FPHASE(0),
      .CLKC1_FPHASE_RSTSEL(0),
      .CLKC1_DUTY50("ENABLE"),
      .CLKC1_DUTY_INT(2),
      .CLKC2_ENABLE("ENABLE"),
      .CLKC2_DIV(16),
      .CLKC2_CPHASE(15),
      .CLKC2_FPHASE(0),
      .CLKC2_FPHASE_RSTSEL(0),
      .CLKC2_DUTY50("ENABLE"),
      .CLKC2_DUTY_INT(8),
      .CLKC3_ENABLE("ENABLE"),
      .CLKC3_DIV(47),
      .CLKC3_CPHASE(46),
      .CLKC3_FPHASE(0),
      .CLKC3_FPHASE_RSTSEL(0),
      .CLKC3_DUTY50("ENABLE"),
      .CLKC3_DUTY_INT(24),
      .PLL_USR_RST("DISABLE"),
      .PLL_FEED_TYPE("EXTERNAL"),
      .PLL_FASTLOOP("ENABLE"),
      .LPF_RES(0),
      .LPF_CAP(25),
      .ICP_CUR(29),
      .PHASE_PATH_SEL(0),
      .DYN_PHASE_PATH_SEL("DISABLE"),
      .DYN_FPHASE_EN("DISABLE"),
      .PI_OUT_SEL("NORMAL"),
      .PI_FRAC_EN("DISABLE"),
      .CLKC0_PI_SHIFT_EN("DISABLE"),
      .FEEDBK_MODE("NORMAL"),
      .DYN_CPHASE_EN("DISABLE")
  )ph1p_phy_pll_wrapper_27c53fedd344_Inst
  (
      .clk4_en(1'b0),
      .clk4_out(),
      .clkb4_out(),
      .clk5_en(1'b0),
      .clk5_out(),
      .clkb5_out(),
      .clk6_en(1'b0),
      .clk6_out(),
      .clkb6_out(),
      .refclk(refclk),
      .drp_clk(1'b0),
      .drp_rstn(1'b1),
      .drp_sel(1'b0),
      .drp_rd(1'b0),
      .drp_wr(1'b0),
      .drp_addr(8'b00000000),
      .drp_wdata(8'b00000000),
      .drp_err(),
      .drp_rdy(),
      .drp_rdata(),
      .psclk(1'b0),
      .psclksel(3'b000),
      .psstep(1'b0),
      .psdown(1'b0),
      .cps_step(1'b0),
      .psdone(),
      .ssc_reset(1'b0),
	  .clkc_rst(2'b00),
      .pllpd(1'b0),
      .reset(1'b0),
      .fbclk(clk0_out),
      .wakeup(1'b1),
      .refclk_rst(1'b0),
      .clk0_en(1'b1),
      .clkb0_out(),
      .clk0_out(clk0_buf),
      .clk1_en(1'b1),
      .clkb1_out(),
      .clk1_out(clk1_out),
      .clk2_en(1'b1),
      .clkb2_out(),
      .clk2_out(clk2_buf),
      .clk3_en(1'b1),
      .clkb3_out(),
      .clk3_out(clk3_buf),
      .lock(lock)
  );
endmodule
