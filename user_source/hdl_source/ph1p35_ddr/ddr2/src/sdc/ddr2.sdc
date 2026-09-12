derive_clocks

# PLL0
rename_clock -name ref_clk [get_clocks {ph1p_ddrmc_wrapper/ph1p_ddrmc_top/u_ddr_phy/u_ddrphy_top/u_ddrphy_clk/u_pll0/u_pll_inst.clkc[0]}]
rename_clock -name ctl_clk [get_clocks {ph1p_ddrmc_wrapper/ph1p_ddrmc_top/u_ddr_phy/u_ddrphy_top/u_ddrphy_clk/u_pll0/u_pll_inst.clkc[1]}]
rename_clock -name ddr_clk [get_clocks {ph1p_ddrmc_wrapper/ph1p_ddrmc_top/u_ddr_phy/u_ddrphy_top/u_ddrphy_clk/u_pll0/u_pll_inst.clkc[2]}]
rename_clock -name mcu_clk [get_clocks {ph1p_ddrmc_wrapper/ph1p_ddrmc_top/u_ddr_phy/u_ddrphy_top/u_ddrphy_clk/u_pll0/u_pll_inst.clkc[3]}]

# PLL1
rename_clock -name usr_clk [get_clocks {ph1p_ddrmc_wrapper/ph1p_ddrmc_top/u_ddr_phy/u_ddrphy_top/u_ddrphy_clk/u_pll1/u_pll_inst.clkc[0]}]

set_clock_groups -asynchronous -group [get_clocks mcu_clk]
