`timescale 1ns / 1ns //仿真时间刻度/精度

module hdmi_tx (
    input wire       I_pixel_clk, //像素时钟
    input wire       I_serial_clk,//串行发送时钟
    input wire       I_rst, //异步复位信号，高电平有效

    input wire       I_key_in,
    
    input wire       I_edid_read_trig,//EDID读触发信号
    output wire      O_edid_read_valid,//EDID读有效信号
    output wire[7:0] O_edid_read_data,//EDID读数据
///**********************  video rgb input  *****************************  
    input wire       I_video_rgb_enable,  //是否使能RGB输入接口，设置1使能，否则采用stream video时序接口
    input wire       I_video_in_de, //RGB 输入de有效
    input wire       I_video_in_vs, //RGB 输入VS 帧同步 
///**********************  video stream input  ***************************
    input wire       I_video_in_user,  //视频输入帧起始信号
    input wire       I_video_in_valid, //视频输入有效信号
    input wire       I_video_in_last,  //视频输入行结束信号
    output wire      O_video_in_ready, //视频输入ready信号
    input wire[23:0] I_video_in_data,  //视频输入数据
///*********************  audio stream input  ***************************
    input wire       I_audio_valid,     //音频输入有效信号
    input wire[23:0] I_audio_left_data, //音频左声道数据
    input wire[23:0] I_audio_right_data,//音频左声道数据
    
    input wire       I_i2s_BCLK,
    input wire       I_i2s_LRCK,
    input wire       I_i2s_DOUT,

    output wire      O_ddc_scl,
    inout wire       IO_ddc_sda,

    output           O_hdmi_clk_p, //HDMI输出时钟P端
    output    [2:0]  O_hdmi_tx_p,  //HDMI输出数据P端
    
    output wire      O_tmds_ch0_p, //HDMI数据通道0
    output wire      O_tmds_ch1_p, //HDMI数据通道1
    output wire      O_tmds_ch2_p, //HDMI数据通道2
    output wire      O_tmds_clk_p  //HDMI时钟通道
);

    wire       S_pll_lock;
    wire       S_rst;

    wire[9:0]  S_ch0_tmds_data; //synthesis keep; 
    wire[9:0]  S_ch1_tmds_data; //synthesis keep; 
    wire[9:0]  S_ch2_tmds_data; //synthesis keep; 
    wire[9:0]  S_clk_tmds_data; //synthesis keep; 

    wire       S_acr_valid; //synthesis keep; 
    wire[19:0] S_acr_cts;   //synthesis keep; 
    wire[19:0] S_acr_n;     //synthesis keep; 
    wire       S_i2s_audio_valid;
    wire[23:0] S_i2s_audio_left_data;
    wire[23:0] S_i2s_audio_right_data;
    wire       S_key_edid_read_trig;

//**********************  video stream input  ***************************
//如果是输入RGB时序，那么转为stream时序，否则仅对信号打一个节拍
    reg       I_video_in_de_r1;
    reg       I_video_in_vs_r1;
    reg       I_video_in_user_r1,I_video_in_user_r2;
    reg       I_video_in_valid_r1,I_video_in_valid_r2;
    reg       I_video_in_last_r2;
    reg[23:0] I_video_in_data_r1,I_video_in_data_r2;
    reg       O_video_in_ready_r;
    reg       vs_start;
  
    always @(posedge I_pixel_clk)begin
    	I_video_in_de_r1 <= I_video_in_de;
    	I_video_in_vs_r1 <= I_video_in_vs;
    end
      
    always @(posedge I_pixel_clk or posedge I_rst )begin
    	if(I_rst)begin
        	I_video_in_last_r2  <= 1'b0;
            I_video_in_valid_r1 <= 1'b0;
            I_video_in_data_r1  <= 24'd0;
            I_video_in_user_r1  <= 1'b0;
            I_video_in_valid_r2 <= 1'b0;
            I_video_in_data_r2  <= 24'd0;
            I_video_in_user_r2  <= 1'b0;
        end    
    	else if(I_video_rgb_enable == 1'b1)begin
        	I_video_in_last_r2  <= ~I_video_in_de & I_video_in_de_r1; //产生stream video last 延迟于数据输入2拍
            I_video_in_valid_r1 <= I_video_in_de;//I_video_in_valid延迟1拍
            I_video_in_data_r1  <= I_video_in_data;//I_video_in_data延迟1拍
            I_video_in_user_r1  <= ~I_video_in_user_r1 & vs_start & I_video_in_de;//I_video_in_user延迟1拍
            
            I_video_in_valid_r2 <= I_video_in_valid_r1;//I_video_in_valid对输入信号延迟2拍，以和I_video_in_last_r2信号配套同步
            I_video_in_data_r2  <= I_video_in_data_r1; //I_video_in_data 对输入信号延迟2拍，以和I_video_in_last_r2信号配套同步
            I_video_in_user_r2  <= I_video_in_user_r1; //I_video_in_user 对输入信号延迟2拍，以和I_video_in_last_r2信号配套同步 
        end     
        else begin
        	I_video_in_last_r2  <= I_video_in_last; //I_video_in_last对输入信号直接寄存1次
            I_video_in_valid_r2 <= I_video_in_valid;//I_video_in_valid对输入信号直接寄存1次
            I_video_in_data_r2  <= I_video_in_data;//I_video_in_data对输入信号直接寄存1次
            I_video_in_user_r2  <= I_video_in_user;//I_video_in_user对输入信号直接寄存1次      
        end 
    end
    
    always @(posedge I_pixel_clk or posedge I_rst )begin
    	if(I_rst)
        	vs_start <= 1'b0;
    	else if(I_video_in_user_r1)//清除VS帧同步
        	vs_start <= 1'b0;
        else if(I_video_in_vs && I_video_in_vs_r1==1'b0)//当I_video_in_vs发生上升沿跳变代表一帧开始
            vs_start <= 1'b1;
    end    

    I2S_receiver u_I2S_receiver(
        .I_clk              ( I_pixel_clk        ),
        .I_rst              ( I_rst              ),
  
        .I_i2s_BCLK         ( I_i2s_BCLK         ),
        .I_i2s_LRCK         ( I_i2s_LRCK         ),
        .I_i2s_DOUT         ( I_i2s_DOUT         ),
  
        .O_audio_valid      ( S_i2s_audio_valid      ),
        .O_audio_left_data  ( S_i2s_audio_left_data  ),
        .O_audio_right_data ( S_i2s_audio_right_data )
    );


    audio_arc_calculate#(
        .ACR_N         ( 6144 )
    )u_audio_arc_calculate(
        .I_clk         ( I_pixel_clk    ),
        .I_rst         ( I_rst          ),

        .I_audio_valid ( I_audio_valid  ),

        .O_acr_valid   ( S_acr_valid    ),
        .O_acr_cts     ( S_acr_cts      ),
        .O_acr_n       ( S_acr_n        )
    );


    key_remove_shakes u_key_remove_shakes(
        .I_clk          ( I_pixel_clk ),
        .I_rst_n        ( S_pll_lock  ),
        .I_key_in       ( I_key_in    ),
        .O_key_trig_out ( S_key_edid_read_trig )
    );



//   video_source_test#(
//        .HTOTAL        ( 2200 ),
//        .HACTIVE       ( 1920 ),
//        .HFP           ( 88   ),
//        .HSA           ( 44   ),
//        .HBP           ( 148  ),
//        .VTOTAL        ( 1125 ),
//        .VACTIVE       ( 1080 ),
//        .VFP           ( 4    ),
//        .VSA           ( 5    ),
//        .VBP           ( 36   )
//    )U_video_source_test(
//        .I_clk         ( I_pixel_clk    ),
//        .I_rst         ( I_rst          ),

//        .I_tpg_trig_en ( 1'b1           ),

//        .O_video_user  ( I_video_in_user  ),
//        .O_video_valid ( I_video_in_valid ),
//        .O_video_last  ( I_video_in_last  ),
//        .O_video_data  ( I_video_in_data  ),
//        .I_video_ready ( O_video_in_ready )
//    );


    hdmi_1_4b_transmitter_core_wrapper#(
        .DEVICE                 ( "PH1P"   ),

				.HTOTAL                 ( 1650     ),
		.HSA                    ( 40       ),
		.HFP                    ( 110      ),
		.HBP                    ( 220      ),
		.HACTIVE                ( 1280     ),
		.VTOTAL                 ( 750      ),
		.VSA                    ( 5        ),
		.VFP                    ( 5        ),
		.VBP                    ( 20       ),
		.VACTIVE                ( 720      ),

				.VIDEO_VIC              ( 4        ),

        .VIDEO_TPG              ( "Disable" ),
        .VIDEO_FORMAT           ( "RGB"    ),

        .AUDIO_SAMPLE_RATE      ( "48K"    ),
        
        .IIC_SCL_DIV            ( 125      )
    )u_hdmi_1_4b_transmitter_core_wrapper(
        .I_pixel_clk        ( I_pixel_clk        ),
        .I_rst              ( I_rst              ),

        .I_edid_read_trig   ( I_edid_read_trig   ),
        .O_edid_read_valid  ( O_edid_read_valid  ),
        .O_edid_read_data   ( O_edid_read_data   ),

        .I_axis_s_user      ( I_video_in_user_r2      ),
        .I_axis_s_valid     ( I_video_in_valid_r2     ),
        .I_axis_s_last      ( I_video_in_last_r2      ),
        .I_axis_s_data      ( I_video_in_data_r2      ),
        .O_axis_s_ready     ( O_video_in_ready     ),

        .I_audio_valid      ( I_audio_valid      ),
        .I_audio_left_data  ( I_audio_left_data  ),
        .I_audio_right_data ( I_audio_right_data ),

        .I_acr_valid        ( S_acr_valid        ),
        .I_acr_cts          ( S_acr_cts          ),
        .I_acr_n            ( S_acr_n            ),

        .O_video_locked     ( ),

        .O_ddc_scl          ( O_ddc_scl          ),
        .IO_ddc_sda         ( IO_ddc_sda         ),

        .O_ch0_tmds_data    ( S_ch0_tmds_data    ),
        .O_ch1_tmds_data    ( S_ch1_tmds_data    ),
        .O_ch2_tmds_data    ( S_ch2_tmds_data    ),
        .O_clk_tmds_data    ( S_clk_tmds_data    )
    );


    hdmi_phy_wrapper  #(
        .DEVICE ( "PH1P" )  //"EF2","EF3","EF4","SF1","EG","PH1A","PH1P","DR1"
    )u_hdmi2phy_wrapper(
        .I_pixel_clk        ( I_pixel_clk     ),
        .I_serial_clk       ( I_serial_clk    ),
        .I_rst              ( I_rst           ),

        .I_tmds_channel_0   ( S_ch0_tmds_data ),
        .I_tmds_channel_1   ( S_ch1_tmds_data ),
        .I_tmds_channel_2   ( S_ch2_tmds_data ),
        .I_tmds_channel_clk ( S_clk_tmds_data ),

        .O_tmds_ch0_p       ( O_tmds_ch0_p    ),
        .O_tmds_ch1_p       ( O_tmds_ch1_p    ),
        .O_tmds_ch2_p       ( O_tmds_ch2_p    ),
        .O_tmds_clk_p       ( O_tmds_clk_p    )
    );


endmodule
