
`timescale 1ns/1ps

module ram_d32970204f32 (
	
	doa, 
	dia, 
	addra, 
	
	clka, 
	wea, 
	
	clkb, 
	
	web, 
	
	dob, 
	dib, 
	addrb
	
);

	parameter DATA_WIDTH_A = 20; 
	parameter ADDR_WIDTH_A = 10;
	parameter DATA_DEPTH_A = 1024;
	parameter DATA_WIDTH_B = DATA_WIDTH_A;
	parameter ADDR_WIDTH_B = ADDR_WIDTH_A;
	parameter DATA_DEPTH_B = DATA_DEPTH_A;
	
	parameter REGMODE_A    = "NOREG";
	parameter REGMODE_B    = "OUTREG";
	parameter WRITEMODE_A  = "NORMAL";
	parameter WRITEMODE_B  = "NORMAL";
	parameter RESETMODE_A  = "ASYNC";
	parameter RESETMODE_B  = "ASYNC";
	
	parameter INIT_FILE    ="NONE";
	parameter FILL_ALL     ="NONE";

	output [DATA_WIDTH_A-1:0] doa;
	output [DATA_WIDTH_B-1:0] dob;
	input  [DATA_WIDTH_A-1:0] dia;
	input  [DATA_WIDTH_B-1:0] dib;
	input  [ADDR_WIDTH_A-1:0] addra;
	input  [ADDR_WIDTH_B-1:0] addrb;
	input  wea;
	input  web;
	
	input  clka;
	
	input  clkb;
	
	PH1P_LOGIC_ERAM #( 
	
		.DATA_WIDTH_A(DATA_WIDTH_A),
		.DATA_WIDTH_B(DATA_WIDTH_B),
		.ADDR_WIDTH_A(ADDR_WIDTH_A),
		.ADDR_WIDTH_B(ADDR_WIDTH_B),
		.DATA_DEPTH_A(DATA_DEPTH_A),
		.DATA_DEPTH_B(DATA_DEPTH_B),
		
		.MODE("DP"),
		.REGMODE_A(REGMODE_A),
		.REGMODE_B(REGMODE_B),
		.WRITEMODE_A(WRITEMODE_A),
		.WRITEMODE_B(WRITEMODE_B),
		
		.IMPLEMENT("20K(FAST)"),
		
		.ECC_ENCODE("DISABLE"),
		.ECC_DECODE("DISABLE"),
		
		.CLKMODE("ASYNC"),
		
		.SSROVERCE("DISABLE"),
		
		.OREGSET_A("RESET"),
		
		.OREGSET_B("RESET"),
		
		.RESETMODE_A(RESETMODE_A),
		.RESETMODE_B(RESETMODE_B),
		
		.ASYNC_RESET_RELEASE_A("ASYNC"),
		
		.ASYNC_RESET_RELEASE_B("ASYNC"),
		
		.INIT_FILE(INIT_FILE),
		.FILL_ALL(FILL_ALL)
		
	) username_inst(
		
		.dia(dia),
		.dib(dib),
		.addra(addra),
		.addrb(addrb),
		
		.cea(1'b1),
		
		.ceb(1'b1),
		
		.ocea(1'b0),
		
		.oceb(1'b0),
		
		.clka(clka),
		
		.clkb(clkb),
		
		.wea(wea),
		.web(web),
		
		.bea(1'b0),
		.beb(1'b0),
		
		.rsta(1'b0),
		
		.rstb(1'b0),
		
		.doa(doa),
		.ecc_sbiterr(),
		.ecc_dbiterr(),
		.ecc_sbiterrinj('d0),
		.ecc_dbiterrinj('d0),
		.dob(dob)
		
	);

endmodule
