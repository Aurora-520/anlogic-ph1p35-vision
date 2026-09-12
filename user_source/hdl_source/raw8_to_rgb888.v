

module raw8_to_rgb888 (
    input wire        I_clk,
    input wire        I_rst_n,

    input wire        I_raw8_frame_start,
    input wire        I_raw8_frame_end,
    input wire        I_raw8_valid,     
    input wire[31:0]  I_raw8_data,      

    output reg        O_rgb888_frame_start,
    output reg        O_rgb888_frame_end,
    output reg        O_rgb888_valid,
    output reg[95:0]  O_rgb888_data
);


     reg[11:0]  S_line_cnt;
     reg        S_raw8_valid_1d;
	 reg        S_raw8_valid_2d;
     reg[31:0]  S_raw8_data_1d;
	 reg[31:0]  S_raw8_data_2d;
     wire       S_raw8_line_end;
     reg        S_raw8_line_end_1d;
     reg        S_raw8_line_end_2d;
     wire[31:0] S_shift_0_data; 
	 reg[31:0]  S_shift_0_data_1d;
     wire[31:0] S_shift_1_data; 
     reg        S_conv_valid;
     reg[31:0]  S_conv_data_1;
     reg[31:0]  S_conv_data_2;
     reg[31:0]  S_conv_data_3;
     reg        S_conv_en;
     reg        S_conv_line_odd_even;
     reg        S_conv_valid_1d;
     reg[31:0]  S_conv_data_1_1d;
     reg[31:0]  S_conv_data_2_1d;
     reg[31:0]  S_conv_data_3_1d;
     reg        S_conv_valid_2d;
     reg[31:0]  S_conv_data_1_2d;
     reg[31:0]  S_conv_data_2_2d;
     reg[31:0]  S_conv_data_3_2d;
     reg        S_conv_cal_valid;
     reg        S_conv_cal_valid_1d;
     reg[31:0]  S_conv_cal_data_1_1;
     reg[31:0]  S_conv_cal_data_1_2;
     reg[31:0]  S_conv_cal_data_1_3;
     reg[31:0]  S_conv_cal_data_2_1;
     reg[31:0]  S_conv_cal_data_2_2;
     reg[31:0]  S_conv_cal_data_2_3;
     reg[31:0]  S_conv_cal_data_3_1;
     reg[31:0]  S_conv_cal_data_3_2;
     reg[31:0]  S_conv_cal_data_3_3;
     reg[9:0]   S_r_data_p0;
     reg[9:0]   S_g_data_p0;
     reg[9:0]   S_b_data_p0;
     reg[9:0]   S_r_data_p1;
     reg[9:0]   S_g_data_p1;
     reg[9:0]   S_b_data_p1;
     reg[9:0]   S_r_data_p2;
     reg[9:0]   S_g_data_p2;
     reg[9:0]   S_b_data_p2;
     reg[9:0]   S_r_data_p3;
     reg[9:0]   S_g_data_p3;
     reg[9:0]   S_b_data_p3;

     always @(posedge I_clk) begin
         O_rgb888_frame_start <= I_raw8_frame_start;
         O_rgb888_frame_end   <= I_raw8_frame_end;
         S_raw8_valid_1d      <= I_raw8_valid;
		 S_raw8_valid_2d      <= S_raw8_valid_1d;
         S_raw8_data_1d       <= I_raw8_data;
		 S_raw8_data_2d       <= S_raw8_data_1d;

		 S_shift_0_data_1d    <= S_shift_0_data;
     end

     assign S_raw8_line_end = ~I_raw8_valid & S_raw8_valid_1d;

     always @(posedge I_clk) begin
         S_raw8_line_end_1d <= S_raw8_line_end;
         S_raw8_line_end_2d <= S_raw8_line_end_1d;
     end

     always @(posedge I_clk or negedge I_rst_n) begin
         if(!I_rst_n)
             S_line_cnt <= 'd0;
         else
             if(I_raw8_frame_start)
                 S_line_cnt <= 'd0;
             else if(S_raw8_line_end_2d)
                 S_line_cnt <= S_line_cnt + 'd1;
             else
                 S_line_cnt <= S_line_cnt;
     end


    //   w32_d962_shifter U0_w32_d962_shifter(
    //       .clk     ( I_clk          ),
    //       .en      ( I_raw8_valid   ),
    //       .datain  ( I_raw8_data    ),
    //       .dataout ( S_shift_0_data )
    //   );

    PH1P_LOGIC_SHIFTER#(
        .DATA_WIDTH ( 32     ),
        .DATA_DEPTH ( 258    ),
        .INIT_FILE  ( "NONE" ),
        .SHIFT_TYPE ( "FIXED"))
    U0_w32_d962_shifter(
        .clk     ( I_clk          ),

        .en      ( I_raw8_valid   ),
        .depth   ( 1'b0           ),
        .datain  ( I_raw8_data    ),

        .dataout ( S_shift_0_data )
    );


    PH1P_LOGIC_SHIFTER#(
        .DATA_WIDTH ( 32     ),
        .DATA_DEPTH ( 258    ),
        .INIT_FILE  ( "NONE" ),
        .SHIFT_TYPE ( "FIXED"))
    U1_w32_d962_shifter(
        .clk     ( I_clk          ),

        .en      ( I_raw8_valid   ),
        .depth   ( 1'b0           ),
        .datain  ( S_shift_0_data ),

        .dataout ( S_shift_1_data )
    );

     always @(posedge I_clk) begin
         if(S_line_cnt >= 'd2)
             S_conv_en <= 1'b1;
         else
             S_conv_en <= 1'b0;
     end

     always @(posedge I_clk) begin
         if(S_conv_en)
             if(S_raw8_line_end_2d)
                 S_conv_line_odd_even <= ~S_conv_line_odd_even;
             else
                 S_conv_line_odd_even <= S_conv_line_odd_even;
         else
             S_conv_line_odd_even <= 1'b0;
     end

     always @(posedge I_clk) begin
         if(S_conv_en)
             begin
				 S_conv_valid  <= I_raw8_valid;
                 S_conv_data_1 <= S_shift_1_data;
                 S_conv_data_2 <= S_shift_0_data;
                 S_conv_data_3 <= I_raw8_data;
             end
         else
             begin
                 S_conv_valid  <= 1'b0;
                 S_conv_data_1 <= 'd0;
                 S_conv_data_2 <= 'd0;
                 S_conv_data_3 <= 'd0;
             end
     end


     always @(posedge I_clk) begin
         S_conv_valid_1d  <=  S_conv_valid ;
         S_conv_data_1_1d <=  S_conv_data_1;
         S_conv_data_2_1d <=  S_conv_data_2;
         S_conv_data_3_1d <=  S_conv_data_3;

         S_conv_valid_2d  <=  S_conv_valid_1d ;
         S_conv_data_1_2d <=  S_conv_data_1_1d;
         S_conv_data_2_2d <=  S_conv_data_2_1d;
         S_conv_data_3_2d <=  S_conv_data_3_1d;
     end

     always @(posedge I_clk) begin
         if(S_conv_valid && S_conv_valid_1d && S_conv_valid_2d)
             begin
                 S_conv_cal_valid    <= 1'b1;
                 S_conv_cal_data_1_1 <= S_conv_data_1_2d;
                 S_conv_cal_data_1_2 <= S_conv_data_1_1d;
                 S_conv_cal_data_1_3 <= S_conv_data_1;
                 S_conv_cal_data_2_1 <= S_conv_data_2_2d;
                 S_conv_cal_data_2_2 <= S_conv_data_2_1d;
                 S_conv_cal_data_2_3 <= S_conv_data_2;
                 S_conv_cal_data_3_1 <= S_conv_data_3_2d;
                 S_conv_cal_data_3_2 <= S_conv_data_3_1d;
                 S_conv_cal_data_3_3 <= S_conv_data_3;
             end
         else
             begin
                 S_conv_cal_valid    <= 1'b0;
                 S_conv_cal_data_1_1 <= 'd0;
                 S_conv_cal_data_1_2 <= 'd0;
                 S_conv_cal_data_1_3 <= 'd0;
                 S_conv_cal_data_2_1 <= 'd0;
                 S_conv_cal_data_2_2 <= 'd0;
                 S_conv_cal_data_2_3 <= 'd0;
                 S_conv_cal_data_3_1 <= 'd0;
                 S_conv_cal_data_3_2 <= 'd0;
                 S_conv_cal_data_3_3 <= 'd0;
             end
     end


     always @(posedge I_clk) begin
         if(S_conv_cal_valid)
             begin
                 S_conv_cal_valid_1d <= S_conv_cal_valid;

                 if(S_conv_line_odd_even)
                     begin
                         S_r_data_p0 <= (S_conv_cal_data_1_2[31:24] + S_conv_cal_data_3_2[31:24]) >> 1;
                         S_g_data_p0 <= S_conv_cal_data_2_2[31:24];
                         S_b_data_p0 <= (S_conv_cal_data_2_1[7:0] + S_conv_cal_data_2_2[23:16]) >> 1;

                         S_r_data_p1 <= (S_conv_cal_data_1_2[31:24] + S_conv_cal_data_1_2[15:8] + S_conv_cal_data_3_2[31:24] + S_conv_cal_data_3_2[15:8]) >> 2;  
                         S_g_data_p1 <= (S_conv_cal_data_1_2[23:16] + S_conv_cal_data_2_2[31:24] + S_conv_cal_data_2_2[15:8] + S_conv_cal_data_3_2[23:16]) >> 2;  
                         S_b_data_p1 <= S_conv_cal_data_2_2[23:16];

                         S_r_data_p2 <= (S_conv_cal_data_1_2[15:8] + S_conv_cal_data_3_2[15:8]) >> 1;
                         S_g_data_p2 <= S_conv_cal_data_2_2[15:8];
                         S_b_data_p2 <= (S_conv_cal_data_2_2[23:16] + S_conv_cal_data_2_2[7:0]) >> 1;

                         S_r_data_p3 <= (S_conv_cal_data_1_2[15:8] + S_conv_cal_data_1_3[31:24] + S_conv_cal_data_3_2[15:8] + S_conv_cal_data_3_3[31:24]) >> 2;  
                         S_g_data_p3 <= (S_conv_cal_data_1_2[7:0] + S_conv_cal_data_2_2[15:8] + S_conv_cal_data_2_3[31:24] + S_conv_cal_data_3_2[7:0]) >> 2;  
                         S_b_data_p3 <= S_conv_cal_data_2_2[7:0];
                     end
                 else
                     begin
                         S_r_data_p0 <= S_conv_cal_data_2_2[31:24];
                         S_g_data_p0 <= (S_conv_cal_data_1_2[31:24] + S_conv_cal_data_2_1[7:0] + S_conv_cal_data_2_2[23:16] + S_conv_cal_data_3_2[31:24]) >> 2;  
                         S_b_data_p0 <= (S_conv_cal_data_1_1[7:0] + S_conv_cal_data_1_2[23:16] + S_conv_cal_data_3_1[7:0] + S_conv_cal_data_3_2[23:16]) >> 2;

                         S_r_data_p1 <= (S_conv_cal_data_2_2[31:24] + S_conv_cal_data_2_2[15:8]) >> 1;
                         S_g_data_p1 <= S_conv_cal_data_2_2[23:16];
                         S_b_data_p1 <= (S_conv_cal_data_1_2[23:16] + S_conv_cal_data_3_2[23:16]) >> 1;

                         S_r_data_p2 <= S_conv_cal_data_2_2[15:8];
                         S_g_data_p2 <= (S_conv_cal_data_1_2[15:8] + S_conv_cal_data_2_2[23:16] + S_conv_cal_data_2_2[7:0] + S_conv_cal_data_3_2[15:8]) >> 2;  
                         S_b_data_p2 <= (S_conv_cal_data_1_2[23:16] + S_conv_cal_data_1_2[7:0] + S_conv_cal_data_3_2[23:16] + S_conv_cal_data_3_2[7:0]) >> 2;  

                         S_r_data_p3 <= (S_conv_cal_data_2_2[15:8] + S_conv_cal_data_2_3[31:24]) >> 1;
                         S_g_data_p3 <= S_conv_cal_data_2_2[7:0];
                         S_b_data_p3 <= (S_conv_cal_data_1_2[7:0] + S_conv_cal_data_3_2[7:0]) >> 1;
                     end
             end
         else
             begin
                 S_conv_cal_valid_1d <= 1'b0;
                 S_r_data_p0 <= 'd0;
                 S_g_data_p0 <= 'd0;
                 S_b_data_p0 <= 'd0;
                 S_r_data_p1 <= 'd0;
                 S_g_data_p1 <= 'd0;
                 S_b_data_p1 <= 'd0;
                 S_r_data_p2 <= 'd0;
                 S_g_data_p2 <= 'd0;
                 S_b_data_p2 <= 'd0;
                 S_r_data_p3 <= 'd0;
                 S_g_data_p3 <= 'd0;
                 S_b_data_p3 <= 'd0;
             end
     end


     always @(posedge I_clk) begin
         if(S_conv_cal_valid_1d)
             begin
                 O_rgb888_valid <= 1'b1;
                 O_rgb888_data  <= {S_r_data_p0[7:0],S_g_data_p0[7:0],S_b_data_p0[7:0],
                                    S_r_data_p1[7:0],S_g_data_p1[7:0],S_b_data_p1[7:0],
                                    S_r_data_p2[7:0],S_g_data_p2[7:0],S_b_data_p2[7:0],
                                    S_r_data_p3[7:0],S_g_data_p3[7:0],S_b_data_p3[7:0]};
             end
         else
             begin
                 O_rgb888_valid <= 1'b0;
                 O_rgb888_data  <= 'd0;
             end
     end
    
endmodule