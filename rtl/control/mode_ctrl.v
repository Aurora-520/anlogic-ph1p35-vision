// K1/K2/K3 mode controller. Buttons are active-low on HX1P35A.
// mode: 0=color, 1=binary, 2=edge, 3=gray.
module algorithm_mode_ctrl #(
    parameter integer DEBOUNCE_CYCLES = 750000
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [2:0] buttons_n,
    output reg  [1:0] mode
);
    localparam integer CW = (DEBOUNCE_CYCLES < 2) ? 1 : $clog2(DEBOUNCE_CYCLES);
    reg [2:0] sync1, sync2, stable;
    reg [CW-1:0] count1, count2, count3;
    reg [2:0] stable_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= 3'b111; sync2 <= 3'b111;
            stable <= 3'b111; stable_d <= 3'b111;
            count1 <= {CW{1'b0}}; count2 <= {CW{1'b0}}; count3 <= {CW{1'b0}};
            mode <= 2'd0;
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
            if (sync2[2] != stable[2]) begin
                if (count3 == DEBOUNCE_CYCLES-1) begin stable[2] <= sync2[2]; count3 <= 0; end
                else count3 <= count3 + 1'b1;
            end else count3 <= 0;

            // A press is a high-to-low transition after debouncing.
            if (stable_d[0] && !stable[0]) begin
                if (mode == 2'd1) mode <= 2'd0; else mode <= 2'd1;
            end
            if (stable_d[1] && !stable[1]) begin
                if (mode == 2'd2) mode <= 2'd0; else mode <= 2'd2;
            end
            if (stable_d[2] && !stable[2]) begin
                if (mode == 2'd3) mode <= 2'd0; else mode <= 2'd3;
            end
        end
    end
endmodule
