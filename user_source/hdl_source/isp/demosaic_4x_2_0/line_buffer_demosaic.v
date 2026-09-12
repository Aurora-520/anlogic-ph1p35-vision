`timescale 1ns / 1ps
/*****************************************************************
Company : MiLianKe Electronic Technology Co., Ltd.
WebSite:https://www.milianke.com
TechWeb:https://www.uisrc.com
tmall-shop:https://milianke.tmall.com
jd-shop:https://milianke.jd.com
taobao-shop: https://milianke.taobao.com
Description: 
The reference demo provided by Milianke is only used for learning. 
We cannot ensure that the demo itself is free of bugs, so users 
should be responsible for the technical problems and consequences
caused by the use of their own products.
@Author      :   XiaoQingquan 
@Time        :   2024/10 
version:     :   
@Description :   
*****************************************************************/

module line_buffer_demosaic #(
    parameter IMG_HEIGHT = 1080,   // 图像高度参数，默认值为1080
    parameter IMG_WIDTH  = 1920    // 图像宽度参数，默认值为1920
) (
    input              I_clk,      // 输入时钟信号
    input              I_rst_n,    // 输入复位信号，低电平有效
    input              I_tuser,    // 输入tuser信号，帧起始标志 
    input  wire        I_valid,    // 输入数据有效信号          
    input  wire [32:0] I_data,     // 输入数据总线，宽度为33位  
    output wire        O_valid,    // 输出数据有效信号          
    output wire [32:0] O_data      // 输出数据总线，宽度为33位  
);

    // 定义读使能信号
    wire        rd_en;  // synthesis keep 

    // 定义地址计数器寄存器和数据寄存器
    reg  [10:0] addra;     // 写地址计数器               
    reg  [10:0] addrb;     // 读地址计数器               
    reg  [32:0] data_d0;   // 延时一个时钟的数据         
    reg         valid_d0;  // 延时一个时钟的数据有效信号  

    // 定义局部参数，计算图像宽度的四分之一，用于地址计数
    localparam IMG_WIDTH_4x = (IMG_WIDTH >> 2);

    // 数据和有效信号的寄存，延时一个时钟
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            data_d0  <= 0;            // 复位时将data_d0清零
            valid_d0 <= 0;            // 复位时将valid_d0清零
        end else begin
            data_d0  <= I_data;       // 正常工作时，data_d0跟随I_data
            valid_d0 <= I_valid;      // 正常工作时，valid_d0跟随I_valid
        end
    end

    // 写地址计数器addra的更新
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            addra <= 0;    // 复位或者I_tuser有效时，将addra清零
        end else if (valid_d0) begin
            // 当valid_d0有效时，更新addra
            addra <= (addra == IMG_WIDTH_4x - 1) ? 0 : addra + 1'b1;
            // 如果addra达到最大值（IMG_WIDTH_4x - 1），则清零，否则加1
        end
    end

    // 行结束标志tlast_lock_d0的更新
    reg tlast_lock_d0;
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            tlast_lock_d0 <= 1'b0;  // 复位或者I_tuser有效时，将tlast_lock_d0清零
        end else if ((tlast_lock_d0 == 1'b0) & (addra == IMG_WIDTH_4x - 1)) begin
            tlast_lock_d0 <= 1'b1;  // 当第一次addra达到最大值时，置位tlast_lock_d0
        end
    end

    // 读使能信号rd_en的生成
    assign rd_en = (I_valid && tlast_lock_d0) ? 1'b1 : 1'b0;
    // 只有当I_valid有效且tlast_lock_d0置位后，才产生读使能信号

    // 读地址计数器addrb的更新
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            addrb <= 0;    // 复位或者I_tuser有效时，将addrb清零
        end else begin
            // 当rd_en有效时，更新addrb
            addrb <= rd_en ? ((addrb == IMG_WIDTH_4x - 1) ? 0 : addrb + 1'b1) : addrb;
            // 如果addrb达到最大值（IMG_WIDTH_4x - 1），则清零，否则加1
            // 如果rd_en无效，addrb保持不变
        end
    end

    // 输出有效信号O_valid的生成
    assign O_valid = (valid_d0 && tlast_lock_d0) ? 1'b1 : 1'b0;
    // 只有当valid_d0有效且tlast_lock_d0置位后，才输出有效数据

    // 实例化块存储器，用于数据的存储和读取
    blk_mem_gen_demosaic blk_mem_gen_demosaic_r0 (
        .clka (I_clk  ),   // 写端口时钟信号
        .wea  (valid_d0),  // 写使能信号
        .addra(addra  ),   // 写地址
        .dia (data_d0),   // 写数据
        .clkb (I_clk  ),   // 读端口时钟信号
        .addrb(addrb  ),   // 读地址
        .dob(O_data )    // 读数据输出
    );

endmodule

