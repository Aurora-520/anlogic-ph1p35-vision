
// DDR2_256M
// DDR2_512M
// DDR2_1G
// DDR2_2G
// DDR2_4G

// DDR2_X4
// DDR2_X8
// DDR2_X16

// DDR2_400B
// DDR2_400C
// DDR2_533B
// DDR2_533C
// DDR2_667C
// DDR2_667D
// DDR2_800C
// DDR2_800D
// DDR2_800E
// DDR2_1066
// DDR2_1333

///////////////////////////////////////////////////////////////////////////////////////////////////
localparam real tREFI =  7_800_000;
localparam real tRTP  =  7_500;
localparam real tWR   = 15_000;
///////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef DDR2_256M
localparam real tRFC = 75_000;
`endif

`ifdef DDR2_512M
localparam real tRFC = 105_000;
`endif

`ifdef DDR2_1G
localparam real tRFC = 127_500;
`endif

`ifdef DDR2_2G
localparam real tRFC = 195_000;
`endif

`ifdef DDR2_4G
localparam real tRFC = 327_500;
`endif

///////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef DDR2_400B
localparam CL   = 3;
localparam real tRAS = 40_000;
localparam real tRC  = 55_000;
`include "ddr2_400.vh"
`endif

`ifdef DDR2_400C
localparam CL   = 4;
localparam real tRAS = 45_000;
localparam real tRC  = 65_000;
`include "ddr2_400.vh"
`endif

`ifdef DDR2_533B
localparam CL   = 3;
localparam real tRAS = 45_000;
localparam real tRC  = 56_250;
`include "ddr2_533.vh"
`endif

`ifdef DDR2_533C
localparam CL   = 4;
localparam real tRAS = 45_000;
localparam real tRC  = 60_000;
`include "ddr2_533.vh"
`endif

`ifdef DDR2_667C
localparam CL   = 4;
localparam real tRAS = 45_000;
localparam real tRC  = 57_000;
`include "ddr2_667.vh"
`endif

`ifdef DDR2_667D
localparam CL   = 5;
localparam real tRAS = 45_000;
localparam real tRC  = 60_000;
`include "ddr2_667.vh"
`endif

`ifdef DDR2_800C
localparam CL   = 4;
localparam real tRAS = 45_000;
localparam real tRC  = 55_000;
`include "ddr2_800.vh"
`endif

`ifdef DDR2_800D
localparam CL   = 5;
localparam real tRAS = 45_000;
localparam real tRC  = 57_500;
`include "ddr2_800.vh"
`endif

`ifdef DDR2_800E
localparam CL   = 6;
localparam real tRAS = 45_000;
localparam real tRC  = 60_000;
`include "ddr2_800.vh"
`endif

`ifdef DDR2_1066
localparam CL   = 7;
localparam real tRAS = 45_000;
localparam real tRC  = 58_125;
`include "ddr2_1066.vh"
`endif

`ifdef DDR2_1333
localparam CL   = 9;
localparam real tRAS = 45_000;
localparam real tRC  = 58_500;
`include "ddr2_1333.vh"
`endif

`ifdef DDR2_1333_8
localparam CL   = 8;
localparam real tRAS = 45_000;
localparam real tRC  = 58_500;
`include "ddr2_1333.vh"
`endif

`ifdef DDR2_1333_9
localparam CL   = 9;
localparam real tRAS = 45_000;
localparam real tRC  = 58_500;
`include "ddr2_1333.vh"
`endif

///////////////////////////////////////////////////////////////////////////////////////////////////
localparam integer nRCD  = CL;
localparam integer nRP   = CL;
localparam integer nREFI = $ceil(tREFI/tCK);
localparam integer nFAW  = $ceil(tFAW /tCK);
localparam integer nRAS  = $ceil(tRAS /tCK);
localparam integer nRFC  = $ceil(tRFC /tCK);
localparam integer nRRD  = $ceil(tRRD /tCK);
localparam integer nWR   = $ceil(tWR  /tCK);
///////////////////////////////////////////////////////////////////////////////////////////////////

