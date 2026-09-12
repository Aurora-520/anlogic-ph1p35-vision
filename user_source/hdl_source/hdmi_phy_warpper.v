

module hdmi_phy_wrapper#(
    parameter DEVICE = "EG"
    )(
    input wire      I_pixel_clk,
    input wire      I_serial_clk,
    input wire      I_rst,

    input wire[9:0] I_tmds_channel_0,
    input wire[9:0] I_tmds_channel_1,
    input wire[9:0] I_tmds_channel_2,
    input wire[9:0] I_tmds_channel_clk,
    
    output wire     O_tmds_ch0_p,
    output wire     O_tmds_ch1_p,
    output wire     O_tmds_ch2_p,
    output wire     O_tmds_clk_p
);
    
    wire[9:0] S_tmds_data_ch0;
    wire[9:0] S_tmds_data_ch1;
    wire[9:0] S_tmds_data_ch2;
    wire[9:0] S_tmds_data_clk;

    assign S_tmds_data_ch0 = {I_tmds_channel_0[0],
                              I_tmds_channel_0[1],
                              I_tmds_channel_0[2],
                              I_tmds_channel_0[3],
                              I_tmds_channel_0[4],
                              I_tmds_channel_0[5],
                              I_tmds_channel_0[6],
                              I_tmds_channel_0[7],
                              I_tmds_channel_0[8],
                              I_tmds_channel_0[9]};

    assign S_tmds_data_ch1 = {I_tmds_channel_1[0],
                              I_tmds_channel_1[1],
                              I_tmds_channel_1[2],
                              I_tmds_channel_1[3],
                              I_tmds_channel_1[4],
                              I_tmds_channel_1[5],
                              I_tmds_channel_1[6],
                              I_tmds_channel_1[7],
                              I_tmds_channel_1[8],
                              I_tmds_channel_1[9]};

    assign S_tmds_data_ch2 = {I_tmds_channel_2[0],
                              I_tmds_channel_2[1],
                              I_tmds_channel_2[2],
                              I_tmds_channel_2[3],
                              I_tmds_channel_2[4],
                              I_tmds_channel_2[5],
                              I_tmds_channel_2[6],
                              I_tmds_channel_2[7],
                              I_tmds_channel_2[8],
                              I_tmds_channel_2[9]};

    assign S_tmds_data_clk = {I_tmds_channel_clk[0],
                              I_tmds_channel_clk[1],
                              I_tmds_channel_clk[2],
                              I_tmds_channel_clk[3],
                              I_tmds_channel_clk[4],
                              I_tmds_channel_clk[5],
                              I_tmds_channel_clk[6],
                              I_tmds_channel_clk[7],
                              I_tmds_channel_clk[8],
                              I_tmds_channel_clk[9]};


    lane_lvds_10_1 #(
        .DEVICE ( DEVICE )    
    )u0_lane_lvds_8_1(
        .I_pixel_clk  ( I_pixel_clk     ),
        .I_serial_clk ( I_serial_clk    ),
        .I_rst        ( I_rst           ),

        .I_data_in    ( S_tmds_data_ch0 ),
        .O_serial_out ( O_tmds_ch0_p    )
    );


    lane_lvds_10_1 #(
        .DEVICE ( DEVICE )    
    )u1_lane_lvds_8_1(
        .I_pixel_clk  ( I_pixel_clk     ),
        .I_serial_clk ( I_serial_clk    ),
        .I_rst        ( I_rst           ),
        
        .I_data_in    ( S_tmds_data_ch1 ),
        .O_serial_out ( O_tmds_ch1_p    )
    );


    lane_lvds_10_1 #(
        .DEVICE ( DEVICE )    
    )u2_lane_lvds_8_1(
        .I_pixel_clk  ( I_pixel_clk     ),
        .I_serial_clk ( I_serial_clk    ),
        .I_rst        ( I_rst           ),
        
        .I_data_in    ( S_tmds_data_ch2 ),
        .O_serial_out ( O_tmds_ch2_p    )
    );


    lane_lvds_10_1 #(
        .DEVICE ( DEVICE )    
    )u3_lane_lvds_8_1(
        .I_pixel_clk  ( I_pixel_clk     ),
        .I_serial_clk ( I_serial_clk    ),
        .I_rst        ( I_rst           ),
        
        .I_data_in    ( S_tmds_data_clk ),
        .O_serial_out ( O_tmds_clk_p    )
    );


endmodule





