// min in tCK
localparam nCCD = 2;
localparam nRTP = 3;
localparam nWTR = 3;
// min in ps
localparam real tWTR = 7_500;

`ifdef DDR2_256M
localparam real tRRD =  7_500;
localparam real tFAW = 35_000;
`else // DDR2_512M DDR2_1G DDR2_2G DDR2_4G
`ifdef DDR2_X16
localparam real tRRD = 10_000;
localparam real tFAW = 45_000;
`else // DDR2_X4 DDR2_X8
localparam real tRRD =  7_500;
localparam real tFAW = 35_000;
`endif
`endif
