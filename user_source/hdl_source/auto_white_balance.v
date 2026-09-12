

module auto_white_balance (
    input wire       I_clk,
    input wire       I_rst_n,

	input wire[19:0] I_r_gain,
    input wire[19:0] I_g_gain,
    input wire[19:0] I_b_gain,

    input wire       I_rgb888_frame_start,
    input wire       I_rgb888_frame_end,
    input wire       I_rgb888_valid,
    input wire[95:0] I_rgb888_data,

    output reg       O_awb_frame_start,
    output reg       O_awb_frame_end,
    output reg       O_awb_valid,
    output reg[95:0] O_awb_data
);


    reg        S_rgb888_valid_1d;
    reg        S_rgb888_valid_2d;

    wire[7:0]  S_r_data_p0;  
    wire[7:0]  S_g_data_p0;
    wire[7:0]  S_b_data_p0;
    wire[7:0]  S_r_data_p1;
    wire[7:0]  S_g_data_p1;
    wire[7:0]  S_b_data_p1;
    wire[7:0]  S_r_data_p2;
    wire[7:0]  S_g_data_p2;
    wire[7:0]  S_b_data_p2;
    wire[7:0]  S_r_data_p3;
    wire[7:0]  S_g_data_p3;
    wire[7:0]  S_b_data_p3;

    reg[27:0]  S_awb_r_data_p0;  ///fi(0,28,12)
    reg[27:0]  S_awb_g_data_p0;  ///fi(0,28,12)
    reg[27:0]  S_awb_b_data_p0;  ///fi(0,28,12)
    reg[27:0]  S_awb_r_data_p1;  ///fi(0,28,12)
    reg[27:0]  S_awb_g_data_p1;  ///fi(0,28,12)
    reg[27:0]  S_awb_b_data_p1;  ///fi(0,28,12)
    reg[27:0]  S_awb_r_data_p2;  ///fi(0,28,12)
    reg[27:0]  S_awb_g_data_p2;  ///fi(0,28,12)
    reg[27:0]  S_awb_b_data_p2;  ///fi(0,28,12)
    reg[27:0]  S_awb_r_data_p3;  ///fi(0,28,12)
    reg[27:0]  S_awb_g_data_p3;  ///fi(0,28,12)
    reg[27:0]  S_awb_b_data_p3;  ///fi(0,28,12)

    reg[7:0]   S_awb_r_data_p0_limit;   
    reg[7:0]   S_awb_g_data_p0_limit;  
    reg[7:0]   S_awb_b_data_p0_limit;  
    reg[7:0]   S_awb_r_data_p1_limit;  
    reg[7:0]   S_awb_g_data_p1_limit;  
    reg[7:0]   S_awb_b_data_p1_limit;  
    reg[7:0]   S_awb_r_data_p2_limit;  
    reg[7:0]   S_awb_g_data_p2_limit;  
    reg[7:0]   S_awb_b_data_p2_limit;  
    reg[7:0]   S_awb_r_data_p3_limit;  
    reg[7:0]   S_awb_g_data_p3_limit;  
    reg[7:0]   S_awb_b_data_p3_limit;  

    assign S_r_data_p0 = I_rgb888_data[95:88];
    assign S_g_data_p0 = I_rgb888_data[87:80];
    assign S_b_data_p0 = I_rgb888_data[79:72];

    assign S_r_data_p1 = I_rgb888_data[71:64];
    assign S_g_data_p1 = I_rgb888_data[63:56];
    assign S_b_data_p1 = I_rgb888_data[55:48];

    assign S_r_data_p2 = I_rgb888_data[47:40];
    assign S_g_data_p2 = I_rgb888_data[39:32];
    assign S_b_data_p2 = I_rgb888_data[31:24];

    assign S_r_data_p3 = I_rgb888_data[23:16];
    assign S_g_data_p3 = I_rgb888_data[15:8];
    assign S_b_data_p3 = I_rgb888_data[7:0];


	always @(posedge I_clk) begin
        if(I_rgb888_valid)
            begin
                S_awb_r_data_p0 <= S_r_data_p0 * I_r_gain; 
                S_awb_g_data_p0 <= S_g_data_p0 * I_g_gain;
                S_awb_b_data_p0 <= S_b_data_p0 * I_b_gain;

                S_awb_r_data_p1 <= S_r_data_p1 * I_r_gain;
                S_awb_g_data_p1 <= S_g_data_p1 * I_g_gain;
                S_awb_b_data_p1 <= S_b_data_p1 * I_b_gain;

                S_awb_r_data_p2 <= S_r_data_p2 * I_r_gain;
                S_awb_g_data_p2 <= S_g_data_p2 * I_g_gain;
                S_awb_b_data_p2 <= S_b_data_p2 * I_b_gain;

                S_awb_r_data_p3 <= S_r_data_p3 * I_r_gain;
                S_awb_g_data_p3 <= S_g_data_p3 * I_g_gain;
                S_awb_b_data_p3 <= S_b_data_p3 * I_b_gain;
            end
        else
            begin
                S_awb_r_data_p0 <= 'd0; 
                S_awb_g_data_p0 <= 'd0;
                S_awb_b_data_p0 <= 'd0;

                S_awb_r_data_p1 <= 'd0;
                S_awb_g_data_p1 <= 'd0;
                S_awb_b_data_p1 <= 'd0;

                S_awb_r_data_p2 <= 'd0;
                S_awb_g_data_p2 <= 'd0;
                S_awb_b_data_p2 <= 'd0;

                S_awb_r_data_p3 <= 'd0;
                S_awb_g_data_p3 <= 'd0;
                S_awb_b_data_p3 <= 'd0;
            end
    end


    always @(posedge I_clk) begin
        S_awb_r_data_p0_limit <= (S_awb_r_data_p0[27:12] >= 16'd255) ? 8'd255 : S_awb_r_data_p0[19:12]; 
        S_awb_g_data_p0_limit <= (S_awb_g_data_p0[27:12] >= 16'd255) ? 8'd255 : S_awb_g_data_p0[19:12]; 
        S_awb_b_data_p0_limit <= (S_awb_b_data_p0[27:12] >= 16'd255) ? 8'd255 : S_awb_b_data_p0[19:12]; 

        S_awb_r_data_p1_limit <= (S_awb_r_data_p1[27:12] >= 16'd255) ? 8'd255 : S_awb_r_data_p1[19:12]; 
        S_awb_g_data_p1_limit <= (S_awb_g_data_p1[27:12] >= 16'd255) ? 8'd255 : S_awb_g_data_p1[19:12]; 
        S_awb_b_data_p1_limit <= (S_awb_b_data_p1[27:12] >= 16'd255) ? 8'd255 : S_awb_b_data_p1[19:12]; 

        S_awb_r_data_p2_limit <= (S_awb_r_data_p2[27:12] >= 16'd255) ? 8'd255 : S_awb_r_data_p2[19:12]; 
        S_awb_g_data_p2_limit <= (S_awb_g_data_p2[27:12] >= 16'd255) ? 8'd255 : S_awb_g_data_p2[19:12]; 
        S_awb_b_data_p2_limit <= (S_awb_b_data_p2[27:12] >= 16'd255) ? 8'd255 : S_awb_b_data_p2[19:12]; 

        S_awb_r_data_p3_limit <= (S_awb_r_data_p3[27:12] >= 16'd255) ? 8'd255 : S_awb_r_data_p3[19:12]; 
        S_awb_g_data_p3_limit <= (S_awb_g_data_p3[27:12] >= 16'd255) ? 8'd255 : S_awb_g_data_p3[19:12]; 
        S_awb_b_data_p3_limit <= (S_awb_b_data_p3[27:12] >= 16'd255) ? 8'd255 : S_awb_b_data_p3[19:12]; 
    end

    always @(posedge I_clk) begin
        S_rgb888_valid_1d <= I_rgb888_valid;
        S_rgb888_valid_2d <= S_rgb888_valid_1d;
        O_awb_valid       <= S_rgb888_valid_2d;

        O_awb_frame_start <= I_rgb888_frame_start;
        O_awb_frame_end   <= I_rgb888_frame_end;

        O_awb_data        <= {S_awb_r_data_p0_limit,S_awb_g_data_p0_limit,S_awb_b_data_p0_limit,
                              S_awb_r_data_p1_limit,S_awb_g_data_p1_limit,S_awb_b_data_p1_limit,
                              S_awb_r_data_p2_limit,S_awb_g_data_p2_limit,S_awb_b_data_p2_limit,
                              S_awb_r_data_p3_limit,S_awb_g_data_p3_limit,S_awb_b_data_p3_limit};
    end


//    always @(posedge I_clk) begin
//        if(I_rgb888_frame_start)
//            begin
//                O_awb_data <= 'd0;
//            end
//        else if(S_rgb888_valid_2d)
//            begin
//                O_awb_data[23:0]  <= O_awb_data[23:0]  + 'd1;
//                O_awb_data[47:24] <= O_awb_data[47:24] + 'd1;
//                O_awb_data[71:48] <= O_awb_data[71:48] + 'd1;
//                O_awb_data[95:72] <= O_awb_data[95:72] + 'd1;
//            end
//        else
//            begin
//                O_awb_data <= O_awb_data;
//            end
//    end
    
endmodule