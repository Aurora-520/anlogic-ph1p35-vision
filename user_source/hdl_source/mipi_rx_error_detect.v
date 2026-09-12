

module mipi_rx_error_detect (
    input wire    I_clk,
    input wire    I_rst_n,

    input wire    I_frame_start, 
    input wire    I_frame_end,   
    input wire    I_data_valid,  

    output reg    O_mipi_rx_error 
);


    reg[11:0] S_line_cnt;      
    reg[11:0] S_col_cnt;       
    reg       S_data_valid_1d;
    wire      S_line_end;
    
    always @ (posedge I_clk) begin
    	S_data_valid_1d <= I_data_valid;
    end
    
    assign S_line_end = ~I_data_valid & S_data_valid_1d;
    
    always @ (posedge I_clk) begin
    	if(I_data_valid)
        	S_col_cnt <= S_col_cnt + 'd1;
     	else
         	S_col_cnt <= 'd0;
    end
    
    always @ (posedge I_clk) begin
    	if(I_frame_start)
        	S_line_cnt <= 'd0;
      	else if(S_line_end)
          	S_line_cnt <= S_line_cnt + 'd1;
       	else
           	S_line_cnt <= S_line_cnt;
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n)
            O_mipi_rx_error <= 1'b0;
        else    
            if(I_frame_end && S_line_cnt != 12'd832)
                O_mipi_rx_error <= 1'b1;
            else if(I_data_valid)
                O_mipi_rx_error <= 1'b0;
            else
                O_mipi_rx_error <= O_mipi_rx_error;
    end
	
	
reg [11:0] h_cnt;
reg [11:0] c_cnt;

always@(posedge I_clk)begin
	if(!I_rst_n || I_frame_end)
		h_cnt <= 12'd0;
	else if(I_data_valid)
		h_cnt <= h_cnt + 1'b1;
	else
		h_cnt <= h_cnt;
end

always@(posedge I_clk)begin
	if(!I_rst_n || I_frame_start)
		c_cnt <= 12'd0;
	else if(I_frame_end)
		c_cnt <= c_cnt + 1'b1;
	else
		c_cnt <= c_cnt;
end
    
   cwc1 cwc_inst
 (
     .probe0(I_frame_start),
     .probe1(I_frame_end),
     .probe2(I_data_valid),
     .probe3(O_mipi_rx_error),
     .probe4(S_line_cnt),
     .probe5(S_col_cnt),
     .probe6(S_data_valid_1d),
     .probe7(S_line_end),
     .probe8(h_cnt),
     .probe9(c_cnt),
     .clk(I_clk)
 );
    
endmodule