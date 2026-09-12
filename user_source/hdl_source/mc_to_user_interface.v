

module mc_to_user_interface (
    input wire          I_clk,
    input wire          I_rst_n,

    /*
        ddr user interface
        当I_ddr_user_ready拉低时，还能写入8个长度数据
    */
    input wire          I_ddr_user_wr_en,
    input wire          I_ddr_user_rd_en,  //synthesis keep
    input wire[24:0]    I_ddr_user_addr,
    input wire[127:0]   I_ddr_user_wr_data,
    output wire         O_ddr_user_ready,
    output wire         O_ddr_user_rd_valid,
    output wire[127:0]  O_ddr_user_rd_data,

    /*
        ddr memory controller interface
    */
    output  wire        O_mc_app_en,
    output  wire [24:0] O_mc_app_addr,
    output  wire [2:0]  O_mc_app_cmd,
    input  wire         I_mc_app_rdy,
    output wire         O_mc_app_wdf_wren,
    output wire [127:0] O_mc_app_wdf_data,
    output wire         O_mc_app_wdf_end,
    output wire [31:0]  O_mc_app_wdf_mask,
    input wire          I_mc_app_wdf_rdy,
    input wire [127:0]  I_mc_app_rd_data,
    input wire          I_mc_app_rd_data_end,
    input wire          I_mc_app_rd_data_valid
);

    wire        S_fifo_wr_en;    
    wire[154:0] S_fifo_wr_data;
    wire        S_fifio_pro_full;
    wire        S_fifo_rd_en;    
    wire[154:0] S_fifo_rd_data;
    wire        S_fifo_rd_valid;
    wire        S_fifo_empty;   

    assign S_fifo_wr_en = I_ddr_user_wr_en | I_ddr_user_rd_en;

    assign S_fifo_wr_data = {I_ddr_user_wr_en,I_ddr_user_rd_en,I_ddr_user_addr,I_ddr_user_wr_data};

    assign S_fifo_rd_en = I_mc_app_rdy & I_mc_app_wdf_rdy & (~S_fifo_empty);

    assign O_ddr_user_ready = ~S_fifio_pro_full;

    assign O_mc_app_en = S_fifo_rd_en;

    assign O_mc_app_addr = O_mc_app_en ? S_fifo_rd_data[152:128] : 'd0;

    assign O_mc_app_cmd = O_mc_app_en && S_fifo_rd_data[153] ? 3'd1 : 3'd0;

    assign O_mc_app_wdf_wren = O_mc_app_en & S_fifo_rd_data[154];

    assign O_mc_app_wdf_end = O_mc_app_wdf_wren;

    assign O_mc_app_wdf_mask = 'd0;

    assign O_mc_app_wdf_data = O_mc_app_wdf_wren ? S_fifo_rd_data[127:0] : 'd0;

    assign O_ddr_user_rd_valid = I_mc_app_rd_data_valid;
    
    assign O_ddr_user_rd_data = I_mc_app_rd_data;

    w155_d512_fifo U_w155_d512_fifo(
        .clk        ( I_clk            ),     
        .rst        ( ~I_rst_n         ),     

        .we         ( S_fifo_wr_en     ),
        .di         ( S_fifo_wr_data   ),
        .afull      ( S_fifio_pro_full ),
        .full_flag  (),
        .wrusedw    (),
 
        .re         ( S_fifo_rd_en     ), 
        .valid      ( S_fifo_rd_valid  ), 
        .dout       ( S_fifo_rd_data   ),  
        .empty_flag ( S_fifo_empty     ),
        .aempty     (),
        .rdusedw    ()
    );
    
endmodule
