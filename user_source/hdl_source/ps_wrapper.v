


module ps_wrapper (
    input wire        I_core_clk,
    input wire        I_timer_clk,
    input wire        I_rst,

    input wire        I_jtag_tck,
    input wire        I_jtag_tms,
    input wire        I_jtag_tdi,
    output wire       O_jtag_tdo,

    input wire        I_apb_clk,
    input wire        I_apb_rst,
    output wire[19:0] O_apb_paddr,
    output wire       O_apb_psel,
    output wire       O_apb_penable,
    output wire       O_apb_pwrite,
    output wire[31:0] O_apb_pwdata,
    output wire[3:0]  O_apb_pstrobe,
    output wire[2:0]  O_apb_pprot,
    input wire[31:0]  I_apb_prdata,
    input wire        I_apb_pready,
    input wire        I_apb_pslverr,

    output wire       O_uart0_tx,
    input wire        I_uart0_rx,

    output wire       O_uart1_tx,
    input wire        I_uart1_rx,

    inout wire        IO_gpio0,
    inout wire        IO_gpio1,
    inout wire        IO_gpio2,
    inout wire        IO_gpio3,
    inout wire        IO_gpio4,
    inout wire        IO_gpio5,
    inout wire        IO_gpio6,
    inout wire        IO_gpio7
);
    

    wire S_gpio0_in;
    wire S_gpio0_out;
    wire S_gpio0_dir;

    wire S_gpio1_in;
    wire S_gpio1_out;
    wire S_gpio1_dir;

    wire S_gpio2_in;
    wire S_gpio2_out;
    wire S_gpio2_dir;

    wire S_gpio3_in; 
    wire S_gpio3_out;
    wire S_gpio3_dir;

    wire S_gpio4_in; 
    wire S_gpio4_out;
    wire S_gpio4_dir;

    wire S_gpio5_in;
    wire S_gpio5_out;
    wire S_gpio5_dir;

    wire S_gpio6_in;
    wire S_gpio6_out;
    wire S_gpio6_dir;

    wire S_gpio7_in;
    wire S_gpio7_out;
    wire S_gpio7_dir;


    assign IO_gpio0 = S_gpio0_dir ? 1'bz : S_gpio0_out;
    assign S_gpio0_in = IO_gpio0;

    assign IO_gpio1 = S_gpio1_dir ? 1'bz : S_gpio1_out;
    assign S_gpio1_in = IO_gpio1;

    assign IO_gpio2 = S_gpio2_dir ? 1'bz : S_gpio2_out;
    assign S_gpio2_in = IO_gpio2;

//    assign IO_gpio3 = S_gpio3_dir ? 1'bz : S_gpio3_out;
//    assign S_gpio3_in = IO_gpio3;

//    assign IO_gpio4 = S_gpio4_dir ? 1'bz : S_gpio4_out;
//    assign S_gpio4_in = IO_gpio4;

    assign IO_gpio3 = S_gpio5_out ? 1'bz : S_gpio3_out;
    assign S_gpio3_in = IO_gpio3;

    assign IO_gpio4 = S_gpio6_out ? 1'bz : S_gpio4_out;
    assign S_gpio4_in = IO_gpio4;


    assign IO_gpio5 = S_gpio5_dir ? 1'bz : S_gpio5_out;
    assign S_gpio5_in = IO_gpio5;

    assign IO_gpio6 = S_gpio6_dir ? 1'bz : S_gpio6_out;
    assign S_gpio6_in = IO_gpio6;

    assign IO_gpio7 = S_gpio7_dir ? 1'bz : S_gpio7_out;
    assign S_gpio7_in = IO_gpio7;

    MCU u_MCU(
        .core_clk   ( I_core_clk    ),
        .timer_clk  ( I_timer_clk   ),

        .core_reset ( I_rst         ),
        .por_reset  ( I_rst         ),

        .nmi        ( 1'b0          ),
        .clic_irq   ( 23'd0         ),

        .jtag_tck   ( I_jtag_tck    ),
        .jtag_tms   ( I_jtag_tms    ),
        .jtag_tdi   ( I_jtag_tdi    ),
        .jtag_tdo   ( O_jtag_tdo    ),

        .apb_clk    ( I_apb_clk     ),
        .apb_rst    ( I_apb_rst     ),
        .paddr      ( O_apb_paddr   ),
        .psel       ( O_apb_psel    ),
        .penable    ( O_apb_penable ),
        .pwrite     ( O_apb_pwrite  ),
        .pwdata     ( O_apb_pwdata  ),
        .pstrobe    ( O_apb_pstrobe ),
        .pprot      ( O_apb_pprot   ),
        .prdata     ( I_apb_prdata  ),
        .pready     ( I_apb_pready  ),
        .pslverr    ( I_apb_pslverr ),

        .ahb_clk    (               ),
        .htrans     (               ),
        .hwrite     (               ),
        .haddr      (               ),
        .hsize      (               ),
        .hburst     (               ),
        .hprot      (               ),
        .hmastlock  (               ),
        .hwdata     (               ),
        .hrdata     ( 32'd0         ),
        .hresp      ( 2'b00         ),
        .hready     ( 1'b1          ),

        .uart0_tx   ( O_uart0_tx    ),
        .uart0_rx   ( I_uart0_rx    ),

        .uart1_tx   ( O_uart1_tx    ),
        .uart1_rx   ( I_uart1_rx    ),

        .gpio0_in   ( S_gpio0_in    ),
        .gpio0_out  ( S_gpio0_out   ),
        .gpio0_dir  ( S_gpio0_dir   ),
        .gpio1_in   ( S_gpio1_in    ),
        .gpio1_out  ( S_gpio1_out   ),
        .gpio1_dir  ( S_gpio1_dir   ),
        .gpio2_in   ( S_gpio2_in    ),
        .gpio2_out  ( S_gpio2_out   ),
        .gpio2_dir  ( S_gpio2_dir   ),
        .gpio3_in   ( S_gpio3_in    ),
        .gpio3_out  ( S_gpio3_out   ),
        .gpio3_dir  ( S_gpio3_dir   ),
        .gpio4_in   ( S_gpio4_in    ),
        .gpio4_out  ( S_gpio4_out   ),
        .gpio4_dir  ( S_gpio4_dir   ),
        .gpio5_in   ( S_gpio5_in    ),
        .gpio5_out  ( S_gpio5_out   ),
        .gpio5_dir  ( S_gpio5_dir   ),
        .gpio6_in   ( S_gpio6_in    ),
        .gpio6_out  ( S_gpio6_out   ),
        .gpio6_dir  ( S_gpio6_dir   ),
        .gpio7_in   ( S_gpio7_in    ),
        .gpio7_out  ( S_gpio7_out   ),
        .gpio7_dir  ( S_gpio7_dir   )
    );


endmodule