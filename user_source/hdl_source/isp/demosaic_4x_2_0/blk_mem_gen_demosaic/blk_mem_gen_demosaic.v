/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Dec 02 2025 10:48:04
**	TD version	:	6.1.155545
************************************************************/
`timescale 1ns/1ps
module blk_mem_gen_demosaic
(
  input   [32:0]                dia,
  input   [10:0]                addra,
  input                         wea,
  input                         clka,
  input   [10:0]                addrb,
  input                         clkb,
  input   [32:0]                dib,
  input                         web,
  output  [32:0]                doa,
  output  [32:0]                dob
);

  ram_c36c2ca3b3a7
  #(
      .DATA_WIDTH_A(33),
      .ADDR_WIDTH_A(11),
      .DATA_DEPTH_A(2048),
      .DATA_WIDTH_B(33),
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
  )ram_c36c2ca3b3a7_Inst
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
