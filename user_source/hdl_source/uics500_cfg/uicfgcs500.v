
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2019/12/17
*Module Name:uicfg7611
*File Name:uicfg7611.v
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

/*******************************uicfg7611***************************
--1.ADV7611芯片配置驱动程序
*********************************************************************/

`timescale 1ns / 1ns

module uicfgcs500#
(
parameter	 CLK_DIV  = 16'd999
)
(
input  wire             I_clk,  //系统时钟输入
input  wire             I_rst_n,  //系统复位输入
input  wire             I_ae_req,//摄像头AE控制
input  wire	 [15:0] 	I_ae,
input  wire	 [15:0] 	I_ag,
output wire             O_cam_scl, //I2C总线，SCL时钟
inout  wire             IO_cam_sda, //I2C总线，SDA数据
output reg              O_cfg_done, //配置完成
output reg              O_ae_cfg_done
);	

localparam CAM_ID = 8'h6C;
//内部计数器产生一个延迟复位
reg[7:0] rst_cnt =0;
always@(posedge I_clk or negedge I_rst_n)  
    if(I_rst_n == 1'b0) //复位初始化寄存器
        rst_cnt<= 8'd0; 
    else if(rst_cnt[7] == 1'b0)
       rst_cnt <= rst_cnt + 1'b1; 
    else 
       rst_cnt <= rst_cnt; 

reg  iic_req;//请求操作I2C控制器信号
wire ic_busy; //I2C控制器忙信号 
reg  [31:0] wr_data;     //写数据寄存器
reg  [1 :0] TS_S = 2'd0; //状态机寄存器
reg  [8 :0] reg_index;   //寄存索引
wire [23:0] REG_DATA;    //寄存器数据
wire [23:0] REG_DATA_REG;    //寄存器数据
wire [23:0] REG_DATA_AE;    //寄存器数据
wire [8 :0] REG_SIZE;    //寄存器数量
wire [8 :0] REG_SIZE_REG;    //寄存器数量
wire [8 :0] REG_SIZE_AE;    //寄存器数量

always@(posedge I_clk ) begin 
    if(rst_cnt[7] == 1'b0)begin //复位初始化寄存器
        reg_index  <= 9'd0;
        iic_req    <= 1'b0;
        wr_data    <= 32'd0;
        O_cfg_done <= 1'b0;
        O_ae_cfg_done <= 1'b0;
        TS_S     <= 2'd0;    
    end
    else begin
        case(TS_S)
        0:if(reg_index == REG_SIZE && O_cfg_done == 1'b0) begin//如果配置完成
            O_cfg_done <= 1'b1;       //设置 cfg_done标准
        end 
        else if(reg_index == REG_SIZE && O_ae_cfg_done == 1'b0) begin//如果配置完成
            O_ae_cfg_done <= 1'b1;       //设置 cfg_done标准
        end 
        else if(I_ae_req)begin
            O_ae_cfg_done <= 0;
            reg_index   <= 0;
        end
        else if((O_cfg_done&O_ae_cfg_done) == 1'b0)
            TS_S <= 2'd1;           //下一个状态
        1:if(!iic_busy)begin        //当总线非忙，才可以操作I2C控制器
            iic_req  <= 1'b1;       //请求操作I2C控制器
			wr_data[7  :0] <= CAM_ID;           //器件地址   
			wr_data[15 :8] <= REG_DATA[23:16];  //寄存器地址-高8bit    
			wr_data[23:16] <= REG_DATA[15: 8];  //寄存器地址-低8bit  
            wr_data[31:24] <= REG_DATA[7 : 0];  //寄存器数据
            TS_S      <= 2'd2; //下一个状态
        end    
        2:if(iic_busy)begin
             iic_req  <= 1'b0;  //重置 iic_req =0
             TS_S     <= 2'd3;  //下一个状态
        end
        3:if(!iic_busy)begin  //当总线非忙，才可以操作I2C控制器 
			reg_index<= reg_index + 1'b1;//寄存器索引加1
			TS_S    <= 2'd0;//回到初始状态
        end 
        endcase
   end
end

assign REG_DATA = (O_cfg_done == 0) ? REG_DATA_REG : REG_DATA_AE;
assign REG_SIZE = (O_cfg_done == 0) ? REG_SIZE_REG : REG_SIZE_AE;

//例化I2C控制模块
uii2c#
(
.WMEN_LEN(4),     //最大支持一次写入4BYTE(包含器件地址)
.RMEN_LEN(1),     //最大支持一次读出1BYTE
.CLK_DIV(CLK_DIV) //100KHZ I2C总线时钟
)
uii2c_inst
(
.I_clk(I_clk),//系统时钟
.I_rstn(rst_cnt[7]),//系统复位
.O_iic_scl(O_cam_scl),//I2C SCL总线时钟
.IO_iic_sda(IO_cam_sda),//I2C SDA数据总线
.I_wr_data(wr_data),//写数据寄存器
.I_wr_cnt(8'd4),//需要写的数据BYTES
.O_rd_data(),   //读数据寄存器
.I_rd_cnt(8'd0),//需要读的数据BYTES
.I_iic_mode(1'b0),//读模式设置
.I_iic_req(iic_req),//I2C控制器请求
.O_iic_busy(iic_busy)//I2C控制器忙
);


//例化CAM的寄存器配置表
uics500reg uics500reg_inst
(
.REG_SIZE(REG_SIZE_REG),  //寄存器数量
.REG_INDEX(reg_index),    //寄存索引
.REG_DATA(REG_DATA_REG)   //寄存器数据
);  

wire 	[15:0] 	w_gain_val; 
SC500GainTbl gain_tbl (.I_clk(I_clk), .I_rstn(rst_cnt[7]==1'b0), .I(I_ag - 16), .O(w_gain_val));
//例化CAM AE的寄存器配置表
uics500regAE uics500regAE_inst
(
.REG_SIZE(REG_SIZE_AE),  //寄存器数量
.REG_INDEX(reg_index),//寄存索引
.REG_DATA(REG_DATA_AE),   //寄存器数据
.I_AG(w_gain_val),
.I_AE(I_ae)
);  




endmodule
