# 修改影响矩阵

| 修改内容 | 必查文件/模块 | 额外验证 |
|---|---|---|
| 摄像头寄存器 | `uics500_cfg/uics500reg_720p60.v`、`uicfgcs500_720p.v` | I2C ACK、MIPI 数据类型、帧尺寸 |
| 分辨率/帧率 | 摄像头表、`isp_top.v`、`video_in/out.v`、`uivtc.v`、`hdmi_tx.v`、PLL、SDC、DDR 地址 | 带宽、行帧计数、时序、长稳 |
| 图像算法 | `isp/` 或后续 `rtl/isp/` | 每像素 valid/sof/eol 对齐、行缓存延迟 |
| OSD/Logo | `hdmi_mixer.v` 或后续 `rtl/overlay/` | 像素坐标、叠加优先级、字符 ROM |
| 按键/模式 | `key_remove_shakes.v`、后续 `rtl/control/` | 消抖、单次事件、跨域同步 |
| 引脚 | `constraints_source/pin.adc` | 板卡版本、原理图页码、电平 |
| DDR/FIFO | `video_in.v`、`video_out.v`、DDR IP | 满/空、读写忙、CDC、溢出 |

规则：一次 PR 尽量只改一个类别；任何平台层改动必须保留可回退的 Lab1 tag。

