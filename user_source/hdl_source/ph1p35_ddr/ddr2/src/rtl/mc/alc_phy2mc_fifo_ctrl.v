
`timescale 1ps/1ps

module alc_phy2mc_fifo_ctrl #(
    parameter DX_NUM = 4
)(
    input                      clk   ,
    input                      rst_n ,

    input  [DX_NUM    -1 : 0]  i_vld ,
    input  [DX_NUM*8*8-1 : 0]  i_dq  ,
    output                     o_vld ,
    output [DX_NUM*8*8-1 : 0]  o_dq  ,
    output [DX_NUM    -1 : 0]  o_full
);

wire [DX_NUM*8*8-1 : 0]  dq_tmp ; 
wire [DX_NUM    -1 : 0]  empty  ;
reg                      rd_en  ;
wire [DX_NUM*8*8-1 : 0]  dout   ; 

reg  [DX_NUM*8*8-1 : 0]  i_dq_r ;
reg  [DX_NUM    -1 : 0]  i_vld_r;

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        i_dq_r <=  {(DX_NUM*8*8){1'b0}};
    else
        i_dq_r <= i_dq;
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        i_vld_r <= {DX_NUM{1'b0}};
    else
        i_vld_r <= i_vld;
end

genvar n , p;
//generate
//for (n = 0; n <= DX_NUM-1; n = n+1) begin : byteIdx_0
//    for (p = 0; p <= 7; p = p+1) begin : pIdx_0
//        assign dq_tmp[n*64 + p*8 +: 8] = i_dq_r[p*(DX_NUM*8) + n*8 +: 8];
//    end
//end
//endgenerate
assign dq_tmp = i_dq_r;

generate
    for (n = 0; n <= DX_NUM-1; n = n+1) begin : byteIdx_1
       ph1p_ddr_fifo_dram_sync #(
            .DW    ( 64 ),
            .AW    ( 4  )
        ) u_wfifo_sync (
            .clk   ( clk                 ),
            .rst   (~rst_n               ),
            .wren  ( i_vld_r[n]          ),
            .din   ( dq_tmp [n*64 +: 64] ),
            .rden  ( o_vld               ),
            .dout  ( dout   [n*64 +: 64] ),
            .full  ( o_full [n]          ),
            .empty ( empty  [n]          )
        );
    end
endgenerate

always @ (posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rd_en <= 1'b0;
    else if ( (|empty == 1'b0) )
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

assign o_dq  = dout;
assign o_vld = rd_en && (|empty == 1'b0);

endmodule

