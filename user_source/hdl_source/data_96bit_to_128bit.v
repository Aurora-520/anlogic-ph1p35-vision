

module data_96bit_to_128bit (
    input wire        I_clk,
    input wire        I_rst_n,
   
    input wire        I_96b_frame_start,
    input wire        I_96b_valid,
    input wire[95:0]  I_96b_data,
  
    output reg        O_128b_frame_start,
    output reg        O_128b_valid,
    output reg[127:0] O_128b_data
);



    reg[95:0]  S_96b_data_1d;
    reg        S_96b_valid_1d;
    reg[1:0]   S_cnt;


    always @(posedge I_clk) begin
        S_96b_valid_1d <= I_96b_valid;
        S_96b_data_1d  <= I_96b_data;

		O_128b_frame_start <= I_96b_frame_start;
    end


    always @(posedge I_clk) begin
        if(I_96b_valid)
            S_cnt <= S_cnt + 'd1;
        else
            S_cnt <= 'd0;
    end


    always @(posedge I_clk) begin
        if(I_96b_valid)
            begin
                case(S_cnt)
                    'd0 : 
                        begin
                            O_128b_valid <= 1'b0;
                            O_128b_data  <= 'd0;
                        end
                    'd1 :
                        begin
                            O_128b_valid <= 1'b1;
                            O_128b_data  <= {S_96b_data_1d,I_96b_data[95:64]};
                        end
                    'd2 :
                        begin
                            O_128b_valid <= 1'b1;
                            O_128b_data  <= {S_96b_data_1d[63:0],I_96b_data[95:32]};
                        end
                    'd3 :
                        begin
                            O_128b_valid <= 1'b1;
                            O_128b_data  <= {S_96b_data_1d[31:0],I_96b_data};
                        end
                    default:
                        begin
                            O_128b_valid <= 1'b0;
                            O_128b_data  <= 'd0;
                        end
                endcase
            end
        else
            begin
                O_128b_valid <= 1'b0;
                O_128b_data  <= 'd0;
            end
    end

    

endmodule