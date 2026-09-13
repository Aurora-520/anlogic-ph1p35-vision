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

## 最终模块化边界

- `rtl/app/design_top_wrapper.v`：唯一板级顶层，只负责端口映射。
- `vendor_reference/rtl/vendor_lab1_core.v`：官方 Lab1 功能核心的隔离副本；禁止在此加入比赛算法。
- `rtl/app/vision_pipeline.v`：项目自有视频处理入口，后续边缘检测、OSD、模式控制从这里接入。
- `rtl/control/mode_ctrl.v`：KEY1~KEY4 消抖和算法模式状态机（模块名仍为 `algorithm_mode_ctrl`）。
- `rtl/isp/pixel_algorithm.v`：RGB 直通、灰度、二值化和 3x3 Sobel 边缘输出。
- `rtl/overlay/logo_overlay.v`：官方安路 Logo 叠加，位于算法输出之后，因此所有算法模式都显示 Logo。
- `rtl/overlay/anlogic_logo_rom.v`：从 Lab3 OSD 例程复制的 Logo ROM。
- `rtl/platform/`：平台相关封装与后续板级适配代码；不放算法业务逻辑。
- `rtl/config/vision_config.vh`：分辨率、功能开关等项目级配置的唯一来源。
- `rtl/common/video_stream_if.vh`：自研模块之间的视频流接口约定。
- `user_source/hdl_source/uics500_cfg/`：SC500 I2C 配置和 720p60 寄存器表。
- `user_source/hdl_source/mipi_dphy_rx/`：PH1P35 MIPI 接收 IP/封装。
- `user_source/hdl_source/isp/`：CSI/RAW10 解包、去马赛克和颜色处理。
- `user_source/hdl_source/ph1p35_ddr/`：DDR2 控制器及 PHY。
- `user_source/hdl_source/video_in.v`、`video_out.v`：帧缓存读写。
- `user_source/hdl_source/vtc/uivtc.v`、`hdmi_mixer.v`、`hdmi_tx.v`：HDMI 时序和发送。
- `user_source/constraints_source/pin.adc`：HX1P35A 引脚约束。

官方底层文件仍保留在 `user_source/hdl_source/`，因为这些文件包含 TD/IP 生成依赖；板级单体顶层已经移入 `vendor_reference` 并改名为 `vendor_lab1_core`，TD 工程现在由自有顶层统一封装。这样既保留可工作的官方链路，又避免以后直接修改官方顶层。

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

## 按键算法模式

按键为低有效，约束对应 HX1P35A 四键图：

```text
上电        -> 彩色原图
KEY1(D5)    -> 二值化；再次 KEY1 -> 彩色原图
KEY2(A9)    -> Sobel 边缘；再次 KEY2 -> 彩色原图
KEY3(B9)    -> 灰度图；再次 KEY3 -> 彩色原图
KEY4(C7)    -> 当前版本预留
```

算法处理位于 HDMI 像素时钟域，输出时序沿用官方视频读出链；MIPI、DDR、HDMI PHY 不改动。
