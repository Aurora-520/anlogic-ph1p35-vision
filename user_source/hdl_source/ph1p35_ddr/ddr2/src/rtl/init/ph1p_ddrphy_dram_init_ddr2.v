
`timescale 1ps/1ps

module ph1p_ddrphy_dram_init #(
    parameter  tCK     = 2500,
    parameter  CL      = 5  ,
    parameter  CWL     = 6  ,
    parameter  PAR     = 0  ,
    parameter  RTT_NOM = "50"
)(
    input                  clk          ,
    input                  rst_n        ,

    input                  start        ,
    output                 done         ,
    output  reg            phy_rst_n    ,

    output  reg            cmd_vld      ,
    output  reg  [  31:0]  cmd_code     ,

    output       [13-1:0]  mr1

);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************
localparam  integer tWR       = 15_000;
localparam  integer nWR       = tWR/tCK;
// MR0
localparam  [ 2:0]  MR0_BL    = 3'b011; // 3'b011 : BL8, 3'b010 : BC4
localparam  [ 2:0]  MR0_CL    = (CL == 8) ? 3'b001 :
                                (CL == 9) ? 3'b000 : CL;
localparam  [ 2:0]  MR0_WR    = (nWR == 2) ? 3'b001 :
                                (nWR == 3) ? 3'b010 :
                                (nWR == 4) ? 3'b011 :
                                (nWR == 5) ? 3'b100 :
                                (nWR == 6) ? 3'b101 :
                                (nWR == 7) ? 3'b110 :
                                (nWR == 8) ? 3'b111 :
                                (nWR == 9) ? 3'b000 : 3'b101; // tWR_min = 15

// MR1
localparam  [ 2:0]  MR1_AL    = 3'b000;
localparam  [ 0:0]  MR1_DRV   = 1'b0; 
localparam  [ 1:0]  MR1_RTTNOM= (RTT_NOM == "75"     ) ? 2'b01 :
                                (RTT_NOM == "150"    ) ? 2'b10 :
                                (RTT_NOM == "50"     ) ? 2'b11 :
                                (RTT_NOM == "DISABLE") ? 2'b00 : 2'b11;

///////////////////////////////////////////////////////////////////////////////////////////////////
// MR0                       A12,  A11:A9,      A8,   A7,   A6:A4,       A3,   A2:A0
localparam  [12:0]  MR0_0 = {1'b0, MR0_WR[2:0], 1'b1, 1'b0, MR0_CL[2:0], 1'b0, MR0_BL[2:0]};
localparam  [12:0]  MR0_1 = {1'b0, MR0_WR[2:0], 1'b0, 1'b0, MR0_CL[2:0], 1'b0, MR0_BL[2:0]};
// MR1                       A12,  A11,  A10,  A9:A7,  A6,            A5:A3,       A2,            A1,         A0 
localparam  [12:0]  MR1_0 = {1'b0, 1'b0, 1'b0, 3'b000, MR1_RTTNOM[1], MR1_AL[2:0], MR1_RTTNOM[0], MR1_DRV[0], 1'b0};
localparam  [12:0]  MR1_1 = {1'b0, 1'b0, 1'b0, 3'b111, MR1_RTTNOM[1], MR1_AL[2:0], MR1_RTTNOM[0], MR1_DRV[0], 1'b0};
// MR2                       A12:A8, A7,   A6:A4,  A3,   A2:A0
localparam  [12:0]  MR2   = {5'h0,   1'b0, 3'b000, 1'b0, 3'b000};
// MR3
localparam  [12:0]  MR3   = 13'h0;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Timing Control, in ps
localparam tCKE = 400_000; // 400ns
localparam tRFC = 327_500; // 4Gb: 327.5ns, 2Gb: 197.5ns, 1Gb: 127.5ns, 512Mb: 105ns, 256Mb : 75ns

localparam [31:0] nCKE = tCKE/tCK + 4;
localparam [31:0] nRP  = CL + 16;
localparam [31:0] nMRD = 4  + 16;
localparam [31:0] nRFC = tRFC/tCK + 4;
localparam [31:0] nEXT = 200;

///////////////////////////////////////////////////////////////////////////////////////////////////
localparam [3 : 0] CMD_RST = 4'b1111;
localparam [3 : 0] CMD_CKE = 4'b1111;
localparam [3 : 0] CMD_MRS = 4'b1000;
localparam [3 : 0] CMD_REF = 4'b1001;
localparam [3 : 0] CMD_PRE = 4'b1010;
localparam [3 : 0] CMD_ACT = 4'b0011;
localparam [3 : 0] CMD_WR  = 4'b1100;
localparam [3 : 0] CMD_RD  = 4'b1101;

///////////////////////////////////////////////////////////////////////////////////////////////////
localparam  [4:0]  S_IDLE  = 5'b0_0000 ;
localparam  [4:0]  S_CKE   = 5'b0_0001 ;
localparam  [4:0]  S_PRE0  = 5'b0_0010 ;
localparam  [4:0]  S_MR2   = 5'b0_0011 ;
localparam  [4:0]  S_MR3   = 5'b0_0100 ;
localparam  [4:0]  S_MR1   = 5'b0_0101 ;
localparam  [4:0]  S_MR0   = 5'b0_0110 ;
localparam  [4:0]  S_PRE1  = 5'b0_0111 ;
localparam  [4:0]  S_REF0  = 5'b0_1000 ;
localparam  [4:0]  S_REF1  = 5'b0_1001 ;
localparam  [4:0]  S_REF2  = 5'b0_1010 ;
localparam  [4:0]  S_REF3  = 5'b0_1011 ;
localparam  [4:0]  S_MR0E  = 5'b0_1100 ;
localparam  [4:0]  S_MR1E0 = 5'b0_1101 ;
localparam  [4:0]  S_MR1E1 = 5'b0_1110 ;
localparam  [4:0]  S_DONE  = 5'b0_1111 ;

//*****************************************************************************************************************************
//    Internal Signal Definition
//*****************************************************************************************************************************
reg   [ 4:0] state_cnt;
reg   [ 4:0] state_cnt_r;
reg   [31:0] wait_cnt;
reg          wait_done;

reg   [ 1:0] start_r ;
wire         start_pos;

//*****************************************************************************************************************************
//    Internal Signal Definition
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        start_r <= 2'b00;
    else 
        start_r <= {start_r[0], start};
end

assign start_pos = (start_r[0] == 1'b1) & (start_r[1] == 1'b0);

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        state_cnt <= 5'h0;
    else
        state_cnt <= ((wait_done == 1'b1) || (start_pos == 1'b1)) ? state_cnt + 1 : state_cnt;
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        state_cnt_r <= 5'h0;
    else
        state_cnt_r <= state_cnt;
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        wait_cnt <= 32'h0;
//  else if (state_cnt != state_cnt_r)
    else if (wait_done == 1'b1)
        wait_cnt <= 32'h0;
    else if ((start_r[1] == 1'b1) && (done == 1'b0))
        wait_cnt <= (wait_done == 1'b1) ? wait_cnt : wait_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        wait_done <= 1'b0;
//  else if (cmd_vld == 1'b1)
//      wait_done <= 1'b0;
    else case (state_cnt)
        S_CKE   : wait_done <= (wait_cnt == {2'b00, nCKE[31:2]});
        S_PRE0  : wait_done <= (wait_cnt == {2'b00, nRP [31:2]});
        S_MR2   : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_MR3   : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_MR1   : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_MR0   : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_PRE1  : wait_done <= (wait_cnt == {2'b00, nRP [31:2]});
        S_REF0  : wait_done <= (wait_cnt == {2'b00, nRFC[31:2]});
        S_REF1  : wait_done <= (wait_cnt == {2'b00, nRFC[31:2]});
        S_REF2  : wait_done <= (wait_cnt == {2'b00, nRFC[31:2]});
        S_REF3  : wait_done <= (wait_cnt == {2'b00, nRFC[31:2]});
        S_MR0E  : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_MR1E0 : wait_done <= (wait_cnt == {2'b00, nMRD[31:2]});
        S_MR1E1 : wait_done <= (wait_cnt == {2'b00, nEXT[31:2]});
        default : wait_done <= wait_done; 
    endcase
end

// cmd_vld
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        cmd_vld <= 1'b0;
    else
        cmd_vld <= (wait_cnt == 32'h1) ? 1'b1 : 1'b0;
end

// cmd_code
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        cmd_code <= 32'h0;
    else case (state_cnt)
        S_CKE   : cmd_code <= {CMD_CKE, 4'b0011, 4'b0000, 20'h0}; 
        S_PRE0  : cmd_code <= {CMD_PRE, 4'b0000, 4'b0000, 20'h0_04_00}; 
        S_MR2   : cmd_code <= {CMD_MRS, 4'b0000, 4'b0010, {7'h0, MR2}}; 
        S_MR3   : cmd_code <= {CMD_MRS, 4'b0000, 4'b0011, {7'h0, MR3}}; 
        S_MR1   : cmd_code <= {CMD_MRS, 4'b0000, 4'b0001, {7'h0, MR1_0}}; 
        S_MR0   : cmd_code <= {CMD_MRS, 4'b0000, 4'b0000, {7'h0, MR0_0}}; 
        S_PRE1  : cmd_code <= {CMD_PRE, 4'b0000, 4'b0000, 20'h0_04_00}; 
        S_REF0  : cmd_code <= {CMD_REF, 4'b0000, 4'b0000, 20'h0_00_00}; 
        S_REF1  : cmd_code <= {CMD_REF, 4'b0000, 4'b0000, 20'h0_00_00}; 
        S_REF2  : cmd_code <= {CMD_REF, 4'b0000, 4'b0000, 20'h0_00_00}; 
        S_REF3  : cmd_code <= {CMD_REF, 4'b0000, 4'b0000, 20'h0_00_00}; 
        S_MR0E  : cmd_code <= {CMD_MRS, 4'b0000, 4'b0000, {7'h0, MR0_1}}; 
        S_MR1E0 : cmd_code <= {CMD_MRS, 4'b0000, 4'b0001, {7'h0, MR1_1}}; 
        S_MR1E1 : cmd_code <= {CMD_MRS, 4'b0000, 4'b0001, {7'h0, MR1_0}}; 
        default : cmd_code <= 32'h0; 
    endcase
end

assign done = (state_cnt[4:0] == S_DONE);

endmodule
