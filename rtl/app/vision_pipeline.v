`include "../config/vision_config.vh"
// Reserved project-owned pipeline boundary. It is intentionally inactive in
// the baseline build; enabling it will not require touching vendor RTL.
module vision_pipeline #(
    parameter ENABLE_EDGE = `VISION_ENABLE_EDGE,
    parameter ENABLE_OSD  = `VISION_ENABLE_OSD
)(
    input wire clk,
    input wire rst_n
);
    // Extension point for edge detection, OSD, and mode control.
endmodule
