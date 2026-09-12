


module ph1p_mipiio_rx_wrapper #(
    parameter DPHY_RX_LOCATION = "DPHY0",
    parameter HS_EQUALIZER = "0dB",
    parameter HS_VGA_GAIN  = "0dB",
    parameter LANE_NUM = 4,
    parameter BYTE_NUM = 1,
    parameter SAMPLE_OFFSET = 8
    )(
    input wire                             I_lp_clk,
    input wire                             I_rst_n,

    input wire[5:0]                        I_clk_lane_in_delay,
    input wire[5:0]                        I_data_lane0_in_delay,
    input wire[5:0]                        I_data_lane1_in_delay,
    input wire[5:0]                        I_data_lane2_in_delay,
    input wire[5:0]                        I_data_lane3_in_delay,

    input wire[LANE_NUM-1 : 0]             I_lane_invert,

    output wire                            O_mipiio_hs_rx_clk,
    output reg                             O_mipiio_hs_rx_valid,
    output wire[LANE_NUM*BYTE_NUM*8-1 : 0] O_mipiio_hs_rx_data,
    output wire[LANE_NUM*BYTE_NUM*8-1 : 0] O_mipiio_hs_rx_slave_data,

    output wire[3:0]                       O_lane_match_error,

    output wire                            O_lp_rx_lane0_p,
    output wire                            O_lp_rx_lane0_n,

    input wire                             I_lp_tx_en,
    input wire                             I_lp_tx_lane0_p,
    input wire                             I_lp_tx_lane0_n,

    inout wire                             IO_rx_clk_pad_n, 
    inout wire                             IO_rx_clk_pad_p, 
    inout wire[3:0]                        IO_rx_data_pad_n,
    inout wire[3:0]                        IO_rx_data_pad_p        
);

    localparam HS_S2P_RATIO = BYTE_NUM == 1 ? "1:8" : "1:16";

    wire       S_mipiio_lane0_p; //synthesis keep   
    wire       S_mipiio_lane0_n; //synthesis keep   

    wire       S_mipiio_lane1_p; //synthesis keep   
    wire       S_mipiio_lane1_n; //synthesis keep   

    wire       S_mipiio_lane2_p; //synthesis keep   
    wire       S_mipiio_lane2_n; //synthesis keep   

    wire       S_mipiio_lane3_p; //synthesis keep   
    wire       S_mipiio_lane3_n; //synthesis keep   

    wire       S_data_lane0_p;
    wire       S_data_lane0_n;

    wire       S_data_lane_hs_en;   //synthesis keep     

    wire       S_lane0_hs_en;//synthesis keep   
    wire       S_lane1_hs_en;//synthesis keep   
    wire       S_lane2_hs_en;//synthesis keep   
    wire       S_lane3_hs_en;//synthesis keep   

    wire[1:0]  S_lane0_terminator_sel;//synthesis keep   
    wire[1:0]  S_lane1_terminator_sel;//synthesis keep   
    wire[1:0]  S_lane2_terminator_sel;//synthesis keep   
    wire[1:0]  S_lane3_terminator_sel;//synthesis keep   

    wire[15:0] S_l0_hs_rx_data; 
    wire[15:0] S_l1_hs_rx_data; 
    wire[15:0] S_l2_hs_rx_data; 
    wire[15:0] S_l3_hs_rx_data; 

    reg[15:0]  S_l0_hs_rx_data_negedge; 
    reg[15:0]  S_l1_hs_rx_data_negedge; 
    reg[15:0]  S_l2_hs_rx_data_negedge; 
    reg[15:0]  S_l3_hs_rx_data_negedge; 

    reg[15:0]  S_l0_hs_rx_data_1d;//synthesis keep 
    reg[15:0]  S_l1_hs_rx_data_1d;//synthesis keep 
    reg[15:0]  S_l2_hs_rx_data_1d;//synthesis keep 
    reg[15:0]  S_l3_hs_rx_data_1d;//synthesis keep 

    wire[15:0] S_l0_hs_rx_slave_data; 
    wire[15:0] S_l1_hs_rx_slave_data;
    wire[15:0] S_l2_hs_rx_slave_data;
    wire[15:0] S_l3_hs_rx_slave_data;

    reg[15:0]  S_l0_hs_rx_slave_data_negedge; 
    reg[15:0]  S_l1_hs_rx_slave_data_negedge; 
    reg[15:0]  S_l2_hs_rx_slave_data_negedge; 
    reg[15:0]  S_l3_hs_rx_slave_data_negedge; 

    reg[15:0]  S_l0_hs_rx_slave_data_1d;//synthesis keep 
    reg[15:0]  S_l1_hs_rx_slave_data_1d;//synthesis keep 
    reg[15:0]  S_l2_hs_rx_slave_data_1d;//synthesis keep 
    reg[15:0]  S_l3_hs_rx_slave_data_1d;//synthesis keep 

    wire[15:0] S_l0_hs_rx_data_invert;
    wire[15:0] S_l1_hs_rx_data_invert;
    wire[15:0] S_l2_hs_rx_data_invert;
    wire[15:0] S_l3_hs_rx_data_invert;

    wire[15:0] S_l0_hs_rx_slave_data_invert;
    wire[15:0] S_l1_hs_rx_slave_data_invert;
    wire[15:0] S_l2_hs_rx_slave_data_invert;
    wire[15:0] S_l3_hs_rx_slave_data_invert;

	wire       S_lane0_lp_tx_p;
    wire       S_lane0_lp_tx_n;

	wire       S_mipiio_hs_rx_clk;

	wire       S_lane0_h_match_error;//synthesis keep 
	wire       S_lane1_h_match_error;//synthesis keep 
	wire       S_lane2_h_match_error;//synthesis keep 
	wire       S_lane3_h_match_error;//synthesis keep 
	
	wire       S_lane0_l_match_error;//synthesis keep 
	wire       S_lane1_l_match_error;//synthesis keep 
	wire       S_lane2_l_match_error;//synthesis keep 
	wire       S_lane3_l_match_error;//synthesis keep 

    reg        S_data_lane_hs_en_1d;
    reg[7:0]   S_sample_offset_cnt;

    assign O_lane_match_error = S_data_lane_hs_en ? {S_lane3_l_match_error,S_lane2_l_match_error,S_lane1_l_match_error,S_lane0_l_match_error} : 4'b0000;


	PH1P_LOGIC_BUFG bufg_feedback (
 		.i( S_mipiio_hs_rx_clk ), 
 		.o( O_mipiio_hs_rx_clk ) 
 	); 


//	assign O_mipiio_hs_rx_clk = S_mipiio_hs_rx_clk;


    /*
        if some lane don't use, make those lane into reset status to save power
    */
    generate begin
        if(LANE_NUM == 1)
            begin
                assign S_lane0_hs_en = S_data_lane_hs_en;
                assign S_lane1_hs_en = 1'b0;
                assign S_lane2_hs_en = 1'b0;
                assign S_lane3_hs_en = 1'b0;

                assign S_lane0_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane1_terminator_sel = 2'b10;
                assign S_lane2_terminator_sel = 2'b10;
                assign S_lane3_terminator_sel = 2'b10;
            end
        else if(LANE_NUM == 2)
            begin
                assign S_lane0_hs_en = S_data_lane_hs_en;
                assign S_lane1_hs_en = S_data_lane_hs_en;
                assign S_lane2_hs_en = 1'b0;
                assign S_lane3_hs_en = 1'b0;

                assign S_lane0_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane1_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane2_terminator_sel = 2'b10;
                assign S_lane3_terminator_sel = 2'b10;
            end
        else if(LANE_NUM == 3)
            begin
                assign S_lane0_hs_en = S_data_lane_hs_en;
                assign S_lane1_hs_en = S_data_lane_hs_en;
                assign S_lane2_hs_en = S_data_lane_hs_en;
                assign S_lane3_hs_en = 1'b0;

                assign S_lane0_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane1_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane2_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane3_terminator_sel = 2'b10;
            end
        else if(LANE_NUM == 4)
            begin
                assign S_lane0_hs_en = S_data_lane_hs_en;
                assign S_lane1_hs_en = S_data_lane_hs_en;
                assign S_lane2_hs_en = S_data_lane_hs_en;
                assign S_lane3_hs_en = S_data_lane_hs_en;

                assign S_lane0_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane1_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane2_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
                assign S_lane3_terminator_sel = S_data_lane_hs_en ? 2'b00 : 2'b11;
            end
        else
            begin
                assign S_lane0_hs_en = 1'b0;
                assign S_lane1_hs_en = 1'b0;
                assign S_lane2_hs_en = 1'b0;
                assign S_lane3_hs_en = 1'b0;

                assign S_lane0_terminator_sel = 2'b10;
                assign S_lane1_terminator_sel = 2'b10;
                assign S_lane2_terminator_sel = 2'b10;
                assign S_lane3_terminator_sel = 2'b10;
            end
    end
    endgenerate



    generate begin
        if(LANE_NUM == 1)
            begin
                if(BYTE_NUM == 1)
                    begin
                        assign S_l0_hs_rx_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d[7:0] : S_l0_hs_rx_data_1d[7:0];

                        assign O_mipiio_hs_rx_data = S_l0_hs_rx_data_invert[7:0];


                        //slave
                        assign S_l0_hs_rx_slave_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d[7:0] : S_l0_hs_rx_slave_data_1d[7:0];

                        assign O_mipiio_hs_rx_slave_data = S_l0_hs_rx_slave_data_invert[7:0];
                    end
                else    
                    begin
                        assign S_l0_hs_rx_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d : S_l0_hs_rx_data_1d;

                        assign O_mipiio_hs_rx_data = S_l0_hs_rx_data_invert;


                        //slave
                        assign S_l0_hs_rx_slave_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d : S_l0_hs_rx_slave_data_1d;

                        assign O_mipiio_hs_rx_slave_data = S_l0_hs_rx_slave_data_invert;
                    end
            end
        else if(LANE_NUM == 2)
            begin
                if(BYTE_NUM == 1)
                    begin
                        assign S_l0_hs_rx_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d[7:0] : S_l0_hs_rx_data_1d[7:0];
                        assign S_l1_hs_rx_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d[7:0] : S_l1_hs_rx_data_1d[7:0];

                        assign O_mipiio_hs_rx_data = {S_l1_hs_rx_data_invert[7:0],
                                                      S_l0_hs_rx_data_invert[7:0]};

                        //slave
                        assign S_l0_hs_rx_slave_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d[7:0] : S_l0_hs_rx_slave_data_1d[7:0];
                        assign S_l1_hs_rx_slave_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d[7:0] : S_l1_hs_rx_slave_data_1d[7:0];

                        assign O_mipiio_hs_rx_slave_data = {S_l1_hs_rx_slave_data_invert[7:0],
                                                            S_l0_hs_rx_slave_data_invert[7:0]};
                    end
                else    
                    begin
                        assign S_l0_hs_rx_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d : S_l0_hs_rx_data_1d;
                        assign S_l1_hs_rx_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d : S_l1_hs_rx_data_1d;

                        assign O_mipiio_hs_rx_data = {S_l1_hs_rx_data_invert,
                                                      S_l0_hs_rx_data_invert};

                        //slave
                        assign S_l0_hs_rx_slave_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d : S_l0_hs_rx_slave_data_1d;
                        assign S_l1_hs_rx_slave_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d : S_l1_hs_rx_slave_data_1d;

                        assign O_mipiio_hs_rx_slave_data = {S_l1_hs_rx_slave_data_invert,
                                                            S_l0_hs_rx_slave_data_invert};
                    end
            end
        else if(LANE_NUM == 3)
            begin
                if(BYTE_NUM == 1)
                    begin
                        assign S_l0_hs_rx_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d[7:0] : S_l0_hs_rx_data_1d[7:0];
                        assign S_l1_hs_rx_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d[7:0] : S_l1_hs_rx_data_1d[7:0];
                        assign S_l2_hs_rx_data_invert[7:0] = I_lane_invert[2] ? ~S_l2_hs_rx_data_1d[7:0] : S_l2_hs_rx_data_1d[7:0];

                        assign O_mipiio_hs_rx_data = {S_l2_hs_rx_data_invert[7:0],
                                                      S_l1_hs_rx_data_invert[7:0],
                                                      S_l0_hs_rx_data_invert[7:0]};


                        //slave
                        assign S_l0_hs_rx_slave_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d[7:0] : S_l0_hs_rx_slave_data_1d[7:0];
                        assign S_l1_hs_rx_slave_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d[7:0] : S_l1_hs_rx_slave_data_1d[7:0];
                        assign S_l2_hs_rx_slave_data_invert[7:0] = I_lane_invert[2] ? ~S_l2_hs_rx_slave_data_1d[7:0] : S_l2_hs_rx_slave_data_1d[7:0];

                        assign O_mipiio_hs_rx_slave_data = {S_l2_hs_rx_slave_data_invert[7:0],
                                                            S_l1_hs_rx_slave_data_invert[7:0],
                                                            S_l0_hs_rx_slave_data_invert[7:0]};
                    end
                else    
                    begin
                        assign S_l0_hs_rx_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d : S_l0_hs_rx_data_1d;
                        assign S_l1_hs_rx_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d : S_l1_hs_rx_data_1d;
                        assign S_l2_hs_rx_data_invert = I_lane_invert[2] ? ~S_l2_hs_rx_data_1d : S_l2_hs_rx_data_1d;

                        assign O_mipiio_hs_rx_data = {S_l2_hs_rx_data_invert,
                                                      S_l1_hs_rx_data_invert,
                                                      S_l0_hs_rx_data_invert};

                        
                        //slave
                        assign S_l0_hs_rx_slave_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d : S_l0_hs_rx_slave_data_1d;
                        assign S_l1_hs_rx_slave_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d : S_l1_hs_rx_slave_data_1d;
                        assign S_l2_hs_rx_slave_data_invert = I_lane_invert[2] ? ~S_l2_hs_rx_slave_data_1d : S_l2_hs_rx_slave_data_1d;

                        assign O_mipiio_hs_rx_slave_data = {S_l2_hs_rx_slave_data_invert,
                                                            S_l1_hs_rx_slave_data_invert,
                                                            S_l0_hs_rx_slave_data_invert};
                    end
            end
        else if(LANE_NUM == 4)
            begin
                if(BYTE_NUM == 1)
                    begin
                        assign S_l0_hs_rx_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d[7:0] : S_l0_hs_rx_data_1d[7:0];
                        assign S_l1_hs_rx_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d[7:0] : S_l1_hs_rx_data_1d[7:0];
                        assign S_l2_hs_rx_data_invert[7:0] = I_lane_invert[2] ? ~S_l2_hs_rx_data_1d[7:0] : S_l2_hs_rx_data_1d[7:0];
                        assign S_l3_hs_rx_data_invert[7:0] = I_lane_invert[3] ? ~S_l3_hs_rx_data_1d[7:0] : S_l3_hs_rx_data_1d[7:0];

                        assign O_mipiio_hs_rx_data = {S_l3_hs_rx_data_invert[7:0],
                                                      S_l2_hs_rx_data_invert[7:0],
                                                      S_l1_hs_rx_data_invert[7:0],
                                                      S_l0_hs_rx_data_invert[7:0]};


                        //slave
                        assign S_l0_hs_rx_slave_data_invert[7:0] = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d[7:0] : S_l0_hs_rx_slave_data_1d[7:0];
                        assign S_l1_hs_rx_slave_data_invert[7:0] = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d[7:0] : S_l1_hs_rx_slave_data_1d[7:0];
                        assign S_l2_hs_rx_slave_data_invert[7:0] = I_lane_invert[2] ? ~S_l2_hs_rx_slave_data_1d[7:0] : S_l2_hs_rx_slave_data_1d[7:0];
                        assign S_l3_hs_rx_slave_data_invert[7:0] = I_lane_invert[3] ? ~S_l3_hs_rx_slave_data_1d[7:0] : S_l3_hs_rx_slave_data_1d[7:0];

                        assign O_mipiio_hs_rx_slave_data = {S_l3_hs_rx_slave_data_invert[7:0],
                                                            S_l2_hs_rx_slave_data_invert[7:0],
                                                            S_l1_hs_rx_slave_data_invert[7:0],
                                                            S_l0_hs_rx_slave_data_invert[7:0]};
                    end
                else    
                    begin
                        assign S_l0_hs_rx_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_data_1d : S_l0_hs_rx_data_1d;
                        assign S_l1_hs_rx_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_data_1d : S_l1_hs_rx_data_1d;
                        assign S_l2_hs_rx_data_invert = I_lane_invert[2] ? ~S_l2_hs_rx_data_1d : S_l2_hs_rx_data_1d;
                        assign S_l3_hs_rx_data_invert = I_lane_invert[3] ? ~S_l3_hs_rx_data_1d : S_l3_hs_rx_data_1d;

                        assign O_mipiio_hs_rx_data = {S_l3_hs_rx_data_invert,
                                                      S_l2_hs_rx_data_invert,
                                                      S_l1_hs_rx_data_invert,
                                                      S_l0_hs_rx_data_invert};


                        //slave
                        assign S_l0_hs_rx_slave_data_invert = I_lane_invert[0] ? ~S_l0_hs_rx_slave_data_1d : S_l0_hs_rx_slave_data_1d;
                        assign S_l1_hs_rx_slave_data_invert = I_lane_invert[1] ? ~S_l1_hs_rx_slave_data_1d : S_l1_hs_rx_slave_data_1d;
                        assign S_l2_hs_rx_slave_data_invert = I_lane_invert[2] ? ~S_l2_hs_rx_slave_data_1d : S_l2_hs_rx_slave_data_1d;
                        assign S_l3_hs_rx_slave_data_invert = I_lane_invert[3] ? ~S_l3_hs_rx_slave_data_1d : S_l3_hs_rx_slave_data_1d;

                        assign O_mipiio_hs_rx_slave_data = {S_l3_hs_rx_slave_data_invert,
                                                            S_l2_hs_rx_slave_data_invert,
                                                            S_l1_hs_rx_slave_data_invert,
                                                            S_l0_hs_rx_slave_data_invert};
                    end
            end
    end
    endgenerate




    assign S_data_lane0_p = I_lane_invert[0] ? S_mipiio_lane0_n : S_mipiio_lane0_p;
    assign S_data_lane0_n = I_lane_invert[0] ? S_mipiio_lane0_p : S_mipiio_lane0_n;


	assign S_lane0_lp_tx_p = I_lane_invert[0] ? I_lp_tx_lane0_n : I_lp_tx_lane0_p;
	assign S_lane0_lp_tx_n = I_lane_invert[0] ? I_lp_tx_lane0_p : I_lp_tx_lane0_n;


    assign O_lp_rx_lane0_p = S_data_lane0_p;
    assign O_lp_rx_lane0_n = S_data_lane0_n;


    always @(posedge O_mipiio_hs_rx_clk) begin
        S_data_lane_hs_en_1d <= S_data_lane_hs_en;
    end

    always @(posedge O_mipiio_hs_rx_clk) begin
        if(S_data_lane_hs_en_1d)
            begin
                if(S_sample_offset_cnt >= 'd30)
                    S_sample_offset_cnt <= S_sample_offset_cnt;
                else
                    S_sample_offset_cnt <= S_sample_offset_cnt + 'd1;
            end
        else
            S_sample_offset_cnt <= 'd0;
    end


    always @(posedge O_mipiio_hs_rx_clk) begin
        O_mipiio_hs_rx_valid <= S_data_lane_hs_en_1d && S_sample_offset_cnt >= SAMPLE_OFFSET ? 1'b1 : 1'b0;
    end


    hs_detect u_lane0_hs_detect(
        .I_clk   ( I_lp_clk          ),
        .I_rst_n ( I_rst_n           ),
   
        .I_lp_p  ( S_data_lane0_p    ),
        .I_lp_n  ( S_data_lane0_n    ),

        .O_hs_en ( S_data_lane_hs_en )
    );



    always @(posedge O_mipiio_hs_rx_clk) begin
        S_l0_hs_rx_data_1d <= S_l0_hs_rx_data;
        S_l1_hs_rx_data_1d <= S_l1_hs_rx_data;
        S_l2_hs_rx_data_1d <= S_l2_hs_rx_data;
		S_l3_hs_rx_data_1d <= S_l3_hs_rx_data;

        S_l0_hs_rx_slave_data_1d <= S_l0_hs_rx_slave_data;
        S_l1_hs_rx_slave_data_1d <= S_l1_hs_rx_slave_data;
        S_l2_hs_rx_slave_data_1d <= S_l2_hs_rx_slave_data;
        S_l3_hs_rx_slave_data_1d <= S_l3_hs_rx_slave_data;
    end




	assign S_lane0_h_match_error = S_l0_hs_rx_data_1d[15:8] != S_l0_hs_rx_slave_data_1d[15:8] ? 1'b1 : 1'b0;
    assign S_lane1_h_match_error = S_l1_hs_rx_data_1d[15:8] != S_l1_hs_rx_slave_data_1d[15:8] ? 1'b1 : 1'b0;
	assign S_lane2_h_match_error = S_l2_hs_rx_data_1d[15:8] != S_l2_hs_rx_slave_data_1d[15:8] ? 1'b1 : 1'b0;
	assign S_lane3_h_match_error = S_l3_hs_rx_data_1d[15:8] != S_l3_hs_rx_slave_data_1d[15:8] ? 1'b1 : 1'b0;

	assign S_lane0_l_match_error = S_l0_hs_rx_data_1d[7:0] != S_l0_hs_rx_slave_data_1d[7:0] ? 1'b1 : 1'b0;
    assign S_lane1_l_match_error = S_l1_hs_rx_data_1d[7:0] != S_l1_hs_rx_slave_data_1d[7:0] ? 1'b1 : 1'b0;
	assign S_lane2_l_match_error = S_l2_hs_rx_data_1d[7:0] != S_l2_hs_rx_slave_data_1d[7:0] ? 1'b1 : 1'b0;
	assign S_lane3_l_match_error = S_l3_hs_rx_data_1d[7:0] != S_l3_hs_rx_slave_data_1d[7:0] ? 1'b1 : 1'b0;


    PH1P_LOGIC_DPHY_MIPI_RX #(
        .DPHY_RX_LOCATION             ( DPHY_RX_LOCATION ),           

        .HS_S2P_RATIO                 ( HS_S2P_RATIO     ),         

        .CK_HS_EQUALIZER              ( HS_EQUALIZER     ),              
        .CK_HS_VGA_GAIN               ( HS_VGA_GAIN      ),              
        .L0_HS_SLAVE_DESER_CLK_OFFSET ( "0ps"            ),
        .L0_HS_EQUALIZER              ( HS_EQUALIZER     ), 
        .L0_HS_VGA_GAIN               ( HS_VGA_GAIN      ), 
        .L1_HS_SLAVE_DESER_CLK_OFFSET ( "0ps"            ),
        .L1_HS_EQUALIZER              ( HS_EQUALIZER     ), 
        .L1_HS_VGA_GAIN               ( HS_VGA_GAIN      ), 
        .L2_HS_SLAVE_DESER_CLK_OFFSET ( "0ps"            ),
        .L2_HS_EQUALIZER              ( HS_EQUALIZER     ), 
        .L2_HS_VGA_GAIN               ( HS_VGA_GAIN      ), 
        .L3_HS_SLAVE_DESER_CLK_OFFSET ( "0ps"            ),
        .L3_HS_EQUALIZER              ( HS_EQUALIZER     ), 
        .L3_HS_VGA_GAIN               ( HS_VGA_GAIN      )
    )u_PH1P_LOGIC_DPHY_MIPI_RX(
        .io_clk_pad_n               ( IO_rx_clk_pad_n        ),
        .io_clk_pad_p               ( IO_rx_clk_pad_p        ),
        .io_data_pad_n              ( IO_rx_data_pad_n       ),
        .io_data_pad_p              ( IO_rx_data_pad_p       ),

        .o_fabric_div4_8_clk        ( S_mipiio_hs_rx_clk     ),
        .i_phy_rst_n                ( I_rst_n                ),

        .i_ck_lp_rx_en              ( 1'b0                   ),
        .o_ck_lp_rx_p               ( ),
        .o_ck_lp_rx_n               ( ),
        .i_ck_hs_rx_en              ( 1'b1                   ),
        .i_ck_hs_terminator_sel     ( 2'b00                  ),
        .i_ck_hs_idelay_en          ( 1'b1                   ),
        .i_ck_hs_idelay_value       ( I_clk_lane_in_delay    ),

        .i_l0_lp_rx_en              ( ~I_lp_tx_en            ),
        .i_l0_lp_tx_en              ( I_lp_tx_en             ),
        .o_l0_lp_rx_p               ( S_mipiio_lane0_p       ),
        .o_l0_lp_rx_n               ( S_mipiio_lane0_n       ),
        .i_l0_lp_tx_p               ( S_lane0_lp_tx_p        ),
        .i_l0_lp_tx_n               ( S_lane0_lp_tx_n        ),
        .i_l0_hs_rx_en              ( S_lane0_hs_en          ),
        .i_l0_hs_terminator_sel     ( S_lane0_terminator_sel ),
        .i_l0_hs_slave_deser_clk_en ( 1'b1                   ),
        .i_l0_hs_idelay_en          ( 1'b1                   ),
        .i_l0_hs_idelay_value       ( I_data_lane0_in_delay  ),
        .o_l0_hs_rx_data            ( S_l0_hs_rx_data        ),
        .o_l0_hs_rx_slave_data      ( S_l0_hs_rx_slave_data  ),

        .i_l1_lp_rx_en              ( ~I_lp_tx_en            ),
        .i_l1_lp_tx_en              ( 1'b0                   ),
        .o_l1_lp_rx_p               ( S_mipiio_lane1_p       ),
        .o_l1_lp_rx_n               ( S_mipiio_lane1_n       ),
        .i_l1_lp_tx_p               ( 1'b0                   ),
        .i_l1_lp_tx_n               ( 1'b0                   ),
        .i_l1_hs_rx_en              ( S_lane1_hs_en          ),
        .i_l1_hs_terminator_sel     ( S_lane1_terminator_sel ),
        .i_l1_hs_slave_deser_clk_en ( 1'b1                   ),
        .i_l1_hs_idelay_en          ( 1'b1                   ),
        .i_l1_hs_idelay_value       ( I_data_lane1_in_delay  ),
        .o_l1_hs_rx_data            ( S_l1_hs_rx_data        ),
        .o_l1_hs_rx_slave_data      ( S_l1_hs_rx_slave_data  ),

        .i_l2_lp_rx_en              ( ~I_lp_tx_en            ),
        .i_l2_lp_tx_en              ( 1'b0                   ),
        .o_l2_lp_rx_p               ( S_mipiio_lane2_p       ),
        .o_l2_lp_rx_n               ( S_mipiio_lane2_n       ),
        .i_l2_lp_tx_p               ( 1'b0                   ),
        .i_l2_lp_tx_n               ( 1'b0                   ),
        .i_l2_hs_rx_en              ( S_lane2_hs_en          ),
        .i_l2_hs_terminator_sel     ( S_lane2_terminator_sel ),
        .i_l2_hs_slave_deser_clk_en ( 1'b1                   ),
        .i_l2_hs_idelay_en          ( 1'b1                   ),
        .i_l2_hs_idelay_value       ( I_data_lane2_in_delay  ),
        .o_l2_hs_rx_data            ( S_l2_hs_rx_data        ),
        .o_l2_hs_rx_slave_data      ( S_l2_hs_rx_slave_data  ),

        .i_l3_lp_rx_en              ( ~I_lp_tx_en            ),
        .i_l3_lp_tx_en              ( 1'b0                   ),
        .o_l3_lp_rx_p               ( S_mipiio_lane3_p       ),
        .o_l3_lp_rx_n               ( S_mipiio_lane3_n       ),
        .i_l3_lp_tx_p               ( 1'b0                   ),
        .i_l3_lp_tx_n               ( 1'b0                   ),
        .i_l3_hs_rx_en              ( S_lane3_hs_en          ),
        .i_l3_hs_terminator_sel     ( S_lane3_terminator_sel ),
        .i_l3_hs_slave_deser_clk_en ( 1'b1                   ),
        .i_l3_hs_idelay_en          ( 1'b1                   ),
        .i_l3_hs_idelay_value       ( I_data_lane3_in_delay  ),
        .o_l3_hs_rx_data            ( S_l3_hs_rx_data        ),
        .o_l3_hs_rx_slave_data      ( S_l3_hs_rx_slave_data  )
    );


    
endmodule