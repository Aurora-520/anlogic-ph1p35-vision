//************************************************************************************************
// Name   :
// Author : xtong
// Function Description :
//************************************************************************************************

`timescale 1ps / 1ps

module ph1p_ddr_fifo_dram_sync #(
    parameter DW  = 32,
    parameter AW  = 4
)(
    input               clk  ,
    input               rst  ,
    input               wren ,
    input               rden ,
    input      [DW-1:0] din  ,
    output     [DW-1:0] dout ,
    output reg          full ,
    output reg          empty
);

//////////////////////////////////////////////////////////////////////////////////////////////////
// Local Parameters
//////////////////////////////////////////////////////////////////////////////////////////////////
localparam TCQ = 0; // in ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Register & Nets Definition
//////////////////////////////////////////////////////////////////////////////////////////////////
reg  [DW-1:0] data[(2**AW)-1:0]; // synthesis ram_style=dram
reg  [AW-1:0] rdptr;
reg  [AW-1:0] wrptr;   
reg  [AW  :0] cnt;
reg  [AW  :0] cnt_nxt;

wire          write;
wire          read;

//////////////////////////////////////////////////////////////////////////////////////////////////
// Function
//////////////////////////////////////////////////////////////////////////////////////////////////
assign write = wren && ~full;
assign read  = rden && ~empty;

// wirte pointer control
always @ (posedge clk) begin
    if (rst) begin
        wrptr <= #TCQ 'h0;
    end else if (write) begin
        wrptr <= #TCQ wrptr + 1'b1;
    end
end

// read pointer control
always @ (posedge clk) begin
    if (rst) begin
        rdptr <= #TCQ 'h0;
    end else if (read) begin
        rdptr <= #TCQ rdptr + 1'b1;
    end
end

// memory storage control
always @ (posedge clk) begin
    if (write) begin
        data[wrptr[AW-1:0]] <= #TCQ din;
    end
end

// control single generation
always @ (posedge clk) begin
    if (rst) begin
        cnt   <= #TCQ {(AW+1){1'b0}};
        full  <= #TCQ 1'b0;
        empty <= #TCQ 1'b1;
    end else begin
        cnt   <= #TCQ  cnt_nxt;
        full  <= #TCQ (cnt_nxt == (2**AW) - 4);
        empty <= #TCQ (cnt_nxt == 'h0);
    end
end

always @ (*) begin
    casez ({write, read})
        2'b00: cnt_nxt = cnt;
        2'b01: cnt_nxt = cnt - 1'b1;
        2'b10: cnt_nxt = cnt + 1'b1;
        2'b11: cnt_nxt = cnt;   
    endcase
end

assign dout = data[rdptr[AW-1:0]];

endmodule

