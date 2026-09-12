localparam [15:0] AC0_BD = 110;
localparam [15:0] AC1_BD = 110;
localparam [15:0] AC2_BD = 0;
localparam [15:0] AC3_BD = 0;
localparam [15:0] AC4_BD = 0;
localparam [15:0] AC5_BD = 0;
localparam [15:0] AC6_BD = 0;
localparam [15:0] AC7_BD = 0;
localparam [15:0] AC8_BD = 0;

localparam [15:0] DX0_BD = 110;
localparam [15:0] DX1_BD = 110;
localparam [15:0] DX2_BD = 0;
localparam [15:0] DX3_BD = 0;
localparam [15:0] DX4_BD = 0;
localparam [15:0] DX5_BD = 0;
localparam [15:0] DX6_BD = 0;
localparam [15:0] DX7_BD = 0;
localparam [15:0] DX8_BD = 0;

localparam [15:0] AC_DX_BD_0 = AC0_BD + DX0_BD;
localparam [15:0] AC_DX_BD_1 = AC1_BD + DX1_BD;
localparam [15:0] AC_DX_BD_2 = AC2_BD + DX2_BD;
localparam [15:0] AC_DX_BD_3 = AC3_BD + DX3_BD;
localparam [15:0] AC_DX_BD_4 = AC4_BD + DX4_BD;
localparam [15:0] AC_DX_BD_5 = AC5_BD + DX5_BD;
localparam [15:0] AC_DX_BD_6 = AC6_BD + DX6_BD;
localparam [15:0] AC_DX_BD_7 = AC7_BD + DX7_BD;
localparam [15:0] AC_DX_BD_8 = AC8_BD + DX8_BD;

localparam [15:0] CK_DX_SKEW_0 = AC0_BD - DX0_BD;
localparam [15:0] CK_DX_SKEW_1 = AC1_BD - DX1_BD;
localparam [15:0] CK_DX_SKEW_2 = AC2_BD - DX2_BD;
localparam [15:0] CK_DX_SKEW_3 = AC3_BD - DX3_BD;
localparam [15:0] CK_DX_SKEW_4 = AC4_BD - DX4_BD;
localparam [15:0] CK_DX_SKEW_5 = AC5_BD - DX5_BD;
localparam [15:0] CK_DX_SKEW_6 = AC6_BD - DX6_BD;
localparam [15:0] CK_DX_SKEW_7 = AC7_BD - DX7_BD;
localparam [15:0] CK_DX_SKEW_8 = AC8_BD - DX8_BD;

localparam AC_DX_BD   = {AC_DX_BD_8, AC_DX_BD_7, AC_DX_BD_6, AC_DX_BD_5, AC_DX_BD_4, AC_DX_BD_3, AC_DX_BD_2, AC_DX_BD_1, AC_DX_BD_0};
localparam CK_DX_SKEW = {CK_DX_SKEW_8, CK_DX_SKEW_7, CK_DX_SKEW_6, CK_DX_SKEW_5, CK_DX_SKEW_4, CK_DX_SKEW_3, CK_DX_SKEW_2, CK_DX_SKEW_1, CK_DX_SKEW_0};
