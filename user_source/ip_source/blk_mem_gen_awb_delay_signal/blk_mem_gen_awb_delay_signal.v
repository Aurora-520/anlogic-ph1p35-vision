/************************************************************\
**	Copyright (c) 2012-2024 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Mar 06 2025 10:18:38
**	TD version	:	6.1.126561
************************************************************/
`timescale 1ns/1ps
module blk_mem_gen_awb_delay_signal
(
  output  [95:0]                doa,
  input   [95:0]                dia,
  input   [10:0]                addra,
  input                         wea,
  input                         clka,
  output  [95:0]                dob,
  input   [10:0]                addrb,
  input                         clkb,
  input   [95:0]                dib,
  input                         web
);

  ram_f84573da5ab5
  #(
      .DATA_WIDTH_A(96),
      .ADDR_WIDTH_A(11),
      .DATA_DEPTH_A(2048),
      .DATA_WIDTH_B(96),
      .ADDR_WIDTH_B(11),
      .DATA_DEPTH_B(2048),
      .REGMODE_A("NOREG"),
      .WRITEMODE_A("NORMAL"),
      .RESETMODE_A("ASYNC"),
      .INIT_FILE("NONE"),
      .REGMODE_B("NOREG"),
      .FILL_ALL("NONE"),
      .WRITEMODE_B("READBEFOREWRITE"),
      .RESETMODE_B("ASYNC")
  )ram_f84573da5ab5_Inst
  (
      .doa(doa),
      .dia(dia),
      .addra(addra),
      .wea(wea),
      .clka(clka),
      .dob(dob),
      .addrb(addrb),
      .clkb(clkb),
      .dib(dib),
      .web(web)
  );
endmodule
