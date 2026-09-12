
// Module : ph1p_ddrphy_rphase_ctrl

`timescale 1ps/1ps

module ph1p_ddrphy_rphase_ctl #(
    parameter  [4:0]  CL  =  9
)(
// clock & reset
    input               clk          ,
    input               rst_n        ,

// misc ctrl 
    input               lb_en        ,
    input      [ 3 : 0] rsl          ,
    input      [ 3 : 0] rd_en        ,

// rdata output
    output              rdq_vld      ,
    output     [63 : 0] rdq_data     ,

// output to GLUE   
    output     [ 7 : 0] te           ,
    output     [ 7 : 0] pdr          ,
    output     [ 7 : 0] gate
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
reg   [ 3:0]  rd_en_r0;
reg   [ 3:0]  rd_en_r1;
reg   [ 3:0]  rd_en_r2;
reg   [ 3:0]  rd_en_r3;
wire  [ 3:0]  rd_en_int;

wire  [ 7:0]  rlatency = CL*2 + rsl - 2; // CL*2 + rsl - 2ui
wire  [ 3:0]  tsel = rlatency[6:3]; // in ctrl_clk
wire  [ 3:0]  psel = rlatency[2:0]; // in ui

//*****************************************************************************************************************************
//    Function : Read Cmd Detect
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        rd_en_r0 <= 4'h0;
        rd_en_r1 <= 4'h0;
        rd_en_r2 <= 4'h0;
        rd_en_r3 <= 4'h0;
    end else begin
        rd_en_r0 <= rd_en;
        rd_en_r1 <= rd_en_r0;
        rd_en_r2 <= rd_en_r1;
        rd_en_r3 <= rd_en_r2;
    end
end

assign rd_en_int = (tsel == 4'h0) ? rd_en    :
                   (tsel == 4'h1) ? rd_en_r0 :
                   (tsel == 4'h2) ? rd_en_r1 :
                   (tsel == 4'h3) ? rd_en_r2 :
                   (tsel == 4'h4) ? rd_en_r3 : rd_en;

//*****************************************************************************************************************************
//    Function : Gate Generation
//*****************************************************************************************************************************
wire  [19:0]  gate_pat = 20'b0000_0000_0000_0111_1111;
reg   [19:0]  gate_load;  

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        gate_load <= 20'h0;
    end else if (rd_en_int[0] == 1'b1) begin
        gate_load <= {8'h00, gate_load[19:8]} | (gate_pat << (psel+4'h0));
    end else if (rd_en_int[1] == 1'b1) begin
        gate_load <= {8'h00, gate_load[19:8]} | (gate_pat << (psel+4'h2));
    end else if (rd_en_int[2] == 1'b1) begin
        gate_load <= {8'h00, gate_load[19:8]} | (gate_pat << (psel+4'h4));
    end else if (rd_en_int[3] == 1'b1) begin
        gate_load <= {8'h00, gate_load[19:8]} | (gate_pat << (psel+4'h6));
    end else begin
        gate_load <= {8'h00, gate_load[19:8]};
    end
end

//*****************************************************************************************************************************
//    Function : TE Generation
//*****************************************************************************************************************************
wire  [19:0]  te_pat = 20'b0000_0000_0011_1111_1111;
reg   [19:0]  te_load;  

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        te_load <= 20'h0;
    end else if (rd_en_int[0] == 1'b1) begin
        te_load <= {8'h00, te_load[19:8]} | (te_pat << (psel+4'h0));
    end else if (rd_en_int[1] == 1'b1) begin
        te_load <= {8'h00, te_load[19:8]} | (te_pat << (psel+4'h2));
    end else if (rd_en_int[2] == 1'b1) begin
        te_load <= {8'h00, te_load[19:8]} | (te_pat << (psel+4'h4));
    end else if (rd_en_int[3] == 1'b1) begin
        te_load <= {8'h00, te_load[19:8]} | (te_pat << (psel+4'h6));
    end else begin
        te_load <= {8'h00, te_load[19:8]};
    end
end

//*****************************************************************************************************************************
//    Function : PDR Generation
//*****************************************************************************************************************************
wire  [19:0]  pdr_pat = 20'b0000_0000_0111_1111_1111;
reg   [19:0]  pdr_load;  

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        pdr_load <= 20'h0;
    end else if (rd_en_int[0] == 1'b1) begin
        pdr_load <= {8'h00, pdr_load[19:8]} | (pdr_pat << (psel+4'h0));
    end else if (rd_en_int[1] == 1'b1) begin
        pdr_load <= {8'h00, pdr_load[19:8]} | (pdr_pat << (psel+4'h2));
    end else if (rd_en_int[2] == 1'b1) begin
        pdr_load <= {8'h00, pdr_load[19:8]} | (pdr_pat << (psel+4'h4));
    end else if (rd_en_int[3] == 1'b1) begin
        pdr_load <= {8'h00, pdr_load[19:8]} | (pdr_pat << (psel+4'h6));
    end else begin
        pdr_load <= {8'h00, pdr_load[19:8]};
    end
end

//*****************************************************************************************************************************
//    Function : Output
//*****************************************************************************************************************************
assign gate = lb_en ? 8'h00 : (~gate_load[7:0]);
assign pdr  = lb_en ? 8'h00 : ( ~pdr_load[7:0]);
assign te   = lb_en ? 8'hff : (   te_load[7:0]);

endmodule
