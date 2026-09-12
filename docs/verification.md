# Phase 1 验收清单

## 编译验收

- [ ] 顶层 `design_top_wrapper`。
- [ ] Device `PH1P35MDG324`。
- [ ] `.al` 中关键源文件 `UsedInSyn=true`、`UsedInP&R=true`。
- [ ] Synthesis 无 error。
- [ ] Physical Design 完成并生成新的 `.bit`。
- [ ] 50MHz、24MHz、MIPI、DDR、HDMI 时钟均有约束。

## 实板验收

- [ ] HX1P35A 使用稳定供电。
- [ ] SC500CS FPC 方向正确，摄像头由板卡供电。
- [ ] HDMI OUT 接显示器或采集卡 HDMI IN。
- [ ] BitWriter 显示 `PH1P35MDG324`。
- [ ] `PROGRAM_SRAM` 显示 `Downloading succeeded`。
- [ ] 等待 5-15 秒后有 1280x720 画面。
- [ ] 连续运行 30 分钟无黑屏、花屏、丢帧。

## 黑屏隔离

1. 普通 HDMI 显示器直连开发板，排除采集卡兼容性。
2. 将 `DEBUG_MODE` 改为 `1`，验证 HDMI 彩条。
3. 将 `DEBUG_MODE` 改为 `3`，观察 I2C、MIPI、CSI、1280 行状态。
4. 只有彩条正常而摄像头画面黑时，才重点检查 SC500 供电、27MHz、I2C、排线和 MIPI lane。

