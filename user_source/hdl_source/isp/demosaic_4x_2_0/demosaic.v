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
version:     :   1.1
@Description :   该模块主要是用于3x3矩阵的形成，以及对图像边界像素的处理
                 在原基础上优化了时序，把原来的一些未完全对齐的信号进行对齐。
*****************************************************************/

module demosaic #(
    parameter IMG_HEIGHT          = 1080,  // 图像高度
    parameter IMG_WIDTH           = 1920,   // 图像宽度
    parameter data_complete_delay = 50  ,
    parameter BAYER_MODE          = "BGGR"
)
(
    input           I_clk   ,   // 时钟信号
    input           I_rst_n ,   // 复位信号，低有效

    input [39:0]            axi4s_video_tdata ,  // AXI4-Stream视频数据
    input [9:0]             axi4s_video_tdest ,
    input                   axi4s_video_tlast ,  // 行结束信号
    input                   axi4s_video_tvalid,  // 数据有效信号
    input                   axi4s_video_tuser ,  // 帧开始信号
    output                  axi4s_video_tready,  // 从模块准备好接受数据

    output                  O_tlast  ,  // 输出行结束信号
    output                  O_tuser  ,  // 输出帧开始信号
    output [127:0]          O_tdata  ,  // 输出数据
    output                  O_tvalid ,  // 输出数据有效信号
    input                   O_tready    // 输出数据准备好信号
);


wire demosaic_tlast ; 
wire demosaic_tuser ; 
wire demosaic_tvalid; 
wire demosaic_tready; 

wire        bayer_ypos      ;
wire [95:0] matrix_last_line;
wire [95:0] matrix_cur_line ;
wire [95:0] matrix_next_line;

raw_matrix_3x3_buffer #(
    .IMG_HEIGHT         (IMG_HEIGHT         ),  // 图像高度
    .IMG_WIDTH          (IMG_WIDTH          ),   // 图像宽度
    .data_complete_delay(data_complete_delay)
)raw_matrix_3x3_buffer_d
(
    /*input           */.I_clk    (I_clk   ),   // 时钟信号
    /*input           */.I_rst_n  (I_rst_n ),   // 复位信号，低有效

   /*input [39:0]    */.axi4s_video_tdata (axi4s_video_tdata ),  // AXI4-Stream视频数据
   /*input [9:0]     */.axi4s_video_tdest (axi4s_video_tdest ),
   /*input           */.axi4s_video_tlast (axi4s_video_tlast ),  // 行结束信号
   /*input           */.axi4s_video_tvalid(axi4s_video_tvalid),  // 数据有效信号
   /*input           */.axi4s_video_tuser (axi4s_video_tuser ),  // 帧开始信号
   /*output          */.axi4s_video_tready(axi4s_video_tready),  // 从模块准备好接受数据

   /*output          */.O_tlast         (demosaic_tlast ),   // 行结束信号输出
   /*output          */.O_tuser         (demosaic_tuser ),   // 帧开始信号输出
   /*output          */.O_tvalid        (demosaic_tvalid),   // 数据有效信号输出
   /*input           */.O_tready        (demosaic_tready),   // 上一级模块准备好接受数据

   /*output          */.bayer_ypos      (bayer_ypos      ),   // Bayer滤波器行位置
   /*output  [95:0]  */.matrix_last_line(matrix_last_line),   // 上一行3x3矩阵数据
   /*output  [95:0]  */.matrix_cur_line (matrix_cur_line ),   // 当前行3x3矩阵数据
   /*output  [95:0]  */.matrix_next_line(matrix_next_line)    // 下一行3x3矩阵数据
);

bilinear_interpolation #(
    .BAYER_MODE (BAYER_MODE)
)bilinear_interpolation_d(
    /*input            */.I_clk            (I_clk   ),
    /*input            */.I_rst_n          (I_rst_n ),

    /*//input
    /*input            */.I_tlast      (demosaic_tlast )    ,
    /*input            */.I_tuser      (demosaic_tuser )    ,
    /*input            */.I_tvalid     (demosaic_tvalid)    ,
    /*output           */.I_tready     (demosaic_tready)    ,
  
    /*input            */.bayer_ypos       (bayer_ypos       ),
    /*input   [95:0]   */.matrix_last_line (matrix_last_line ),
    /*input   [95:0]   */.matrix_cur_line  (matrix_cur_line  ),
    /*input   [95:0]   */.matrix_next_line (matrix_next_line ),
  
    /*//output
    /*output           */.O_tlast (O_tlast ),
    /*output           */.O_tuser (O_tuser ),
    /*output [127 : 0] */.O_tdata (O_tdata ),
    /*output           */.O_tvalid(O_tvalid),
    /*input            */.O_tready(O_tready)

);



endmodule