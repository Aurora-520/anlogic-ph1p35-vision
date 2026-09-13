// Project video-stream contract. Modules may use these names when the
// application pipeline is enabled; vendor IP remains isolated from this API.
`ifndef VIDEO_STREAM_IF_VH
`define VIDEO_STREAM_IF_VH
// Signals: frame_start, line_end, valid, data[PIXEL_BITS-1:0]
`define VIDEO_STREAM_PORTS \
    input  wire frame_start, input wire line_end, input wire valid, \
    input  wire [`VISION_PIXEL_BITS-1:0] data
`endif
