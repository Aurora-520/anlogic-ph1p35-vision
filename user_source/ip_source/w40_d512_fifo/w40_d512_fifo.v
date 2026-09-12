/************************************************************\
**	Copyright (c) 2012-2024 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Jul 26 2024 10:43:41
**	TD version	:	6.1.120544
************************************************************/
`timescale 1 ns / 1 ps
module w40_d512_fifo
(
  input                         rst,
  input                         clk,
  input                         we,
  input   [39:0]                di,
  input                         re,
  output  [39:0]                dout,
  output                        valid,
  output                        full_flag,
  output                        empty_flag,
  output                        afull,
  output                        aempty,
  output  [8:0]                 wrusedw,
  output  [8:0]                 rdusedw
);

  soft_fifo_al_2758cdf81c93
  #(
      .DATA_WIDTH_W(40),
      .DATA_WIDTH_R(40),
      .ADDR_WIDTH_W(9),
      .ADDR_WIDTH_R(9),
      .AL_FULL_NUM(253),
      .AL_EMPTY_NUM(2),
      .SHOW_AHEAD_EN(0),
      .OUTREG_EN("NOREG")
  )soft_fifo_al_2758cdf81c93_Inst
  (
      .rst(rst),
      .clk(clk),
      .we(we),
      .di(di),
      .re(re),
      .dout(dout),
      .valid(valid),
      .full_flag(full_flag),
      .empty_flag(empty_flag),
      .afull(afull),
      .aempty(aempty),
      .wrusedw(wrusedw),
      .rdusedw(rdusedw)
  );
endmodule
