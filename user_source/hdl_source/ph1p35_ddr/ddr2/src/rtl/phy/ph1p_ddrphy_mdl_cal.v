
// bit[0] : mdl_lcdl_en
// bit[1] : wdqs_lcdl_en
// bit[2] : wdq_lcdl_en
// bit[3] : gate_lcdl_en
// bit[4] : rdqsn_lcdl_en
// bit[5] : gsdqs_lcdl_en
// bit[6] : rdqs_lcdl_en

`timescale 1ps/1ps

module ph1p_ddrphy_mdl_cal #(
    parameter  MDL_MODE = "FULL"
) (
    input                clk                    ,
    input                rst_n                  ,

    input                cal_en_in              ,
    input                cal_in                 ,
    output reg           cal_en                 ,
    output reg           cal_clk_en             ,
    output               cal_mode               ,

    input                mdl_start              ,
    output               mdl_done               ,
    output reg           mdl_err                ,
    output reg [8 : 0]   mdl_tck                ,
    output     [8 : 0]   mdl_ui                 ,

    input                dcp_rdy                ,
    output               dcp_inc                ,
    output     [3 : 0]   dcp_type               ,
    output reg [8 : 0]   dcp_code               ,
    output reg           dcp_vld
);

//*****************************************************************************************************************************************
// Parameter Definition
//*****************************************************************************************************************************************
localparam pLCDL_DLY_WIDTH     = 9       ;

localparam pCAL_TIMER_WIDTH    = 5       ;
localparam pLCDL_CAL_WIDTH     = 4       ;

localparam sCAL_IDLE           = 4'b0000 ;
localparam sCAL_START          = 4'b0001 ;
localparam sCAL_CK_ENABLE1     = 4'b0010 ;
localparam sCAL_CK_DISABLE1    = 4'b0011 ;
localparam sCAL_ENABLE         = 4'b0100 ;
localparam sCAL_CK_ENABLE2     = 4'b0101 ;
localparam sCAL_CK_DISABLE2    = 4'b0110 ;
localparam sCAL_WAIT           = 4'b0111 ;
localparam sCAL_PROC_RESULT    = 4'b1000 ;
localparam sCAL_DLY_WAIT       = 4'b1001 ;
localparam sCAL_DONE           = 4'b1010 ;

//*****************************************************************************************************************************************
// Signals Definition
//*****************************************************************************************************************************************
wire                           t_cal_s_done         ;
wire                           t_cal_on_done        ;
wire                           t_cal_h_done         ;
wire                           next_interval        ;
wire                           cal_timer_rst        ;
wire                           search_last_interval ;
wire                           cal_measure          ;
wire                           dcp_vld_temp         ;

reg                            cal_en_out_err       ;

reg   [pLCDL_CAL_WIDTH   -1:0] lcdl_cal_state       ;

reg                            measure_done         ;
reg   [pLCDL_DLY_WIDTH   -1:0] measured_probe       ;
reg                            measure_done_temp    ;
reg   [                   2:0] mdl_done_temp        ;

reg                            cal_start            ;
reg   [pCAL_TIMER_WIDTH  -1:0] cal_timer            ;
reg                            cal_timer_done       ;
reg                            cal_timer_cnt_en     ;
reg   [pLCDL_DLY_WIDTH   -2:0] step                 ;

reg   [                   1:0] dcp_rdy_r            ;
wire                           dcp_rdy_pos          ;

//*****************************************************************************************************************************************
// State Machine Start
//*****************************************************************************************************************************************
assign cal_measure = (mdl_start == 1'b1) && (mdl_done == 1'b0);

//*****************************************************************************************************************************************
// MDL Search : Binary search
//*****************************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin : measured_probe_proc
    if (rst_n == 1'b0) begin
        measured_probe <= {(pLCDL_DLY_WIDTH){1'b0}};
    end else begin
        if (cal_start) begin
            measured_probe <= 9'h100 ;
        end else if (next_interval) begin
            measured_probe <= (cal_in == 0) ? (measured_probe + step) : (measured_probe - step);
        end
    end
end

always @ (posedge clk or negedge rst_n )
begin : step_proc
    if (rst_n == 1'b0) begin
        step <= {1'b1, {(pLCDL_DLY_WIDTH-2){1'b0}}};
    end else if (next_interval == 1'b1) begin
        if (step[0] == 1'b1) begin
            step <= {1'b0, step[pLCDL_DLY_WIDTH-2:1]} + {{(pLCDL_DLY_WIDTH-2){1'b0}}, 1'b1} ;
        end else begin
            step <= {1'b0, step[pLCDL_DLY_WIDTH-2:1]};
        end
    end
end

assign search_last_interval =  (~(|step[pLCDL_DLY_WIDTH-2:1]) & step[0]);

//*************************************************************************************************************************************************
// LCDL State Machine Control
//*************************************************************************************************************************************************
// MDL mresurement method ( Binary search ) :
//     When doing mdl, dly_ddr_phy_clk and ddr_phy_clk have a ddr_phy_clk(mc1_dly_cal_md: 1'b0 : 1tck, 1'b1 : 1ui) delay. Using dly_ddr_phy_clk and ddr_phy_clk simultaneously with cal_en, they must sample
//     the process from 0 to 1 to cal_en. The dly_ddr_phy_clk sampling result is used to sample the ddr_phy_clk sampling result, so as to determine whether the next
//     step is to add step size or subtrack step size. It ends when the step size is 1 .
// Key Point : Sample the change in cal_en from 0 to 1 .

always @ (posedge clk or negedge rst_n )
begin : lcdl_cal_state_proc
    if (rst_n == 1'b0) begin
        lcdl_cal_state <= sCAL_IDLE;
    end else if (cal_measure == 1'b0) begin
        lcdl_cal_state <= sCAL_IDLE;
    end else begin
    case (lcdl_cal_state)
        sCAL_IDLE : begin
            if (cal_measure == 1'b1) begin
                lcdl_cal_state <= sCAL_START;
            end else begin
                lcdl_cal_state <= sCAL_IDLE ;
            end
        end
        sCAL_START : begin
            lcdl_cal_state <= sCAL_CK_ENABLE1;
        end
        sCAL_CK_ENABLE1 : begin
            if (t_cal_on_done == 1'b1) begin // Gate ddr_phy_clk  is used to sample cal_en. The sampling result must be 0 . Multuiple Sampling
                lcdl_cal_state <= sCAL_CK_DISABLE1;
            end else begin
                lcdl_cal_state <= sCAL_CK_ENABLE1 ;
            end
        end
        sCAL_CK_DISABLE1 : begin             // Disable ddr_phy_clk. Avoid  missample cal_en to 1 due to ddr_phy_clk cabling delay
            if (t_cal_h_done == 1'b1) begin
                lcdl_cal_state <= sCAL_ENABLE     ;
            end else begin
                lcdl_cal_state <= sCAL_CK_DISABLE1;
            end
        end
        sCAL_ENABLE : begin                  // Enable cal_en to be 1.
            if (t_cal_s_done == 1'b1) begin
                lcdl_cal_state <= sCAL_CK_ENABLE2;
            end else begin
                lcdl_cal_state <= sCAL_ENABLE    ;
            end
        end
        sCAL_CK_ENABLE2 : begin              // Enbale cal_en to be 1, ndly_ddr_phy_clk and dly_ddr_phy_clk sample cal_en. Enable ddr_phy_clk
            if (t_cal_on_done == 1'b1) begin
                lcdl_cal_state <= sCAL_CK_DISABLE2;
            end else begin
                lcdl_cal_state <= sCAL_CK_ENABLE2 ;
            end
        end
        sCAL_CK_DISABLE2 : begin             // Enbale cal_en to be 1, Disable ddr_phy_clk.
            if (t_cal_h_done == 1'b1) begin
                lcdl_cal_state <= sCAL_WAIT       ;
            end else begin
                lcdl_cal_state <= sCAL_CK_DISABLE2;
            end
        end
        sCAL_WAIT : begin                    // Enable cal_en to be 0, Verify the cal_en sampling result of dly_ddr_phy_clk. if the adoption result is 0, the adjustment is out of range. if the result is 1, it is normal and proceed to the next step.
            if (cal_en_in == 1'b1) begin
                lcdl_cal_state <= sCAL_PROC_RESULT;
            end else begin
                lcdl_cal_state <= sCAL_WAIT       ;
            end
        end
        sCAL_PROC_RESULT : begin             //  Adjust dly_ddr_phy_clk delay or mdl calibration is complete .
            if (search_last_interval == 1'b1) begin
                lcdl_cal_state <= sCAL_DONE      ;
            end else begin
       //       lcdl_cal_state <= sCAL_CK_ENABLE1;
                lcdl_cal_state <= sCAL_DLY_WAIT  ;
            end
        end
        sCAL_DLY_WAIT : begin
            if (dcp_rdy_pos == 1'b1) begin
                lcdl_cal_state <= sCAL_CK_ENABLE1;
            end else begin
                lcdl_cal_state <= sCAL_DLY_WAIT  ;
            end
        end
        sCAL_DONE : begin
            lcdl_cal_state <= sCAL_DONE;
        end
        default : begin
            lcdl_cal_state <= sCAL_IDLE;
        end
    endcase
  end
end

assign next_interval = (lcdl_cal_state == sCAL_PROC_RESULT);

always @ (posedge clk  or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        mdl_err <= 1'b0;
    end else if ( (lcdl_cal_state == sCAL_WAIT) && (cal_en_in == 1'b0)) begin
        mdl_err <= 1'b1;
    end else begin
        mdl_err <= mdl_err;
    end
end

//**************************************************************************************************************************************************
// LCDL State Machine Output
//**************************************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin : cal_start_PROC
    if (rst_n == 1'b0) begin
        cal_start    <= 1'b0;
        cal_en       <= 1'b0;
        cal_clk_en   <= 1'b0;
        measure_done <= 1'b0;
    end else if (cal_measure == 1'b0) begin
        cal_start    <= 1'b0;
        cal_en       <= 1'b0;
        cal_clk_en   <= 1'b0;
        measure_done <= 1'b0;
    end else begin
        cal_start    <= (lcdl_cal_state == sCAL_START);
        cal_en       <= (lcdl_cal_state == sCAL_ENABLE) || (lcdl_cal_state == sCAL_CK_ENABLE2) || (lcdl_cal_state == sCAL_CK_DISABLE2);
        cal_clk_en   <= (lcdl_cal_state == sCAL_CK_ENABLE1) || (lcdl_cal_state == sCAL_CK_ENABLE2);
        measure_done <= (lcdl_cal_state == sCAL_DONE);
    end
end

assign t_cal_s_done  = (cal_timer[4:0] == 5'h13);
assign t_cal_on_done = (cal_timer[4:0] == 5'h1f);
assign t_cal_h_done  = (cal_timer[4:0] == 5'h13);

always @ (*) begin : cal_timer_done_proc
    case(lcdl_cal_state)
        sCAL_ENABLE      : cal_timer_done = t_cal_s_done ;
        sCAL_CK_ENABLE1  : cal_timer_done = t_cal_on_done;
        sCAL_CK_ENABLE2  : cal_timer_done = t_cal_on_done;
        sCAL_CK_DISABLE1 : cal_timer_done = t_cal_h_done ;
        sCAL_CK_DISABLE2 : cal_timer_done = t_cal_h_done ;
        default          : cal_timer_done = 1'b0;
    endcase
end

assign cal_timer_rst = (cal_measure == 1'b0) || (cal_start == 1'b1) || (cal_timer_done == 1'b1);

always @ (*) begin : cal_timer_cnt_en_proc
    case (lcdl_cal_state)
        sCAL_ENABLE      : cal_timer_cnt_en = 1'b1;
        sCAL_CK_ENABLE1  : cal_timer_cnt_en = 1'b1;
        sCAL_CK_ENABLE2  : cal_timer_cnt_en = 1'b1;
        sCAL_CK_DISABLE1 : cal_timer_cnt_en = 1'b1;
        sCAL_CK_DISABLE2 : cal_timer_cnt_en = 1'b1;
        default          : cal_timer_cnt_en = 1'b0;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin : cal_timer_proc
    if (rst_n == 1'b0) begin
        cal_timer <= {(pCAL_TIMER_WIDTH){1'b0}};
    end else if (cal_timer_rst == 1'b1) begin
        cal_timer <= {(pCAL_TIMER_WIDTH){1'b0}};
    end else if (cal_timer_cnt_en == 1'b1) begin
        cal_timer <= cal_timer + 1;
  end
end

//*************************************************************************************************************************************************
// dcp_rdy_pos
//*************************************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_rdy_r <= 2'b00;
    end else begin
        dcp_rdy_r <= {dcp_rdy_r[0], dcp_rdy};
    end
end

assign dcp_rdy_pos = (dcp_rdy_r[0] == 1'b1) && (dcp_rdy_r[1] == 1'b0);

//*************************************************************************************************************************************************
// MDL DelayLine
//*************************************************************************************************************************************************
assign dcp_vld_temp = (measured_probe != dcp_code ) ? 1'd1 : 1'd0   ;

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        dcp_code <= 9'd0;
        dcp_vld  <= 1'b0;
    end else begin
        dcp_code <= measured_probe;
        dcp_vld  <= dcp_vld_temp;
    end
end


//*************************************************************************************************************************************************
// MDL Results Output
//*************************************************************************************************************************************************
always @ (posedge clk or negedge rst_n )
begin
    if (rst_n == 1'b0) begin
        mdl_tck           <= 9'h1ff; // gate_cnt_full needs to be compared with ui. Therefore, the defalut value of ui must be 9'h1ff
        measure_done_temp <= 1'b0;
    end else if (measure_done) begin
        mdl_tck           <= measured_probe;
        measure_done_temp <= 1'b1;
    end else begin
        mdl_tck           <= mdl_tck;
        measure_done_temp <= measure_done_temp;
    end
end

// Optimized timing : mdl_done
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        mdl_done_temp <= 3'b0;
    end else begin
        mdl_done_temp <= {mdl_done_temp[1:0], measure_done_temp};
    end
end

assign mdl_done = mdl_done_temp[2];

//*************************************************************************************************************************************************
// INPUT & OUTPUT
//*************************************************************************************************************************************************
assign cal_mode  = cal_measure ;
assign dcp_inc   = 1'b0;
assign dcp_type  = 4'h0;

assign mdl_ui    = (MDL_MODE == "FULL") ? {1'b0, mdl_tck[8:1]} : mdl_tck;

//*************************************************************************************************************************************************
// Debug Signals
//*************************************************************************************************************************************************

endmodule
