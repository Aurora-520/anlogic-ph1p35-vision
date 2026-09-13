// Final application top-level.
//
// Board pins stay stable while the implementation is split into:
//   vendor_reference : factory MIPI/ISP/DDR/HDMI implementation
//   rtl              : project-owned extension points and application logic
// This wrapper intentionally contains only board-level wiring. New algorithms
// and OSD blocks must be inserted in rtl/app/vision_pipeline.v, not here.
module design_top_wrapper (
    input wire        I_sys_clk,
    input wire        I_rst_n,
    output wire       O_cam_scl,
    inout  wire       IO_cam_sda,
    output wire       O_cam_24m,
    output wire       O_cam_rst,
    inout  wire [3:0] I_button,
    output wire       O_screen_pwm,
    output wire       O_tmds_ch0_p,
    output wire       O_tmds_ch1_p,
    output wire       O_tmds_ch2_p,
    output wire       O_tmds_clk_p,
    inout  wire       IO_rx_clk_pad_n,
    inout  wire       IO_rx_clk_pad_p,
    inout  wire [3:0] IO_rx_data_pad_n,
    inout  wire [3:0] IO_rx_data_pad_p,
    output wire [12:0] ddr_addr,
    output wire [1:0]  ddr_ba,
    output wire [0:0]  ddr_cke,
    output wire [0:0]  ddr_odt,
    output wire [0:0]  ddr_cs_n,
    output wire       ddr_ras_n,
    output wire       ddr_cas_n,
    output wire       ddr_we_n,
    output wire [0:0] ddr_ck_p,
    output wire [0:0] ddr_ck_n,
    inout  wire [1:0] ddr_dm,
    inout  wire [15:0] ddr_dq,
    inout  wire [1:0] ddr_dqs_p,
    inout  wire [1:0] ddr_dqs_n
);

    // Application extension boundary is clocked from the board clock and
    // reset with the board reset. It is intentionally side-effect free in
    // the baseline, but is now part of the real top-level hierarchy.
    vision_pipeline u_vision_pipeline (
        .clk(I_sys_clk),
        .rst_n(I_rst_n)
    );

    // The proven factory pipeline is isolated behind one stable boundary.
    // This keeps the first hardware milestone intact while all future work
    // is attached through project-owned modules and interfaces.
    vendor_lab1_core u_vendor_pipeline (
        .I_sys_clk(I_sys_clk), .I_rst_n(I_rst_n),
        .O_cam_scl(O_cam_scl), .IO_cam_sda(IO_cam_sda),
        .O_cam_24m(O_cam_24m), .O_cam_rst(O_cam_rst),
        .I_button(I_button), .O_screen_pwm(O_screen_pwm),
        .O_tmds_ch0_p(O_tmds_ch0_p), .O_tmds_ch1_p(O_tmds_ch1_p),
        .O_tmds_ch2_p(O_tmds_ch2_p), .O_tmds_clk_p(O_tmds_clk_p),
        .IO_rx_clk_pad_n(IO_rx_clk_pad_n), .IO_rx_clk_pad_p(IO_rx_clk_pad_p),
        .IO_rx_data_pad_n(IO_rx_data_pad_n), .IO_rx_data_pad_p(IO_rx_data_pad_p),
        .ddr_addr(ddr_addr), .ddr_ba(ddr_ba), .ddr_cke(ddr_cke),
        .ddr_odt(ddr_odt), .ddr_cs_n(ddr_cs_n), .ddr_ras_n(ddr_ras_n),
        .ddr_cas_n(ddr_cas_n), .ddr_we_n(ddr_we_n), .ddr_ck_p(ddr_ck_p),
        .ddr_ck_n(ddr_ck_n), .ddr_dm(ddr_dm), .ddr_dq(ddr_dq),
        .ddr_dqs_p(ddr_dqs_p), .ddr_dqs_n(ddr_dqs_n)
    );
endmodule
