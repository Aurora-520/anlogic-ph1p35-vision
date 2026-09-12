`timescale 1 ns / 1 ps
module w128_d512_fifo
(
  input                         rst,
  input                         clkw,
  input                         clkr,
  input                         we,
  input   [127:0]               di,
  input                         re,
  output  [127:0]               dout,
  output                        valid,
  output                        full_flag,
  output                        empty_flag,
  output                        afull,
  output                        aempty,
  output  [8:0]                 wrusedw,
  output  [8:0]                 rdusedw
);

  soft_fifo_al_4057d6b76aa6
  #(
      .DATA_WIDTH_W(128),
      .DATA_WIDTH_R(128),
      .ADDR_WIDTH_W(9),
      .ADDR_WIDTH_R(9),
      .AL_FULL_NUM(253),
      .AL_EMPTY_NUM(2),
      .SHOW_AHEAD_EN(0),
      .OUTREG_EN("NOREG")
  )soft_fifo_al_4057d6b76aa6_Inst
  (
      .rst(rst),
      .clkw(clkw),
      .clkr(clkr),
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
