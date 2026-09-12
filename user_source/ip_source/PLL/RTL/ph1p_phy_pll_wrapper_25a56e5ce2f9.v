
module ph1p_phy_pll_wrapper_25a56e5ce2f9 #(
    parameter FBKCLK                 = "CLKC0_EXT",     
    parameter FBKCLK_INT             = "VCO_PHASE0",     
    parameter FIN                    = "100.0000",     	
    parameter REFCLK_DIV             = 1,                                   
    parameter FBCLK_DIV              = 1,               

    parameter CLKC0_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC0           = "VCO",                   
    parameter DIVOUT_MUXC0           = "DIV",	
    parameter CLKC0_DIV              = 1,  
    parameter CLKC0_CPHASE           = 0,  
    parameter CLKC0_FPHASE           = 0,
    parameter CLKC0_FPHASE_RSTSEL    = 0, 
    parameter CLKC0_DUTY50           = "ENABLE",              
    parameter CLKC0_DUTY_INT         = 1,    

    parameter CLKC1_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC1           = "VCO",                   
    parameter DIVOUT_MUXC1           = "DIV",	
    parameter CLKC1_DIV              = 1,  
    parameter CLKC1_CPHASE           = 0,  
    parameter CLKC1_FPHASE           = 0,
    parameter CLKC1_FPHASE_RSTSEL    = 0, 
    parameter CLKC1_DUTY50           = "ENABLE",              
    parameter CLKC1_DUTY_INT         = 1,    

    parameter CLKC2_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC2           = "VCO",                   
    parameter DIVOUT_MUXC2           = "DIV",	
    parameter CLKC2_DIV              = 1,  
    parameter CLKC2_CPHASE           = 0,  
    parameter CLKC2_FPHASE           = 0,
    parameter CLKC2_FPHASE_RSTSEL    = 0, 
    parameter CLKC2_DUTY50           = "ENABLE",              
    parameter CLKC2_DUTY_INT         = 1,    

    parameter CLKC3_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC3           = "VCO",                   
    parameter DIVOUT_MUXC3           = "DIV",	
    parameter CLKC3_DIV              = 1,  
    parameter CLKC3_CPHASE           = 0,  
    parameter CLKC3_FPHASE           = 0,
    parameter CLKC3_FPHASE_RSTSEL    = 0, 
    parameter CLKC3_DUTY50           = "ENABLE",              
    parameter CLKC3_DUTY_INT         = 1,    
	
    parameter CLKC4_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC4           = "VCO",                   
    parameter DIVOUT_MUXC4           = "DIV",	
    parameter CLKC4_DIV              = 1,  
    parameter CLKC4_CPHASE           = 0,  
    parameter CLKC4_FPHASE           = 0,
    parameter CLKC4_FPHASE_RSTSEL    = 0, 
    parameter CLKC4_DUTY50           = "ENABLE",              
    parameter CLKC4_DUTY_INT         = 1,    

    parameter CLKC5_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC5           = "VCO",                   
    parameter DIVOUT_MUXC5           = "DIV",	
    parameter CLKC5_DIV              = 1,  
    parameter CLKC5_CPHASE           = 0,  
    parameter CLKC5_FPHASE           = 0,
    parameter CLKC5_FPHASE_RSTSEL    = 0, 
    parameter CLKC5_DUTY50           = "ENABLE",              
    parameter CLKC5_DUTY_INT         = 1,    
	
    parameter CLKC6_ENABLE           = "DISABLE", 
    parameter PREDIV_MUXC6           = "VCO",                   
    parameter DIVOUT_MUXC6           = "DIV",	
    parameter CLKC6_DIV              = 1,  
    parameter CLKC6_CPHASE           = 0,  
    parameter CLKC6_FPHASE           = 0,
    parameter CLKC6_FPHASE_RSTSEL    = 0, 
    parameter CLKC6_DUTY50           = "ENABLE",              
    parameter CLKC6_DUTY_INT         = 1,  

    parameter WORK_MODE              = "USER",          

    parameter PD_DIG                 = "ENABLE",        
    parameter PLL_USR_RST            = "ENABLE",        
    parameter PLL_FEED_TYPE          = "INTERNAL",      
    parameter PLL_FASTLOOP           = "DISABLE",     

// loop     parameter
    parameter LPF_RES                = 3,               
    parameter LPF_CAP                = 3,               
    parameter ICP_CUR                = 1,               
//frac-N
    parameter FRAC_ENABLE            = "DISABLE",       
    parameter SDM_FRAC               = 0,                              

//fine phase shift
    parameter PHASE_PATH_SEL         = 0,               
    parameter DYN_PHASE_PATH_SEL     = "DISABLE",       
    parameter DYN_FPHASE_EN          = "DISABLE",       

//ssc
    parameter SSC_ENABLE             = "DISABLE",             
    parameter SSC_RST                = "ENABLE",        
    parameter SSC_MODE               = "CENTER",        
    parameter SSC_FREQ_DIV           = 0,                              
    parameter SSC_RNGE               = 242,                            

// lock detector
    parameter REFCLK_DET_BYP         = "DISABLE",       
//channel 0 frac div related
    parameter CLKC0_FRAC_EN          = "DISABLE",             
    parameter CLKC0_FRAC             = 0,               
    parameter PI_OUT_SEL             = "NORMAL",        
    parameter PI_FRAC_EN             = "DISABLE",       
    parameter CLKC0_PI_SHIFT_EN      = "DISABLE",       

    parameter FEEDBK_MODE            = "NORMAL",        
    parameter DYN_CPHASE_EN          = "DISABLE"       
) (
//Global clocks
    input           refclk,                          
    input           fbclk, 
//output clocks
	input			clk0_en,
	output			clk0_out,
	output			clkb0_out,

	input			clk1_en,
	output			clk1_out,
	output			clkb1_out,

	input			clk2_en,
	output			clk2_out,
	output			clkb2_out,

	input			clk3_en,
	output			clk3_out,
	output			clkb3_out,

	input			clk4_en,
	output			clk4_out,
	output			clkb4_out,

	input			clk5_en,
	output			clk5_out,
	output			clkb5_out,

	input			clk6_en,
	output			clk6_out,
	output			clkb6_out,
//PLL  lock detector
    output          lock,           
//PLL and output path reset 
    input           reset,       
    input   [1:0]   clkc_rst,          
    input           refclk_rst,     
    input           wakeup,         
       
//PLL dynamic coarse phase shift
    input           cps_step,       
//PLL power done
    input           pllpd,          
//PLL   dynami fine phase shift
    input           psclk,          
    input   [2:0]   psclksel,       
    input           psstep,         
    input           psdown,         
    output          psdone,         
//Ports of drp
    input           drp_clk,        
    input           drp_rstn,       
    input           drp_sel,        
    input           drp_rd,         
    input           drp_wr,         
    input  [7:0]    drp_addr,                      
    input  [7:0]    drp_wdata,                     
    output          drp_err,        
    output          drp_rdy,        
    output [7:0]    drp_rdata,                       
//Ports of ssc
    input           ssc_reset                     
);

	PH1P_PHY_PLL_V2 #(
    .FBKCLK                 (FBKCLK),
    .FBKCLK_INT             (FBKCLK_INT),
    .FIN                    (FIN),
//loop     parameter
    .REFCLK_DIV             (REFCLK_DIV),
    .FBCLK_DIV              (FBCLK_DIV),
//fine phase shift
    .CLKC0_FPHASE           (CLKC0_FPHASE),
    .CLKC1_FPHASE           (CLKC1_FPHASE),
    .CLKC2_FPHASE           (CLKC2_FPHASE),
    .CLKC3_FPHASE           (CLKC3_FPHASE),
    .CLKC4_FPHASE           (CLKC4_FPHASE),
    .CLKC5_FPHASE           (CLKC5_FPHASE),
    .CLKC6_FPHASE           (CLKC6_FPHASE),
//coarse phase shift
    .PREDIV_MUXC0           (PREDIV_MUXC0),
    .PREDIV_MUXC1           (PREDIV_MUXC1),
    .PREDIV_MUXC2           (PREDIV_MUXC2),
    .PREDIV_MUXC3           (PREDIV_MUXC3),
    .PREDIV_MUXC4           (PREDIV_MUXC4),
    .PREDIV_MUXC5           (PREDIV_MUXC5),
    .PREDIV_MUXC6           (PREDIV_MUXC6),

    .CLKC0_CPHASE           (CLKC0_CPHASE),
    .CLKC1_CPHASE           (CLKC1_CPHASE),
    .CLKC2_CPHASE           (CLKC2_CPHASE),
    .CLKC3_CPHASE           (CLKC3_CPHASE),
    .CLKC4_CPHASE           (CLKC4_CPHASE),
    .CLKC5_CPHASE           (CLKC5_CPHASE),
    .CLKC6_CPHASE           (CLKC6_CPHASE),
//output divider
    .CLKC0_DIV              (CLKC0_DIV),
    .CLKC1_DIV              (CLKC1_DIV),
    .CLKC2_DIV              (CLKC2_DIV),
    .CLKC3_DIV              (CLKC3_DIV),
    .CLKC4_DIV              (CLKC4_DIV),
    .CLKC5_DIV              (CLKC5_DIV),
    .CLKC6_DIV              (CLKC6_DIV),
// duty
    .CLKC0_DUTY_INT         (CLKC0_DUTY_INT),
    .CLKC1_DUTY_INT         (CLKC1_DUTY_INT),
    .CLKC2_DUTY_INT         (CLKC2_DUTY_INT),
    .CLKC3_DUTY_INT         (CLKC3_DUTY_INT),
    .CLKC4_DUTY_INT         (CLKC4_DUTY_INT),
    .CLKC5_DUTY_INT         (CLKC5_DUTY_INT),
    .CLKC6_DUTY_INT         (CLKC6_DUTY_INT),
// clk output
    .DIVOUT_MUXC0           (DIVOUT_MUXC0),
    .DIVOUT_MUXC1           (DIVOUT_MUXC1),
    .DIVOUT_MUXC2           (DIVOUT_MUXC2),
    .DIVOUT_MUXC3           (DIVOUT_MUXC3),
    .DIVOUT_MUXC4           (DIVOUT_MUXC4),
    .DIVOUT_MUXC5           (DIVOUT_MUXC5),
    .DIVOUT_MUXC6           (DIVOUT_MUXC6),

    .CLKC0_ENABLE           (CLKC0_ENABLE),
    .CLKC1_ENABLE           (CLKC1_ENABLE),
    .CLKC2_ENABLE           (CLKC2_ENABLE),
    .CLKC3_ENABLE           (CLKC3_ENABLE),
    .CLKC4_ENABLE           (CLKC4_ENABLE),
    .CLKC5_ENABLE           (CLKC5_ENABLE),
    .CLKC6_ENABLE           (CLKC6_ENABLE),

    .WORK_MODE              (WORK_MODE),

    .PD_DIG                 (PD_DIG),
    .PLL_USR_RST            (PLL_USR_RST),
    .PLL_FEED_TYPE          (PLL_FEED_TYPE),
    .PLL_FASTLOOP           (PLL_FASTLOOP),

// loop     parameter
    .LPF_RES                (LPF_RES),
    .LPF_CAP                (LPF_CAP),
    .ICP_CUR                (ICP_CUR),
//frac-N
    .FRAC_ENABLE            (FRAC_ENABLE),
    .SDM_FRAC               (SDM_FRAC),

//fine phase shift
    .PHASE_PATH_SEL         (PHASE_PATH_SEL),
    .DYN_PHASE_PATH_SEL     (DYN_PHASE_PATH_SEL),
    .DYN_FPHASE_EN          (DYN_FPHASE_EN),

    .CLKC0_FPHASE_RSTSEL    (CLKC0_FPHASE_RSTSEL),
    .CLKC1_FPHASE_RSTSEL    (CLKC1_FPHASE_RSTSEL),
    .CLKC2_FPHASE_RSTSEL    (CLKC2_FPHASE_RSTSEL),
    .CLKC3_FPHASE_RSTSEL    (CLKC3_FPHASE_RSTSEL),
    .CLKC4_FPHASE_RSTSEL    (CLKC4_FPHASE_RSTSEL),
    .CLKC5_FPHASE_RSTSEL    (CLKC5_FPHASE_RSTSEL),
    .CLKC6_FPHASE_RSTSEL    (CLKC6_FPHASE_RSTSEL),

    .CLKC0_DUTY50           (CLKC0_DUTY50),
    .CLKC1_DUTY50           (CLKC1_DUTY50),
    .CLKC2_DUTY50           (CLKC2_DUTY50),
    .CLKC3_DUTY50           (CLKC3_DUTY50),
    .CLKC4_DUTY50           (CLKC4_DUTY50),
    .CLKC5_DUTY50           (CLKC5_DUTY50),
    .CLKC6_DUTY50           (CLKC6_DUTY50),
//ssc
    .SSC_ENABLE             (SSC_ENABLE),
    .SSC_RST                (SSC_RST),
    .SSC_MODE               (SSC_MODE),
    .SSC_FREQ_DIV           (SSC_FREQ_DIV),
    .SSC_RNGE               (SSC_RNGE),

// lock detector
    .REFCLK_DET_BYP         (REFCLK_DET_BYP),
//channel 0 frac div related
    .CLKC0_FRAC_EN          (CLKC0_FRAC_EN),
    .CLKC0_FRAC             (CLKC0_FRAC),
    .PI_OUT_SEL             (PI_OUT_SEL),
    .PI_FRAC_EN             (PI_FRAC_EN),
    .CLKC0_PI_SHIFT_EN      (CLKC0_PI_SHIFT_EN),

    .FEEDBK_MODE            (FEEDBK_MODE),
    .DYN_CPHASE_EN          (DYN_CPHASE_EN)
	) u_PH1P_PHY_PLL (
		.refclk			( refclk		),
		.refclk_rst		( refclk_rst	),
		.fbclk			( fbclk			),
		.clkc			({clk6_out,clk5_out,clk4_out,clk3_out,clk2_out,clk1_out,clk0_out}),
		.clkcb			({clkb6_out,clkb5_out,clkb4_out,clkb3_out,clkb2_out,clkb1_out,clkb0_out}),
		.lock			( lock			),
		.pllreset		( reset  		),
		.clkc_rst		( clkc_rst		),
		.clkc_en		({clk6_en,clk5_en,clk4_en,clk3_en,clk2_en,clk1_en,clk0_en}),
		.wakeup			( wakeup		),
		.cps_step		( cps_step		),
		.pllpd			( pllpd			),
		.drp_clk		( drp_clk		),
		.drp_rstn		( drp_rstn		),
		.drp_sel		( drp_sel		),
		.drp_rd			( drp_rd		),
		.drp_wr			( drp_wr		),
		.drp_addr		( drp_addr		),
		.drp_wdata		( drp_wdata		),
		.drp_err		( drp_err		),
		.drp_rdy		( drp_rdy		),
		.drp_rdata		( drp_rdata		),
		.psdone			( psdone		),
		.psclk			( psclk			),
		.psdown			( psdown		),
		.psstep			( psstep		),
		.psclksel		( psclksel		),
		.ssc_reset		( ssc_reset		),
        .scan_clk       ( 1'b1          ),
        .scan_enable    ( 1'b1          ),
        .scan_mode      ( 1'b0          ),
        .scan_resetn    ( 1'b1          )
	);

endmodule

