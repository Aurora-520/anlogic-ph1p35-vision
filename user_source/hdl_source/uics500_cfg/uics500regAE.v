`timescale 1ns / 1ps
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2019/12/17
*Module Name:HDMI_IN_Test
*File Name:HDMI_IN_Test.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.0
*Signal description
*1) _i input
*2) _o output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/

/*******************************ui7611reg***************************
--1.ADV7611–æ∆¨≈‰÷√ºƒ¥Ê∆˜≈‰÷√±Ì
*********************************************************************/

module uics500regAE
(  
input      [8 :0]  REG_INDEX,
output reg [31:0]  REG_DATA,
output     [8 :0]  REG_SIZE,
input      [15:0]  I_AE,
input      [15:0]  I_AG
);

assign	REG_SIZE = 9'd5;
//-----------------------------------------------------------------
/////////////////////	Config Data REG	  //////////////////////////	
always@(*)
   case(REG_INDEX)
		0:	REG_DATA = {16'h3e00, 4'h0, I_AE[15:12]}; 
		1:	REG_DATA = {16'h3e01, I_AE[11: 4]}; 
		2:	REG_DATA = {16'h3e02, I_AE[3:0], 4'h0};
		3:	REG_DATA = {16'h3e08, I_AG[15:8]};
		4:	REG_DATA = {16'h3e09, I_AG[7 :0]};
		default:REG_DATA    =   {16'h0000, 8'h00};
   endcase

endmodule
