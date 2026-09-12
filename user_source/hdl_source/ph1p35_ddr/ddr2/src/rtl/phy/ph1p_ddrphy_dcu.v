
// module : Delayline Control Unit (DCU)

// dca_type[3:0] = 4'b0000 : mdl
//                 4'b0011 : gated
//                 4'b0100 : wdqs
//                 4'b0110 : wqd
//                 4'b1000 : rdqsp
//                 4'b1010 : rdqsn
//                 4'b1100 : gate

`timescale 1ps / 1ps

module ph1p_ddrphy_dcu (
// Clock & Reset
    input                 clk           ,
    input                 rst_n         ,

// Delayline Control Port
    input                dcp_vld       , // 1-cycle pulse
    input      [3 : 0]   dcp_type      ,
    input      [8 : 0]   dcp_code      ,
    input                dcp_inc       ,
    output               dcp_rdy       ,

// Delayline Status 
    output     [8 : 0]   dly_cur_gate  ,
    output     [8 : 0]   dly_cur_wdqs  ,
    output     [8 : 0]   dly_cur_wdq   ,
    output     [8 : 0]   dly_cur_rdqsp ,
    output     [8 : 0]   dly_cur_rdqsn ,
    output     [8 : 0]   dly_cur_mdl   ,

// Delayline Configuration Port on DX_GLUE
    output               dcp_gate      ,
    output               dcp_psel      ,
    output     [5 : 0]   dcp_paddr     ,
    output     [8 : 0]   dcp_pdata     ,

// MISC
    input      [3 : 0]   rsl_i         ,
    input      [3 : 0]   wsl_i         ,
    output     [3 : 0]   rsl_o         , // to PHY
    output     [3 : 0]   wsl_o         , // to PHY
    input      [8 : 0]   ui
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************
`ifdef PH1P_DDRPHY_SIM
localparam STEP = 8;
`else
localparam STEP = 1;
`endif

localparam [5:0] LCDL_ADDR_MDL   = 6'b00_0000;
localparam [5:0] LCDL_ADDR_GSDQS = 6'b00_0011;
localparam [5:0] LCDL_ADDR_WDQS  = 6'b00_0100;
localparam [5:0] LCDL_ADDR_WDQ   = 6'b00_0110;
localparam [5:0] LCDL_ADDR_RDQSP = 6'b00_1000;
localparam [5:0] LCDL_ADDR_RDQSN = 6'b00_1010;
localparam [5:0] LCDL_ADDR_GATE  = 6'b00_1100;

localparam [5:0] BDL_ADDR_OE     = 6'b00_1110;
localparam [5:0] BDL_ADDR_PDR    = 6'b00_1111;
localparam [5:0] BDL_ADDR_TE     = 6'b01_0000;
localparam [5:0] BDL_ADDR_WDQS   = 6'b01_0001;
localparam [5:0] BDL_ADDR_RDQSP  = 6'b01_1111;
localparam [5:0] BDL_ADDR_RDQSN  = 6'b10_0000;
localparam [5:0] BDL_ADDR_WDQ    = 6'b01_0011;
localparam [5:0] BDL_ADDR_WDM    = 6'b01_1011;
localparam [5:0] BDL_ADDR_RDQ    = 6'b10_0001;
localparam [5:0] BDL_ADDR_RDM    = 6'b10_1001;
localparam [5:0] BDL_ADDR_WDQSN  = 6'b01_0010;
localparam [5:0] BDL_ADDR_GATEW  = 6'b01_1100;
localparam [5:0] BDL_ADDR_GATER  = 6'b10_1010;
localparam [5:0] BDL_ADDR_GATE_SHADOW_W  = 6'b01_1110;
localparam [5:0] BDL_ADDR_GATE_SHADOW_R  = 6'b10_1100;
localparam [5:0] BDL_ADDR_SEW    = 6'b01_1101;
localparam [5:0] BDL_ADDR_SER    = 6'b10_1011;

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
reg   [3:0]  rsl_r;
reg   [3:0]  wsl_r;

reg   [8:0]  lcdl_gate_r ;
reg   [8:0]  lcdl_wdqs_r ;
reg   [8:0]  lcdl_wdq_r  ;
reg   [8:0]  lcdl_rdqsp_r;
reg   [8:0]  lcdl_rdqsn_r;
reg   [8:0]  lcdl_mdl_r  ;

wire         lcdl_gate_inc ;
wire         lcdl_wdqs_inc ;
wire         lcdl_wdq_inc  ;
wire         lcdl_rdqsp_inc;
wire         lcdl_rdqsn_inc;
wire         lcdl_mdl_inc  ;

wire         lcdl_gate_ld ;
wire         lcdl_wdqs_ld ;
wire         lcdl_wdq_ld  ;
wire         lcdl_rdqsp_ld;
wire         lcdl_rdqsn_ld;
wire         lcdl_mdl_ld  ;
//*****************************************************************************************************************************
//    DelayLine Load & Increase Mode
//*****************************************************************************************************************************
assign lcdl_gate_inc  = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_GATE );
assign lcdl_wdqs_inc  = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_WDQS );
assign lcdl_wdq_inc   = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_WDQ  );
assign lcdl_rdqsp_inc = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_RDQSP);
assign lcdl_rdqsn_inc = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_RDQSN);
assign lcdl_mdl_inc   = dcp_vld & (dcp_inc == 1'b1) & (dcp_type == LCDL_ADDR_MDL  );

assign lcdl_gate_ld   = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_GATE );
assign lcdl_wdqs_ld   = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_WDQS );
assign lcdl_wdq_ld    = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_WDQ  );
assign lcdl_rdqsp_ld  = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_RDQSP);
assign lcdl_rdqsn_ld  = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_RDQSN);
assign lcdl_mdl_ld    = dcp_vld & (dcp_inc == 1'b0) & (dcp_type == LCDL_ADDR_MDL  );

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        lcdl_gate_r <= 9'h0;
    end else if ((lcdl_gate_inc == 1'b1) && (lcdl_gate_r >= ui)) begin
        lcdl_gate_r <= 9'h0;
    end else if (lcdl_gate_inc == 1'b1) begin
        lcdl_gate_r <= lcdl_gate_r + STEP;
    end else if (lcdl_gate_ld == 1'b1) begin
        lcdl_gate_r <= dcp_code[8:0];
    end else begin
        lcdl_gate_r <= lcdl_gate_r;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        rsl_r <= 4'h0;
    end else if ((lcdl_gate_inc == 1'b1) && (lcdl_gate_r >= ui)) begin
        rsl_r <= rsl_r + 1'b1;
    end else if (lcdl_gate_ld == 1'b1) begin
        rsl_r <= rsl_i;
    end else begin
        rsl_r <= rsl_r;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        lcdl_wdqs_r <= 9'h0;
    end else if ((lcdl_wdqs_inc == 1'b1) && (lcdl_wdqs_r >= ui)) begin
        lcdl_wdqs_r <= 9'h0;
    end else if (lcdl_wdqs_inc == 1'b1) begin
        lcdl_wdqs_r <= lcdl_wdqs_r + STEP;
    end else if (lcdl_wdqs_ld == 1'b1) begin
        lcdl_wdqs_r <= dcp_code[8:0];
    end else begin
        lcdl_wdqs_r <= lcdl_wdqs_r;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        lcdl_wdq_r <= 9'h0;
    end else if ((lcdl_wdq_inc == 1'b1) && (lcdl_wdq_r >= ui)) begin
        lcdl_wdq_r <= 9'h0;
    end else if (lcdl_wdq_inc == 1'b1) begin
        lcdl_wdq_r <= lcdl_wdq_r + STEP;
    end else if (lcdl_wdq_ld == 1'b1) begin
        lcdl_wdq_r <= dcp_code[8:0];
    end else begin
        lcdl_wdq_r <= lcdl_wdq_r;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        wsl_r <= 4'h0;
    end else if ((lcdl_wdqs_inc == 1'b1) && (lcdl_wdqs_r >= ui)) begin
        wsl_r <= wsl_r + 1'b1;
    end else if ((lcdl_wdq_inc == 1'b1) && (lcdl_wdq_r >= ui)) begin
        wsl_r <= wsl_r + 1'b1;
    end else if (lcdl_wdqs_ld == 1'b1) begin
        wsl_r <= wsl_i;
    end else if (lcdl_wdq_ld == 1'b1) begin
        wsl_r <= wsl_i;
    end else begin
        wsl_r <= wsl_r;
    end
end


always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        lcdl_rdqsp_r <= 9'h0;
//  end else if ((lcdl_rdqsp_inc == 1'b1) && (lcdl_rdqsp_r >= ui)) begin
//      lcdl_rdqsp_r <= 9'h0;
    end else if (lcdl_rdqsp_inc == 1'b1) begin
        lcdl_rdqsp_r <= lcdl_rdqsp_r + STEP;
    end else if (lcdl_rdqsp_ld == 1'b1) begin
        lcdl_rdqsp_r <= dcp_code[8:0];
    end else begin
        lcdl_rdqsp_r <= lcdl_rdqsp_r;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        lcdl_rdqsn_r <= 9'h0;
    end else if ((lcdl_rdqsn_inc == 1'b1) && (lcdl_rdqsn_r >= ui)) begin
        lcdl_rdqsn_r <= 9'h0;
    end else if (lcdl_rdqsn_inc == 1'b1) begin
        lcdl_rdqsn_r <= lcdl_rdqsn_r + STEP;
    end else if (lcdl_rdqsn_ld == 1'b1) begin
        lcdl_rdqsn_r <= dcp_code[8:0];
    end else begin
        lcdl_rdqsn_r <= lcdl_rdqsn_r;
    end
end

//*****************************************************************************************************************************
//    Output
//*****************************************************************************************************************************
reg  [5:0] ctl_cnt     ;
reg        dcp_vld_r   ;
reg        dcp_vld_int ;
reg        dcp_rdy_r   ;

// 
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_vld_r <= 1'b0;
    end else begin
        dcp_vld_r <= dcp_vld;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_vld_int <= 1'b0;
    end else if (dcp_vld_r == 1'b1) begin
        dcp_vld_int <= 1'b1;
    end else if (&ctl_cnt == 1'b1) begin
        dcp_vld_int <= 1'b0;
    end else begin
        dcp_vld_int <= dcp_vld_int;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        ctl_cnt <= 6'h0;
    end else if (&ctl_cnt == 1'b1) begin
        ctl_cnt <= 6'h0;
    end else if (dcp_vld_int == 1'b1) begin
        ctl_cnt <= ctl_cnt + 1'b1;
    end else begin
        ctl_cnt <= ctl_cnt;
    end
end

// dcp_rdy ctrl
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        dcp_rdy_r <= 1'b1;
    else if (dcp_vld == 1'b1)
        dcp_rdy_r <= 1'b0;
    else if (&ctl_cnt == 1'b1)
        dcp_rdy_r <= 1'b1;
    else
        dcp_rdy_r <= dcp_rdy_r;
end

// output
assign dcp_rdy   = dcp_rdy_r;
assign dcp_gate  = dcp_vld_int;
assign dcp_psel  = (ctl_cnt >= 6'h10) && (ctl_cnt <= 6'h1f);
assign dcp_paddr = {2'b00, dcp_type[3:0]};
assign dcp_pdata = ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_GATE )) ? lcdl_gate_r  :
                   ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_WDQS )) ? lcdl_wdqs_r  :
                   ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_WDQ  )) ? lcdl_wdq_r   :
                   ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_RDQSP)) ? lcdl_rdqsp_r :
                   ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_RDQSN)) ? lcdl_rdqsn_r :
                   ((dcp_inc == 1'b1) && (dcp_type == LCDL_ADDR_MDL  )) ? lcdl_mdl_r   : dcp_code[8:0];

assign dly_cur_gate  = lcdl_gate_r ;
assign dly_cur_wdqs  = lcdl_wdqs_r ;
assign dly_cur_wdq   = lcdl_wdq_r  ;
assign dly_cur_rdqsp = lcdl_rdqsp_r;
assign dly_cur_rdqsn = lcdl_rdqsn_r;
assign dly_cur_mdl   = lcdl_mdl_r  ;

assign rsl_o         = rsl_r;
assign wsl_o         = wsl_r;

endmodule

