
// TODO: Add Training Force Configure

`define ENABLE_TRAIN_FORCE

`timescale 1ps/1ps

module ph1p_ddrphy_fast_init_wrapper #(
    parameter DX_NUM  =  2
)( 

// Clock & Reset
    input                clk        , 
    input                rst_n      , 

// User APB : used for Training Force, Async Port
    input                apb_pclk   ,
    input                apb_prst_n ,
    input                apb_psel   ,
    input                apb_penable,
    input                apb_pwrite ,
    input        [ 7:0]  apb_paddr  ,
    input        [31:0]  apb_pwdata ,
    output  reg  [31:0]  apb_prdata ,
    output  reg          apb_pready ,

// Delayline Control Port
    output  [DX_NUM*1-1 : 0]  dcp_inc   ,
    output  [DX_NUM*1-1 : 0]  dcp_vld   ,
    output  [DX_NUM*4-1 : 0]  dcp_type  ,
    output  [DX_NUM*9-1 : 0]  dcp_code  ,
    input   [DX_NUM*1-1 : 0]  dcp_rdy   ,

// DelayLine Current Configure
    input   [DX_NUM*9-1 : 0]  dly_cur_gate  ,
    input   [DX_NUM*9-1 : 0]  dly_cur_wdqs  ,
    input   [DX_NUM*9-1 : 0]  dly_cur_wdq   ,
    input   [DX_NUM*9-1 : 0]  dly_cur_rdqsp ,
    input   [DX_NUM*9-1 : 0]  dly_cur_rdqsn ,
    input   [DX_NUM*4-1 : 0]  wsl_i         ,
    input   [DX_NUM*4-1 : 0]  rsl_i         ,
    input   [DX_NUM*2-1 : 0]  gate_status   ,

// MISC
    output  [DX_NUM*4-1 : 0]  wsl       ,
    output  [DX_NUM*4-1 : 0]  rsl       ,

    input                     lb_en     ,

    input   [DX_NUM*9-1 : 0]  mdl_ui    ,
    input                     start     ,
    output reg                phy_rst_n ,
    output                    done

);

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
localparam [8:0] INIT_GATED = 9'h10;

localparam [3:0] LCDL_ADDR_MDL   = 4'b0000;
localparam [3:0] LCDL_ADDR_GSDQS = 4'b0011;
localparam [3:0] LCDL_ADDR_WDQS  = 4'b0100;
localparam [3:0] LCDL_ADDR_WDQ   = 4'b0110;
localparam [3:0] LCDL_ADDR_RDQSP = 4'b1000;
localparam [3:0] LCDL_ADDR_RDQSN = 4'b1010;
localparam [3:0] LCDL_ADDR_GATE  = 4'b1100;

`ifndef PH1P_DDRPHY_SIM
`include "./include/ph1p_ddrphy_board_delay.vh"
`endif

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
wire  [DX_NUM*1-1 : 0] done_int;
wire                   mdl_done_pos;
reg   [         3 : 0] mdl_done_r  ;
wire  [DX_NUM*1-1 : 0] phy_rst_n_int;
//*****************************************************************************************************************************
//    APB Register Access
//*****************************************************************************************************************************
// Register Field Definition:
// 0x00 - rw : user set init dly code
//        [ 8: 0] code
//        [15:12] wsl/rsl
//        [19:16] type
//        [31:28] byte_sel
// 0x04 - rw : set dly type for user reading dly code
//        [19:16] type
//        [31:28] byte_sel
// 0x08 - ro : return dly_code set by 0x04
//        [ 8: 0] code
//        [15:12] wsl/rsl
// 0x0C - rw : enable user fast init & delayline reconfigure on the fly
//        usr_mode == 0, usr_recfg == 0 : no operation
//        usr_mode == 1, usr_recfg == 0 : update init_delay
//        usr_mode == 1, usr_recfg == 1 : update init_delay & recfg to DDRPHY
//        [ 0: 0] user_mode
//        [ 4: 4] user_recfg
//        [ 8: 8] user_rst  
// 0x10 - ro : return cur_dly_code set by 0x04
//        [ 8: 0] code
//        [15:12] wsl/rsl, rdqs_gate_status when RDQSP/N


wire          apb_wr_en;
wire          apb_rd_en;

reg   [31:0]  wdata_00; // synthesis keep
reg   [31:0]  wdata_04; // synthesis keep
reg   [31:0]  wdata_08; // synthesis keep
reg   [31:0]  wdata_0c; // synthesis keep

wire  [31:0]  rdata_08; // synthesis keep
wire  [31:0]  rdata_10; // synthesis keep

wire          usr_mode     ; // synthesis keep
wire          usr_recfg    ; // synthesis keep
wire          usr_rst      ; // synthesis keep
reg           wdly_vld     ; // synthesis keep
wire  [ 3:0]  wdly_byte_sel; // synthesis keep
wire  [ 3:0]  wdly_type    ; // synthesis keep
wire  [ 8:0]  wdly_code    ; // synthesis keep
wire  [ 3:0]  wdly_sl      ; // synthesis keep
wire  [ 3:0]  rdly_byte_sel; // synthesis keep
wire  [ 3:0]  rdly_type    ; // synthesis keep
wire  [ 8:0]  rdly_code    ; // synthesis keep

wire  [  3:0]  usr_type  ;
reg   [9-1:0]  usr_vld   ;

reg   [9*9-1:0] init_gate ; // synthesis keep
reg   [9*9-1:0] init_wdqs ; // synthesis keep
reg   [9*9-1:0] init_wdq  ; // synthesis keep
reg   [9*9-1:0] init_rdqsp; // synthesis keep
reg   [9*9-1:0] init_rdqsn; // synthesis keep
reg   [9*4-1:0] init_wsl  ; // synthesis keep
reg   [9*4-1:0] init_rsl  ; // synthesis keep

reg   [9*4-1:0] preset_rsl  ;
reg   [9*9-1:0] preset_gate ;
reg   [9*9-1:0] preset_wdqs ; 

// apb timing control
assign apb_wr_en = apb_psel & apb_penable & (apb_pwrite == 1'b1) & apb_pready;
assign apb_rd_en = apb_psel & apb_penable & (apb_pwrite == 1'b0);

always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0)
        apb_pready <= 1'b0;
    else if (apb_psel & (apb_penable == 1'b0))
        apb_pready <= 1'b0;
    else if (apb_psel & apb_penable & (apb_pwrite == 1'b1))
        apb_pready <= 1'b1;
    else if (apb_psel & apb_penable & (apb_pwrite == 1'b0))
        apb_pready <= apb_rd_en;
    else
        apb_pready <= 1'b1;
end

// apb write
always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0) begin
        wdata_00 <= 32'h0;
        wdata_04 <= 32'h0;
        wdata_08 <= 32'h0;
        wdata_0c <= 32'h0;
    end else if (apb_wr_en) begin
        case (apb_paddr[7:0])
            8'h00  : wdata_00 <= apb_pwdata;
            8'h04  : wdata_04 <= apb_pwdata;
            8'h08  : wdata_08 <= apb_pwdata;
            8'h0c  : wdata_0c <= apb_pwdata;
            default: begin
            end
        endcase
    end else begin
        wdata_00 <= wdata_00;
        wdata_04 <= wdata_04;
        wdata_08 <= wdata_08;
        wdata_0c <= wdata_0c;
    end
end

// apb read
always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0) begin
        apb_prdata <= 32'h0;
    end else if (apb_rd_en) begin
        case (apb_paddr[7:0])
            8'h00  : apb_prdata <= wdata_00;
            8'h04  : apb_prdata <= wdata_04;
            8'h08  : apb_prdata <= rdata_08;
            8'h0c  : apb_prdata <= wdata_0c;
            8'h10  : apb_prdata <= rdata_10;
            default: apb_prdata <= 32'hdeadbeef;
        endcase
    end else begin
        apb_prdata <= apb_prdata;
    end
end

always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0) begin
        wdly_vld <= 1'b0;
    end else if (apb_wr_en) begin
        wdly_vld <= 1'b1;
    end else begin
        wdly_vld <= 1'b0;
    end
end

assign wdly_byte_sel[3:0] = wdata_00[31:28];
assign wdly_type    [3:0] = wdata_00[19:16];
assign wdly_code    [8:0] = wdata_00[ 8: 0];
assign wdly_sl      [3:0] = wdata_00[15:12];
assign rdly_byte_sel[3:0] = wdata_04[31:28];
assign rdly_type    [3:0] = wdata_04[19:16];
assign usr_mode           = wdata_0c[0];
assign usr_recfg          = wdata_0c[4];
assign usr_rst            = wdata_0c[8];

assign usr_type           = wdly_type;

// sync mdl_done to apb_pcl
always @ (posedge apb_pclk or negedge apb_prst_n)
begin
    if (apb_prst_n == 1'b0) begin
        mdl_done_r <= 4'b0000;
    end else begin
        mdl_done_r <= {mdl_done_r[2:0], start};
    end
end

assign mdl_done_pos = (mdl_done_r[0] == 1'b1) & (mdl_done_r[1] == 1'b0);

genvar n;
`ifdef PH1P_DDRPHY_SIM
for (n = 0; n < DX_NUM; n = n+1) begin : init_lcdl 
    always @ (posedge apb_pclk) begin
       init_wsl  [n*4 +: 4] <= 4'h2;
       init_rsl  [n*4 +: 4] <= 4'h3;
       init_gate [n*9 +: 9] <= 9'h8c; // 700ps
       init_wdqs [n*9 +: 9] <= 9'h0;
       init_wdq  [n*9 +: 9] <= lb_en ? 9'h00 : {1'b0, mdl_ui[n*9+8:n*9+1]};
       init_rdqsp[n*9 +: 9] <= {1'b0, mdl_ui[n*9+8:n*9+1]};
       init_rdqsn[n*9 +: 9] <= {1'b0, mdl_ui[n*9+8:n*9+1]};
    end
end// end of for
`else
for (n = 0; n < DX_NUM; n = n+1) begin : init_lcdl 

    always @ (*) begin
        preset_rsl [n*4 +: 4] <= 4'h4;
`ifdef PH1P35
        preset_gate[n*9 +: 9] <= (AC_DX_BD [n*16 +: 16] +  400)/6; 
`else
        preset_gate[n*9 +: 9] <= (AC_DX_BD [n*16 +: 16] + 1000)/6; 
`endif
        preset_wdqs[n*9 +: 9] <= CK_DX_SKEW[n*16 +: 16]/6; // skew < UI, for low speed, mdl step=6
    end

    always @ (posedge apb_pclk or negedge apb_prst_n)
    begin
        if (apb_prst_n == 1'b0) begin
            usr_vld   [n]        <= 1'b0;
            init_wsl  [n*4 +: 4] <= {4{1'b0}};
            init_rsl  [n*4 +: 4] <= {4{1'b0}};
            init_gate [n*9 +: 9] <= {9{1'b0}};
            init_wdqs [n*9 +: 9] <= {9{1'b0}};
            init_wdq  [n*9 +: 9] <= {9{1'b0}};
            init_rdqsp[n*9 +: 9] <= {9{1'b0}};
            init_rdqsn[n*9 +: 9] <= {9{1'b0}};
        end else if ((usr_mode == 1'b0) && (mdl_done_pos == 1'b1)) begin
            usr_vld   [n]        <= 1'b0;
            init_rsl  [n*4 +: 4] <= preset_rsl [n*4 +: 4];
            init_gate [n*9 +: 9] <= preset_gate[n*9 +: 9]; 
            init_wsl  [n*4 +: 4] <= 4'h2;
            init_wdqs [n*9 +: 9] <= lb_en ? 9'h00 : preset_wdqs[n*9 +: 9];
            init_wdq  [n*9 +: 9] <= lb_en ? 9'h00 : {1'b0, mdl_ui[n*9+8:n*9+1]};
            init_rdqsp[n*9 +: 9] <= {1'b0, mdl_ui[n*9+8:n*9+1]};
            init_rdqsn[n*9 +: 9] <= {1'b0, mdl_ui[n*9+8:n*9+1]};
        end else if ((usr_mode == 1'b1) && (wdly_vld == 1'b1)) begin
            usr_vld   [n]        <=  (wdly_byte_sel == n) ? 1'b1 : 1'b0;
            init_rsl  [n*4 +: 4] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_GATE )) ? wdly_sl   : init_rsl  [n*4 +: 4];
            init_wsl  [n*4 +: 4] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_WDQS )) ? wdly_sl   : init_wsl  [n*4 +: 4];
            init_gate [n*9 +: 9] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_GATE )) ? wdly_code : init_gate [n*9 +: 9];
            init_wdqs [n*9 +: 9] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_WDQS )) ? wdly_code : init_wdqs [n*9 +: 9];
            init_wdq  [n*9 +: 9] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_WDQ  )) ? wdly_code : init_wdq  [n*9 +: 9];
            init_rdqsp[n*9 +: 9] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_RDQSP)) ? wdly_code : init_rdqsp[n*9 +: 9];
            init_rdqsn[n*9 +: 9] <= ((wdly_byte_sel == n) && (wdly_type == LCDL_ADDR_RDQSN)) ? wdly_code : init_rdqsn[n*9 +: 9];
        end else begin
            usr_vld   [n]        <= 1'b0;
            init_wsl  [n*4 +: 4] <= init_wsl  [n*4 +: 4];
            init_rsl  [n*4 +: 4] <= init_rsl  [n*4 +: 4];
            init_gate [n*9 +: 9] <= init_gate [n*9 +: 9];
            init_wdqs [n*9 +: 9] <= init_wdqs [n*9 +: 9];
            init_wdq  [n*9 +: 9] <= init_wdq  [n*9 +: 9];
            init_rdqsp[n*9 +: 9] <= init_rdqsp[n*9 +: 9];
            init_rdqsn[n*9 +: 9] <= init_rdqsn[n*9 +: 9];
        end
    end
end // end of for
`endif

wire  [DX_NUM*4-1:0] gate_status_e;
wire  [         7:0] rdly_bit_shift;

for (n = 0; n <= DX_NUM-1; n = n+1) begin: gate_status_exp
     assign gate_status_e[n*4 +: 4] = {2'b00, gate_status[n*2 +: 2]};
end

assign rdly_bit_shift = (rdly_byte_sel == 4'h0) ? 9*0 :
                        (rdly_byte_sel == 4'h1) ? 9*1 :
                        (rdly_byte_sel == 4'h2) ? 9*2 :
                        (rdly_byte_sel == 4'h3) ? 9*3 :
                        (rdly_byte_sel == 4'h4) ? 9*4 :
                        (rdly_byte_sel == 4'h5) ? 9*5 :
                        (rdly_byte_sel == 4'h6) ? 9*6 :
                        (rdly_byte_sel == 4'h7) ? 9*7 :
                        (rdly_byte_sel == 4'h8) ? 9*8 : 8'h00;

assign rdata_08[31:16] = 16'h0311;
assign rdata_08[11: 9] =  3'h0;

assign rdata_08[15:12] = (rdly_type == LCDL_ADDR_GATE ) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_rsl   >> rdly_byte_sel*4) : 4'h0) :
                         (rdly_type == LCDL_ADDR_WDQS ) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_wsl   >> rdly_byte_sel*4) : 4'h0) : 4'h0;
assign rdata_08[ 8: 0] = (rdly_type == LCDL_ADDR_GATE ) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_gate  >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_WDQS ) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_wdqs  >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_WDQ  ) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_wdq   >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_RDQSP) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_rdqsp >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_RDQSN) ? ((rdly_byte_sel <= DX_NUM-1) ? (init_rdqsn >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_MDL  ) ? ((rdly_byte_sel <= DX_NUM-1) ? (mdl_ui     >> rdly_bit_shift ) : 9'h0) : 9'h0;


assign rdata_10[31:16] = {rdly_byte_sel[3:0], 8'h0, rdly_type[3:0]};
assign rdata_10[11: 9] =  3'h0;

assign rdata_10[15:12] = (rdly_type == LCDL_ADDR_GATE ) ? ((rdly_byte_sel <= DX_NUM-1) ? (rsl_i         >> rdly_byte_sel*4) : 4'h0) :
                         (rdly_type == LCDL_ADDR_WDQS ) ? ((rdly_byte_sel <= DX_NUM-1) ? (wsl_i         >> rdly_byte_sel*4) : 4'h0) :
                         (rdly_type == LCDL_ADDR_RDQSP) ? ((rdly_byte_sel <= DX_NUM-1) ? (gate_status_e >> rdly_byte_sel*4) : 4'h0) :
                         (rdly_type == LCDL_ADDR_RDQSN) ? ((rdly_byte_sel <= DX_NUM-1) ? (gate_status_e >> rdly_byte_sel*4) : 4'h0) : 4'h0;
assign rdata_10[ 8: 0] = (rdly_type == LCDL_ADDR_GATE ) ? ((rdly_byte_sel <= DX_NUM-1) ? (dly_cur_gate  >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_WDQS ) ? ((rdly_byte_sel <= DX_NUM-1) ? (dly_cur_wdqs  >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_WDQ  ) ? ((rdly_byte_sel <= DX_NUM-1) ? (dly_cur_wdq   >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_RDQSP) ? ((rdly_byte_sel <= DX_NUM-1) ? (dly_cur_rdqsp >> rdly_bit_shift ) : 9'h0) :
                         (rdly_type == LCDL_ADDR_RDQSN) ? ((rdly_byte_sel <= DX_NUM-1) ? (dly_cur_rdqsn >> rdly_bit_shift ) : 9'h0) : 9'h0;

//*****************************************************************************************************************************
//    Function : Fast_Init
//*****************************************************************************************************************************
reg                  usr_recfg_r ;
reg   [       9-1:0] usr_vld_r   ;
reg   [       4-1:0] usr_type_r  ;
reg   [DX_NUM*4-1:0] init_wsl_r  ; // synthesis keep
reg   [DX_NUM*4-1:0] init_rsl_r  ; // synthesis keep
reg   [DX_NUM*9-1:0] init_gate_r ; // synthesis keep
reg   [DX_NUM*9-1:0] init_wdqs_r ; // synthesis keep
reg   [DX_NUM*9-1:0] init_wdq_r  ; // synthesis keep
reg   [DX_NUM*9-1:0] init_rdqsp_r; // synthesis keep
reg   [DX_NUM*9-1:0] init_rdqsn_r; // synthesis keep

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        usr_recfg_r  <= 1'b0;
        usr_type_r   <= 4'h0;
        usr_vld_r    <= 9'h0;
        init_wsl_r   <= {(DX_NUM*4){1'b0}};
        init_rsl_r   <= {(DX_NUM*4){1'b0}};
        init_gate_r  <= {(DX_NUM*9){1'b0}};
        init_wdqs_r  <= {(DX_NUM*9){1'b0}};
        init_wdq_r   <= {(DX_NUM*9){1'b0}};
        init_rdqsp_r <= {(DX_NUM*9){1'b0}};
        init_rdqsn_r <= {(DX_NUM*9){1'b0}};
        phy_rst_n    <= 1'b1;
    end else begin
        usr_recfg_r  <= usr_recfg  ;
        usr_type_r   <= usr_type   ;
        usr_vld_r    <= usr_vld    ;
        init_wsl_r   <= init_wsl   ;
        init_rsl_r   <= init_rsl   ;
        init_gate_r  <= init_gate  ;
        init_wdqs_r  <= init_wdqs  ;
        init_wdq_r   <= init_wdq   ;
        init_rdqsp_r <= init_rdqsp ;
        init_rdqsn_r <= init_rdqsn ;
        phy_rst_n    <= (&phy_rst_n_int) & (~usr_rst);
    end
end


generate
    for (n = 0; n < DX_NUM; n = n+1) begin: byteIdx
        ph1p_ddrphy_fast_init  u_ddrphy_fast_init (
            .clk          ( clk                    ), 
            .rst_n        ( rst_n                  ), 
            .usr_recfg    ( usr_recfg_r            ),
            .usr_vld      ( usr_vld_r[n]           ),
            .usr_type     ( usr_type_r             ),
            .start        ( mdl_done_r[3]          ), 
            .init_gate    ( init_gate_r [9*n +: 9] ), 
            .init_wdqs    ( init_wdqs_r [9*n +: 9] ), 
            .init_wdq     ( init_wdq_r  [9*n +: 9] ), 
            .init_rdqsp   ( init_rdqsp_r[9*n +: 9] ), 
            .init_rdqsn   ( init_rdqsn_r[9*n +: 9] ), 
            .init_gated   ( INIT_GATED             ), 
            .dcp_inc      ( dcp_inc     [n]        ),
            .dcp_vld      ( dcp_vld     [n]        ),
            .dcp_type     ( dcp_type    [4*n +: 4] ),
            .dcp_code     ( dcp_code    [9*n +: 9] ),
            .dcp_rdy      ( dcp_rdy     [n]        ),
            .phy_rst_n    ( phy_rst_n_int[n]        ),
            .done         ( done_int    [n]        ) 
        );
    end
endgenerate

//*****************************************************************************************************************************
//    Output
//*****************************************************************************************************************************
assign done = (&done_int == 1'b1) ? 1'b1 : 1'b0;

assign wsl  = init_wsl_r;
assign rsl  = init_rsl_r;

endmodule
