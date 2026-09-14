// Always-on Anlogic logo overlay, adapted from Lab3's anlogic_logo_rom.
// The alpha bit is bit 24; RGB is bits 23:0. Logo position is intentionally
// fixed at the active-frame origin and is independent of algorithm mode.
module logo_overlay #(
    parameter integer IMG_WIDTH = 1280,
    parameter integer IMG_HEIGHT = 720,
    parameter integer LOGO_X = 0,
    parameter integer LOGO_Y = 0,
    parameter integer LOGO_W = 160,
    parameter integer LOGO_H = 160
)(
    input wire clk,
    input wire rst_n,
    input wire frame_start,
    input wire line_end,
    input wire de,
    input wire [23:0] pixel_in,
    output reg [23:0] pixel_out
);
    reg [11:0] x;
    reg [11:0] y;
    reg [14:0] logo_addr;
    wire [24:0] logo_pixel;
    wire in_logo = de && (x >= LOGO_X) && (x < LOGO_X + LOGO_W) &&
                   (y >= LOGO_Y) && (y < LOGO_Y + LOGO_H);

    anlogic_logo_rom u_logo_rom(.I_addr(logo_addr), .O_pixel(logo_pixel));

    always @* begin
        logo_addr = 15'd0;
        if (in_logo) begin
            // The Lab3 logo is 160 pixels wide. Express 160 as 128+32 so
            // TD maps the row offset to wiring/LUTs instead of a DSP multiply
            // on the 75 MHz HDMI pixel path.
            logo_addr = (((y - LOGO_Y) << 7) + ((y - LOGO_Y) << 5))
                      + (x - LOGO_X);
        end
        if (in_logo && logo_pixel[24]) pixel_out = logo_pixel[23:0];
        else pixel_out = pixel_in;
        if (!de) pixel_out = 24'd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin x <= 0; y <= 0; end
        else if (frame_start) begin x <= 0; y <= 0; end
        else if (de) begin
            if (line_end) begin
                x <= 0;
                if (y == IMG_HEIGHT-1) y <= 0; else y <= y + 1'b1;
            end else if (x == IMG_WIDTH-1) x <= 0;
            else x <= x + 1'b1;
        end
    end
endmodule
