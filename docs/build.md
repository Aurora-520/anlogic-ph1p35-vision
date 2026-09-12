# 从源码编译与下载

## 工程入口

在安路 TD 中打开：

```text
E:\Projects\Embedded\FPGA\anlogic-ph1p35-vision\td_project\camera_to_dsi_display.al
```

不要打开 `best_result`，也不要只新建一个空工程添加少量 `.v` 文件。`.al` 已经包含完整源文件、IP、引脚和时序约束。

## 编译

1. 检查 Device 为 `PH1P35MDG324`，Top Module 为 `design_top_wrapper`。
2. 运行 `Synthesis`。
3. 检查 `syn_1` 日志无 error。
4. 运行 `Physical Design` 或 `Place & Route`。
5. 检查时序报告无关键负裕量。
6. 在以下目录取出本次生成的文件：

```text
td_project\camera_to_dsi_display_Runs\phy_1\camera_to_dsi_display.bit
```

以文件修改时间确认它确实是本次生成的结果。`best_result` 可能是官方旧结果，不能作为“已重新编译”的证据。

## 下载

第一次用 BitWriter 的 `PROGRAM_SRAM` 加载 `.bit`。它只在当前上电期间运行，适合验证。确认摄像头到 HDMI 稳定后，再通过 `Create Flash File` 生成 Flash 镜像，使用 `PROGRAM_FLASH` 固化。

## 修改后重编译

任何 HDL、约束或 IP 参数变化，都要重新执行：

```text
保存 → Synthesis → Physical Design → 生成 bit → PROGRAM_SRAM
```

只运行综合不会生成最终可下载的布局布线结果。

