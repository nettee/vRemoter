# vRemoter · Chromecast + Typeless

把蓝牙语音遥控器变成 Mac 的语音麦克风与快捷键控制器，方便在 Codex 等工具中进行 Vibe Coding。

本项目 fork 自 [VincentKingHsu/vRemoter](https://github.com/VincentKingHsu/vRemoter)，定制开发位于 [`feat/chromecast-typeless`](https://github.com/nettee/vRemoter/tree/feat/chromecast-typeless)。当前版本：**1.2.3-typeless.6**。改动记录见 [CHANGELOG.md](CHANGELOG.md)。

第一次安装或迁移到另一台电脑，请按[新 Mac 安装与 Typeless 接入手册](docs/guides/new-mac-typeless.md)操作。

## 语音输入

1. 从 [Releases](https://github.com/nettee/vRemoter/releases/tag/v1.2.3-typeless.6) 下载 Apple 芯片版独立 PKG 并安装。它同时安装定制 App 与虚拟麦克风驱动，无需原版 vRemoter 或 BlackHole。
2. 通过 macOS 蓝牙设置配对 Chromecast Voice Remote，启动 vRemoter，并授予麦克风、辅助功能、输入监控和蓝牙权限。
3. 在“按键映射 → 语音工具”选择 **Typeless**，触发键设为 **Fn / Globe**；在 Typeless 中添加同一个点按开始／结束快捷键。可以保留原来的右 Command 快捷键。
4. 在 Typeless 中选择 **vRemoteDr 2ch** 作为麦克风。
5. 选择“点按免持／按住说话”：点按语音键，松手后说话，再点按结束；也可按住说话，松开结束。

新安装默认选择 Typeless、Fn 和点按免持。已有用户的选择保留；需要只按住说话时，可在遥控器模式中选择“按住说话”。原有豆包兼容模式仍可选，Typeless 不依赖它的安装或录音状态。

Mac 麦克风开关打开时，电脑音频也会送入虚拟麦克风，包括遥控器未录音的时候，因此原有右 Command 等 Typeless 快捷键仍可用。关闭 Mac 开关可单独验证遥控器收音。系统静音键控制扬声器，不是麦克风静音。

结束录音后，Typeless 将文字放入当前输入框；再按确认键发送。点按控制与音源由 vRemoter 协调；用其他 Typeless 快捷键或其界面结束遥控器会话，可能导致状态不同步。此时先停止 Typeless，再用 vRemoter 的结束录音控制关闭遥控器，重新开始。传输失败会关闭会话并报告错误。

退出 vRemoter 后，如需继续使用电脑语音输入，请在 Typeless 中将麦克风改回自动检测或电脑麦克风。

## Codex 日常按键方案

在“按键映射”中启用 Chromecast 映射。下面是实机使用的方案，也保存在 [Examples/chromecast-codex.plist](Examples/chromecast-codex.plist) 中。该文件仅记录偏好配置，不会由安装包自动导入。

| 按键 | 映射 | 用途 |
| --- | --- | --- |
| 语音 | 语音会话 | 点按开始／结束，或按住说话 |
| 方向环 | ↑↓←→ | 移动光标、选择菜单、历史输入 |
| 中央确认 | Return | 确认／发送，取决于前台焦点及发送设置 |
| 返回 | Escape | 取消／关闭弹层；不是页面后退 |
| Home | 切换应用 | 连按轮换，停手 1 秒选定；切换中可用左右方向选择 |
| YouTube | Tab | 移动焦点／缩进 |
| Netflix | Delete | 删除光标前一个字符 |
| 信源 | ⌘V | 粘贴 |
| 音量＋／－、静音 | 系统声音 | 调整扬声器 |
| 电源 | 禁用 | 不发送动作 |

映射作用于当前前台应用。Escape 在普通文本框里可能没有可见效果；Codex 的页面后退为 ⌘[。可在 Codex 的 Settings → Keyboard Shortcuts 核对本机快捷键。

## 验证记录

2026-11-19 实机：Apple M4 Pro、macOS 15.7.1、Chromecast Remote `18D1:9450`、固件 `26.5`、Typeless 2.11.0。

- 已验证仅遥控器收音的按住说话、松开出字。
- 已验证点按免持，多轮连续出字，最长一轮约 37 秒，无中断。
- 已验证同一虚拟麦克风下，电脑右 Command 语音输入仍可用。
- 已验证删除、确认、Tab、左右方向与应用切换；返回键日志确认发送 Escape。未逐项验证全部 Codex 界面效果。
- X6 兼容代码保留，本 fork 未进行 X6 实机测试。

## 构建与检查

```sh
swift run --disable-sandbox vRemote --voice-session-self-test
zsh Scripts/run-self-tests.sh
zsh Scripts/build-pkg.sh
zsh Scripts/test-package.sh
```

独立安装包为 `dist/vRemoter-1.2.3-typeless.6-AppleSilicon.pkg`，包括 `dist/build/vRemote.app` 与从仓库内源码构建的 HAL 驱动。构建和目标机器均无需安装原版或 BlackHole。需要 Apple 开发工具；首次 App 构建需要联网获取 SwiftPM 依赖。

App 与驱动使用本地 ad-hoc 签名，安装包尚未进行 Developer ID 签名与公证。首次打开可能需要在系统隐私与安全性设置中由用户确认。安装需要管理员授权，并会短暂重启音频服务。

驱动源码、许可和构建说明见 [Driver/README.md](Driver/README.md) 与 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。Release 随附对应驱动源码压缩包和 SHA-256 校验文件。更新源指向本 fork 的 GitHub Releases。

## 源码与历史

- `Sources/vRemote/`：App、BLE/ATVV、混音、状态协调与按键映射。
- `SelfTests/`：协议与配置回归数据。
- `Scripts/`：构建、打包与测试脚本。
- `Examples/`：实机使用的遥控器配置示例。
- `docs/`：随仓库维护的静态页面；历史截图来自上游，可能与当前界面不同。
- `CHANGELOG.md`：本 fork 改动及上游历史。
- `OPERATIONS.md`、`Server/`、`Design/`：保留的上游运维与设计材料，不代表本 fork 已部署这些服务。

原项目作者与第三方归属保留；本 App 使用 [MIT 许可](LICENSE)；第三方与音频驱动许可见第三方许可说明及对应源文件。
