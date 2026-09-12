/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2023/03/23
*Module Name:
*File Name:
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.0
*Signal description
*1) I_ input
*2) O_ output
*3) IO_ input output
*4) S_ system internal signal
*5) _n activ low
*6) _dg debug signal 
*7) _r delay or register
*8) _s state mechine
*********************************************************************/
/*********csi_unpacket_2lane MIPI CSI解码***********
--版本号1.0
--MIPI IP数据解码为32bit数据输出给下一级使用，这里需要了解MIPI协议的数据格式
*********************************************************************/

`timescale 1ns / 1ns

module csi_unpacket 
(
input wire          I_clk,  //来自MIPI 核的时钟
input wire          I_rst_n,//异步复位

input wire          I_hs_valid,//synthesis keep //来自MIPI核的数据有效信号,其中也包含的数据类型
input wire[15: 0]   I_hs_data, //synthesis keep //来自MIPI核的数据,其中也包含的数据类型数据，这里定义2LANE，1BYTE模式

output reg           O_csi_frame_start, //帧起始，1个周期有效
output reg           O_csi_frame_end,   //帧结束，1个周期有效
output reg           O_csi_valid, //synthesis keep      //有效数据输出
output reg           O_csi_hs,
output reg  [31: 0]  O_csi_data   //synthesis keep      //有效数据，这里定义2LANE，1BYTE模式
);


//MIPI数据类型
//DT 00 帧起始包
//DT 01 帧结束包
//DT 02 行起始包
//DT 03 行结束包
//DT 2a 8BIT模式下的数据长包
//DT 2b 10BIT模式下的数据长包

localparam FRAME_DATA_DT  = 8'h2B;   //RAW10
//localparam FRAME_DATA_DT  = 8'h2A;     //RAW8
localparam FRAME_START_DT = 8'h00;
localparam FRAME_END_DT   = 8'h01;

reg        S_hs_valid_1d;      //synthesis keep   
reg [15:0] S_hs_data_1d;       //synthesis keep   
wire       S_head_en;          //synthesis keep   
reg        S_head_en_1d;       //synthesis keep      
reg [15:0] S_data_length;      //synthesis keep      
reg        S_data_en;          //synthesis keep        
reg [15:0] S_data_en_cnt;      //synthesis keep      

assign  S_head_en  = ~S_hs_valid_1d & I_hs_valid;//帧头使能

//I_hs_valid 和 I_hs_data 各打1拍
always @(posedge I_clk) begin 
    S_hs_valid_1d        <= I_hs_valid;
    S_hs_data_1d         <= I_hs_data;
    S_head_en_1d         <= S_head_en;//帧头使能
end

//帧起始判断
always @(posedge I_clk) 
    O_csi_frame_start <= (S_head_en_1d && S_hs_data_1d[15:8] == FRAME_START_DT);


//帧结束判断
always @(posedge I_clk) 
    O_csi_frame_end  <= (S_head_en_1d && S_hs_data_1d[15:8] == FRAME_END_DT);

//获取数据长度
always @(posedge I_clk) begin 
    if(I_hs_valid)begin
        if(S_head_en_1d && S_hs_data_1d[15:8] == FRAME_DATA_DT)
            S_data_length <= {I_hs_data[15:8],S_hs_data_1d[7:0]} >> 1;
        else    
            S_data_length <= S_data_length;
    end
    else    
        S_data_length <= 'd0;
end


//数据有效使能
always @(posedge I_clk or negedge I_rst_n) begin
    if(!I_rst_n)
        S_data_en <= 1'b0;
    else    
        if(S_head_en_1d && S_hs_data_1d[15:8] == FRAME_DATA_DT)
            S_data_en <= 1'b1;
        else if(S_data_en_cnt == S_data_length-1)
            S_data_en <= 1'b0;
        else    
            S_data_en <= S_data_en;
end

//数据长度计数器
always @(posedge I_clk) begin
    if(S_data_en)
        S_data_en_cnt <= S_data_en_cnt + 'd1;
    else
        S_data_en_cnt <= 'd0;
end

//有效数据同步输出,把2LANE的16bit数据转为32bit数据
reg  csi_valid_r;//synthesis keep

always @(posedge I_clk) begin
    csi_valid_r   <= S_data_en ? ~csi_valid_r : 0; 
    O_csi_valid   <= csi_valid_r;
    O_csi_hs      <= I_hs_valid; 
end

always @(posedge I_clk) begin
    O_csi_data    <= S_data_en ? {O_csi_data[15:0],I_hs_data} : 0;
end

   cwc3 cwc3_inst
 (
     .probe0(I_hs_valid),
     .probe1(I_hs_data),
     .probe2(S_hs_valid_1d),
     .probe3(S_hs_data_1d),
     .probe4(S_head_en),
     .probe5(S_head_en_1d),
     .probe6(S_data_length),
     .probe7(S_data_en),
     .probe8(S_data_en_cnt),
     .probe9(csi_valid_r),
     .probe10(O_csi_frame_start),
     .probe11(O_csi_frame_end),
     .probe12(O_csi_valid),
     .probe13(O_csi_hs),
     .probe14(O_csi_data),
     .clk(I_clk)
 );

    
endmodule