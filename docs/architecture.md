# Phase 1 架构

## 目标

先跑通一条不可破坏的官方基线：

```text
SC500CS
  -> 2-lane MIPI D-PHY RX
  -> CSI-2 unpacket
  -> RAW10 unpacket
  -> ISP（BLC/demosaic/AWB）
  -> DDR2 frame buffer / clock crossing
  -> HDMI timing / TMDS TX
```

视频模式固定为 SC500CS 1280x720@60fps，HDMI 有效区为 1280x720。第一阶段不切换 1080p30，不改 MIPI PHY、DDR、PLL 和 HDMI 物理层。

## 当前源代码边界

- `user_source/hdl_source/design_top_wrapper.v`：系统例化和时钟/复位连接。
- `user_source/hdl_source/uics500_cfg/`：SC500 I2C 配置和 720p60 寄存器表。
- `user_source/hdl_source/mipi_dphy_rx/`：PH1P35 MIPI 接收 IP/封装。
- `user_source/hdl_source/isp/`：CSI/RAW10 解包、去马赛克和颜色处理。
- `user_source/hdl_source/ph1p35_ddr/`：DDR2 控制器及 PHY。
- `user_source/hdl_source/video_in.v`、`video_out.v`：帧缓存读写。
- `user_source/hdl_source/vtc/uivtc.v`、`hdmi_mixer.v`、`hdmi_tx.v`：HDMI 时序和发送。
- `user_source/constraints_source/pin.adc`：HX1P35A 引脚约束。

`rtl/` 当前只作为后续自有模块的目标目录。若直接移动官方文件，必须同步修改 `.al` 的相对路径和编译顺序；第一阶段不做迁移。

## 关键时钟域

| 时钟 | 用途 |
|---|---|
| `I_sys_clk` / `sys_clk_50m` | 顶层、控制和 PLL 输入 |
| `S_100m_clk` | MIPI LP/控制 |
| `S_24m_clk` | SC500 EXTCLK 和 I2C |
| `S_csi_rx_clk` | MIPI/CSI/RAW10/ISP 输入链 |
| `S_ddr_clk` | DDR2 用户接口和视频帧缓存 |
| `S_hdmi_pixel_clk` | HDMI 720p 像素时序 |
| `S_hdmi_serial_clk` | HDMI 串行发送 |

跨时钟域只能通过官方 FIFO、DDR 帧缓存或明确的同步器完成。不要把一个时钟域的 `valid` 直接送到另一个时钟域。

## 调试模式

`design_top_wrapper.v` 当前将 `hdmi_mixer` 设置为 `DEBUG_MODE=0`，默认输出摄像头画面。临时定位 HDMI 问题时可以改为 `1`（彩条）或 `3`（四段链路状态条），重新综合并生成 `.bit`；调试完成后恢复为 `0`。

