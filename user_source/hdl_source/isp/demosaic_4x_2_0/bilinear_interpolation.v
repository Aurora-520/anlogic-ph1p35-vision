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
@Time        :   2025/8 
version:     :   2.0
@Description :   由于RGGB和GBRG的Bayer格式中的三元操作符的条件判断分支是颠倒的，
                 导致在需要插值的地方使用了原始值，在有原始值的地方进行了错误的
                 平均，现在重写修改了此处，让其正确的去进行平均。
*****************************************************************/


module bilinear_interpolation #(
    parameter BAYER_MODE = "BGGR"
)(
    input             I_clk            ,
    input             I_rst_n          ,

    //input
    input             I_tlast          ,
    input             I_tuser          ,
    input             I_tvalid         ,
    output            I_tready         ,
  
    input             bayer_ypos       ,
    input   [95:0]    matrix_last_line ,
    input   [95:0]    matrix_cur_line  ,
    input   [95:0]    matrix_next_line ,
  
    //output
    output            O_tlast         ,
    output            O_tuser         ,
    output [127 : 0]  O_tdata         ,
    output            O_tvalid        ,
    input             O_tready

);

/*********************************************************
                  function 声明
*********************************************************/
// calculate the data's bit width
function integer clog2b(
    input integer depth
);
    begin
        for(clog2b=0; depth>0; clog2b=clog2b+1)begin
            depth = depth >> 1;
        end
    end    
endfunction

/*********************************************************
                      RAW格式
*********************************************************/
// bayer mode 
////bayer格式
localparam RGGB = "RGGB";
localparam BGGR = "BGGR";
localparam GBRG = "GBRG";
localparam GRBG = "GRBG";



/*********************************************************
                       reg 信号声明
*********************************************************/
reg         bayer_ypos_r0,  bayer_ypos_r1;

reg [9:0]   r0_matrix_plus, g0_matrix_plus, b0_matrix_plus ;
reg [9:0]   r1_matrix_plus, g1_matrix_plus, b1_matrix_plus ;
reg [9:0]   r2_matrix_plus, g2_matrix_plus, b2_matrix_plus ;
reg [9:0]   r3_matrix_plus, g3_matrix_plus, b3_matrix_plus ;
// -----------------------------------------------------------------

reg [8:0]   r0_sum_part0, r0_sum_part1 ;
reg [8:0]   r1_sum_part0, r1_sum_part1 ;
reg [8:0]   r2_sum_part0, r2_sum_part1 ;
reg [8:0]   r3_sum_part0, r3_sum_part1 ;

reg [8:0]   g0_sum_part0, g0_sum_part1 ;
reg [8:0]   g1_sum_part0, g1_sum_part1 ;
reg [8:0]   g2_sum_part0, g2_sum_part1 ;
reg [8:0]   g3_sum_part0, g3_sum_part1 ;

reg [8:0]   b0_sum_part0, b0_sum_part1 ;
reg [8:0]   b1_sum_part0, b1_sum_part1 ;
reg [8:0]   b2_sum_part0, b2_sum_part1 ;
reg [8:0]   b3_sum_part0, b3_sum_part1 ;

// -----------------------------------------------------------------
reg [8:0]   r0_mean, g0_mean, b0_mean ;
reg [8:0]   r1_mean, g1_mean, b1_mean ;
reg [8:0]   r2_mean, g2_mean, b2_mean ;
reg [8:0]   r3_mean, g3_mean, b3_mean ;
// -----------------------------------------------------------------
reg [31:0] rgb_data0 ;
reg [31:0] rgb_data1 ;
reg [31:0] rgb_data2 ;
reg [31:0] rgb_data3 ;

reg   [4:0]   I_tlast_r ;
reg   [4:0]   I_tuser_r ;
reg   [4:0]   I_tvalid_r;
/*********************************************************
                    wire 信号声明
*********************************************************/

// bayer format BGGR 
wire    [7:0]   matrix03, matrix04, matrix05, matrix06, matrix07, matrix08 ;
wire    [7:0]   matrix13, matrix14, matrix15, matrix16, matrix17, matrix18 ;
wire    [7:0]   matrix23, matrix24, matrix25, matrix26, matrix27, matrix28 ;


wire    [127:0] rgb_data;
wire            rgb_data_valid ;
/*********************************************************
                        信号描述
*********************************************************/
assign {matrix03, matrix04, matrix05, matrix06, matrix07, matrix08} = matrix_last_line[71:24];
assign {matrix13, matrix14, matrix15, matrix16, matrix17, matrix18} = matrix_cur_line[71:24];
assign {matrix23, matrix24, matrix25, matrix26, matrix27, matrix28} = matrix_next_line[71:24];



/*********************************************************
                        信号延迟
*********************************************************/
// pipleline 0
always @(posedge I_clk or negedge I_rst_n) begin
    if(!I_rst_n) begin 
        bayer_ypos_r0 <= 'b0 ;
        bayer_ypos_r1 <= 'b0 ;
    end
    else begin
        bayer_ypos_r0 <= bayer_ypos ;
        bayer_ypos_r1 <= bayer_ypos_r0 ;
    end
end

/*****************************************************************
                        BAYER_MODE_BGGR                                        
*****************************************************************/

////////////////////////////////////////////
//
//              双线性插值算法
//
////////////////////////////////////////////
// mipi ov5640 raw
generate if(BAYER_MODE == BGGR) begin : BAYER_MODE_BGGR
    // R Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_sum_part0, r0_sum_part1} <= 'd0 ; 
            r1_sum_part0  <= 'd0 ; 
            {r2_sum_part0, r2_sum_part1}  <= 'd0 ; 
            r3_sum_part0  <= 'd0 ; 
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                r0_sum_part0 <= matrix13 + matrix15 ;
                r0_sum_part1 <= 'd0 ;
        
                r1_sum_part0 <= matrix15 ;
        
                r2_sum_part0 <= matrix15 + matrix17 ;
                r2_sum_part1 <= 'd0 ;
        
                r3_sum_part0 <= matrix17 ;
            end
            else begin
                r0_sum_part0 <= matrix03 + matrix05 ;
                r0_sum_part1 <= matrix23 + matrix25 ;

                r1_sum_part0 <= matrix05 + matrix25 ;

                r2_sum_part0 <= matrix05 + matrix07 ;
                r2_sum_part1 <= matrix25 + matrix27 ;

                r3_sum_part0 <= matrix07 + matrix27 ;
            end
        end
    end

// G Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {g0_sum_part0, g0_sum_part1} <= 'b0 ;
            {g1_sum_part0, g1_sum_part1} <= 'b0 ;
            {g2_sum_part0, g2_sum_part1} <= 'b0 ;
            {g3_sum_part0, g3_sum_part1} <= 'b0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                g0_sum_part0 <= matrix14 ;
                g0_sum_part1 <= 'd0 ;

                g1_sum_part0 <= matrix05 + matrix25 ;
                g1_sum_part1 <= matrix14 + matrix16 ;

                g2_sum_part0 <= matrix16;
                g2_sum_part1 <= 'd0 ;

                g3_sum_part0 <= matrix07 + matrix27 ; 
                g3_sum_part1 <= matrix16 + matrix18 ;
            end
            else begin
                g0_sum_part0 <= matrix04 + matrix24 ;
                g0_sum_part1 <= matrix13 + matrix15 ;

                g1_sum_part0 <= matrix15 ;
                g1_sum_part1 <= 'd0 ;

                g2_sum_part0 <= matrix06 + matrix26 ;
                g2_sum_part1 <= matrix15 + matrix17 ;

                g3_sum_part0 <= matrix17 ; 
                g3_sum_part1 <= 'd0 ;
            end
        end
    end
//B Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            b0_sum_part0 <= 'd0 ;
            {b1_sum_part0, b1_sum_part1} <= 'd0 ;
            b2_sum_part0 <= 'd0 ;
            {b3_sum_part0, b3_sum_part1} <= 'd0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                b0_sum_part0 <= matrix04 + matrix24 ;

                b1_sum_part0 <= matrix04 + matrix06 ;
                b1_sum_part1 <= matrix24 + matrix26 ;

                b2_sum_part0 <= matrix06 + matrix26 ;

                b3_sum_part0 <= matrix06 + matrix08 ;
                b3_sum_part1 <= matrix26 + matrix28 ;
            end
            else begin
                b0_sum_part0 <= matrix14 ;

                b1_sum_part0 <= matrix14 + matrix16 ;
                b1_sum_part1 <= 'd0 ;

                b2_sum_part0 <= matrix16 ;

                b3_sum_part0 <= matrix16 + matrix18 ;
                b3_sum_part1 <= 'd0 ;
            end
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_matrix_plus, g0_matrix_plus, b0_matrix_plus} <= 'd0 ;
            {r1_matrix_plus, g1_matrix_plus, b1_matrix_plus} <= 'd0 ;
            {r2_matrix_plus, g2_matrix_plus, b2_matrix_plus} <= 'd0 ;
            {r3_matrix_plus, g3_matrix_plus, b3_matrix_plus} <= 'd0 ;
        end
        else if(I_tvalid_r[0])begin
            r0_matrix_plus <= r0_sum_part0 + r0_sum_part1 ;
            r1_matrix_plus <= r1_sum_part0 ;
            r2_matrix_plus <= r2_sum_part0 + r2_sum_part1 ;
            r3_matrix_plus <= r3_sum_part0 ;

            g0_matrix_plus <= g0_sum_part0 + g0_sum_part1 ;
            g1_matrix_plus <= g1_sum_part0 + g1_sum_part1 ;
            g2_matrix_plus <= g2_sum_part0 + g2_sum_part1 ;
            g3_matrix_plus <= g3_sum_part0 + g3_sum_part1 ;

            b0_matrix_plus <= b0_sum_part0 ;
            b1_matrix_plus <= b1_sum_part0 + b1_sum_part1 ;
            b2_matrix_plus <= b2_sum_part0 ;
            b3_matrix_plus <= b3_sum_part0 + b3_sum_part1 ;
        end
    end


    // pipleline 1
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_mean, g0_mean, b0_mean} <= 'd0 ;
            {r1_mean, g1_mean, b1_mean} <= 'd0 ;
            {r2_mean, g2_mean, b2_mean} <= 'd0 ;
            {r3_mean, g3_mean, b3_mean} <= 'd0 ;
        end
        else if(I_tvalid_r[1]) begin
            r0_mean <= bayer_ypos_r1 ? r0_matrix_plus >> 1 : r0_matrix_plus >> 2 ;
            g0_mean <= bayer_ypos_r1 ? g0_matrix_plus      : g0_matrix_plus >> 2 ;
            b0_mean <= bayer_ypos_r1 ? b0_matrix_plus >> 1 : b0_matrix_plus      ;

            r1_mean <= bayer_ypos_r1 ? r1_matrix_plus      : r1_matrix_plus >> 1 ;
            g1_mean <= bayer_ypos_r1 ? g1_matrix_plus >> 2 : g1_matrix_plus ;
            b1_mean <= bayer_ypos_r1 ? b1_matrix_plus >> 2 : b1_matrix_plus >> 1 ;

            r2_mean <= bayer_ypos_r1 ? r2_matrix_plus >> 1 : r2_matrix_plus >> 2;
            g2_mean <= bayer_ypos_r1 ? g2_matrix_plus      : g2_matrix_plus >> 2;   
            b2_mean <= bayer_ypos_r1 ? b2_matrix_plus >> 1 : b2_matrix_plus ;

            r3_mean <= bayer_ypos_r1 ? r3_matrix_plus      : r3_matrix_plus >> 1 ;
            g3_mean <= bayer_ypos_r1 ? g3_matrix_plus >> 2 : g3_matrix_plus ;
            b3_mean <= bayer_ypos_r1 ? b3_matrix_plus >> 2 : b3_matrix_plus >> 1 ;
        end
    end
end


/*****************************************************************
                        BAYER_MODE_GBRG                                             
*****************************************************************/



    else if(BAYER_MODE == GBRG)
    begin:BAYER_MODE_GBRG

    // R Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_sum_part0, r0_sum_part1} <= 'd0 ; 
            {r1_sum_part0, r1_sum_part1}  <= 'd0 ; 
            r2_sum_part0  <= 'd0 ; 
            {r3_sum_part0, r3_sum_part1}  <= 'd0 ; 
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                r0_sum_part0 <= matrix14 ;
                r0_sum_part1 <= 'd0;

                r1_sum_part0 <= matrix14 + matrix16;
                r1_sum_part1 <= 'd0;

                r2_sum_part0 <= matrix16;

                r3_sum_part0 <= matrix16 + matrix18 ;
                r3_sum_part1 <= 'd0;
            end
            else begin
                r0_sum_part0 <= 'd0;
                r0_sum_part1 <= matrix04 + matrix24;

                r1_sum_part0 <= matrix04 + matrix06 ;
                r1_sum_part1 <= matrix24 + matrix26 ;

                r2_sum_part0 <= matrix06 + matrix26 ;

                r3_sum_part0 <= matrix06 + matrix26 ;
                r3_sum_part1 <= matrix08 + matrix28 ;
            end
        end
    end
// G Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {g0_sum_part0, g0_sum_part1} <= 'b0 ;
            {g1_sum_part0, g1_sum_part1} <= 'b0 ;
            {g2_sum_part0, g2_sum_part1} <= 'b0 ;
            {g3_sum_part0, g3_sum_part1} <= 'b0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                g0_sum_part0 <= matrix04 + matrix24;
                g0_sum_part1 <= matrix13 + matrix15;

                g1_sum_part0 <= matrix15;
                g1_sum_part1 <= 'd0 ;

                g2_sum_part0 <= matrix06 + matrix26 ;
                g2_sum_part1 <= matrix15 + matrix17 ;

                g3_sum_part0 <= matrix17  ; 
                g3_sum_part1 <= 'd0 ;
            end
            else begin
                g0_sum_part0 <= matrix14 ;
                g0_sum_part1 <= 'd0;

                g1_sum_part0 <= matrix05 + matrix25;
                g1_sum_part1 <= matrix14 + matrix16;

                g2_sum_part0 <= matrix16 ;
                g2_sum_part1 <= 'd0;

                g3_sum_part0 <= matrix07 + matrix27; 
                g3_sum_part1 <= matrix16 + matrix18;
            end
        end
    end
//B Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {b0_sum_part0, b0_sum_part1} <= 'd0 ;
            {b1_sum_part0, b1_sum_part1} <= 'd0 ;
            {b2_sum_part0, b2_sum_part1} <= 'd0 ;
            {b3_sum_part0, b3_sum_part1} <= 'd0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                b0_sum_part0 <= matrix03 + matrix23 ;//????
                b0_sum_part1 <= matrix05 + matrix25 ;//????

                b1_sum_part0 <= 'd0;//????
                b1_sum_part1 <= matrix05 + matrix25 ;

                b2_sum_part0 <= matrix05 + matrix25 ;
                b2_sum_part1 <= matrix07 + matrix27 ;

                b3_sum_part0 <= 'd0 ;//????
                b3_sum_part1 <= matrix07 + matrix27 ;
            end
            else begin
                b0_sum_part0 <= matrix13 + matrix15 ;
                b0_sum_part1 <= 'd0;

                b1_sum_part0 <= matrix15 ;
                b1_sum_part1 <= 'd0 ;

                b2_sum_part0 <= matrix15 +  matrix17;
                b2_sum_part1 <= 'd0;

                b3_sum_part0 <= matrix17 ;
                b3_sum_part1 <= 'd0 ;
            end
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_matrix_plus, g0_matrix_plus, b0_matrix_plus} <= 'd0 ;
            {r1_matrix_plus, g1_matrix_plus, b1_matrix_plus} <= 'd0 ;
            {r2_matrix_plus, g2_matrix_plus, b2_matrix_plus} <= 'd0 ;
            {r3_matrix_plus, g3_matrix_plus, b3_matrix_plus} <= 'd0 ;
        end
        else if(I_tvalid_r[0])begin
            r0_matrix_plus <= r0_sum_part0 + r0_sum_part1 ;
            r1_matrix_plus <= r1_sum_part0 + r1_sum_part1 ;
            r2_matrix_plus <= r2_sum_part0   ;
            r3_matrix_plus <= r3_sum_part0 + r3_sum_part1 ;

            g0_matrix_plus <= g0_sum_part0 + g0_sum_part1 ;
            g1_matrix_plus <= g1_sum_part0 + g1_sum_part1 ;
            g2_matrix_plus <= g2_sum_part0 + g2_sum_part1 ;
            g3_matrix_plus <= g3_sum_part0 + g3_sum_part1 ;

            b0_matrix_plus <= b0_sum_part0 + b0_sum_part1 ;
            b1_matrix_plus <= b1_sum_part0 + b1_sum_part1 ;
            b2_matrix_plus <= b2_sum_part0 + b2_sum_part1 ;
            b3_matrix_plus <= b3_sum_part0 + b3_sum_part1 ;
        end
    end


    // pipleline 1
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_mean, g0_mean, b0_mean} <= 'd0 ;
            {r1_mean, g1_mean, b1_mean} <= 'd0 ;
            {r2_mean, g2_mean, b2_mean} <= 'd0 ;
            {r3_mean, g3_mean, b3_mean} <= 'd0 ;
        end
        else if(I_tvalid_r[1])begin
            r0_mean <= bayer_ypos_r1    ? r0_matrix_plus      : r0_matrix_plus >> 1 ;
            g0_mean <= (!bayer_ypos_r1) ? g0_matrix_plus      : g0_matrix_plus >> 2 ;
            b0_mean <= bayer_ypos_r1    ? b0_matrix_plus >> 2 : b0_matrix_plus >> 1 ;

            r1_mean <= bayer_ypos_r1    ? r1_matrix_plus >> 1 : r1_matrix_plus >> 2 ;
            g1_mean <= (!bayer_ypos_r1) ? g1_matrix_plus >> 2 : g1_matrix_plus      ;
            b1_mean <= bayer_ypos_r1 ? b1_matrix_plus >> 1 : b1_matrix_plus      ;

            r2_mean <= bayer_ypos_r1    ? r2_matrix_plus      : r2_matrix_plus >> 1 ;
            g2_mean <= (!bayer_ypos_r1) ? g2_matrix_plus      : g2_matrix_plus >> 2 ;   
            b2_mean <= bayer_ypos_r1    ? b2_matrix_plus >> 2 : b2_matrix_plus >> 1 ;

            r3_mean <= bayer_ypos_r1    ? r3_matrix_plus >> 1 : r3_matrix_plus >> 2 ;
            g3_mean <= (!bayer_ypos_r1) ? g3_matrix_plus >> 2 : g3_matrix_plus      ;
            b3_mean <= bayer_ypos_r1    ? b3_matrix_plus >> 1 : b3_matrix_plus      ;
        end
    end
end

/*****************************************************************
                       BAYER_MODE_RGGB                             
*****************************************************************/

    else if(BAYER_MODE == RGGB)
    begin:BAYER_MODE_RGGB

    // R Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_sum_part0, r0_sum_part1} <= 'd0 ; 
            {r1_sum_part0, r1_sum_part1}  <= 'd0 ; 
            r2_sum_part0  <= 'd0 ; 
            {r3_sum_part0, r3_sum_part1}  <= 'd0 ; 
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                r0_sum_part0 <= matrix04 + matrix24;//
                r0_sum_part1 <= 'd0;

                r1_sum_part0 <= matrix04 + matrix24;
                r1_sum_part1 <= matrix06 + matrix26;

                r2_sum_part0 <= matrix06 + matrix26;

                r3_sum_part0 <= matrix06 + matrix26;
                r3_sum_part1 <= matrix08 + matrix28;
            end
            else begin
                r0_sum_part0 <= matrix14;
                r0_sum_part1 <= 'd0;

                r1_sum_part0 <= matrix14 + matrix16;
                r1_sum_part1 <= 'd0;

                r2_sum_part0 <= matrix16  ;

                r3_sum_part0 <= matrix16 + matrix18 ;
                r3_sum_part1 <= 'd0 ;
            end
        end
    end
// G Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {g0_sum_part0, g0_sum_part1} <= 'b0 ;
            {g1_sum_part0, g1_sum_part1} <= 'b0 ;
            {g2_sum_part0, g2_sum_part1} <= 'b0 ;
            {g3_sum_part0, g3_sum_part1} <= 'b0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                g0_sum_part0 <= matrix14 ;
                g0_sum_part1 <= 'd0;

                g1_sum_part0 <= matrix05 + matrix25;
                g1_sum_part1 <= matrix14 + matrix16;

                g2_sum_part0 <= matrix16 ;
                g2_sum_part1 <= 'd0;

                g3_sum_part0 <= matrix07 + matrix27; 
                g3_sum_part1 <= matrix16 + matrix18;
            end
            else begin
                g0_sum_part0 <= matrix04 + matrix24;
                g0_sum_part1 <= matrix13 + matrix15;

                g1_sum_part0 <= matrix15;
                g1_sum_part1 <= 'd0 ;

                g2_sum_part0 <= matrix06 + matrix26 ;
                g2_sum_part1 <= matrix15 + matrix17 ;

                g3_sum_part0 <= matrix17  ; 
                g3_sum_part1 <= 'd0 ;
            end
        end
    end
//B Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {b0_sum_part0, b0_sum_part1} <= 'd0 ;
            {b1_sum_part0, b1_sum_part1} <= 'd0 ;
            {b2_sum_part0, b2_sum_part1} <= 'd0 ;
            {b3_sum_part0, b3_sum_part1} <= 'd0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                b0_sum_part0 <= matrix13 + matrix15 ;
                b0_sum_part1 <= 'd0;

                b1_sum_part0 <= matrix15 ;
                b1_sum_part1 <= 'd0 ;

                b2_sum_part0 <= matrix15 +  matrix17;
                b2_sum_part1 <= 'd0;

                b3_sum_part0 <= matrix17 ;
                b3_sum_part1 <= 'd0 ;
            end
            else begin
                b0_sum_part0 <= matrix03 + matrix23 ;//????
                b0_sum_part1 <= matrix05 + matrix25 ;//????

                b1_sum_part0 <= 'd0;//????
                b1_sum_part1 <= matrix05 + matrix25 ;

                b2_sum_part0 <= matrix05 + matrix25 ;
                b2_sum_part1 <= matrix07 + matrix27 ;

                b3_sum_part0 <= 'd0 ;//????
                b3_sum_part1 <= matrix07 + matrix27 ;
            end
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_matrix_plus, g0_matrix_plus, b0_matrix_plus} <= 'd0 ;
            {r1_matrix_plus, g1_matrix_plus, b1_matrix_plus} <= 'd0 ;
            {r2_matrix_plus, g2_matrix_plus, b2_matrix_plus} <= 'd0 ;
            {r3_matrix_plus, g3_matrix_plus, b3_matrix_plus} <= 'd0 ;
        end
        else if(I_tvalid_r[0])begin
            r0_matrix_plus <= r0_sum_part0 + r0_sum_part1 ;
            r1_matrix_plus <= r1_sum_part0 + r1_sum_part1 ;
            r2_matrix_plus <= r2_sum_part0   ;
            r3_matrix_plus <= r3_sum_part0 + r3_sum_part1 ;

            g0_matrix_plus <= g0_sum_part0 + g0_sum_part1 ;
            g1_matrix_plus <= g1_sum_part0 + g1_sum_part1 ;
            g2_matrix_plus <= g2_sum_part0 + g2_sum_part1 ;
            g3_matrix_plus <= g3_sum_part0 + g3_sum_part1 ;

            b0_matrix_plus <= b0_sum_part0 + b0_sum_part1 ;
            b1_matrix_plus <= b1_sum_part0 + b1_sum_part1 ;
            b2_matrix_plus <= b2_sum_part0 + b2_sum_part1 ;
            b3_matrix_plus <= b3_sum_part0 + b3_sum_part1 ;
        end
    end


    // pipleline 1
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_mean, g0_mean, b0_mean} <= 'd0 ;
            {r1_mean, g1_mean, b1_mean} <= 'd0 ;
            {r2_mean, g2_mean, b2_mean} <= 'd0 ;
            {r3_mean, g3_mean, b3_mean} <= 'd0 ;
        end
        else if(I_tvalid_r[1])begin
            r0_mean <= (!bayer_ypos_r1) ? r0_matrix_plus      : r0_matrix_plus >> 1 ;
            g0_mean <= bayer_ypos_r1    ? g0_matrix_plus      : g0_matrix_plus >> 2 ;
            b0_mean <= (!bayer_ypos_r1) ? b0_matrix_plus >> 2 : b0_matrix_plus >> 1 ;

            r1_mean <= (!bayer_ypos_r1) ? r1_matrix_plus >> 1 : r1_matrix_plus >> 2 ;
            g1_mean <= bayer_ypos_r1    ? g1_matrix_plus >> 2 : g1_matrix_plus      ;
            b1_mean <= (!bayer_ypos_r1) ? b1_matrix_plus >> 1 : b1_matrix_plus      ;

            r2_mean <= (!bayer_ypos_r1) ? r2_matrix_plus      : r2_matrix_plus >> 1 ;
            g2_mean <= bayer_ypos_r1    ? g2_matrix_plus      : g2_matrix_plus >> 2 ;   
            b2_mean <= (!bayer_ypos_r1) ? b2_matrix_plus >> 2 : b2_matrix_plus >> 1 ;

            r3_mean <= (!bayer_ypos_r1) ? r3_matrix_plus >> 1 : r3_matrix_plus >> 2 ;
            g3_mean <= bayer_ypos_r1    ? g3_matrix_plus >> 2 : g3_matrix_plus      ;
            b3_mean <= (!bayer_ypos_r1) ? b3_matrix_plus >> 1 : b3_matrix_plus      ;
        end
    end
end


/*****************************************************************
                       BAYER_MODE_GRBG                             
*****************************************************************/


    else if(BAYER_MODE == GRBG)
    begin:BAYER_MODE_GRBG

    // R Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_sum_part0, r0_sum_part1} <= 'd0 ; 
            {r1_sum_part0, r1_sum_part1}  <= 'd0 ; 
            {r2_sum_part0, r2_sum_part1} <= 'd0 ; 
            {r3_sum_part0, r3_sum_part1}  <= 'd0 ; 
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                r0_sum_part0 <= matrix03 + matrix05 ;
                r0_sum_part1 <= matrix23 + matrix25 ;

                r1_sum_part0 <= matrix05 + matrix25 ;
                r1_sum_part1 <= 'd0;

                r2_sum_part0 <= matrix05 + matrix07 ;
                r2_sum_part1 <= matrix25 + matrix27 ;

                r3_sum_part0 <= matrix07 + matrix27 ;       
                r3_sum_part1 <= 'd0 ;                                                                 
            end
            else begin
                r0_sum_part0 <= matrix13 + matrix15 ;
                r0_sum_part1 <= 'd0 ;

                r1_sum_part0 <= matrix15 ;
                r1_sum_part1 <= 'd0;

                r2_sum_part0 <= matrix15 + matrix17 ;
                r2_sum_part1 <= 'd0 ;

                r3_sum_part0 <= matrix17 ;
                r3_sum_part1 <= 'd0 ;  
            end
        end
    end
// G Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {g0_sum_part0, g0_sum_part1} <= 'b0 ;
            {g1_sum_part0, g1_sum_part1} <= 'b0 ;
            {g2_sum_part0, g2_sum_part1} <= 'b0 ;
            {g3_sum_part0, g3_sum_part1} <= 'b0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                g0_sum_part0 <= matrix04 + matrix24;
                g0_sum_part1 <= matrix13 + matrix15;

                g1_sum_part0 <= matrix15;
                g1_sum_part1 <= 'd0 ;

                g2_sum_part0 <= matrix06 + matrix26 ;
                g2_sum_part1 <= matrix15 + matrix17 ;

                g3_sum_part0 <= matrix17  ; 
                g3_sum_part1 <= 'd0 ;
            end
            else begin
                g0_sum_part0 <= matrix14 ;
                g0_sum_part1 <= 'd0;

                g1_sum_part0 <= matrix05 + matrix25;
                g1_sum_part1 <= matrix14 + matrix16;

                g2_sum_part0 <= matrix16 ;
                g2_sum_part1 <= 'd0;

                g3_sum_part0 <= matrix07 + matrix27; 
                g3_sum_part1 <= matrix16 + matrix18;
            end
        end
    end
//B Channel
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {b0_sum_part0, b0_sum_part1} <= 'd0 ;
            {b1_sum_part0, b1_sum_part1} <= 'd0 ;
            {b2_sum_part0, b2_sum_part1} <= 'd0 ;
            {b3_sum_part0, b3_sum_part1} <= 'd0 ;
        end
        else if(I_tvalid)begin
            if(bayer_ypos) begin
                b0_sum_part0 <= matrix14 ;
                b0_sum_part1 <= 'd0;

                b1_sum_part0 <= matrix14 + matrix16 ;
                b1_sum_part1 <= 'd0 ;

                b2_sum_part0 <= matrix16 ;
                b2_sum_part1 <= 'd0;

                b3_sum_part0 <= matrix16 + matrix18 ;
                b3_sum_part1 <= 'd0 ;
            end
            else begin
                b0_sum_part0 <= matrix04 + matrix24 ;
                b0_sum_part1 <= 'd0;

                b1_sum_part0 <= matrix04 + matrix06 ;
                b1_sum_part1 <= matrix24 + matrix26 ;

                b2_sum_part0 <= matrix06 + matrix26 ;
                b2_sum_part1 <= 'd0;

                b3_sum_part0 <= matrix06 + matrix08 ;
                b3_sum_part1 <= matrix26 + matrix28 ;
            end
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_matrix_plus, g0_matrix_plus, b0_matrix_plus} <= 'd0 ;
            {r1_matrix_plus, g1_matrix_plus, b1_matrix_plus} <= 'd0 ;
            {r2_matrix_plus, g2_matrix_plus, b2_matrix_plus} <= 'd0 ;
            {r3_matrix_plus, g3_matrix_plus, b3_matrix_plus} <= 'd0 ;
        end
        else if(I_tvalid_r[0])begin
            r0_matrix_plus <= r0_sum_part0 + r0_sum_part1 ;
            r1_matrix_plus <= r1_sum_part0 + r1_sum_part1 ;
            r2_matrix_plus <= r2_sum_part0 + r2_sum_part1 ;
            r3_matrix_plus <= r3_sum_part0 + r3_sum_part1 ;

            g0_matrix_plus <= g0_sum_part0 + g0_sum_part1 ;
            g1_matrix_plus <= g1_sum_part0 + g1_sum_part1 ;
            g2_matrix_plus <= g2_sum_part0 + g2_sum_part1 ;
            g3_matrix_plus <= g3_sum_part0 + g3_sum_part1 ;

            b0_matrix_plus <= b0_sum_part0 + b0_sum_part1 ;
            b1_matrix_plus <= b1_sum_part0 + b1_sum_part1 ;
            b2_matrix_plus <= b2_sum_part0 + b2_sum_part1 ;
            b3_matrix_plus <= b3_sum_part0 + b3_sum_part1 ;
        end
    end


    // pipleline 1
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_mean, g0_mean, b0_mean} <= 'd0 ;
            {r1_mean, g1_mean, b1_mean} <= 'd0 ;
            {r2_mean, g2_mean, b2_mean} <= 'd0 ;
            {r3_mean, g3_mean, b3_mean} <= 'd0 ;
        end
        else if(I_tvalid_r[1])begin
            r0_mean <= (!bayer_ypos_r1) ? r0_matrix_plus >> 1 : r0_matrix_plus >> 2 ;
            g0_mean <= (!bayer_ypos_r1) ? g0_matrix_plus      : g0_matrix_plus >> 2 ;
            b0_mean <= (!bayer_ypos_r1) ? b0_matrix_plus >> 1 : b0_matrix_plus      ;

            r1_mean <= (!bayer_ypos_r1) ? r1_matrix_plus      : r1_matrix_plus >> 1 ;
            g1_mean <= (!bayer_ypos_r1) ? g1_matrix_plus >> 2 : g1_matrix_plus      ;
            b1_mean <= (!bayer_ypos_r1) ? b1_matrix_plus >> 2 : b1_matrix_plus >> 1 ;

            r2_mean <= (!bayer_ypos_r1) ? r2_matrix_plus >> 1 : r2_matrix_plus >> 2 ;
            g2_mean <= (!bayer_ypos_r1) ? g2_matrix_plus      : g2_matrix_plus >> 2 ;      
            b2_mean <= (!bayer_ypos_r1) ? b2_matrix_plus >> 1 : b2_matrix_plus      ;

            r3_mean <= (!bayer_ypos_r1) ? r3_matrix_plus      : r3_matrix_plus >> 1 ;
            g3_mean <= (!bayer_ypos_r1) ? g3_matrix_plus >> 2 : g3_matrix_plus      ;
            b3_mean <= (!bayer_ypos_r1) ? b3_matrix_plus >> 2 : b3_matrix_plus >> 1 ;
        end
    end
end

endgenerate 
    


    reg [7:0] r0_mean_d,r1_mean_d,r2_mean_d,r3_mean_d;
    reg [7:0] g0_mean_d,g1_mean_d,g2_mean_d,g3_mean_d;
    reg [7:0] b0_mean_d,b1_mean_d,b2_mean_d,b3_mean_d;
    // pipleline 2
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            {r0_mean_d,r1_mean_d,r2_mean_d,r3_mean_d} <= 'd0 ;
            {g0_mean_d,g1_mean_d,g2_mean_d,g3_mean_d} <= 'd0 ;
            {b0_mean_d,b1_mean_d,b2_mean_d,b3_mean_d} <= 'd0 ;
        end
        else if(I_tvalid_r[2])begin
            r0_mean_d <= r0_mean[8]?255:r0_mean[7:0];
            g0_mean_d <= g0_mean[8]?255:g0_mean[7:0];
            b0_mean_d <= b0_mean[8]?255:b0_mean[7:0];

            r1_mean_d <= r1_mean[8]?255:r1_mean[7:0];
            g1_mean_d <= g1_mean[8]?255:g1_mean[7:0];
            b1_mean_d <= b1_mean[8]?255:b1_mean[7:0];

            r2_mean_d <= r2_mean[8]?255:r2_mean[7:0];
            g2_mean_d <= g2_mean[8]?255:g2_mean[7:0];
            b2_mean_d <= b2_mean[8]?255:b2_mean[7:0];

            r3_mean_d <= r3_mean[8]?255:r3_mean[7:0];
            g3_mean_d <= g3_mean[8]?255:g3_mean[7:0];
            b3_mean_d <= b3_mean[8]?255:b3_mean[7:0];
        end
    end

    // pipleline 3
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            rgb_data0 <= 'd0 ;
            rgb_data1 <= 'd0 ;
            rgb_data2 <= 'd0 ;
            rgb_data3 <= 'd0 ;
        end
        else if(I_tvalid_r[3])begin
            rgb_data0 <= {8'b0, r0_mean_d, g0_mean_d, b0_mean_d};
            rgb_data1 <= {8'b0, r1_mean_d, g1_mean_d, b1_mean_d};
            rgb_data2 <= {8'b0, r2_mean_d, g2_mean_d, b2_mean_d};
            rgb_data3 <= {8'b0, r3_mean_d, g3_mean_d, b3_mean_d};
        end
    end

    assign rgb_data = {rgb_data3, rgb_data2, rgb_data1, rgb_data0};
/*****************************************************************
                          信号同步                                        
*****************************************************************/

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n)
            {I_tlast_r,I_tuser_r,I_tvalid_r} <= 0;
        else begin
            I_tlast_r  <= {I_tlast_r[3:0],I_tlast};
            I_tuser_r  <= {I_tuser_r[3:0],I_tuser};
            I_tvalid_r <= {I_tvalid_r[3:0],I_tvalid};
        end
    end

    assign  O_tlast  = I_tlast_r[4];   
    assign  O_tuser  = I_tuser_r[4];   
    assign  O_tvalid = I_tvalid_r[4];

    
    assign O_tdata  = rgb_data;
    assign I_tready = O_tready;

endmodule