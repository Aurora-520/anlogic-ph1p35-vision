


module mipi_dphy_rx_ph1p_mipiio_wrapper #(
    parameter DPHY_RX_LOCATION = "DPHY0",
    parameter HS_EQUALIZER = "0dB",
    parameter HS_VGA_GAIN  = "0dB",
    parameter LANE_NUM = 4,
    parameter BYTE_NUM = 1
    )(
    input wire                             I_lp_clk,
    input wire                             I_rst,

    input wire[5:0]                        I_clk_lane_in_delay,
    input wire[5:0]                        I_data_lane0_in_delay,
    input wire[5:0]                        I_data_lane1_in_delay,
    input wire[5:0]                        I_data_lane2_in_delay,
    input wire[5:0]                        I_data_lane3_in_delay,

    input wire[LANE_NUM-1 : 0]             I_lane_invert,

    output wire                            O_hs_rx_clk,
    output wire                            O_hs_rx_valid,
    output wire[LANE_NUM*BYTE_NUM*8-1 : 0] O_hs_rx_data,

    output wire                            O_lp_rx_lane0_p,
    output wire                            O_lp_rx_lane0_n,

    input wire                             I_lp_tx_en,
    input wire                             I_lp_tx_lane0_p,
    input wire                             I_lp_tx_lane0_n,

    output wire[3 : 0]                     O_lane_match_error,

    output wire[LANE_NUM-1 : 0]            O_lane_error,

    inout wire                             IO_rx_clk_pad_n, 
    inout wire                             IO_rx_clk_pad_p, 
    inout wire[3:0]                        IO_rx_data_pad_n,
    inout wire[3:0]                        IO_rx_data_pad_p     
);



    wire                            S_hs_rx_valid;        
    wire[LANE_NUM*BYTE_NUM*8-1 : 0] S_hs_rx_data;           
    wire[LANE_NUM*BYTE_NUM*8-1 : 0] S_hs_rx_slave_data;   

    wire[LANE_NUM-1 : 0]            S_byte_aligne_valid;   
    wire[BYTE_NUM*8-1 : 0]          S_byte_aligne_data[LANE_NUM-1 : 0]; 

    wire[LANE_NUM-1 : 0]            S_ch_aligner_valid;   
    wire[BYTE_NUM*8-1 : 0]          S_ch_aligner_data[LANE_NUM-1 : 0];

    assign O_hs_rx_valid = &S_ch_aligner_valid;

    genvar i;
    generate
        for(i = 0; i < LANE_NUM; i = i+1) begin :   MIPI_DATA_MERGE
        	assign O_hs_rx_data[8*BYTE_NUM*(i+1)-1 : i*8*BYTE_NUM] = S_ch_aligner_data[LANE_NUM-1-i];
        end
    endgenerate


    channel_aligner_wrapper#(
        .CH_NUM      ( LANE_NUM   ),
        .DATA_WIDTH  ( BYTE_NUM*8 )
    )u_channel_aligner_wrapper(
        .I_clk              ( O_hs_rx_clk         ),
        .I_rst_n            ( ~I_rst              ),

        .I_ch_valid         ( S_byte_aligne_valid ),
        .I_ch_data          ( S_byte_aligne_data  ),

        .O_ch_aligner_valid ( S_ch_aligner_valid ),
        .O_ch_aligner_data  ( S_ch_aligner_data  )
    );



    byte_aligner_wrapper#(
        .LANE_NUM ( LANE_NUM ),
        .BYTE_NUM ( BYTE_NUM )
    )u_byte_aligner_wrapper(
        .I_clk               ( O_hs_rx_clk         ),
        .I_rst               ( I_rst               ),

        .I_hs_rx_valid       ( S_hs_rx_valid       ),
        .I_hs_rx_data        ( S_hs_rx_data        ),

        .O_byte_aligne_valid ( S_byte_aligne_valid ),
        .O_byte_aligne_data  ( S_byte_aligne_data  ),

        .O_lane_error        ( O_lane_error        )
    );



    ph1p_mipiio_rx_wrapper#(
        .DPHY_RX_LOCATION ( DPHY_RX_LOCATION ),
        .HS_EQUALIZER     ( HS_EQUALIZER     ),
        .HS_VGA_GAIN      ( HS_VGA_GAIN      ),
        .LANE_NUM         ( LANE_NUM         ),
        .BYTE_NUM         ( BYTE_NUM         )
    )u_ph1p_mipiio_rx_wrapper(
        .I_lp_clk                  ( I_lp_clk              ),
        .I_rst_n                   ( ~I_rst                ),
              
        .I_clk_lane_in_delay       ( I_clk_lane_in_delay   ),
        .I_data_lane0_in_delay     ( I_data_lane0_in_delay ),
        .I_data_lane1_in_delay     ( I_data_lane1_in_delay ),
        .I_data_lane2_in_delay     ( I_data_lane2_in_delay ),
        .I_data_lane3_in_delay     ( I_data_lane3_in_delay ),
              
        .I_lane_invert             ( I_lane_invert         ),
              
        .O_mipiio_hs_rx_clk        ( O_hs_rx_clk           ),
        .O_mipiio_hs_rx_valid      ( S_hs_rx_valid         ),
        .O_mipiio_hs_rx_data       ( S_hs_rx_data          ),
        .O_mipiio_hs_rx_slave_data ( S_hs_rx_slave_data    ),
          
        .O_lane_match_error        ( O_lane_match_error    ),

        .O_lp_rx_lane0_p           ( O_lp_rx_lane0_p       ),
        .O_lp_rx_lane0_n           ( O_lp_rx_lane0_n       ),
              
        .I_lp_tx_en                ( I_lp_tx_en            ),
        .I_lp_tx_lane0_p           ( I_lp_tx_lane0_p       ),
        .I_lp_tx_lane0_n           ( I_lp_tx_lane0_n       ),

        .IO_rx_clk_pad_n           ( IO_rx_clk_pad_n       ),
        .IO_rx_clk_pad_p           ( IO_rx_clk_pad_p       ),
        .IO_rx_data_pad_n          ( IO_rx_data_pad_n      ),
        .IO_rx_data_pad_p          ( IO_rx_data_pad_p      )
    );




    
endmodule