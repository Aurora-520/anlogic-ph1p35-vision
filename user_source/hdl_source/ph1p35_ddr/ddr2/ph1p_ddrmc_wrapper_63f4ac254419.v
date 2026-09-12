
///////////////////////////////////////////////////////////////////////////////////////////////////
// module : ph1p_ddrmc_wrapper_63f4ac254419
///////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

`ifdef PH1P_MIS_SIM
`include "ph1p_mis_define.vh"
`else
`include "./src/rtl/include/ph1p_mis_define.vh"
`endif

module ph1p_ddrmc_wrapper_63f4ac254419 #(
    parameter tCK              = 1876,
    parameter BK_NUM           = 2 ,
    parameter AC_NUM           = 4 ,
    parameter DX_NUM           = 2 ,

    parameter CK_WIDTH         = 1 ,
    parameter CS_WIDTH         = 1 ,
    parameter CKE_WIDTH        = 1 ,
    parameter ODT_WIDTH        = 1 ,
    parameter BG_WIDTH         = 0 ,
    parameter BA_WIDTH         = 2 ,
    parameter ROW_WIDTH        = 13,
    parameter COL_WIDTH        = 10,
    parameter ADR_WIDTH        = 13,

    parameter HOST_AC_DRV      = "48",
    parameter HOST_DX_DRV      = "48",
    parameter HOST_DX_ODT      = "60",
    parameter DRAM_DRV         = "RZQ/5",
    parameter DRAM_ODT         = "RZQ/4",

    parameter WDM              = 1 ,
    parameter CWL              = 6 ,
    parameter CL               = 8 ,
    parameter CAL_EN           = 1 ,

// PLL
    parameter PLL0_REFCLK_FREQ = "100",
    parameter PLL0_REFCLK_DIV  =  1   ,
    parameter PLL0_FBKCLK_DIV  =  12  ,
    parameter PLL0_CLK2_DIV    =  3   ,
    parameter PLL0_CLK3_DIV    =  24  ,
    parameter PLL0_FRAC        = "DISABLE",
    parameter PLL0_FRAC_SDM    =  0   ,
    parameter PLL1_REFCLK_FREQ = "100",
    parameter PLL1_REFCLK_DIV  =  1   ,
    parameter PLL1_CLK0_DIV    =  12  ,

// MC
    parameter MC_ECC           = "OFF",
    parameter MC_ADDR_MAP      = "ROW_COLUMN_BANK",
    parameter MC_REORDER       = "STRICT",
    parameter MC_ADDR_WIDTH    = BG_WIDTH + BA_WIDTH + ROW_WIDTH + COL_WIDTH,
    parameter MC_DATA_WIDTH    = (MC_ECC == "OFF") ? DX_NUM*64 : (DX_NUM-1)*64,
    parameter MC_MASK_WIDTH    = (MC_ECC == "OFF") ? DX_NUM*8  : (DX_NUM-1)*8,

    parameter AXI_ID_WIDTH     = 4,
    parameter AXI_ADDR_WIDTH   = MC_ADDR_WIDTH + $clog2(MC_DATA_WIDTH/8) - 3,
    parameter AXI_DATA_WIDTH   = MC_DATA_WIDTH,
    parameter AXI_MASK_WIDTH   = MC_MASK_WIDTH
)(
// clock & reset
    input                        ref_clk      ,
    input                        sys_rst_n    ,

// debug apb
    input                        apb_pclk     ,
    input                        apb_prst_n   ,
    output                       apb_pready   ,
    input                        apb_psel     ,
    input                        apb_penable  ,
    input                        apb_pwrite   ,
    input   [15             :0]  apb_paddr    ,
    input   [31             :0]  apb_pwdata   ,
    output  [31             :0]  apb_prdata   ,

// mc user interface
    output                       cfg_clk      ,
    output                       cfg_rst_n    ,
    output                       dhi_clk      ,
    output                       ddrphy_rst_n ,
    output                       ddrphy_rdy   ,

`ifdef MC0_MIS_AXI
// AXI Interface
    input                        axi_aclk     ,
    input                        axi_aresetn  ,
// AXI Write Address Channel
    input  [AXI_ID_WIDTH  -1:0]  axi_awid     ,
    input  [AXI_ADDR_WIDTH-1:0]  axi_awaddr   ,
    input  [7:0]                 axi_awlen    ,
    input  [2:0]                 axi_awsize   ,
    input  [1:0]                 axi_awburst  ,
    input                        axi_awvalid  ,
    output                       axi_awready  ,
// AXI Write Data Channel
    input  [AXI_DATA_WIDTH-1:0]  axi_wdata    ,
    input  [AXI_MASK_WIDTH-1:0]  axi_wstrb    ,
    input                        axi_wlast    ,
    input                        axi_wvalid   ,
    output                       axi_wready   ,
// AXI Write Response Channel
    output [AXI_ID_WIDTH  -1:0]  axi_bid      ,
    output [1:0]                 axi_bresp    ,
    output                       axi_bvalid   ,
    input                        axi_bready   ,
// AXI Read Address Channel
    input  [AXI_ID_WIDTH  -1:0]  axi_arid     ,
    input  [AXI_ADDR_WIDTH-1:0]  axi_araddr   ,
    input  [7:0]                 axi_arlen    ,
    input  [2:0]                 axi_arsize   ,
    input  [1:0]                 axi_arburst  ,
    input                        axi_arvalid  ,
    output                       axi_arready  ,
// AXI Read Data Channel
    output [AXI_ID_WIDTH  -1:0]  axi_rid      ,
    output [AXI_DATA_WIDTH-1:0]  axi_rdata    ,
    output [1:0]                 axi_rresp    ,
    output                       axi_rlast    ,
    output                       axi_rvalid   ,
    input                        axi_rready   ,
`else
// Write Address Ports
    input  [ MC_ADDR_WIDTH-1:0]  paxi_awaddr  ,
    input                        paxi_awvalid ,
    output                       paxi_awready ,
// Write Data Ports
    input  [ MC_DATA_WIDTH-1:0]  paxi_wdata   ,
    input  [ MC_MASK_WIDTH-1:0]  paxi_wstrb   ,
    input                        paxi_wvalid  ,
    input                        paxi_wlast   ,
    output                       paxi_wready  ,
// Read Address Ports
    input  [ MC_ADDR_WIDTH-1:0]  paxi_araddr  ,
    input                        paxi_arvalid ,
    output                       paxi_arready ,
// Read Data Ports
    output [ MC_DATA_WIDTH-1:0]  paxi_rdata   ,
    output                       paxi_rlast   ,
    output                       paxi_rvalid  ,
    input                        paxi_rready  ,
`endif

// ddrio
`ifdef DRAM_DDR4
    output  [CK_WIDTH  -1 : 0]   ddr_ck_t     ,
    output  [CK_WIDTH  -1 : 0]   ddr_ck_c     ,
    output  [           0 : 0]   ddr_reset_n  ,
    output  [CKE_WIDTH -1 : 0]   ddr_cke      ,
    output  [ODT_WIDTH -1 : 0]   ddr_odt      ,
    output  [CS_WIDTH  -1 : 0]   ddr_cs_n     ,
    output  [           0 : 0]   ddr_act_n    ,
    output  [BG_WIDTH  -1 : 0]   ddr_bg       ,
    output  [BA_WIDTH  -1 : 0]   ddr_ba       ,
    output  [ADR_WIDTH -1 : 0]   ddr_addr     ,
    inout   [DX_NUM    -1 : 0]   ddr_dqs_t    ,
    inout   [DX_NUM    -1 : 0]   ddr_dqs_c    ,
    inout   [DX_NUM  *8-1 : 0]   ddr_dq       ,
    inout   [DX_NUM    -1 : 0]   ddr_dm_n
`else // DDR3/DDR2
    output  [CK_WIDTH  -1 : 0]   ddr_ck_p     ,
    output  [CK_WIDTH  -1 : 0]   ddr_ck_n     ,
`ifndef DRAM_DDR2
    output  [           0 : 0]   ddr_reset_n  ,
`endif
    output  [CKE_WIDTH -1 : 0]   ddr_cke      ,
    output  [ODT_WIDTH -1 : 0]   ddr_odt      ,
    output  [CS_WIDTH  -1 : 0]   ddr_cs_n     ,
    output  [           0 : 0]   ddr_ras_n    ,
    output  [           0 : 0]   ddr_cas_n    ,
    output  [           0 : 0]   ddr_we_n     ,
    output  [BA_WIDTH  -1 : 0]   ddr_ba       ,
    output  [ROW_WIDTH -1 : 0]   ddr_addr     ,
    inout   [DX_NUM    -1 : 0]   ddr_dqs_p    ,
    inout   [DX_NUM    -1 : 0]   ddr_dqs_n    ,
    inout   [DX_NUM  *8-1 : 0]   ddr_dq       ,
    inout   [DX_NUM    -1 : 0]   ddr_dm
`endif
);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal signals
///////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef MC0_MIS_AXI
// Write Address Ports
wire [MC_ADDR_WIDTH-1:0]  paxi_awaddr ;
wire                      paxi_awvalid;
wire                      paxi_awready;
// Write Data Ports
wire [MC_DATA_WIDTH-1:0]  paxi_wdata  ;
wire [MC_MASK_WIDTH-1:0]  paxi_wstrb  ;
wire                      paxi_wvalid ;
wire                      paxi_wlast  ;
wire                      paxi_wready ;
// Read Address Ports
wire [MC_ADDR_WIDTH-1:0]  paxi_araddr ;
wire                      paxi_arvalid;
wire                      paxi_arready;
// Read Data Ports
wire [MC_DATA_WIDTH-1:0]  paxi_rdata  ;
wire                      paxi_rlast  ;
wire                      paxi_rvalid ;
wire                      paxi_rready ;
`endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// AXI to MC
///////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef MC0_MIS_AXI
mc0_axi2mc_top #(
    .AXI_ID_WIDTH     ( AXI_ID_WIDTH    ),
    .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH  ),
    .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH  ),
    .AXI_MASK_WIDTH   ( AXI_MASK_WIDTH  ),
    .MC_ADDR_WIDTH    ( MC_ADDR_WIDTH   ),
    .MC_DATA_WIDTH    ( MC_DATA_WIDTH   ),
    .MC_MASK_WIDTH    ( MC_MASK_WIDTH   )
) u_axi2mc (
// AXI Interface
// Clock & Reset
    .axi_aclk         ( axi_aclk        ),
    .axi_aresetn      ( axi_aresetn     ),
// AXI Write Address Channel
    .axi_awid         ( axi_awid        ),
    .axi_awaddr       ( axi_awaddr      ),
    .axi_awlen        ( axi_awlen       ),
    .axi_awsize       ( axi_awsize      ),
    .axi_awburst      ( axi_awburst     ),
    .axi_awlock       ( 1'b0            ),
    .axi_awcache      ( 4'b0000         ),
    .axi_awprot       ( 3'b000          ),
    .axi_awqos        ( 4'b0000         ),
    .axi_awvalid      ( axi_awvalid     ),
    .axi_awready      ( axi_awready     ),
// AXI Write Data Channel
    .axi_wdata        ( axi_wdata       ),
    .axi_wstrb        ( axi_wstrb       ),
    .axi_wlast        ( axi_wlast       ),
    .axi_wvalid       ( axi_wvalid      ),
    .axi_wready       ( axi_wready      ),
// AXI Write Response Channel
    .axi_bid          ( axi_bid         ),
    .axi_bresp        ( axi_bresp       ),
    .axi_bvalid       ( axi_bvalid      ),
    .axi_bready       ( axi_bready      ),
// AXI Read Address Channel
    .axi_arid         ( axi_arid        ),
    .axi_araddr       ( axi_araddr      ),
    .axi_arlen        ( axi_arlen       ),
    .axi_arsize       ( axi_arsize      ),
    .axi_arburst      ( axi_arburst     ),
    .axi_arlock       ( 1'b0            ),
    .axi_arcache      ( 4'b0000         ),
    .axi_arprot       ( 3'b000          ),
    .axi_arqos        ( 4'b0000         ),
    .axi_arvalid      ( axi_arvalid     ),
    .axi_arready      ( axi_arready     ),
// AXI Read Data Channel
    .axi_rid          ( axi_rid         ),
    .axi_rdata        ( axi_rdata       ),
    .axi_rresp        ( axi_rresp       ),
    .axi_rlast        ( axi_rlast       ),
    .axi_rvalid       ( axi_rvalid      ),
    .axi_rready       ( axi_rready      ),

// MC Interface
    .ddrphy_rdy       ( ddrphy_rdy      ),
// mc user interface
// Write Address Ports
    .paxi_awaddr      ( paxi_awaddr     ),
    .paxi_awvalid     ( paxi_awvalid    ),
    .paxi_awready     ( paxi_awready    ),
// Write Data Ports
    .paxi_wdata       ( paxi_wdata      ),
    .paxi_wstrb       ( paxi_wstrb      ),
    .paxi_wvalid      ( paxi_wvalid     ),
    .paxi_wlast       ( paxi_wlast      ),
    .paxi_wready      ( paxi_wready     ),
// Read Address Ports
    .paxi_araddr      ( paxi_araddr     ),
    .paxi_arvalid     ( paxi_arvalid    ),
    .paxi_arready     ( paxi_arready    ),
// Read Data Ports
    .paxi_rdata       ( paxi_rdata      ),
    .paxi_rlast       ( paxi_rlast      ),
    .paxi_rvalid      ( paxi_rvalid     ),
    .paxi_rready      ( paxi_rready     )
);
`endif

///////////////////////////////////////////////////////////////////////////////////////////////////
//  DDRMC Top
///////////////////////////////////////////////////////////////////////////////////////////////////
ph1p_ddrmc_top  #(
    .tCK              ( tCK              ),
    .BK_NUM           ( BK_NUM           ),
    .AC_NUM           ( AC_NUM           ),
    .DX_NUM           ( DX_NUM           ),

    .CK_WIDTH         ( CK_WIDTH         ),
    .CS_WIDTH         ( CS_WIDTH         ),
    .CKE_WIDTH        ( CKE_WIDTH        ),
    .ODT_WIDTH        ( ODT_WIDTH        ),
    .BG_WIDTH         ( BG_WIDTH         ),
    .BA_WIDTH         ( BA_WIDTH         ),
    .COL_WIDTH        ( COL_WIDTH        ),
    .ROW_WIDTH        ( ROW_WIDTH        ),
    .ADR_WIDTH        ( ADR_WIDTH        ),

    .HOST_AC_DRV      ( HOST_AC_DRV      ),
    .HOST_DX_DRV      ( HOST_DX_DRV      ),
    .HOST_DX_ODT      ( HOST_DX_ODT      ),
    .DRAM_DRV         ( DRAM_DRV         ),
    .DRAM_ODT         ( DRAM_ODT         ),

    .WDM              ( WDM              ),
    .CAL_EN           ( CAL_EN           ),
    .CWL              ( CWL              ),
    .CL               ( CL               ),
// PLL
    .PLL0_REFCLK_FREQ ( PLL0_REFCLK_FREQ ),
    .PLL0_REFCLK_DIV  ( PLL0_REFCLK_DIV  ),
    .PLL0_FBKCLK_DIV  ( PLL0_FBKCLK_DIV  ),
    .PLL0_CLK2_DIV    ( PLL0_CLK2_DIV    ),
    .PLL0_CLK3_DIV    ( PLL0_CLK3_DIV    ),
    .PLL0_FRAC        ( PLL0_FRAC        ),
    .PLL0_FRAC_SDM    ( PLL0_FRAC_SDM    ),
    .PLL1_REFCLK_FREQ ( PLL1_REFCLK_FREQ ),
    .PLL1_REFCLK_DIV  ( PLL1_REFCLK_DIV  ),
    .PLL1_CLK0_DIV    ( PLL1_CLK0_DIV    ),
//MC
    .MC_ECC           ( MC_ECC           ),
    .MC_ADDR_MAP      ( MC_ADDR_MAP      ),
    .MC_REORDER       ( MC_REORDER       ),
    .MC_ADDR_WIDTH    ( MC_ADDR_WIDTH    ),
    .MC_DATA_WIDTH    ( MC_DATA_WIDTH    ),
    .MC_MASK_WIDTH    ( MC_MASK_WIDTH    )
) ph1p_ddrmc_top (
// clock & reset
    .ref_clk          ( ref_clk          ),
    .sys_rst_n        ( sys_rst_n        ),
// debug apb
    .apb_pclk         ( apb_pclk         ),
    .apb_prst_n       ( apb_prst_n       ),
    .apb_pready       ( apb_pready       ),
    .apb_psel         ( apb_psel         ),
    .apb_penable      ( apb_penable      ),
    .apb_pwrite       ( apb_pwrite       ),
    .apb_paddr        ( apb_paddr        ),
    .apb_pwdata       ( apb_pwdata       ),
    .apb_prdata       ( apb_prdata       ),
// mc user interface
    .dhi_clk          ( dhi_clk          ),
    .cfg_clk          ( cfg_clk          ),
    .cfg_rst_n        ( cfg_rst_n        ),
    .ddrphy_rst_n     ( ddrphy_rst_n     ),
    .ddrphy_rdy       ( ddrphy_rdy       ),

    .paxi_awaddr      ( paxi_awaddr      ),
    .paxi_awvalid     ( paxi_awvalid     ),
    .paxi_awready     ( paxi_awready     ),
    .paxi_wdata       ( paxi_wdata       ),
    .paxi_wstrb       ( paxi_wstrb       ),
    .paxi_wvalid      ( paxi_wvalid      ),
    .paxi_wlast       ( paxi_wlast       ),
    .paxi_wready      ( paxi_wready      ),
    .paxi_araddr      ( paxi_araddr      ),
    .paxi_arvalid     ( paxi_arvalid     ),
    .paxi_arready     ( paxi_arready     ),
    .paxi_rdata       ( paxi_rdata       ),
    .paxi_rlast       ( paxi_rlast       ),
    .paxi_rvalid      ( paxi_rvalid      ),
    .paxi_rready      ( paxi_rready      ),
// ddrio
`ifdef DRAM_DDR4
    .ddr_ck_t         ( ddr_ck_t         ),
    .ddr_ck_c         ( ddr_ck_c         ),
    .ddr_reset_n      ( ddr_reset_n      ),
    .ddr_cke          ( ddr_cke          ),
    .ddr_odt          ( ddr_odt          ),
    .ddr_cs_n         ( ddr_cs_n         ),
    .ddr_act_n        ( ddr_act_n        ),
    .ddr_bg           ( ddr_bg           ),
    .ddr_ba           ( ddr_ba           ),
    .ddr_addr         ( ddr_addr         ),
    .ddr_dqs_t        ( ddr_dqs_t        ),
    .ddr_dqs_c        ( ddr_dqs_c        ),
    .ddr_dq           ( ddr_dq           ),
    .ddr_dm_n         ( ddr_dm_n         )
`else
    .ddr_ck_p         ( ddr_ck_p         ),
    .ddr_ck_n         ( ddr_ck_n         ),
`ifndef DRAM_DDR2
    .ddr_reset_n      ( ddr_reset_n      ),
`endif
    .ddr_cke          ( ddr_cke          ),
    .ddr_odt          ( ddr_odt          ),
    .ddr_cs_n         ( ddr_cs_n         ),
    .ddr_ras_n        ( ddr_ras_n        ),
    .ddr_cas_n        ( ddr_cas_n        ),
    .ddr_we_n         ( ddr_we_n         ),
    .ddr_ba           ( ddr_ba           ),
    .ddr_addr         ( ddr_addr         ),
    .ddr_dqs_p        ( ddr_dqs_p        ),
    .ddr_dqs_n        ( ddr_dqs_n        ),
    .ddr_dq           ( ddr_dq           ),
    .ddr_dm           ( ddr_dm           )
`endif
);

///////////////////////////////////////////////////////////////////////////////////////////////////
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-009"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
m9qcOt5lHUz/F+lrpf6AiPTCWKXE3qqNfJG/HFNRiZ0nckVPx97nc4RMEMTbPAlf
9JGllIgoMFJ7ZH7Ezb7aOPNJkSQm4Bk5XljwMlN4C3xCMI0ALM9VstD55LiHiPF+
RlscFeoorMmSjhfzHHXPzK4LuaUOKjgOInTrRS6PuTI=
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-009"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
m9qcOt5lHUz/F+lrpf6AiPTCWKXE3qqNfJG/HFNRiZ0nckVPx97nc4RMEMTbPAlf
9JGllIgoMFJ7ZH7Ezb7aOPNJkSQm4Bk5XljwMlN4C3xCMI0ALM9VstD55LiHiPF+
RlscFeoorMmSjhfzHHXPzK4LuaUOKjgOInTrRS6PuTI=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
iGDe174QOvlGg6aywFQXo7uWAhN4/9k0obvYWOWGusqCpX9dMpkOLvV7wn9pURJJ
SVc/k6ZrdDNN54sV3nhuoebBnew1pJT7xrjeSzcFzxk5klM/XPFpyB0LuSobaLEt
AH29AJGazQi9huI94TG7Uid9Arrcpb8c8zYWSAU51rNwORcwx6yzeWBNnYzBaEIW
3Pdv72fMiZwPyCaHLc6l4VLbXh7eqhvCUUDZ6vVDVPZdRmqR04y3M3R8e1LIzaqU
WT1w8/ICWtGI1T1T5KAUprM9gvKBqTlxa/shvKs5Iou0UTuWvWaWHONuz5HY/E/i
WjSC4J10hdZZX/ROXMGQ9g==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
l0h7NRg/On5Dx1GbkkoiNzM4bC+6eT9ViAio4lpYNxma0uN6wih4hhZ6FxApwRvD
/2z+8eIPycdOWy0UQi8jO7G1vIsxHrh/drjoKGuNW/afFzmuH6+W8erpvHj6o1vc
P6gVW6u0emiyfnga4TCrq4yZyriMaa8UdwM5pNVqnog=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
pz7npZw50nuSMdaeJCryzai6+SiicxpMF1Qh+kW4+9sOm2ud1QLskWgZuzOP3Zld
eDRuqoVvyHOrKEnNLe/UOn47reHUx9Yko7viXaJ3jVCCclgNCvPfR1XXCt9SX9pW
TCYnseV/NK2Hc9FTVJXaGNS1uzzpZu38P0xSq4q91NJ610RD/y544HU7C6MVDl2G
ZCMhdFsoCkzX9kbgj+iDM/UVbXpbDQNmBsYjF7MPr4c2LFDBfE4jIGcS+jPPOnbY
O/cTt3YySriwPCkHTrl/pbxcveVfetL15rgrUhbGnmCaiRIoykVRdxAr/DtrmB37
JaEHfnO18/zyeqy0WB9XVw==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
1uCh/WCyGsSf/cIm05faD9XOK4wtO53xOv7TPpCsbJehpJAk+BM2vlto80OkCl+g
30rCL4ZAUisOCxASlNIX1GApgHFDx2eA47XkjmaX6gxjAIw1OFxTfX1MLmEhqZ8a
plbMWGsLxzRQWtzXt6aj0cAlDiHsN0t+w4H/qDZnpCA=
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
mVQwPFmqTyJ2Oii57G06nfEQmH03W2WbdlFr608tBLW3BrwGiZwaHyWMGX6kaUae
Kcc9fIH4x+HLZoFxEf65kWfFxrod45JDOd86Y/vNIq3anZ4smHca5j+E7DtqOfzu
mufzbJLWYC+i8+moWMoXRW9Lx7YtLkO/ne/dy5PEG4M=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 48)
`pragma protect data_block
cUizKmd7oPh2xiQZDVcoDS7Cr0n/H3yAXMMi9veidM4uwVxByJzfy9M+UaXz3cnz
`pragma protect end_protected
///////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
