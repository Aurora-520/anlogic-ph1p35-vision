// K1/K2 mode controller. Buttons are active-low on HX1P35A.
// mode: 0=color, 1=binary, 2=gray, 3=edge, 4=cartoon.
// K1 cycles the four ISP modes. K2 toggles color/cartoon; from any ISP
// mode, K2 first returns to color so the two controls remain independent.
module algorithm_mode_ctrl #(
    parameter integer DEBOUNCE_CYCLES = 750000
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [1:0] buttons_n,
    output reg  [2:0] mode
);
    localparam integer CW = (DEBOUNCE_CYCLES < 2) ? 1 : $clog2(DEBOUNCE_CYCLES);
    reg [1:0] sync1, sync2, stable;
    reg [CW-1:0] count1, count2;
    reg [1:0] stable_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= 2'b11; sync2 <= 2'b11;
            stable <= 2'b11; stable_d <= 2'b11;
            count1 <= {CW{1'b0}}; count2 <= {CW{1'b0}};
            mode <= 3'd0;
        end else begin
            sync1 <= buttons_n;
            sync2 <= sync1;
            stable_d <= stable;
            if (sync2[0] != stable[0]) begin
                if (count1 == DEBOUNCE_CYCLES-1) begin stable[0] <= sync2[0]; count1 <= 0; end
                else count1 <= count1 + 1'b1;
            end else count1 <= 0;
            if (sync2[1] != stable[1]) begin
                if (count2 == DEBOUNCE_CYCLES-1) begin stable[1] <= sync2[1]; count2 <= 0; end
                else count2 <= count2 + 1'b1;
            end else count2 <= 0;
            // A press is a high-to-low transition after debouncing.
            if (stable_d[0] && !stable[0]) begin
                if (mode == 3'd4) mode <= 3'd0;
                else if (mode == 3'd3) mode <= 3'd0;
                else if (mode == 3'd2) mode <= 3'd3;
                else if (mode == 3'd1) mode <= 3'd2;
                else mode <= 3'd1;
            end
            if (stable_d[1] && !stable[1]) begin
                if (mode == 3'd0) mode <= 3'd4;
                else mode <= 3'd0;
            end
        end
    end
endmodule
