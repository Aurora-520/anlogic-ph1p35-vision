
`timescale 1ps/1ps

module ph1p_ddrphy_init #(
    parameter  ROM_LEN   = 64,
    parameter  ROM_INIT  = ""
)(
    input               clk        ,
    input               rst_n      ,

    output reg          done       ,

    // DCP
    output              dcp_psel   ,
    output     [ 5:0]   dcp_paddr  ,
    output     [ 8:0]   dcp_pdata  ,
    output              dcp_gate   ,

    // APB
    output              apb_psel   ,
    output              apb_penable,
    output              apb_pwrite ,
    output      [15:0]  apb_paddr  ,
    output      [31:0]  apb_pwdata ,
    input       [31:0]  apb_prdata ,
    input               apb_pready
);

//*****************************************************************************************************************************
//    Parameter Definition
//*****************************************************************************************************************************

//*****************************************************************************************************************************
//    Signals Definition
//*****************************************************************************************************************************
reg  [51 : 0] rom_w52 [0: ROM_LEN]; // synthesis ram_style=dram
reg  [ 7 : 0] rom_addr;
reg  [51 : 0] rom_data;

reg           psel_r            ;
reg           penable_r         ;
wire          prdy_int          ;

wire          transfer_vld       ;
reg  [15 : 0] transfer_done      ;
wire          transfer_done_int  ;
reg           transfer_done_r    ;

//*****************************************************************************************************************************
//    Function Definition : ROM
//*****************************************************************************************************************************
initial begin
    $readmemh(ROM_INIT, rom_w52);
end

//*****************************************************************************************************************************
//    Function Definition : Rom Addr
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        rom_addr <= 8'h0;
    else if (transfer_done_int)
        rom_addr <= (rom_addr == ROM_LEN-1) ? rom_addr : rom_addr + 1'd1;
    else
        rom_addr <= rom_addr;
end

//*****************************************************************************************************************************
//    Function Definition : Rom Data
//*****************************************************************************************************************************
always @ (*) begin
    rom_data <= rom_w52[rom_addr];
end

//*****************************************************************************************************************************
//    Function Definition : Start posedge
//*****************************************************************************************************************************
reg   [3 : 0] por_cnt   ;
wire          start     ;
reg           start_r   ;
wire          start_pos ;

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        por_cnt <= 4'h0;
    else
        por_cnt <= (&por_cnt == 1'b1) ? por_cnt : por_cnt + 1'b1;
end

assign start = (&por_cnt == 1'b1) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        start_r <= 1'b1;
    else
        start_r <= start;
end

assign start_pos = (start == 1'b1) && (start_r == 1'b0);

//*****************************************************************************************************************************
//    Function Definition : Pipeline
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        transfer_done_r <= 1'b0;
    else
        transfer_done_r <= transfer_done_int;
end

//*****************************************************************************************************************************
//    Function Definition : PSEL
//*****************************************************************************************************************************
assign prdy_int     = apb_psel ? apb_pready : dcp_psel ? 1'b1 : apb_pready;

assign transfer_vld = (psel_r && prdy_int && penable_r);

always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        psel_r <= 1'b0;
    else if (start_pos)
        psel_r <= 1'b1;
    else if (transfer_done_r && (done == 1'b0))
        psel_r <= 1'b1;
    else if (transfer_vld)
        psel_r <= 1'b0;
    else
        psel_r <= psel_r;
end

//*****************************************************************************************************************************
//    Function Definition : Penable
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        penable_r <= 1'b0;
    else if ((psel_r == 1'b1) && (penable_r == 1'b0))
        penable_r <= 1'b1;
    else if (transfer_vld)
        penable_r <= 1'b0; // transfer_vld
    else
        penable_r <= penable_r;
end

//*****************************************************************************************************************************
//    Function Definition : Dly
//*****************************************************************************************************************************
always @ (posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        transfer_done <= 16'h0;
    else
        transfer_done <= {transfer_done[14:0], transfer_vld};
end

assign transfer_done_int = transfer_done[15];


//*****************************************************************************************************************************
//    Function Definition : Done
//*****************************************************************************************************************************
always @ ( posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0) begin
        done <= 1'b0;
    end else if (transfer_done_int && (rom_addr == ROM_LEN-1)) begin
        done <= 1'b1;
    end else begin
        done <= done;
    end
end

//*****************************************************************************************************************************
//    Function Definition : IN/OUT Ctl
//*****************************************************************************************************************************
assign apb_psel    = (rom_data[51:48] == 4'h0) ? psel_r : 1'b0;
assign apb_pwrite  = apb_psel ;
assign apb_penable = penable_r;
assign apb_paddr   = rom_data[47:32];
assign apb_pwdata  = rom_data[31: 0];

assign dcp_psel   = (rom_data[51:48] == 4'h1) ? psel_r : 1'b0;
assign dcp_gate   = dcp_psel;
assign dcp_paddr  = rom_data[37:32];
assign dcp_pdata  = rom_data[ 8: 0];

endmodule
