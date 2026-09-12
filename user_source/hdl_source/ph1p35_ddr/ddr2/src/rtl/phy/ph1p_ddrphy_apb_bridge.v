
`timescale 1ps/1ps

module ph1p_ddrphy_apb_bridge (
    input               slv_apb_pclk    ,
    input               slv_apb_prst_n  ,
    input               slv_apb_psel    ,
    input               slv_apb_penable ,
    input               slv_apb_pwrite  ,
    input       [31:0]  slv_apb_paddr   ,
    input       [31:0]  slv_apb_pwdata  ,
    output      [31:0]  slv_apb_prdata  ,
    output  reg         slv_apb_pready  ,

    input               mst_apb_pclk    ,
    input               mst_apb_prst_n  ,
    output  reg         mst_apb_psel    ,
    output  reg         mst_apb_penable ,
    output  reg         mst_apb_pwrite  ,
    output  reg [31:0]  mst_apb_paddr   ,
    output  reg [31:0]  mst_apb_pwdata  ,
    input       [31:0]  mst_apb_prdata  ,
    input               mst_apb_pready
);

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Local Parameter
///////////////////////////////////////////////////////////////////////////////////////////////////

localparam [1:0] S_IDLE   = 2'b00;
localparam [1:0] S_SETUP  = 2'b01;
localparam [1:0] S_ACCESS = 2'b11;
localparam [1:0] S_WAIT   = 2'b10;

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Internal Signals
///////////////////////////////////////////////////////////////////////////////////////////////////
// Slave Clock Domain
wire         slv_apb_wen;
wire         slv_apb_ren;
reg          slv_apb_wen_r;
reg          slv_apb_ren_r;

wire         slv_apb_wen_pos;
wire         slv_apb_ren_pos;

wire         slv_apb_ack;
reg   [ 3:0] slv_apb_ack_r;

reg   [31:0] slv_addr;
reg   [31:0] slv_wdata;
reg   [31:0] slv_rdata;

// Master Clock Domain
reg   [ 1:0] mst_state;

reg   [ 3:0] mst_wen_r;
reg   [ 3:0] mst_ren_r;
wire         mst_apb_wen;
wire         mst_apb_ren;

reg   [31:0] mst_addr;
reg   [31:0] mst_wdata;
reg   [31:0] mst_rdata;

wire         mst_apb_wack;
wire         mst_apb_rack;
reg          mst_apb_ack;

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Slave APB Timing Control
///////////////////////////////////////////////////////////////////////////////////////////////////

assign slv_apb_wen = slv_apb_psel & slv_apb_penable & (slv_apb_pwrite == 1'b1);
assign slv_apb_ren = slv_apb_psel & slv_apb_penable & (slv_apb_pwrite == 1'b0);

always @ (posedge slv_apb_pclk or negedge slv_apb_prst_n)
begin
    if (slv_apb_prst_n == 1'b0) begin
        slv_apb_wen_r <= 1'b0;
        slv_apb_ren_r <= 1'b0;
    end else begin
        slv_apb_wen_r <= slv_apb_wen;
        slv_apb_ren_r <= slv_apb_ren;
    end
end

assign slv_apb_wen_pos = (slv_apb_wen == 1'b1) & (slv_apb_wen_r == 1'b0);
assign slv_apb_ren_pos = (slv_apb_ren == 1'b1) & (slv_apb_ren_r == 1'b0);

always @ (posedge slv_apb_pclk or negedge slv_apb_prst_n)
begin
    if (slv_apb_prst_n == 1'b0)
        slv_apb_pready <= 1'b0;
    else if ((slv_apb_psel == 1'b1) && (slv_apb_penable == 1'b0))
        slv_apb_pready <= 1'b0;
    else if ((slv_apb_psel == 1'b1) && (slv_apb_penable == 1'b1) && (slv_apb_ack == 1'b1))
        slv_apb_pready <= 1'b1;
end

assign slv_apb_prdata = slv_rdata;

// Capture Address & Wdata
always @ (posedge slv_apb_pclk or negedge slv_apb_prst_n)
begin
    if (slv_apb_prst_n == 1'b0) begin
        slv_addr  <= 32'h0;
        slv_wdata <= 32'h0;
    end else begin
        slv_addr  <= (slv_apb_wen_pos || slv_apb_ren_pos) ? slv_apb_paddr  : slv_addr;
        slv_wdata <= (slv_apb_wen_pos) ? slv_apb_pwdata : slv_wdata;
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Slave APB to Master APB interaction
///////////////////////////////////////////////////////////////////////////////////////////////////
// Single-Bit CDC
always @ (posedge mst_apb_pclk or negedge slv_apb_wen_r)
begin
    if (slv_apb_wen_r == 1'b0) begin
        mst_wen_r[3:0] <= 4'b0000;
    end else begin
        mst_wen_r[3:0] <= {mst_wen_r[2:0], 1'b1};
    end
end

always @ (posedge mst_apb_pclk or negedge slv_apb_ren_r)
begin
    if (slv_apb_ren_r == 1'b0) begin
        mst_ren_r[3:0] <= 4'b0000;
    end else begin
        mst_ren_r[3:0] <= {mst_ren_r[2:0], 1'b1};
    end
end

assign mst_apb_wen = (mst_wen_r[3] == 1'b0) & (mst_wen_r[2] == 1'b1);
assign mst_apb_ren = (mst_ren_r[3] == 1'b0) & (mst_ren_r[2] == 1'b1);

// Multi-Bit CDC
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_addr  <= 32'h0;
        mst_wdata <= 32'h0;
    end else if (mst_apb_wen || mst_apb_ren) begin
        mst_addr  <= slv_addr;
        mst_wdata <= slv_wdata;
    end
end

// mst_apb_ack to slv_apb_ack
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_ack <= 1'b0;
    end else if (mst_apb_wen || mst_apb_ren) begin
        mst_apb_ack <= 1'b0;
    end else if (mst_apb_wack || mst_apb_rack) begin
        mst_apb_ack <= 1'b1;
    end
end

always @ (posedge slv_apb_pclk or negedge mst_apb_ack)
begin
    if (mst_apb_ack == 1'b0)
        slv_apb_ack_r[3:0] <= 4'b0000;
    else
        slv_apb_ack_r[3:0] <= {slv_apb_ack_r[2:0], 1'b1};
end

assign slv_apb_ack = (slv_apb_ack_r[2] == 1'b1) & (slv_apb_ack_r[3] == 1'b0);

// mst_apb_rdata to slv_apb_rdata
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_rdata <= 32'h0;
    end else if (mst_apb_rack) begin
        mst_rdata <= mst_apb_prdata;
    end
end

always @ (posedge slv_apb_pclk or negedge slv_apb_prst_n)
begin
    if (slv_apb_prst_n == 1'b0)
        slv_rdata <= 32'h0;
    else
        slv_rdata <= mst_rdata;
end

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Master APB Timing Control
///////////////////////////////////////////////////////////////////////////////////////////////////
// Master APB FSM
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0)
        mst_state <= S_IDLE;
    else case (mst_state)
        S_IDLE   : mst_state <= (mst_apb_wen || mst_apb_ren) ? S_SETUP : S_IDLE;
        S_SETUP  : mst_state <= S_ACCESS;
        S_ACCESS : mst_state <= S_WAIT;
        S_WAIT   : mst_state <= (mst_apb_pready == 1'b1) ? ((mst_apb_wen || mst_apb_ren) ? S_SETUP : S_IDLE) : S_WAIT;
        default  : mst_state <= S_IDLE;
    endcase
end

assign mst_apb_wack = mst_apb_psel & mst_apb_penable & mst_apb_pready & (mst_apb_pwrite == 1'b1);
assign mst_apb_rack = mst_apb_psel & mst_apb_penable & mst_apb_pready & (mst_apb_pwrite == 1'b0);


// Master APB Signal Output
// apb_psel
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_psel <= 1'b0;
    end else begin
        mst_apb_psel <= (mst_state == S_SETUP) ? 1'b1 : (mst_apb_wack | mst_apb_rack) ? 1'b0 : mst_apb_psel;
    end
end

// apb_penable
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_penable <= 1'b0;
    end else begin
        mst_apb_penable <= (mst_state == S_ACCESS) ? 1'b1 : (mst_apb_wack | mst_apb_rack) ? 1'b0 : mst_apb_penable;
    end
end

// apb_pwrite
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_pwrite <= 1'b0;
    end else begin
        mst_apb_pwrite <= mst_apb_wen ? 1'b1 : mst_apb_ren ? 1'b0 : mst_apb_pwrite;
    end
end

// apb_paddr
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_paddr <= 32'h0;
    end else begin
        mst_apb_paddr <= mst_addr;
    end
end

// apb_pwdata
always @ (posedge mst_apb_pclk or negedge mst_apb_prst_n)
begin
    if (mst_apb_prst_n == 1'b0) begin
        mst_apb_pwdata <= 32'h0;
    end else begin
        mst_apb_pwdata <= mst_wdata;
    end
end


///////////////////////////////////////////////////////////////////////////////////////////////////
//  End of module
///////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
