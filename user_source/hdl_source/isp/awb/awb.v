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
@Description :   在原基础上删去了一些赘余的代码，并且优化了时序，加入BRAM IP核，
                 让从除法器出来的每一个数据都可以对上相应的像素数据进行增益，使
                 得它的适用行更加广泛了。
*****************************************************************/
module awb  #(   
    parameter IMG_HEIGHT = 1080,   // 图像高度参数，默认值为1080
    parameter IMG_WIDTH  = 1920    // 图像宽度参数，默认值为1920
) 
(
    input                   I_clk  ,    // 输入时钟信号
    input                   I_rst_n,    // 输入复位信号，低电平有效

    input                   I_tlast  ,  // 行结束信号
    input                   I_tuser  ,  // 帧开始信号
    input [95:0]            I_tdata  ,  // 输入数据，总共包含4个像素的RGB值，每个像素24位，4*24=96位
    input                   I_tvalid ,  // 输入数据有效信号
    output                  I_tready ,  // 输入数据准备好信号

    output                  O_tlast  ,  // 输出行结束信号
    output                  O_tuser  ,  // 输出帧开始信号
    output [95:0]           O_tdata  ,  // 输出数据
    output                  O_tvalid ,  // 输出数据有效信号
    input                   O_tready    // 输出数据准备好信号
);

/*****************************************************************
                          RGB565转RGB888（未使用部分）                                        
*****************************************************************/

// //RGB565转RGB888的代码（此部分代码被注释掉，未使用）
// wire [4:0]  rgb565_r   = I_st_data[11+:5];
// wire [5:0]  rgb565_g   = I_st_data[5+:6];
// wire [4:0]  rgb565_b   = I_st_data[0+:5];

// wire [23:0] rgb888     = {{rgb565_r[4:0],rgb565_r[2:0]},{rgb565_g[5:0],rgb565_g[1:0]},{rgb565_b[4:0],rgb565_b[2:0]}};

// wire [7:0]  rgb888_r   = rgb888[16+:8];
// wire [7:0]  rgb888_g   = rgb888[8+:8] ;
// wire [7:0]  rgb888_b   = rgb888[0+:8] ;

/*****************************************************************
                          中间信号                                        
*****************************************************************/

  reg         I_tvalid_r0,I_tvalid_r1;			// 输入有效信号的寄存
  reg  [95:0] I_tdata_d0,I_tdata_d1,I_tdata_d2; // 输入数据的寄存


  // 累加RGB通道的数值，用于计算平均值
  reg  [31:0]         sum_r[0:3];
  reg  [31:0]         sum_g[0:3];
  reg  [31:0]         sum_b[0:3];

  
  wire  [95:0]        data_d0 ;		// 延时后的数据
  wire                valid_d0;     // 延时后的有效信号
  wire                I_tuser_r0;   // 延时后的帧开始信号 
                                    
  reg                 I_tuser_r1;   // 帧开始信号的寄存
                                    
  reg   [95:0]        data_d1 ;     // 再次延时后的数据
  reg                 valid_d1;     // 再次延时后的有效信号

  /*****************************************************************
                            平均值计算                                      
*****************************************************************/

	// 对输入数据和有效信号进行寄存，形成流水线
  always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        I_tdata_d0  <= 0;
        I_tdata_d1  <= 0;
        I_tdata_d2  <= 0;
        {I_tvalid_r0,I_tvalid_r1} <= 0;
    end else begin
        I_tdata_d0  <= I_tdata   ;
        I_tdata_d1  <= I_tdata_d0;
        I_tdata_d2  <= I_tdata_d1;
        I_tvalid_r0 <= I_tvalid;
        I_tvalid_r1 <= I_tvalid_r0;
    end
  end
  
  // 将输入数据拆分为4个像素的RGB分量
    wire [7:0] rgb888_r_d0[0:3];
    wire [7:0] rgb888_g_d0[0:3];
    wire [7:0] rgb888_b_d0[0:3];

    assign  rgb888_r_d0[0] = I_tdata_d0[16+:8];
    assign  rgb888_g_d0[0] = I_tdata_d0[8+:8];
    assign  rgb888_b_d0[0] = I_tdata_d0[0+:8];
  
    assign  rgb888_r_d0[1] = I_tdata_d0[40+:8];
    assign  rgb888_g_d0[1] = I_tdata_d0[32+:8];
    assign  rgb888_b_d0[1] = I_tdata_d0[24+:8];
  
    assign  rgb888_r_d0[2] = I_tdata_d0[64+:8];
    assign  rgb888_g_d0[2] = I_tdata_d0[56+:8];
    assign  rgb888_b_d0[2] = I_tdata_d0[48+:8];
  
    assign  rgb888_r_d0[3] = I_tdata_d0[88+:8];
    assign  rgb888_g_d0[3] = I_tdata_d0[80+:8];
    assign  rgb888_b_d0[3] = I_tdata_d0[72+:8];

// 对每个通道的值进行累加，用于计算平均值
  always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n || I_tuser) begin
	  // 复位或行开始信号有效时，清零累加器
      sum_r[0] <= 0;
      sum_g[0] <= 0;
      sum_b[0] <= 0;

      sum_r[1] <= 0;
      sum_g[1] <= 0;
      sum_b[1] <= 0;

      sum_r[2] <= 0;
      sum_g[2] <= 0;
      sum_b[2] <= 0;

      sum_r[3] <= 0;
      sum_g[3] <= 0;
      sum_b[3] <= 0;
    end else if (I_tvalid_r0) begin
	  // 当输入有效时，累加RGB分量的值
      sum_r[0] <= sum_r[0] + rgb888_r_d0[0];
      sum_g[0] <= sum_g[0] + rgb888_g_d0[0];
      sum_b[0] <= sum_b[0] + rgb888_b_d0[0];

      sum_r[1] <= sum_r[1] + rgb888_r_d0[1];
      sum_g[1] <= sum_g[1] + rgb888_g_d0[1];
      sum_b[1] <= sum_b[1] + rgb888_b_d0[1];

      sum_r[2] <= sum_r[2] + rgb888_r_d0[2];
      sum_g[2] <= sum_g[2] + rgb888_g_d0[2];
      sum_b[2] <= sum_b[2] + rgb888_b_d0[2];

      sum_r[3] <= sum_r[3] + rgb888_r_d0[3];
      sum_g[3] <= sum_g[3] + rgb888_g_d0[3];
      sum_b[3] <= sum_b[3] + rgb888_b_d0[3];
    end
  end



  /*****************************************************************
                           除法运算                                        
*****************************************************************/
  // 定义除法器的输出信号
  wire [47:0] dout_R[3:0];
  wire [47:0] dout_B[3:0];

  wire done[3:0];
  // 提取除法器的输出数据，用于后续增益计算
  wire [47:0] in_r_x1;
  wire [47:0] in_b_x1;
  assign in_r_x1 = dout_R[0][47:0];
  assign in_b_x1 = dout_B[0][47:0];


  wire [47:0] in_r_x2;
  wire [47:0] in_b_x2;
  assign in_r_x2 = dout_R[1][47:0];
  assign in_b_x2 = dout_B[1][47:0];


  wire [47:0] in_r_x3;
  wire [47:0] in_b_x3;
  assign in_r_x3 = dout_R[2][47:0];
  assign in_b_x3 = dout_B[2][47:0];


  wire [47:0] in_r_x4;
  wire [47:0] in_b_x4;
  assign in_r_x4 = dout_R[3][47:0];
  assign in_b_x4 = dout_B[3][47:0];
    

/*****************************************************************
                   IP 调用                                    
*****************************************************************/
    //为了保证合理的延迟，这里使用了除法器

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : div_gen
      divider div_gen_G_R_r1 (
          .clk(I_clk),  					// input wire aclk
          .rst(!I_rst_n),                    
          .start(I_tvalid_r1),              // 输入除数有效信号
          .denominator(sum_r[i]),  			// 输入除数数据，R通道的累加值
          .numerator({sum_g[i],16'd0}),  	// 输入被除数数据，G通道的累加值，扩展16位
          .quotient(dout_R[i]),  			// 输出数据，G/R的比值
          .done(done[i])                    // 输出数据有效信号
      );

      divider divide_G_B_r1 (
          .clk(I_clk),  					// input wire aclk
          .rst(!I_rst_n),                    
          .start(I_tvalid_r1),              // 输入除数有效信号
          .denominator(sum_b[i]),  			// 输入除数数据，R通道的累加值
          .numerator({sum_g[i],16'd0}),  	// 输入被除数数据，G通道的累加值，扩展16位
          .quotient(dout_B[i]),  			// 输出数据，G/R的比值
          .done()                           // 输出数据有效信号
      );
    end
  endgenerate
     
	// 信号延迟模块，用于同步信号，延迟50个时钟周期
    signal_delay #(
        .IMG_HEIGHT   (IMG_HEIGHT),
        .IMG_WIDTH    (IMG_WIDTH ),
        .DATA_WIDTH   (96  ),	// 数据位宽为96位
        .DELAY_CYCLE  (50)      // 延迟50个时钟周期
    )signal_delay_d (           
         .I_clk  (I_clk  ),     // 输入时钟信号
         .I_rst_n(I_rst_n),     // 输入复位信号
         .I_tuser(I_tuser),  	// 输入帧开始信号
         .I_valid(I_tvalid_r1), // 输入数据有效信号
         .I_data (I_tdata_d1 ), // 输入数据
         .O_valid(valid_d0   ), // 输出数据有效信号
         .O_data (data_d0    ), // 输出数据
         .O_tuser(I_tuser_r0 )  // 输出帧开始信号
    );

/*****************************************************************
                            增益计算                                      
*****************************************************************/

    reg  [19:0]   in_r_r1;
    reg  [19:0]   in_b_r1;

    reg  [19:0]   in_r_r2;
    reg  [19:0]   in_b_r2;

    reg  [19:0]   in_r_r3;
    reg  [19:0]   in_b_r3;

    reg  [19:0]   in_r_r4;
    reg  [19:0]   in_b_r4;
	
	// 计算增益，防止增益过大溢出，限制在0xFFFFF
    always @(posedge I_clk or negedge I_rst_n)begin 
        if(!I_rst_n || I_tuser)begin
            in_r_r1 <= 20'h10000;
            in_b_r1 <= 20'h10000;
        end
        else if(done[0])begin
            if(|in_r_x1[47:20])    // 判断高位是否有1，防止溢出
                in_r_r1 <= 20'hfffff;
            else 
                in_r_r1 <= in_r_x1[19:0];
            if(|in_b_x1[47:20])
                in_b_r1 <= 20'hfffff;
            else 
                in_b_r1 <= in_b_x1[19:0];
        end
    end

    always @(posedge I_clk or negedge I_rst_n)begin 
        if(!I_rst_n|| I_tuser)begin
            in_r_r2 <= 20'h10000;
            in_b_r2 <= 20'h10000;
        end
        else if(done[1])begin
            if(|in_r_x2[47:20])
                in_r_r2 <= 20'hfffff;
            else 
                in_r_r2 <= in_r_x2[19:0];
            if(|in_b_x2[47:20])
                in_b_r2 <= 20'hfffff;
            else 
                in_b_r2 <= in_b_x2[19:0];
        end
    end



    always @(posedge I_clk or negedge I_rst_n)begin 
        if(!I_rst_n || I_tuser)begin
            in_r_r3 <= 20'h10000;
            in_b_r3 <= 20'h10000;
        end
        else if(done[2])begin
            if(|in_r_x3[47:20])
                in_r_r3 <= 20'hfffff;
            else 
                in_r_r3 <= in_r_x3[19:0];
            if(|in_b_x3[47:20])
                in_b_r3 <= 20'hfffff;
            else 
                in_b_r3 <= in_b_x3[19:0];
        end
    end




    always @(posedge I_clk or negedge I_rst_n)begin 
        if(!I_rst_n || I_tuser)begin
            in_r_r4 <= 20'h10000;
            in_b_r4 <= 20'h10000;
        end
        else if(done[3])begin
            if(|in_r_x4[47:20])
                in_r_r4 <= 20'hfffff;
            else 
                in_r_r4 <= in_r_x4[19:0];
            if(|in_b_x4[47:20])
                in_b_r4 <= 20'hfffff;
            else 
                in_b_r4 <= in_b_x4[19:0];
        end
    end
    // 信号同步，延迟一级
    always @(posedge I_clk or negedge I_rst_n) begin
      if (!I_rst_n) begin
          valid_d1 <= 0;
          data_d1  <= 0;
          I_tuser_r1 <= 0;
      end else begin
          valid_d1 <= valid_d0;
          data_d1  <= data_d0 ;
          I_tuser_r1 <= I_tuser_r0;
      end
    end
/*****************************************************************
                           像素值计算                                       
*****************************************************************/

    reg [27:0] R_new_r1;
    reg [27:0] G_new_r1;
    reg [27:0] B_new_r1;

    reg [27:0] R_new_r2;
    reg [27:0] G_new_r2;
    reg [27:0] B_new_r2;

    reg [27:0] R_new_r3;
    reg [27:0] G_new_r3;
    reg [27:0] B_new_r3;

    reg [27:0] R_new_r4;
    reg [27:0] G_new_r4;
    reg [27:0] B_new_r4;


    wire   [7:0] rgb888_r_d1[0:3];
    wire   [7:0] rgb888_g_d1[0:3];
    wire   [7:0] rgb888_b_d1[0:3];

    assign  rgb888_r_d1[0] = data_d1[16+:8];
    assign  rgb888_g_d1[0] = data_d1[8+:8];
    assign  rgb888_b_d1[0] = data_d1[0+:8];

    assign  rgb888_r_d1[1] = data_d1[40+:8];
    assign  rgb888_g_d1[1] = data_d1[32+:8];
    assign  rgb888_b_d1[1] = data_d1[24+:8];

    assign  rgb888_r_d1[2] = data_d1[64+:8];
    assign  rgb888_g_d1[2] = data_d1[56+:8];
    assign  rgb888_b_d1[2] = data_d1[48+:8];

    assign  rgb888_r_d1[3] = data_d1[88+:8];
    assign  rgb888_g_d1[3] = data_d1[80+:8];
    assign  rgb888_b_d1[3] = data_d1[72+:8];
	
	// 计算新的RGB值，应用增益
    always @(posedge I_clk or negedge I_rst_n)begin 
        if(!I_rst_n)begin
            R_new_r1 <= 0;
            G_new_r1 <= 0;
            B_new_r1 <= 0;

            R_new_r2 <= 0;
            G_new_r2 <= 0;
            B_new_r2 <= 0;

            R_new_r3 <= 0;
            G_new_r3 <= 0;
            B_new_r3 <= 0;

            R_new_r4 <= 0;
            G_new_r4 <= 0;
            B_new_r4 <= 0;
        end
        else if(valid_d1) begin
            R_new_r1 <= in_r_r1 * rgb888_r_d1[0];
            G_new_r1 <=           rgb888_g_d1[0];
            B_new_r1 <= in_b_r1 * rgb888_b_d1[0];

            R_new_r2 <= in_r_r2 * rgb888_r_d1[1];
            G_new_r2 <=           rgb888_g_d1[1];
            B_new_r2 <= in_b_r2 * rgb888_b_d1[1];

            R_new_r3 <= in_r_r3 * rgb888_r_d1[2];
            G_new_r3 <=           rgb888_g_d1[2];
            B_new_r3 <= in_b_r3 * rgb888_b_d1[2];

            R_new_r4 <= in_r_r4 * rgb888_r_d1[3];
            G_new_r4 <=           rgb888_g_d1[3];
            B_new_r4 <= in_b_r4 * rgb888_b_d1[3];
        end
    end

/*****************************************************************
                            像素值截断                                      
*****************************************************************/

    wire [7:0] R_new_x1;
    wire [7:0] G_new_x1;
    wire [7:0] B_new_x1;

    wire [7:0] R_new_x2;
    wire [7:0] G_new_x2;
    wire [7:0] B_new_x2;

    wire [7:0] R_new_x3;
    wire [7:0] G_new_x3;
    wire [7:0] B_new_x3;

    wire [7:0] R_new_x4;
    wire [7:0] G_new_x4;
    wire [7:0] B_new_x4;
	
	// 对新的像素值进行截断，防止溢出
    assign R_new_x1 = (R_new_r1[27:24])?255:R_new_r1[23:16];
    assign G_new_x1 =  G_new_r1;
    assign B_new_x1 = (B_new_r1[27:24])?255:B_new_r1[23:16];

    assign R_new_x2 = (R_new_r2[27:24])?255:R_new_r2[23:16];
    assign G_new_x2 =  G_new_r2;
    assign B_new_x2 = (B_new_r2[27:24])?255:B_new_r2[23:16];

    assign R_new_x3 = (R_new_r3[27:24])?255:R_new_r3[23:16];
    assign G_new_x3 =  G_new_r3;
    assign B_new_x3 = (B_new_r3[27:24])?255:B_new_r3[23:16];

    assign R_new_x4 = (R_new_r4[27:24])?255:R_new_r4[23:16];
    assign G_new_x4 =  G_new_r4;
    assign B_new_x4 = (B_new_r4[27:24])?255:B_new_r4[23:16];
/*****************************************************************
                           ͬ同步信号                                      
*****************************************************************/

    reg valid_d2,I_tuser_r2;
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n)begin
            valid_d2 <= 0;
            I_tuser_r2 <= 0;
        end
        else begin
            valid_d2 <= valid_d1;
            I_tuser_r2 <= I_tuser_r1;
        end
    end

	// 输出信号的生成
    assign  O_tlast  = (valid_d1 == 0) && (valid_d2 == 1);   // 行结束信号
    assign  O_tuser  = I_tuser_r2 ;                          // 帧开始信号
    assign  O_tvalid = valid_d2;                             // 输出有效信号
	
	// 输出数据，由四个像素的数据拼接而成
    assign  O_tdata = O_tvalid?{R_new_x4,G_new_x4,B_new_x4,
                       R_new_x3,G_new_x3,B_new_x3,
                       R_new_x2,G_new_x2,B_new_x2,
                       R_new_x1,G_new_x1,B_new_x1}:0;
    // assign O_t_data = {R_new[7-:5],G_new[7-:6],B_new[7-:5]};
	// 输入准备好信号，直接连接到输出准备好信号
    assign  I_tready = O_tready;
 
endmodule



