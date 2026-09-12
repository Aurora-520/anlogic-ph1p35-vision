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
@Time        :   2025/01 
version:     :   
@Description :   
*****************************************************************/
module signal_delay #(
    parameter IMG_HEIGHT = 1080,
    parameter IMG_WIDTH  = 1920,
    parameter DATA_WIDTH = 96,
    parameter DELAY_CYCLE = 50
) (
    input                        I_clk,	   // 输入时钟信号
    input                        I_rst_n,  // 输入复位信号，低电平有效
    input                        I_tuser,  // 输入tuser信号，帧起始标志 
    input  wire                  I_valid,  // 输入数据有效信号          
    input  wire [DATA_WIDTH-1:0] I_data,   // 输入数据总线，宽度为33位  
    output wire                  O_valid,  // 输出数据有效信号          
    output wire [DATA_WIDTH-1:0] O_data ,  // 输出数据总线，宽度为33位  
    output wire                  O_tuser   // 输出tuser信号，帧起始标志  
);

    wire        rd_en; 

    reg  [10:0] addra; 
    reg  [10:0] addrb; 


    reg  [13:0] h_cnt;
    reg  [13:0] v_cnt;
    reg  [13:0] rd_cnt;
    
    reg  [DATA_WIDTH-1:0] I_data_r;
    reg         rd_valid,I_valid_r;

    localparam IMG_WIDTH_4x = (IMG_WIDTH >> 2);
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n ) begin
            I_valid_r <= 0;
            I_data_r  <= 0;
        end
        else begin
            I_valid_r <= I_valid;
            I_data_r  <= I_data;
        end
    end
	
	//行列计数器
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end
        else begin
            h_cnt <= I_valid_r ? ((h_cnt == IMG_WIDTH_4x-1) ? 0 : h_cnt + 1) : h_cnt;
            v_cnt <= I_valid_r &&(h_cnt == IMG_WIDTH_4x-1) ? ((v_cnt == IMG_HEIGHT - 1) ? 0 : v_cnt + 1) : v_cnt;
        end
    end
    
	//读有效信号
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            rd_valid <= 0;
        end
        else if(h_cnt == DELAY_CYCLE - 3)begin
            rd_valid <= 1;
        end
        else if(rd_cnt == IMG_WIDTH_4x - 1) //一次都有效开始之后，读IMG_WIDTH_4x个数据即可
            rd_valid <= 0;
    end
	
	 //读数据计数
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            rd_cnt <= 0;
        end
        else if(rd_cnt == IMG_WIDTH_4x )
            rd_cnt <= 0;
        else if(rd_valid)begin
            rd_cnt <= rd_cnt + 1;
        end
    end
	
	//写地址
    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n || I_tuser) begin
            addra <= 0;
        end else if (I_valid_r) begin
            addra <= (addra == IMG_WIDTH_4x - 1) ? 'b0 : addra + 1'b1;
        end
    end

	//读地址
    always @(posedge I_clk or negedge I_rst_n) begin
      if (!I_rst_n || I_tuser) begin
        addrb <= 0;
      end else begin
        addrb <= rd_valid ? (addrb == IMG_WIDTH_4x - 1) ? 'b0 : addrb + 1'b1 : addrb;
      end
    end
    
	//为了和输出的数据O_data同步，进行打拍处理
    reg rd_valid_d;
    always @(posedge I_clk or negedge I_rst_n) begin
      if (!I_rst_n) begin
        rd_valid_d <= 0;
      end else begin
        rd_valid_d <= rd_valid;
      end
    end
    assign O_valid = rd_valid_d;
    assign O_tuser = (v_cnt == 0) && (rd_cnt == 1);

    blk_mem_gen_awb_delay_signal blk_mem_gen_awb_delay_signal_d (
      .clka (I_clk   ),  // input wire clka
      .wea  (I_valid_r),  // input wire [0 : 0] wea
      .addra(addra   ),  // input wire [10 : 0] addra
      .dia  (I_data_r ),  // input wire [95 : 0] dina
      .clkb (I_clk   ),  // input wire clkb
      .addrb(addrb   ),  // input wire [10 : 0] addrb
      .dob  (O_data  )   // output wire [95 : 0] doutb
    );


endmodule