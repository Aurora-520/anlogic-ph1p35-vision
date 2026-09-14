// Streaming pixel algorithms in the HDMI pixel clock domain.
// mode 0: passthrough, mode 1: binary, mode 2: gray, mode 3: Sobel edge,
// mode 4: cartoon (color quantization with Sobel edge overlay).
module pixel_algorithm #(
    parameter integer IMG_WIDTH = 1280,
    parameter integer IMG_HEIGHT = 720,
    parameter integer BINARY_TH = 8'd96,
    parameter integer EDGE_TH = 11'd80
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [2:0] mode,
    input  wire       frame_start,
    input  wire       line_end,
    input  wire       de,
    input  wire [23:0] pixel_in,
    output reg  [23:0] pixel_out
);
    reg [10:0] x;
    reg [10:0] y;
    (* ram_style = "block" *) reg [7:0] line1 [0:IMG_WIDTH-1];
    (* ram_style = "block" *) reg [7:0] line2 [0:IMG_WIDTH-1];
    reg [7:0] top_prev2, top_prev1, mid_prev2, mid_prev1, bot_prev2, bot_prev1;

    wire [7:0] gray = {2'b0,pixel_in[23:18]} + {1'b0,pixel_in[15:9]} + {2'b0,pixel_in[7:2]};
    wire [7:0] top_now = line2[x];
    wire [7:0] mid_now = line1[x];
    wire [7:0] bot_now = gray;
    wire signed [12:0] gx = -$signed({1'b0,top_prev2}) + $signed({1'b0,top_now})
                           - ($signed({1'b0,mid_prev2}) <<< 1) + ($signed({1'b0,mid_now}) <<< 1)
                           - $signed({1'b0,bot_prev2}) + $signed({1'b0,bot_now});
    wire signed [12:0] gy =  $signed({1'b0,top_prev2}) + ($signed({1'b0,top_prev1}) <<< 1) + $signed({1'b0,top_now})
                           - $signed({1'b0,bot_prev2}) - ($signed({1'b0,bot_prev1}) <<< 1) - $signed({1'b0,bot_now});
    wire [12:0] abs_gx = gx[12] ? (~gx + 1'b1) : gx;
    wire [12:0] abs_gy = gy[12] ? (~gy + 1'b1) : gy;
    wire [13:0] magnitude = abs_gx + abs_gy;
    wire edge_valid = de && (y >= 11'd2) && (x >= 11'd2);
    wire [23:0] binary_pixel = (gray >= BINARY_TH) ? 24'hffffff : 24'h000000;
    wire [23:0] gray_pixel = {gray,gray,gray};
    wire [23:0] edge_pixel = (edge_valid && magnitude >= EDGE_TH) ? 24'hffffff : 24'h000000;
    // Three bits per channel produce stable posterized color regions while
    // keeping the operation purely combinational in the pixel clock domain.
    wire [23:0] quantized_pixel = {pixel_in[23:21],5'b0,
                                   pixel_in[15:13],5'b0,
                                   pixel_in[7:5],5'b0};
    wire [23:0] cartoon_pixel = (edge_valid && magnitude >= EDGE_TH) ?
                                 24'h101010 : quantized_pixel;

    always @* begin
        case (mode)
            3'd1: pixel_out = binary_pixel;
            3'd2: pixel_out = gray_pixel;
            3'd3: pixel_out = edge_pixel;
            3'd4: pixel_out = cartoon_pixel;
            default: pixel_out = pixel_in;
        endcase
        if (!de) pixel_out = 24'd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0; y <= 0;
            top_prev2 <= 0; top_prev1 <= 0; mid_prev2 <= 0; mid_prev1 <= 0; bot_prev2 <= 0; bot_prev1 <= 0;
        end else if (frame_start) begin
            x <= 0; y <= 0;
            top_prev2 <= 0; top_prev1 <= 0; mid_prev2 <= 0; mid_prev1 <= 0; bot_prev2 <= 0; bot_prev1 <= 0;
        end else if (de) begin
            line2[x] <= mid_now;
            line1[x] <= bot_now;
            top_prev2 <= top_prev1; top_prev1 <= top_now;
            mid_prev2 <= mid_prev1; mid_prev1 <= mid_now;
            bot_prev2 <= bot_prev1; bot_prev1 <= bot_now;
            if (line_end) begin
                x <= 0;
                if (y == IMG_HEIGHT-1) y <= 0; else y <= y + 1'b1;
                top_prev2 <= 0; top_prev1 <= 0; mid_prev2 <= 0; mid_prev1 <= 0; bot_prev2 <= 0; bot_prev1 <= 0;
            end else if (x == IMG_WIDTH-1) x <= 0;
            else x <= x + 1'b1;
        end
    end
endmodule
