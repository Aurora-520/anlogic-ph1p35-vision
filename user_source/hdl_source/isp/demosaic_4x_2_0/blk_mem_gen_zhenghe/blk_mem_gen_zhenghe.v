/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Dec 02 2025 10:46:39
**	TD version	:	6.1.155545
************************************************************/
`timescale 1ns/1ps
module blk_mem_gen_zhenghe
(
  input   [31:0]                dia,
  input   [10:0]                addra,
  input                         wea,
  input                         clka,
  input   [10:0]                addrb,
  input                         clkb,
  input   [31:0]                dib,
  input                         web,
  output  [31:0]                doa,
  output  [31:0]                dob
);

  ram_d32970204f32
  #(
      .DATA_WIDTH_A(32),
      .ADDR_WIDTH_A(11),
      .DATA_DEPTH_A(2048),
      .DATA_WIDTH_B(32),
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
  )ram_d32970204f32_Inst
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
