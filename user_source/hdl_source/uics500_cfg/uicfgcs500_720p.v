`timescale 1ns / 1ns

module uicfgcs500_720p #(
    parameter CLK_DIV = 16'd239
)(
    input  wire        I_clk,
    input  wire        I_rst_n,
    input  wire        I_ae_req,
    input  wire [15:0] I_ae,
    input  wire [15:0] I_ag,
    output wire        O_cam_scl,
    inout  wire        IO_cam_sda,
    output reg         O_cfg_done,
    output reg         O_ae_cfg_done
);

localparam CAM_ID = 8'h6c;
localparam [17:0] POST_STREAM_DELAY = 18'd240000;

reg [7:0]  rst_cnt = 8'd0;
reg        iic_req;
wire       iic_busy;
reg [31:0] wr_data;
reg [1:0]  state;
reg [8:0]  reg_index;
reg [17:0] delay_cnt;

wire [23:0] init_data;
wire [8:0]  init_size;
wire [23:0] ae_data;
wire [8:0]  ae_size;
wire [23:0] selected_data = O_cfg_done ? ae_data : init_data;
wire [8:0]  selected_size = O_cfg_done ? ae_size : init_size;

always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n)
        rst_cnt <= 8'd0;
    else if (!rst_cnt[7])
        rst_cnt <= rst_cnt + 1'b1;
end

always @(posedge I_clk) begin
    if (!rst_cnt[7]) begin
        reg_index            <= 9'd0;
        iic_req              <= 1'b0;
        wr_data              <= 32'd0;
        O_cfg_done           <= 1'b0;
        O_ae_cfg_done        <= 1'b0;
        delay_cnt            <= 18'd0;
        state                <= 2'd0;
    end else begin
        case (state)
            2'd0: begin
                iic_req <= 1'b0;
                if (!O_cfg_done) begin
                    if ((reg_index == 9'd115) && (delay_cnt < POST_STREAM_DELAY)) begin
                        // Factory file requests 10 ms between 0x0100=1 and 0x302d=0.
                        delay_cnt <= delay_cnt + 1'b1;
                    end else if (reg_index == init_size) begin
                        O_cfg_done    <= 1'b1;
                        O_ae_cfg_done <= 1'b1;
                        reg_index     <= 9'd0;
                    end else begin
                        state <= 2'd1;
                    end
                end else if (I_ae_req) begin
                    O_ae_cfg_done <= 1'b0;
                    reg_index     <= 9'd0;
                end else if (!O_ae_cfg_done) begin
                    if (reg_index == ae_size)
                        O_ae_cfg_done <= 1'b1;
                    else
                        state <= 2'd1;
                end
            end
            2'd1: begin
                if (!iic_busy) begin
                    iic_req       <= 1'b1;
                    wr_data[7:0]  <= CAM_ID;
                    wr_data[15:8] <= selected_data[23:16];
                    wr_data[23:16]<= selected_data[15:8];
                    wr_data[31:24]<= selected_data[7:0];
                    state         <= 2'd2;
                end
            end
            2'd2: begin
                if (iic_busy) begin
                    iic_req <= 1'b0;
                    state   <= 2'd3;
                end
            end
            2'd3: begin
                if (!iic_busy) begin
                    reg_index <= reg_index + 1'b1;
                    state     <= 2'd0;
                end
            end
        endcase
    end
end

uii2c #(
    .WMEN_LEN (4),
    .RMEN_LEN (1),
    .CLK_DIV  (CLK_DIV)
) u_i2c (
    .I_clk      (I_clk),
    .I_rstn     (rst_cnt[7]),
    .O_iic_scl  (O_cam_scl),
    .IO_iic_sda (IO_cam_sda),
    .I_wr_data  (wr_data),
    .I_wr_cnt   (8'd4),
    .O_rd_data  (),
    .I_rd_cnt   (8'd0),
    .I_iic_mode (1'b0),
    .I_iic_req  (iic_req),
    .O_iic_busy (iic_busy)
);

uics500reg_720p60 u_init_table (
    .REG_INDEX (reg_index),
    .REG_DATA  (init_data),
    .REG_SIZE  (init_size)
);

wire [15:0] gain_value;
SC500GainTbl u_gain_table (
    .I_clk  (I_clk),
    .I_rstn (rst_cnt[7]),
    .I      (I_ag - 16),
    .O      (gain_value)
);

uics500regAE u_ae_table (
    .REG_INDEX (reg_index),
    .REG_DATA  (ae_data),
    .REG_SIZE  (ae_size),
    .I_AG      (gain_value),
    .I_AE      (I_ae)
);

endmodule
