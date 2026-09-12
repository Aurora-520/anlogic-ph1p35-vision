
// ac_wdata - AC#0
assign ac0_wdata[ 0*8 +: 8] = 8'hff;
assign ac0_wdata[ 1*8 +: 8] = 8'hff;
assign ac0_wdata[ 2*8 +: 8] = 8'hff;
assign ac0_wdata[ 3*8 +: 8] = 8'hff;
assign ac0_wdata[ 4*8 +: 8] = dhi_addr_x8   [ 1*8 +: 8];
assign ac0_wdata[ 5*8 +: 8] = 8'hff;
assign ac0_wdata[ 6*8 +: 8] = 8'hff;
assign ac0_wdata[ 7*8 +: 8] = 8'hff;
assign ac0_wdata[ 8*8 +: 8] = dhi_addr_x8   [ 4*8 +: 8];
assign ac0_wdata[ 9*8 +: 8] = dhi_addr_x8   [ 6*8 +: 8];
assign ac0_wdata[10*8 +: 8] = dhi_addr_x8   [ 8*8 +: 8];
assign ac0_wdata[11*8 +: 8] = dhi_addr_x8   [11*8 +: 8];
assign ac0_wdata[12*8 +: 8] = 8'hff;
// ac_wdata - AC#1
assign ac1_wdata[ 0*8 +: 8] = dhi_ba_x8     [ 1*8 +: 8];
assign ac1_wdata[ 1*8 +: 8] = dhi_addr_x8   [ 9*8 +: 8];
assign ac1_wdata[ 2*8 +: 8] = 8'hff;
assign ac1_wdata[ 3*8 +: 8] = 8'hff;
assign ac1_wdata[ 4*8 +: 8] = dhi_addr_x8   [ 0*8 +: 8];
assign ac1_wdata[ 5*8 +: 8] = dhi_addr_x8   [12*8 +: 8];
assign ac1_wdata[ 6*8 +: 8] = 8'hff;
assign ac1_wdata[ 7*8 +: 8] = 8'hff;
assign ac1_wdata[ 8*8 +: 8] = dhi_addr_x8   [ 2*8 +: 8];
assign ac1_wdata[ 9*8 +: 8] = dhi_addr_x8   [10*8 +: 8];
assign ac1_wdata[10*8 +: 8] = 8'hff;
assign ac1_wdata[11*8 +: 8] = 8'hff;
assign ac1_wdata[12*8 +: 8] = 8'hff;
// ac_wdata - AC#2
assign ac2_wdata[ 0*8 +: 8] = dhi_ba_x8     [ 0*8 +: 8];
assign ac2_wdata[ 1*8 +: 8] = dhi_addr_x8   [ 3*8 +: 8];
assign ac2_wdata[ 2*8 +: 8] = 8'hff;
assign ac2_wdata[ 3*8 +: 8] = 8'hff;
assign ac2_wdata[ 4*8 +: 8] = dhi_cs_n_x8   [ 0*8 +: 8];
assign ac2_wdata[ 5*8 +: 8] = dhi_addr_x8   [ 5*8 +: 8];
assign ac2_wdata[ 6*8 +: 8] = 8'hff;
assign ac2_wdata[ 7*8 +: 8] = 8'hff;
assign ac2_wdata[ 8*8 +: 8] = dhi_cas_n_x8  [ 0*8 +: 8];
assign ac2_wdata[ 9*8 +: 8] = dhi_addr_x8   [ 7*8 +: 8];
assign ac2_wdata[10*8 +: 8] = 8'hff;
assign ac2_wdata[11*8 +: 8] = 8'hff;
assign ac2_wdata[12*8 +: 8] = 8'hff;
// ac_wdata - AC#3
assign ac3_wdata[ 0*8 +: 8] = 8'hff;
assign ac3_wdata[ 1*8 +: 8] = 8'hff;
assign ac3_wdata[ 2*8 +: 8] = 8'hff;
assign ac3_wdata[ 3*8 +: 8] = 8'hff;
assign ac3_wdata[ 4*8 +: 8] = dhi_ras_n_x8  [ 0*8 +: 8];
assign ac3_wdata[ 5*8 +: 8] = dhi_cke_x8    [ 0*8 +: 8];
assign ac3_wdata[ 6*8 +: 8] = 8'haa;
assign ac3_wdata[ 7*8 +: 8] = 8'h55;
assign ac3_wdata[ 8*8 +: 8] = dhi_odt_x8    [ 0*8 +: 8];
assign ac3_wdata[ 9*8 +: 8] = dhi_we_n_x8   [ 0*8 +: 8];
assign ac3_wdata[10*8 +: 8] = 8'hff;
assign ac3_wdata[11*8 +: 8] = 8'hff;
assign ac3_wdata[12*8 +: 8] = 8'hff;

// dx_wdata - DX#0
assign dx0_wdata[ 0*8 +: 8] =  dhi_wdq_bit   [(0*64+6*8) +: 8];
assign dx0_wdata[ 1*8 +: 8] =  8'hff;
assign dx0_wdata[ 2*8 +: 8] =  dhi_wdm       [ 0*8       +: 8];
assign dx0_wdata[ 3*8 +: 8] =  dhi_wdq_bit   [(0*64+1*8) +: 8];
assign dx0_wdata[ 4*8 +: 8] =  dhi_wdq_bit   [(0*64+0*8) +: 8];
assign dx0_wdata[ 5*8 +: 8] =  dhi_wdq_bit   [(0*64+7*8) +: 8];
assign dx0_wdata[ 6*8 +: 8] =  dhi_wdqs      [ 0*8       +: 8];
assign dx0_wdata[ 7*8 +: 8] = ~dhi_wdqs      [ 0*8       +: 8];
assign dx0_wdata[ 8*8 +: 8] =  dhi_wdq_bit   [(0*64+2*8) +: 8];
assign dx0_wdata[ 9*8 +: 8] =  dhi_wdq_bit   [(0*64+3*8) +: 8];
assign dx0_wdata[10*8 +: 8] =  dhi_wdq_bit   [(0*64+5*8) +: 8];
assign dx0_wdata[11*8 +: 8] =  dhi_wdq_bit   [(0*64+4*8) +: 8];
assign dx0_wdata[12*8 +: 8] =  8'hff;
// dx_wdata - DX#1
assign dx1_wdata[ 0*8 +: 8] =  dhi_wdq_bit   [(1*64+2*8) +: 8];
assign dx1_wdata[ 1*8 +: 8] =  dhi_wdq_bit   [(1*64+5*8) +: 8];
assign dx1_wdata[ 2*8 +: 8] =  dhi_wdq_bit   [(1*64+3*8) +: 8];
assign dx1_wdata[ 3*8 +: 8] =  dhi_wdq_bit   [(1*64+4*8) +: 8];
assign dx1_wdata[ 4*8 +: 8] =  dhi_wdq_bit   [(1*64+7*8) +: 8];
assign dx1_wdata[ 5*8 +: 8] =  8'hff;
assign dx1_wdata[ 6*8 +: 8] =  dhi_wdqs      [ 1*8       +: 8];
assign dx1_wdata[ 7*8 +: 8] = ~dhi_wdqs      [ 1*8       +: 8];
assign dx1_wdata[ 8*8 +: 8] =  dhi_wdm       [ 1*8       +: 8];
assign dx1_wdata[ 9*8 +: 8] =  dhi_wdq_bit   [(1*64+0*8) +: 8];
assign dx1_wdata[10*8 +: 8] =  dhi_wdq_bit   [(1*64+6*8) +: 8];
assign dx1_wdata[11*8 +: 8] =  dhi_wdq_bit   [(1*64+1*8) +: 8];
assign dx1_wdata[12*8 +: 8] =  8'hff;

// dhi_rdq - DX#0
assign dhi_rdq_bit[(0*64+6*8) +: 8] = dx0_rdata[ 0*8 +: 8];
assign dhi_rdq_bit[(0*64+1*8) +: 8] = dx0_rdata[ 3*8 +: 8];
assign dhi_rdq_bit[(0*64+0*8) +: 8] = dx0_rdata[ 4*8 +: 8];
assign dhi_rdq_bit[(0*64+7*8) +: 8] = dx0_rdata[ 5*8 +: 8];
assign dhi_rdq_bit[(0*64+2*8) +: 8] = dx0_rdata[ 8*8 +: 8];
assign dhi_rdq_bit[(0*64+3*8) +: 8] = dx0_rdata[ 9*8 +: 8];
assign dhi_rdq_bit[(0*64+5*8) +: 8] = dx0_rdata[10*8 +: 8];
assign dhi_rdq_bit[(0*64+4*8) +: 8] = dx0_rdata[11*8 +: 8];
// dhi_rdq - DX#1
assign dhi_rdq_bit[(1*64+2*8) +: 8] = dx1_rdata[ 0*8 +: 8];
assign dhi_rdq_bit[(1*64+5*8) +: 8] = dx1_rdata[ 1*8 +: 8];
assign dhi_rdq_bit[(1*64+3*8) +: 8] = dx1_rdata[ 2*8 +: 8];
assign dhi_rdq_bit[(1*64+4*8) +: 8] = dx1_rdata[ 3*8 +: 8];
assign dhi_rdq_bit[(1*64+7*8) +: 8] = dx1_rdata[ 4*8 +: 8];
assign dhi_rdq_bit[(1*64+0*8) +: 8] = dx1_rdata[ 9*8 +: 8];
assign dhi_rdq_bit[(1*64+6*8) +: 8] = dx1_rdata[10*8 +: 8];
assign dhi_rdq_bit[(1*64+1*8) +: 8] = dx1_rdata[11*8 +: 8];

// dhi_rdq_en
assign dx0_rdqs_gate = dhi_rdq_en[0*8 +: 8];
assign dx1_rdqs_gate = dhi_rdq_en[1*8 +: 8];

// dhi_rdq_vld
assign dhi_rdq_vld[0] = dx_rdata_vld[0];
assign dhi_rdq_vld[1] = dx_rdata_vld[1];

// dx_indd - DX#0
assign dx_indd[6] = dx_indd_bit[0*13+0];
assign dx_indd[1] = dx_indd_bit[0*13+3];
assign dx_indd[0] = dx_indd_bit[0*13+4];
assign dx_indd[7] = dx_indd_bit[0*13+5];
assign dx_indd[2] = dx_indd_bit[0*13+8];
assign dx_indd[3] = dx_indd_bit[0*13+9];
assign dx_indd[5] = dx_indd_bit[0*13+10];
assign dx_indd[4] = dx_indd_bit[0*13+11];
// dx_indd - DX#1
assign dx_indd[10] = dx_indd_bit[1*13+0];
assign dx_indd[13] = dx_indd_bit[1*13+1];
assign dx_indd[11] = dx_indd_bit[1*13+2];
assign dx_indd[12] = dx_indd_bit[1*13+3];
assign dx_indd[15] = dx_indd_bit[1*13+4];
assign dx_indd[8] = dx_indd_bit[1*13+9];
assign dx_indd[14] = dx_indd_bit[1*13+10];
assign dx_indd[9] = dx_indd_bit[1*13+11];

// IOCLK
assign ctl_clk_ac[0] = ctl_clk[0];
assign ddr_clk_ac[0] = ddr_clk[0];
assign ctl_clk_ac[1] = ctl_clk[0];
assign ddr_clk_ac[1] = ddr_clk[0];
assign ctl_clk_ac[2] = ctl_clk[0];
assign ddr_clk_ac[2] = ddr_clk[0];
assign ctl_clk_ac[3] = ctl_clk[0];
assign ddr_clk_ac[3] = ddr_clk[0];
assign ctl_clk_dx[0] = ctl_clk[1];
assign ddr_clk_dx[0] = ddr_clk[1];
assign ctl_clk_dx[1] = ctl_clk[1];
assign ddr_clk_dx[1] = ddr_clk[1];
