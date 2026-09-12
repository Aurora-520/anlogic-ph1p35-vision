`timescale 1ps/1ps

module ph1p_ddrphy_sync_rst_gen (
    input    clk      ,
    input    rst_async,
    output   rst_sync ,
    output   rst_sync_n
);

reg [1:0] rst_int;
reg [1:0] rst_int_n;

always @ (posedge clk or posedge rst_async)
begin
    if (rst_async == 1'b1) begin
        rst_int[1:0] <= 2'b11;
    end else begin
        rst_int[0] <= 1'b0;
        rst_int[1] <= rst_int[0];
    end
end

always @ (posedge clk or posedge rst_async)
begin
    if (rst_async == 1'b1) begin
        rst_int_n[1:0] <= 2'b00;
    end else begin
        rst_int_n[0] <= 1'b1;
        rst_int_n[1] <= rst_int_n[0];
    end
end

assign rst_sync   = rst_int  [1];
assign rst_sync_n = rst_int_n[1];

endmodule

