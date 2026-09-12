`timescale 1ps/1ps

module ph1p_ddrphy_bankref_cfg (

    input                apb_pclk   ,
    input                apb_prst_n ,
    input                apb_psel   ,
    input                apb_penable,
    input                apb_pwrite ,
    input       [7 : 0]  apb_paddr  ,
    input       [7 : 0]  apb_pwdata ,
    output reg  [7 : 0]  apb_prdata ,
    output reg           apb_pready ,

    output      [7 : 0]  vref1_ctrl ,
    output      [7 : 0]  vref2_ctrl
);

//*****************************************************************************
//    Function : APB
//*****************************************************************************

wire   apb_wr_en ;
wire   apb_rd_en ;

reg  [7:0] reg48;
reg  [7:0] reg4c;
reg  [7:0] reg50;
reg  [7:0] reg54;
reg  [7:0] reg5a;

assign apb_wr_en = apb_psel & apb_penable & (apb_pwrite==1'b1) & apb_pready;
assign apb_rd_en = apb_psel & apb_penable & (apb_pwrite==1'b0);

// apb pready control
always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0)
        apb_pready <= 1'b1;
    else if (apb_psel & (apb_penable == 1'b0))
        apb_pready <= 1'b0;
    else if (apb_psel & apb_penable & (apb_pwrite == 1'b1))
        apb_pready <= 1'b1;
    else if (apb_psel & apb_penable & (apb_pwrite == 1'b0))
        apb_pready <= apb_rd_en ;
    else
        apb_pready <= 1'b1;
end

// apb write
always @ (posedge apb_pclk or negedge apb_prst_n) begin
    if (apb_prst_n == 1'b0) begin
        reg48 <= 8'h0;
        reg4c <= 8'h0;
        reg50 <= 8'h0;
        reg54 <= 8'h0;
        reg5a <= 8'h0;
    end else if (apb_wr_en) begin
        case (apb_paddr[7:0])
            8'h48 : reg48 <= apb_pwdata;
            8'h4c : reg4c <= apb_pwdata;
            8'h50 : reg50 <= apb_pwdata;
            8'h54 : reg54 <= apb_pwdata;
            8'h5a : reg5a <= apb_pwdata;
            default: begin
            end
        endcase
    end
end

// apb_read
always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0) begin
        apb_prdata <= 8'h0;
    end else if (apb_rd_en) begin
        case (apb_paddr[7:0])
            8'h00  : apb_prdata <= 8'h56;
            8'h48  : apb_prdata <= reg48;
            8'h4c  : apb_prdata <= reg4c;
            8'h50  : apb_prdata <= reg50;
            8'h54  : apb_prdata <= reg54;
            8'h5a  : apb_prdata <= reg5a;
            default: apb_prdata <= 8'h00;
        endcase
    end else begin
        apb_prdata <= 8'h0;
    end
end

assign vref1_ctrl = (reg5a[3:0] == 4'b1) ? reg4c[7:0] : reg48[7:0];
assign vref2_ctrl = (reg5a[3:0] == 4'b1) ? reg54[7:0] : reg50[7:0];

endmodule
