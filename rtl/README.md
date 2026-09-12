# 自有 RTL 目录

第一阶段不移动官方 `user_source` 文件，确保 TD 相对路径和编译顺序稳定。后续新增的自有模块按以下目录放置：

- `isp/`：灰度、Sobel、滤波、颜色处理
- `analytics/`：目标检测、帧差、统计
- `overlay/`：OSD、Logo、状态栏
- `control/`：按键、模式和参数
- `stream/`：自有流接口适配、CDC、FIFO

模块接入前先写接口说明和仿真，再修改 `.al` 的源文件列表。
