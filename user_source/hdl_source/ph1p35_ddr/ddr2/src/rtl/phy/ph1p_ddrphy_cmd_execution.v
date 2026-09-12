`timescale 1ps/1ps

module ph1p_ddrphy_cmd_execution #(
    parameter ADR_WIDTH    = 15 ,
    parameter COL_WIDTH    = 10 ,
    parameter ROW_WIDTH    = 15 ,
    parameter BA_WIDTH     = 3  ,
    parameter CWL          = 5  ,
    parameter CL           = 6 
)(
    input                            clk           ,
    input                            rst_n         ,

    input                            wrlvl_en      ,

    input      [           4-1 : 0]  cmd_vld       ,
    input      [        32*4-1 : 0]  cmd_code      ,

    output     [           4-1 : 0]  cmd_wr        ,
    output     [           4-1 : 0]  cmd_rd        ,

    output reg                       dhi_rst_n     ,
    output reg [           4-1 : 0]  dhi_cke       ,
    output     [           4-1 : 0]  dhi_odt       ,
    output reg [           4-1 : 0]  dhi_cs_n      ,
    output reg [           4-1 : 0]  dhi_act_n     ,
    output reg [           4-1 : 0]  dhi_cas_n     ,
    output reg [           4-1 : 0]  dhi_ras_n     ,
    output reg [           4-1 : 0]  dhi_we_n      ,
    output reg [BA_WIDTH * 4-1 : 0]  dhi_ba        ,
    output reg [ADR_WIDTH* 4-1 : 0]  dhi_addr      ,
    output reg [           4-1 : 0]  dhi_parity
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************
localparam  RST  = 4'h1;
localparam  CKE  = 4'h2;
localparam  MRS  = 4'h3;
localparam  REF  = 4'h4;
localparam  PRE  = 4'h5;
localparam  ACT  = 4'h6;
localparam  WR   = 4'h7;
localparam  RD   = 4'h8;
localparam  ZQC  = 4'h9;

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
wire [          4-1 : 0] op_code_rst_n    ;
wire [          4-1 : 0] op_code_cke      ;
wire [          4-1 : 0] op_code_odt      ;
wire [          4-1 : 0] op_code_cs_n     ;
wire [          4-1 : 0] op_code_act_n    ;
wire [          4-1 : 0] op_code_ras_n    ;
wire [          4-1 : 0] op_code_cas_n    ;
wire [          4-1 : 0] op_code_we_n     ;
wire [BA_WIDTH *4-1 : 0] op_code_ba       ;
wire [ADR_WIDTH*4-1 : 0] op_code_addr     ;

reg  [          4-1 : 0] dhi_odt_int      ;
//*****************************************************************************************************************************
//    Function Definition
//*****************************************************************************************************************************
genvar n, p;
generate 
for (p = 0; p <= 3; p = p+1) begin : cmd_decode
    ph1p_ddrphy_cmd_decode #(
        .ROW_WIDTH  ( ROW_WIDTH ),
        .COL_WIDTH  ( COL_WIDTH ),
        .ADR_WIDTH  ( ADR_WIDTH ),
        .BA_WIDTH   ( BA_WIDTH  )
    ) u_ddrphy_cmd_decode (
        .clk              ( clk                                      ),
        .rst_n            ( rst_n                                    ),

        .cmd_vld          ( cmd_vld      [p]                         ),
        .cmd_code         ( cmd_code     [p*32 +: 32]                ),

        .cmd_wr           ( cmd_wr       [p]                         ),
        .cmd_rd           ( cmd_rd       [p]                         ),

        .op_code_rst_n    ( op_code_rst_n[p]                         ),
        .op_code_cke      ( op_code_cke  [p]                         ),
        .op_code_odt      ( op_code_odt  [p]                         ),
        .op_code_cs_n     ( op_code_cs_n [p]                         ),
        .op_code_act_n    ( op_code_act_n[p]                         ),
        .op_code_ras_n    ( op_code_ras_n[p]                         ),
        .op_code_cas_n    ( op_code_cas_n[p]                         ),
        .op_code_we_n     ( op_code_we_n [p]                         ),
        .op_code_ba       ( op_code_ba   [p* BA_WIDTH  +:  BA_WIDTH] ),
        .op_code_addr     ( op_code_addr [p*ADR_WIDTH  +: ADR_WIDTH] )
    );
end
endgenerate

// output
always @ (posedge clk or negedge rst_n)
begin 
    if (rst_n == 1'b0) begin
        dhi_rst_n <= 1'b0;
        dhi_cke   <= 4'h0;
        dhi_cs_n  <= 4'hf;
        dhi_act_n <= 4'hf;
        dhi_ras_n <= 4'hf;
        dhi_cas_n <= 4'hf;
        dhi_we_n  <= 4'hf;
    end else begin
        dhi_rst_n <=  op_code_rst_n[0];
        dhi_cke   <= {4{op_code_cke[0]}};
        dhi_cs_n  <=  (wrlvl_en == 1'b1) ? 4'hf : op_code_cs_n  ;
        dhi_act_n <=  op_code_act_n ;
        dhi_ras_n <=  op_code_ras_n ;
        dhi_cas_n <=  op_code_cas_n ;
        dhi_we_n  <=  op_code_we_n  ;
    end
end


always @ (posedge clk or negedge rst_n)
begin 
    if (rst_n == 1'b0)
        dhi_odt_int <= 4'h0; 
    else if (wrlvl_en == 1'b1)
        dhi_odt_int <= 4'h0;
    else if (|cmd_wr == 1'b1)
        dhi_odt_int <= 4'hf;
    else if (|cmd_rd == 1'b1)
        dhi_odt_int <= 4'h0;
    else
        dhi_odt_int <= dhi_odt_int;
end

assign dhi_odt = (wrlvl_en == 1'b1) ? 4'hf : dhi_odt_int ;

// dhi_ba
for (n = 0; n <= BA_WIDTH-1; n = n+1) begin : ba_bit
    for (p = 0; p <= 3; p = p+1) begin : ba_phase
        always @ (posedge clk or negedge rst_n)
        begin 
            if (rst_n == 1'b0)
                dhi_ba[n*4+p] <= 1'b0;
            else
                dhi_ba[n*4+p] <= op_code_ba[p*BA_WIDTH+n];
        end
    end
end

// dhi_addr
for (n = 0; n <= ADR_WIDTH-1; n = n+1) begin : addr_bit
    for (p = 0; p <= 3; p = p+1) begin : addr_phase
        always @ (posedge clk or negedge rst_n)
        begin 
            if (rst_n == 1'b0)
                dhi_addr[n*4+p] <= 1'b0;
            else
                dhi_addr[n*4+p] <= op_code_addr[p*ADR_WIDTH+n];
        end
    end
end

// parity : even parity gen
// act_n/addr/bg_ba
`ifdef DRAM_DDR4
wire [3:0] cmd_even;

for (p = 0; p <= 3; p = p+1) begin: cmd_even_gen
    assign cmd_even[p] = dhi_act_n[p] ^ (^dhi_ba[p*BA_WIDTH +: BA_WIDTH]) + (^dhi_addr[p*ADR_WIDTH +: ADR_WIDTH]);
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dhi_parity <= 4'h0;
    end else begin
        dhi_parity <= cmd_even;
    end
end
`else
always @ (posedge clk)
begin
    dhi_parity <= 4'h0;
end
`endif

endmodule
