`timescale 1ps/1ps

module ph1p_ddrphy_cmd_decode #(
    parameter COL_WIDTH = 10 ,
    parameter ROW_WIDTH = 15 ,
    parameter ADR_WIDTH = 15 ,
    parameter BA_WIDTH  = 3
)(
    input                          clk             ,
    input                          rst_n           ,

    input                          cmd_vld         ,
    input        [32       -1 : 0] cmd_code        ,

    output  reg                    cmd_wr          ,
    output  reg                    cmd_rd          ,

    output  reg                    op_code_rst_n   ,
    output  reg                    op_code_cke     ,
    output  reg                    op_code_odt     ,
    output  reg                    op_code_cs_n    ,
    output  reg                    op_code_act_n   ,
    output  reg                    op_code_ras_n   ,
    output  reg                    op_code_cas_n   ,
    output  reg                    op_code_we_n    ,
    output  reg  [BA_WIDTH -1 : 0] op_code_ba      ,
    output  reg  [ADR_WIDTH-1 : 0] op_code_addr      
);
 
//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************
localparam [3 : 0] RST = 4'b1111;
localparam [3 : 0] CKE = 4'b1111;
localparam [3 : 0] MRS = 4'b1000;
localparam [3 : 0] REF = 4'b1001;
localparam [3 : 0] PRE = 4'b1010;
localparam [3 : 0] ACT = 4'b0011;
localparam [3 : 0] WR  = 4'b1100;
localparam [3 : 0] RD  = 4'b1101;
localparam [3 : 0] ZQC = 4'b1110;

localparam CMD_TYPE_WIDTH    = 4  ;
localparam CMD_COL_WIDTH     = COL_WIDTH;
localparam CMD_ROW_WIDTH     = ROW_WIDTH;
localparam CMD_BA_WIDTH      =  BA_WIDTH;

// DO NOT Change the value of OFFSET
localparam CMD_TYPE_OFFSET   = 28 ;
localparam CMD_RST_OFFSET    = 24 ;
localparam CMD_CKE_OFFSET    = 25 ;

localparam CMD_BA_OFFSET     = 20 ;
localparam CMD_A10_OFFSET    = 10 ;
localparam CMD_COL_OFFSET    = 0  ;
localparam CMD_ROW_OFFSET    = 0  ;

//*****************************************************************************************************************************
//    Internal Signals
//*****************************************************************************************************************************
wire  [3:0] cmd_type;

//*****************************************************************************************************************************
//    Op_decode
//*****************************************************************************************************************************
assign cmd_type = cmd_vld ? cmd_code[CMD_TYPE_OFFSET +: CMD_TYPE_WIDTH] : 4'h0;

// Reset & CKE 
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_rst_n <= 1'b0;
    else if (cmd_type == RST)
        op_code_rst_n <= cmd_code[CMD_RST_OFFSET];
    else
        op_code_rst_n <= op_code_rst_n; 
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_cke <= 1'b0;
    else if (cmd_type == CKE)
        op_code_cke <= cmd_code[CMD_CKE_OFFSET];
    else
        op_code_cke <= op_code_cke; 
end

// CS_N
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_cs_n <= 1'b1;
    else if ((cmd_type == MRS) ||  
             (cmd_type == REF) ||  
             (cmd_type == PRE) ||  
             (cmd_type == ACT) ||  
             (cmd_type == WR ) ||  
             (cmd_type == RD ) ||  
             (cmd_type == ZQC))
        op_code_cs_n <= 1'b0;
    else
        op_code_cs_n <= 1'b1;
end

// ACT_N/RAS_N/CAS_N/WE_N
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        {op_code_act_n, op_code_ras_n, op_code_cas_n, op_code_we_n} <= 4'b1111;
    else
        {op_code_act_n, op_code_ras_n, op_code_cas_n, op_code_we_n} <= 
             (cmd_type == MRS) ? 4'b1000 :
             (cmd_type == REF) ? 4'b1001 :
             (cmd_type == PRE) ? 4'b1010 :
             (cmd_type == ACT) ? 4'b0011 :
             (cmd_type == WR ) ? 4'b1100 :
             (cmd_type == RD ) ? 4'b1101 :
             (cmd_type == ZQC) ? 4'b1110 : 4'b1111;
end

// BA
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_ba <= {BA_WIDTH{1'b0}};
    else if ((cmd_type == MRS) ||  
             (cmd_type == PRE) ||  
             (cmd_type == ACT) ||  
             (cmd_type == WR ) ||  
             (cmd_type == RD ))
        op_code_ba <= cmd_code[CMD_BA_OFFSET +: CMD_BA_WIDTH];
    else
        op_code_ba <= {BA_WIDTH{1'b0}};
end

// ADDR
`ifdef DRAM_DDR4
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_addr <= 17'b1_1100_0000_0000_0000;
    else if ((cmd_type == ACT))
        op_code_addr <= {{(17-ROW_WIDTH){1'b0}}, cmd_code[CMD_ROW_OFFSET +: ROW_WIDTH]};
    else if ((cmd_type == MRS))
        op_code_addr <= {3'b000, cmd_code[0 +: 14]};
    else if ((cmd_type == WR))
        op_code_addr <= {3'b100, 3'b000, cmd_code[CMD_A10_OFFSET], cmd_code[CMD_COL_OFFSET +: CMD_COL_WIDTH]};
    else if ((cmd_type == RD))
        op_code_addr <= {3'b101, 3'b000, cmd_code[CMD_A10_OFFSET], cmd_code[CMD_COL_OFFSET +: CMD_COL_WIDTH]};
    else if ((cmd_type == PRE))
        op_code_addr <= {3'b010, 3'b000, cmd_code[CMD_A10_OFFSET], 10'h0};
    else if ((cmd_type == ZQC))
        op_code_addr <= {3'b110, 3'b000, cmd_code[CMD_A10_OFFSET], 10'h0};
    else
        op_code_addr <= 17'b1_1100_0000_0000_0000;
end
`else
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_addr <= {ADR_WIDTH{1'b0}};
    else if ((cmd_type == MRS) || (cmd_type == ACT))
        op_code_addr <= cmd_code[CMD_ROW_OFFSET +: ROW_WIDTH];
    else if ((cmd_type == WR) || (cmd_type == RD))
        op_code_addr <= {{(ROW_WIDTH-11){1'b0}}, cmd_code[CMD_A10_OFFSET], cmd_code[CMD_COL_OFFSET +: CMD_COL_WIDTH]};
    else if ((cmd_type == PRE) || (cmd_type == ZQC))
        op_code_addr <= {{(ROW_WIDTH-11){1'b0}}, cmd_code[CMD_A10_OFFSET], 10'h0};
    else
        op_code_addr <= {ROW_WIDTH{1'b0}};
end
`endif

// cmd_wr/cmd_rd
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        cmd_wr <= 1'b0;
    else
        cmd_wr <= (cmd_type == WR) ? 1'b1 : 1'b0;
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        cmd_rd <= 1'b0;
    else
        cmd_rd <= (cmd_type == RD) ? 1'b1 : 1'b0;
end

// op_code_odt
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        op_code_odt <= 1'b0;
    else if (cmd_type == WR)
        op_code_odt <= 1'b1;
    else if (cmd_type == RD)
        op_code_odt <= 1'b0;
    else 
        op_code_odt <= op_code_odt;
end

endmodule
