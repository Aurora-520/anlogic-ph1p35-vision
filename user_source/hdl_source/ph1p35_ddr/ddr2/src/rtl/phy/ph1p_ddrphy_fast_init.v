
// dca_type[3:0] = 4'b0000 : mdl
//                 4'b0011 : gated
//                 4'b0100 : wdqs
//                 4'b0110 : wqd
//                 4'b1000 : rdqsp
//                 4'b1010 : rdqsn
//                 4'b1100 : gate

`timescale 1ps/1ps

module ph1p_ddrphy_fast_init (
// Clock & Reset
    input              clk          , 
    input              rst_n        , 

// User DelayLine Reconfigure on the fly
    input              usr_recfg    ,
    input              usr_vld      ,
    input       [3:0]  usr_type     ,

// User Delayline Settings
    input       [8:0]  init_gate    , 
    input       [8:0]  init_wdqs    , 
    input       [8:0]  init_wdq     , 
    input       [8:0]  init_rdqsp   , 
    input       [8:0]  init_rdqsn   , 
    input       [8:0]  init_gated   , 

// Delayline Control Port
    output             dcp_inc      ,
    output reg         dcp_vld      ,
    output reg  [3:0]  dcp_type     ,
    output reg  [8:0]  dcp_code     ,
    input              dcp_rdy      ,

// MISC
    input              start        , 
    output reg         phy_rst_n    ,
    output             done 
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************
localparam [3:0] LCDL_ADDR_MDL   = 4'b0000;
localparam [3:0] LCDL_ADDR_GSDQS = 4'b0011;
localparam [3:0] LCDL_ADDR_WDQS  = 4'b0100;
localparam [3:0] LCDL_ADDR_WDQ   = 4'b0110;
localparam [3:0] LCDL_ADDR_RDQSP = 4'b1000;
localparam [3:0] LCDL_ADDR_RDQSN = 4'b1010;
localparam [3:0] LCDL_ADDR_GATE  = 4'b1100;

localparam [3:0] S_IDLE  = 4'b0000;
localparam [3:0] S_GATE  = 4'b0001;
localparam [3:0] S_WDQS  = 4'b0010;
localparam [3:0] S_WDQ   = 4'b0011;
localparam [3:0] S_RDQSP = 4'b0100;
localparam [3:0] S_RDQSN = 4'b0101;
localparam [3:0] S_GATED = 4'b0110;
localparam [3:0] S_RST   = 4'b0111;
localparam [3:0] S_DONE  = 4'b1000;

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
reg   [3:0]  state_cnt  ;
reg   [3:0]  state_cnt_r;

reg   [1:0]  start_r    ;
wire         start_pos  ;

reg   [1:0]  dcp_rdy_r  ;
wire         dcp_rdy_pos;

reg   [3:0]  cfg_cnt    ;

reg   [4:0]  rst_cnt    ;
reg          rst_done   ;

//*****************************************************************************************************************************
//    WSL/RSL Set
//*****************************************************************************************************************************
// Pulse Ctrl Signal Gen
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        start_r <= 2'd0 ;
    end else begin
        start_r <= {start_r[0], start};
    end
end

assign start_pos = (~start_r[1]) && start_r[0];

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_rdy_r <= 2'd0 ;
    end else begin
        dcp_rdy_r <= {dcp_rdy_r[0], dcp_rdy};
    end
end

assign dcp_rdy_pos = (~dcp_rdy_r[1]) && dcp_rdy_r[0];

// State Machine Counter
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        state_cnt <= 4'h0;
    end else if ((state_cnt == S_IDLE) && (start_pos == 1'b1)) begin
        state_cnt <= S_GATE;
    end else if ((state_cnt >= S_GATE) && (state_cnt <= S_GATED) && (dcp_rdy_pos == 1'b1)) begin // dcp_cfg
        state_cnt <= state_cnt + 1'b1;
    end else if ((state_cnt == S_RST ) && (rst_done == 1'b1)) begin // phy_rst
        state_cnt <= S_DONE;
    end else if (state_cnt == S_DONE) begin // done
        state_cnt <= S_DONE;
    end else begin
        state_cnt <= state_cnt;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        state_cnt_r <= 4'h0;
    end else begin
        state_cnt_r <= state_cnt;
    end
end

// cfg counter
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        cfg_cnt <= 4'h0;
    end else if (state_cnt != state_cnt_r) begin
        cfg_cnt <= 4'h0;
    end else if (&cfg_cnt == 1'b1) begin
        cfg_cnt <= 4'hf;
    end else begin
        cfg_cnt <= cfg_cnt + 1'b1;
    end
end

// dcp ctrl output
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_vld  <= 1'b0;
        dcp_type <= 4'h0;
        dcp_code <= 9'h0;
    end else if (usr_recfg == 1'b1) begin
        dcp_vld  <= usr_vld;
        dcp_type <= usr_type;
        dcp_code <= (usr_type == LCDL_ADDR_GATE ) ? init_gate  : 
                    (usr_type == LCDL_ADDR_WDQS ) ? init_wdqs  : 
                    (usr_type == LCDL_ADDR_WDQ  ) ? init_wdq   : 
                    (usr_type == LCDL_ADDR_RDQSP) ? init_rdqsp : 
                    (usr_type == LCDL_ADDR_RDQSN) ? init_rdqsn : 9'h0;
    end else begin // fast_init
        dcp_vld  <= ((state_cnt >= S_GATE) && (state_cnt <= S_GATED)) ? ~cfg_cnt[3] : 1'b0;
        dcp_type <= (state_cnt == S_GATE ) ? LCDL_ADDR_GATE  : 
                    (state_cnt == S_WDQS ) ? LCDL_ADDR_WDQS  : 
                    (state_cnt == S_WDQ  ) ? LCDL_ADDR_WDQ   : 
                    (state_cnt == S_RDQSP) ? LCDL_ADDR_RDQSP : 
                    (state_cnt == S_RDQSN) ? LCDL_ADDR_RDQSN :
                    (state_cnt == S_GATED) ? LCDL_ADDR_GSDQS : 4'hf; 
        dcp_code <= (state_cnt == S_GATE ) ? init_gate  : 
                    (state_cnt == S_WDQS ) ? init_wdqs  : 
                    (state_cnt == S_WDQ  ) ? init_wdq   : 
                    (state_cnt == S_RDQSP) ? init_rdqsp : 
                    (state_cnt == S_RDQSN) ? init_rdqsn :
                    (state_cnt == S_GATED) ? init_gated : 9'h0; 
    end
end

assign dcp_inc = 1'b0;

// reset counter
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        rst_cnt <= 5'h0;
    end else if (state_cnt == S_RST) begin
        rst_cnt <= (&rst_cnt == 1'b1) ? rst_cnt : rst_cnt + 1'b1;
    end else begin
        rst_cnt <= rst_cnt;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        rst_done <= 1'b0;
    end else begin
        rst_done <= (&rst_cnt == 1'b1);
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        phy_rst_n <= 1'b0;
    end else if (state_cnt == S_RST) begin
        phy_rst_n <= rst_cnt[4];
    end else begin
        phy_rst_n <= 1'b1;
    end
end

// Done
assign done = (state_cnt == S_DONE) ? 1'b1 : 1'b0;

endmodule



