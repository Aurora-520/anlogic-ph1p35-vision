`timescale 1ns / 1ps

/*
 * SC500CS 1280x720 @ 60 fps 当前完整寄存器配置
 * ------------------------------------------------------------
 * 本模式使用 24 MHz MCLK、2-Lane MIPI、RAW10，Lane速率约
 * 480 Mbps，并通过Sensor内部VBIN和HSUB输出真实的1280x720图像。
 * 当前工程默认编译并使用本文件；备用的1920x1080@30完整配置
 * 保存在uics500reg_1080p30.v中，默认不加入工程源文件列表。
 *
 * 提示：以后切换分辨率或帧率时，不能只更换Sensor寄存器表，
 * 还需要同步检查MIPI接收参数、图像宽高、ISP、DDR帧缓存、
 * HDMI时序、HDMI TX参数以及相关时钟和时序约束。各级配置必须
 * 使用同一组分辨率和帧率，否则可能出现黑屏、花屏或图像错位。
 */
module uics500reg_720p60(
    input      [8:0]  REG_INDEX,
    output reg [31:0] REG_DATA,
    output     [8:0]  REG_SIZE
);
assign REG_SIZE = 9'd116;
always @(*) begin
    case (REG_INDEX)
        0: REG_DATA={16'h0103,8'h01}; 1: REG_DATA={16'h0100,8'h00};
        2: REG_DATA={16'h36e9,8'h80}; 3: REG_DATA={16'h36f9,8'h80};
        4: REG_DATA={16'h36ea,8'h3c}; 5: REG_DATA={16'h36ec,8'h1b};
        6: REG_DATA={16'h36fd,8'h14}; 7: REG_DATA={16'h36e9,8'h04};
        8: REG_DATA={16'h36f9,8'h04}; 9: REG_DATA={16'h3016,8'h10};
        10: REG_DATA={16'h3017,8'h0e}; 11: REG_DATA={16'h301f,8'h04};
        12: REG_DATA={16'h302d,8'h20}; 13: REG_DATA={16'h3106,8'h01};
        14: REG_DATA={16'h3200,8'h00}; 15: REG_DATA={16'h3201,8'h14};
        16: REG_DATA={16'h3202,8'h01}; 17: REG_DATA={16'h3203,8'h00};
        18: REG_DATA={16'h3204,8'h0a}; 19: REG_DATA={16'h3205,8'h1b};
        20: REG_DATA={16'h3206,8'h06}; 21: REG_DATA={16'h3207,8'ha7};
        22: REG_DATA={16'h3208,8'h05}; 23: REG_DATA={16'h3209,8'h00}; // 1280
        24: REG_DATA={16'h320a,8'h02}; 25: REG_DATA={16'h320b,8'hd0}; // 720
        26: REG_DATA={16'h320c,8'h06}; 27: REG_DATA={16'h320d,8'h40}; // HTS 1600
        28: REG_DATA={16'h320e,8'h03}; 29: REG_DATA={16'h320f,8'he8}; // VTS 1000
        30: REG_DATA={16'h3210,8'h00}; 31: REG_DATA={16'h3211,8'h02};
        32: REG_DATA={16'h3212,8'h00}; 33: REG_DATA={16'h3213,8'h02};
        34: REG_DATA={16'h3215,8'h31}; 35: REG_DATA={16'h3220,8'h01}; // VBIN + HSUB
        36: REG_DATA={16'h3249,8'h0f}; 37: REG_DATA={16'h3253,8'h06};
        38: REG_DATA={16'h3271,8'h13}; 39: REG_DATA={16'h3273,8'h13};
        40: REG_DATA={16'h3301,8'h0a}; 41: REG_DATA={16'h3309,8'h60};
        42: REG_DATA={16'h330a,8'h00}; 43: REG_DATA={16'h330b,8'he8};
        44: REG_DATA={16'h331e,8'h41}; 45: REG_DATA={16'h331f,8'h51};
        46: REG_DATA={16'h3320,8'h04}; 47: REG_DATA={16'h3333,8'h10};
        48: REG_DATA={16'h335d,8'h60}; 49: REG_DATA={16'h3364,8'h56};
        50: REG_DATA={16'h336b,8'h08}; 51: REG_DATA={16'h3390,8'h08};
        52: REG_DATA={16'h3391,8'h18}; 53: REG_DATA={16'h3392,8'h38};
        54: REG_DATA={16'h3393,8'h0a}; 55: REG_DATA={16'h3394,8'h24};
        56: REG_DATA={16'h3395,8'h40}; 57: REG_DATA={16'h33ad,8'h29};
        58: REG_DATA={16'h341c,8'h04}; 59: REG_DATA={16'h341d,8'h04};
        60: REG_DATA={16'h341e,8'h03}; 61: REG_DATA={16'h3425,8'h00};
        62: REG_DATA={16'h3426,8'h00}; 63: REG_DATA={16'h3622,8'hc7};
        64: REG_DATA={16'h3632,8'h44}; 65: REG_DATA={16'h3636,8'h6e};
        66: REG_DATA={16'h3637,8'h08}; 67: REG_DATA={16'h3638,8'h0a};
        68: REG_DATA={16'h3651,8'h9d}; 69: REG_DATA={16'h3670,8'h4b};
        70: REG_DATA={16'h3674,8'hc0}; 71: REG_DATA={16'h3675,8'h58};
        72: REG_DATA={16'h3676,8'h5a}; 73: REG_DATA={16'h367c,8'h18};
        74: REG_DATA={16'h367d,8'h38}; 75: REG_DATA={16'h3690,8'h43};
        76: REG_DATA={16'h3691,8'h53}; 77: REG_DATA={16'h3692,8'h53};
        78: REG_DATA={16'h3699,8'h08}; 79: REG_DATA={16'h369a,8'h10};
        80: REG_DATA={16'h369b,8'h1f}; 81: REG_DATA={16'h369c,8'h18};
        82: REG_DATA={16'h369d,8'h38}; 83: REG_DATA={16'h36a2,8'h08};
        84: REG_DATA={16'h36a3,8'h18}; 85: REG_DATA={16'h36a6,8'h08};
        86: REG_DATA={16'h36a7,8'h18}; 87: REG_DATA={16'h36ab,8'h40};
        88: REG_DATA={16'h36ac,8'h40}; 89: REG_DATA={16'h36ad,8'h40};
        90: REG_DATA={16'h3901,8'h00}; 91: REG_DATA={16'h3904,8'h0c};
        92: REG_DATA={16'h3906,8'h3a}; 93: REG_DATA={16'h391d,8'h14};
        94: REG_DATA={16'h3e00,8'h00}; 95: REG_DATA={16'h3e01,8'h7c};
        96: REG_DATA={16'h3e02,8'h60}; 97: REG_DATA={16'h4000,8'h00};
        98: REG_DATA={16'h4001,8'h04}; 99: REG_DATA={16'h4002,8'haa};
        100: REG_DATA={16'h4003,8'haa}; 101: REG_DATA={16'h4004,8'haa};
        102: REG_DATA={16'h4005,8'h00}; 103: REG_DATA={16'h4006,8'h07};
        104: REG_DATA={16'h4007,8'ha5}; 105: REG_DATA={16'h4008,8'h00};
        106: REG_DATA={16'h4009,8'hc8}; 107: REG_DATA={16'h440e,8'h02};
        108: REG_DATA={16'h4509,8'h28}; 109: REG_DATA={16'h4837,8'h42}; // 480 Mbps/lane
        110: REG_DATA={16'h5000,8'h4e}; 111: REG_DATA={16'h5901,8'h04};
        // The factory file leaves gain at its reset default.  Program a
        // 4x analogue gain for the 60 fps mode's shorter exposure time.
        112: REG_DATA={16'h3e08,8'h0f}; 113: REG_DATA={16'h3e09,8'h20};
        114: REG_DATA={16'h0100,8'h01}; // stream on
        115: REG_DATA={16'h302d,8'h00}; // after 10 ms delay
        default: REG_DATA={16'h0000,8'h00};
    endcase
end
endmodule
