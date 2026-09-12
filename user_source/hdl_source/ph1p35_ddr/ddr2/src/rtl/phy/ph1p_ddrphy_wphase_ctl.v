
// Module : ph1p_ddrphy_wphase_ctrl

`timescale 1ps/1ps

module ph1p_ddrphy_wphase_ctl #(
    parameter  [4:0]  CWL    = 9
)(
// clock & reset
    input               clk          ,
    input               rst_n        ,

// misc ctrl 
    input               lb_en        ,
    input      [ 3 : 0] wsl          ,
    input               wrlvl_en     ,
    input      [ 3 : 0] wr_en        ,

// wdata ctrl
    output              wdq_en       ,
    input      [63 : 0] wdq_data     ,
    input      [ 7 : 0] wdq_mask     ,

// output to GLUE   
    output     [ 7 : 0] oe           ,
    output     [63 : 0] wdq          ,
    output     [ 7 : 0] wdm          ,
    output     [ 7 : 0] wdqs
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
reg   [ 3:0]  wr_en_r0;
reg   [ 3:0]  wr_en_r1;
reg   [ 3:0]  wr_en_r2;
reg   [ 3:0]  wr_en_r3;
wire  [ 3:0]  wr_en_int;
wire  [ 3:0]  wr_en_pre;

wire  [ 7:0]  wlatency = CWL*2 + wsl - 2 - 2 + 1; // CWL*2 + wsl - twpre - 2ui + 1ui
wire  [ 3:0]  tsel = wlatency[6:3]; // in ctrl_clk
wire  [ 3:0]  psel = wlatency[2:0]; // in ui

//*****************************************************************************************************************************
//    Function : WR Cmd Detect
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        wr_en_r0 <= 4'h0;
        wr_en_r1 <= 4'h0;
        wr_en_r2 <= 4'h0;
        wr_en_r3 <= 4'h0;
    end else begin
        wr_en_r0 <= wr_en;
        wr_en_r1 <= wr_en_r0;
        wr_en_r2 <= wr_en_r1;
        wr_en_r3 <= wr_en_r2;
    end
end

assign wr_en_int = (tsel == 4'h0) ? wr_en    :
                   (tsel == 4'h1) ? wr_en_r0 :
                   (tsel == 4'h2) ? wr_en_r1 :
                   (tsel == 4'h3) ? wr_en_r2 :
                   (tsel == 4'h4) ? wr_en_r3 : wr_en;

assign wr_en_pre = ((tsel-1) == 4'h0) ? wr_en    :
                   ((tsel-1) == 4'h1) ? wr_en_r0 :
                   ((tsel-1) == 4'h2) ? wr_en_r1 :
                   ((tsel-1) == 4'h3) ? wr_en_r2 :
                   ((tsel-1) == 4'h4) ? wr_en_r3 : wr_en;

//*****************************************************************************************************************************
//    Function : WDQS Generation
//*****************************************************************************************************************************
`ifdef DRAM_DDR4
wire  [19:0]  wdqs_pat = lb_en ? 20'b0000_0000_0000_1010_1010 : 20'b0000_0000_0001_0101_0101;
`elsif DRAM_DDR3
wire  [19:0]  wdqs_pat = lb_en ? 20'b0000_0000_0000_1010_1010 : 20'b0000_0000_0001_0101_0101;
`elsif DRAM_DDR2
wire  [19:0]  wdqs_pat = lb_en ? 20'b0000_0000_0000_1010_1010 : 20'b0000_0000_0001_0101_0100;
`endif

reg   [19:0]  wdqs_load;  

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        wdqs_load <= 20'h0;
    end else if (wr_en_int[0] == 1'b1) begin
        wdqs_load <= {8'h00, wdqs_load[19:8]} | (wdqs_pat << (psel+4'h0));
    end else if (wr_en_int[1] == 1'b1) begin
        wdqs_load <= {8'h00, wdqs_load[19:8]} | (wdqs_pat << (psel+4'h2));
    end else if (wr_en_int[2] == 1'b1) begin
        wdqs_load <= {8'h00, wdqs_load[19:8]} | (wdqs_pat << (psel+4'h4));
    end else if (wr_en_int[3] == 1'b1) begin
        wdqs_load <= {8'h00, wdqs_load[19:8]} | (wdqs_pat << (psel+4'h6));
    end else begin
        wdqs_load <= {8'h00, wdqs_load[19:8]};
    end
end


//*****************************************************************************************************************************
//    Function : WOE Generation
//*****************************************************************************************************************************
wire  [19:0]  woe_pat = 20'b0000_0000_0011_1111_1111;
reg   [19:0]  woe_load;  

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        woe_load <= 20'h0;
    end else if (wr_en_int[0] == 1'b1) begin
        woe_load <= {8'h00, woe_load[19:8]} | (woe_pat << (psel+4'h0));
    end else if (wr_en_int[1] == 1'b1) begin
        woe_load <= {8'h00, woe_load[19:8]} | (woe_pat << (psel+4'h2));
    end else if (wr_en_int[2] == 1'b1) begin
        woe_load <= {8'h00, woe_load[19:8]} | (woe_pat << (psel+4'h4));
    end else if (wr_en_int[3] == 1'b1) begin
        woe_load <= {8'h00, woe_load[19:8]} | (woe_pat << (psel+4'h6));
    end else begin
        woe_load <= {8'h00, woe_load[19:8]};
    end
end

//*****************************************************************************************************************************
//    Function : WDQ Generation
//*****************************************************************************************************************************
wire [  64-1:0] wdq_data_p;
reg  [8*20-1:0] wdq_load_r;
wire [  64-1:0] wdq_load_int;

genvar n, p;

for (n = 0; n <= 7; n = n+1) begin : bitIdx_0
    for (p = 0; p <= 7; p = p+1) begin : pIdx_0
        assign wdq_data_p[8*n+p] = wdq_data[8*p+n];
    end
end

for (n = 0; n <= 7; n = n+1) begin : wdq_ctrl
    always @ (posedge clk or negedge rst_n)
    begin
        if (rst_n == 1'b0) begin
            wdq_load_r[20*n +: 20] <= 20'h0;
        end else if (wr_en_int[0]) begin
            wdq_load_r[20*n +: 20] <= {8'h00, wdq_load_r[(20*n+20-1):(20*n+8)]} | (wdq_data_p[8*n +: 8] << (psel+4'h0+4'h1));
        end else if (wr_en_int[1]) begin
            wdq_load_r[20*n +: 20] <= {8'h00, wdq_load_r[(20*n+20-1):(20*n+8)]} | (wdq_data_p[8*n +: 8] << (psel+4'h2+4'h1));
        end else if (wr_en_int[2]) begin
            wdq_load_r[20*n +: 20] <= {8'h00, wdq_load_r[(20*n+20-1):(20*n+8)]} | (wdq_data_p[8*n +: 8] << (psel+4'h4+4'h1));
        end else if (wr_en_int[3]) begin
            wdq_load_r[20*n +: 20] <= {8'h00, wdq_load_r[(20*n+20-1):(20*n+8)]} | (wdq_data_p[8*n +: 8] << (psel+4'h6+4'h1));
        end else begin
            wdq_load_r[20*n +: 20] <= {8'h00, wdq_load_r[(20*n+20-1):(20*n+8)]};
        end
    end
end

for (n = 0; n <= 7; n = n+1) begin : bitIdx_1
    for (p = 0; p <= 7; p = p+1) begin : pIdx_1
        assign wdq_load_int[p*8+n] = wdq_load_r[n*20+p];
    end
end

//*****************************************************************************************************************************
//    Function : WDM Generation
//*****************************************************************************************************************************
reg  [20-1:0]  wdm_load_r;
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        wdm_load_r <= 20'h0;
    end else if (wr_en_int[0]) begin
        wdm_load_r <= {8'h00, wdm_load_r[20-1:8]} | (wdq_mask << (psel+4'h0+4'h1));
    end else if (wr_en_int[1]) begin
        wdm_load_r <= {8'h00, wdm_load_r[20-1:8]} | (wdq_mask << (psel+4'h2+4'h1));
    end else if (wr_en_int[2]) begin
        wdm_load_r <= {8'h00, wdm_load_r[20-1:8]} | (wdq_mask << (psel+4'h4+4'h1));
    end else if (wr_en_int[3]) begin
        wdm_load_r <= {8'h00, wdm_load_r[20-1:8]} | (wdq_mask << (psel+4'h6+4'h1));
    end else begin
        wdm_load_r <= {8'h00, wdm_load_r[20-1:8]};
    end
end

//*****************************************************************************************************************************
//    Function : Output
//*****************************************************************************************************************************
assign wdq_en = |wr_en_pre;

assign wdqs = wdqs_load[7:0];
assign wdq  = wdq_load_int;
assign wdm  = wdm_load_r[7:0];
assign oe   = lb_en ? 8'h0 : wrlvl_en ? 8'hff : (~woe_load[7:0]);

endmodule
