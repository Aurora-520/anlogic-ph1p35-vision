


module video_cutting (
    input wire       I_clk,
    input wire       I_rst_n,

    input wire       I_raw8_frame_start,
    input wire       I_raw8_frame_end,
    input wire       I_raw8_valid,
    input wire[31:0] I_raw8_data,

    output reg       O_raw8_frame_start,
    output reg       O_raw8_frame_end,
    output reg       O_raw8_valid,
    output reg[31:0] O_raw8_data
);


    reg[11:0] S_col_cnt;
    reg[11:0] S_line_cnt;
    reg       S_raw8_valid_1d;
    wire      S_raw8_valid_n_edge;
    reg       S_line_en;

    always @(posedge I_clk) begin
        S_raw8_valid_1d <= I_raw8_valid;
    end

    assign S_raw8_valid_n_edge = ~I_raw8_valid & S_raw8_valid_1d;


    always @(posedge I_clk) begin
        if(I_raw8_valid)
            S_col_cnt <= S_col_cnt + 'd1;
        else
            S_col_cnt <= 'd0;
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n)
            S_line_cnt <= 'd0;
        else
            if(I_raw8_frame_start)
                S_line_cnt <= 'd0;
            else if(S_raw8_valid_n_edge)
                S_line_cnt <= S_line_cnt + 'd1;
            else
                S_line_cnt <= S_line_cnt;
    end


    always @(posedge I_clk) begin
        if(S_line_cnt >= 'd126 && S_line_cnt <= 'd727)
            S_line_en <= 1'b1;
        else
            S_line_en <= 1'b0;
    end

    always @(posedge I_clk) begin
        if(I_raw8_valid && S_col_cnt >= 'd100 && S_col_cnt <= 'd357 && S_line_en)
            begin
                O_raw8_valid <= 1'b1;
                O_raw8_data  <= I_raw8_data;
            end
        else    
            begin
                O_raw8_valid <= 1'b0;
                O_raw8_data  <= 'd0;
            end
    end

    always @(posedge I_clk) begin
        O_raw8_frame_start <= I_raw8_frame_start;
        O_raw8_frame_end   <= I_raw8_frame_end;
    end
//  cwc2 cwc2_inst
//(
//    .probe0(I_raw8_frame_start),
//    .probe1(I_raw8_frame_end),
//    .probe2(I_raw8_valid),
//    .probe3(I_raw8_data),
//    .probe4(O_raw8_frame_start),
//    .probe5(O_raw8_frame_end),
//    .probe6(O_raw8_valid),
//    .probe7(O_raw8_data),
//    .probe8(S_col_cnt),
//    .probe9(S_line_cnt),
//    .probe10(S_raw8_valid_1d),
//    .probe11(S_raw8_valid_n_edge),
//    .probe12(S_line_en),
//    .clk(I_clk)
//);
    
endmodule