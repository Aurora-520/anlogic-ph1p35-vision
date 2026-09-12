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
version:     :   1.0
@Description :   使用BRAM进行FIFO整合，并且不影响下一帧的数据传输
*****************************************************************/


module zhenghe#(
    parameter [12:0] IMG_WIDTH  = 640,
    parameter [12:0] IMG_HEIGHT = 480,
    parameter [8:0]  DATA_WIDTH = 96 ,
    parameter [8:0]  data_complete_delay = 50 //每行BRAM完成数据传输后与这行最后一个数据的距离
) 
(
    input                   I_clk  ,
    input                   I_rst_n,

    input                   I_tlast  ,
    input                   I_tuser  ,
    input [DATA_WIDTH-1:0]  I_tdata  ,
    input                   I_tvalid , 

    output reg              O_tlast  ,
    output reg              O_tuser  ,
    output [DATA_WIDTH-1:0] O_tdata  ,
    output reg              O_tvalid 
);
    reg  [10:0]             addra,addrb;
    reg                     valid_r0,valid_r1;
    reg                     I_tlast_d0,I_tlast_d1;
    reg                     I_tuser_d0,I_tuser_d1;
    reg  [13:0]             y_cnt;
    reg  [20:0]             x_cnt;
    reg  [DATA_WIDTH-1:0]   data_d0;
    wire [DATA_WIDTH-1:0]   data_d;
    localparam   IMG_WIDTH_4x = (IMG_WIDTH>>2);

    wire         flag_valid       ;
    wire [15:0]  rd_valid_width_d0;
    wire [15:0]  rd_valid_width_d1;
    reg          flag_valid_d0    ;
    reg          flag_valid_d1    ;
    reg          flag_valid_first;
    reg  [15:0]  cnt_first;
    reg  [15:0]  valid_width;
    ////为了方便对后续的信号进行合理的处理，在此对部分信号进行打拍操作
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            valid_r0   <= 0;
            valid_r1   <= 0;
            I_tlast_d0 <= 0;
            I_tlast_d1 <= 0;
            data_d0    <= 0;
            I_tuser_d0 <= 0;
            I_tuser_d1 <= 0;
        end else begin
            valid_r0   <= I_tvalid;
            valid_r1   <= valid_r0;
            I_tlast_d0 <= I_tlast;
            I_tlast_d1 <= I_tlast_d0;
            data_d0    <= I_tdata;
            I_tuser_d0 <= I_tuser;
            I_tuser_d1 <= I_tuser_d0;
        end
    end  
    
    ////以每帧的第一行的数据长度作为VALID_WIDTH，为了防止可能的错误，每一帧都更新一次。
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) 
            flag_valid_first <= 0;
        else if(I_tuser )
            flag_valid_first <= 1;
        else if(I_tlast_d0)
            flag_valid_first <= 0;
    end
    
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser_d1) 
            cnt_first <= 0;
        else if(flag_valid_first )
            cnt_first <= cnt_first + 1;
    end

    
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n ) 
            valid_width <= IMG_WIDTH_4x;
        else if(I_tuser && (cnt_first > IMG_WIDTH_4x))
            valid_width <= cnt_first;
    end

    ////计数行数
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser) 
            y_cnt <= 0;
        else if(I_tlast_d0)
            y_cnt <= y_cnt + 1;
    end
    
    //从每行的第一个数据到这行的最后一个数据，flag_valid_d0处于高电平
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) 
            flag_valid_d0 <= 0;
        else if(I_tuser || I_tlast_d1)
            flag_valid_d0 <= 0;
        else if(valid_r1)
            flag_valid_d0 <= 1;
    end
    
    //从每行的最后一个数据到下一行的第一个数据，flag_valid_d1处于高电平
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser ) 
            flag_valid_d1 <= 0;
        else if(I_tlast)
            flag_valid_d1 <= 1;
        else if(I_tvalid)
            flag_valid_d1 <= 0;    
    end

    assign flag_valid        = flag_valid_d0 || flag_valid_d1 ;
    assign rd_valid_width_d0 = valid_width - IMG_WIDTH_4x + data_complete_delay;
    assign rd_valid_width_d1 = valid_width + data_complete_delay + 1;
    
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser) 
            x_cnt <= 0;
        else if(flag_valid)
            x_cnt <= x_cnt + 1;
        else 
            x_cnt <= 0;
    end
    
    assign rd_valid = (x_cnt < rd_valid_width_d1) && (x_cnt > rd_valid_width_d0);
    
    //////A端口
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser) begin
            addra <= 0;
        end 
        else if(valid_r0)begin
            addra <= (addra == IMG_WIDTH_4x -1) ? 'b0 : addra + 1'b1;
        end
    end

    //////B端口
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n || I_tuser) begin
            addrb <= 0;
        end 
        else if(rd_valid)begin
            addrb <= (addrb == IMG_WIDTH_4x -1) ? 'b0 : addrb + 1'b1;
        end
    end
    blk_mem_gen_zhenghe blk_mem_gen_zhenghe_d1 (
      .clka (I_clk   ),  // input wire clka
      .wea  (valid_r0),  // input wire [0 : 0] wea
      .addra(addra   ),  // input wire [10 : 0] addra
      .dia (data_d0 ),  // input wire [95 : 0] dina
      .clkb (I_clk   ),  // input wire clkb
      .addrb(addrb   ),  // input wire [10 : 0] addrb
      .dob(data_d  )   // output wire [95 : 0] doutb
    );
    wire   O_tuser_d,O_tvalid_d,O_tlast_d;
    assign O_tuser_d  = (x_cnt == rd_valid_width_d0 + 1) && (y_cnt == 0);
    assign O_tvalid_d = rd_valid;
    assign O_tdata    = data_d;
    assign O_tlast_d  = (x_cnt == rd_valid_width_d1 - 1) ;


    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            O_tuser  <= 0;
            O_tvalid <= 0;
            O_tlast  <= 0;
        end else begin
            O_tuser  <= O_tuser_d;
            O_tvalid <= O_tvalid_d;
            O_tlast  <= O_tlast_d;
        end
    end  
    
endmodule