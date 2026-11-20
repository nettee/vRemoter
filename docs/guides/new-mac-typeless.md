# 新 Mac 安装手册：Chromecast 遥控器接入 Typeless

更新日期：2026-11-20。适用定制版：`1.2.3-typeless.5`。

目标：按一下遥控器语音键，松手说话，再按一下结束出字；也能按住说话、松开结束。电脑原有 Typeless 快捷键可以继续使用。

## 1. 准备什么

- 一台 Apple 芯片 Mac（M 系列），拥有管理员验证权限。
- Chromecast Voice Remote，装好电池。已实测型号为 `18D1:9450`、固件 `26.5`；不是 Chromecast 投屏接收器，也不需要把投屏器接到电脑上。
- Typeless 账号、网络连接。
- 原版驱动安装包和本 fork 的定制 App，二者都需要。

当前提供的 `.5.zip` 中 App 为 **arm64**，不能直接用于 Intel Mac。项目声明最低 macOS 12，但完整链路仅在 M4 Pro、macOS 15.7.1、Typeless 2.11.0 上实测；其他系统还需满足所安装 Typeless 版本的要求。源码可在目标机器构建，不代表 Intel 已实测可用。

### 获取文件

| 文件 | 用途 | 获取方式 |
| --- | --- | --- |
| `vRemoter-1.2.3.pkg` | 首次安装虚拟麦克风驱动，同时会安装原版 App | [上游原版 PKG](https://updates.vincentstudio.org/vremoter/vRemoter-1.2.3.pkg) |
| `vRemoter-1.2.3-typeless.5.zip` | 替换为本 fork 的 Typeless 定制 App；不含驱动 | 从原电脑通过隔空投送／文件复制取得本次构建包；也可按文末说明自行构建 |
| Typeless macOS 安装包 | 语音识别与文字输入 | [Typeless 官方下载](https://www.typeless.com/downloads) |

原电脑留存的 `vRemoter-1.2.3-verified.pkg` 与表中的原版 PKG 内容相同，仅文件名不同。

**本 fork 已推送源码，但截至本手册日期未发布 `.5` 的 GitHub Release 附件。** 不要把 GitHub 的“Download ZIP”源码压缩包当成可安装 App，也不要假定 Releases 页面已有安装包。

可在终端核对 SHA-256，例如先输入 `shasum -a 256 `，再将下载文件拖进终端并回车：

| 文件 | 本次核验的 SHA-256 |
| --- | --- |
| 原版 `1.2.3.pkg` | `d59be08ab10b3293d1f23eb8cf2ba454af4dd7e9cf353062d7135c46ccb938ba` |
| 本次构建 `.5.zip` | `5593703d5f218dac3fd476843bcaad982e5e2f685d9f5d1ff53892cc7e1625ed` |

这两个校验值只适用于上述文件；重新构建或重新压缩的 ZIP 可能不同。原版 PKG 信息来自[上游版本清单](https://updates.vincentstudio.org/vremoter/releases.json)。

## 2. 安装 Typeless，先确认电脑本身能出字

1. 打开 Typeless DMG，将 App 拖到“应用程序”，从那里启动并登录。
2. 按提示授权 Typeless 的“麦克风”和“辅助功能”。可在“系统设置 → 隐私与安全性”中核对。
3. 暂时使用 Typeless 的自动检测／电脑麦克风，打开备忘录或文本编辑器。
4. 用 Typeless 的键盘快捷键说一句话，确认电脑麦克风可以正常出字。

这一步失败时先解决 Typeless 本身的登录、权限或收音问题，再继续接遥控器。[Typeless 官方安装说明](https://www.typeless.com/help/installation-and-setup)

## 3. 安装虚拟麦克风驱动

1. 结束正在进行的通话、录音等工作。原版 PKG 安装会重启系统音频服务，声音可能短暂中断。
2. 双击原版 `vRemoter-1.2.3.pkg`，按安装器提示完成管理员验证。
3. 安装完成后，原版 vRemoter 可能自动打开。通过其菜单栏菜单选择“退出”，暂时不要配置原版语音功能。
4. 在“系统设置 → 声音 → 输入”中检查是否出现 **`vRemoteDr 2ch`**。此时只需确认设备存在，不必把它设为系统默认输入。

安装后的驱动目录是：

```text
/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver
```

如果列表里没有设备，先重启 Mac，再检查。如果仍没有，确认装的是含驱动的 **PKG**，不是仅含 App 的 ZIP／DMG。

**只有 App 不够；只安装普通 BlackHole 也不等于安装了 `vRemoteDr 2ch`。** 本 fork 使用这个专用设备名称和标识。

## 4. 把原版 App 替换为 Typeless 定制版

1. 确认原版 vRemoter 已退出。
2. 解压 `vRemoter-1.2.3-typeless.5.zip`，得到 **`vRemote.app`**。
3. 在访达中把它拖到“应用程序”，替换原版 `/Applications/vRemote.app`，按需完成管理员验证。
4. 从“应用程序”启动替换后的 App。
5. 查看控制台版本号，必须显示 **`1.2.3-typeless.5`**。显示 `1.2.3` 代表仍打开了原版。

也可以把定制 App 命名为 `vRemote-Typeless.app` 再放进“应用程序”，但应只运行一个 vRemote 实例，并关闭原版的登录自启。为减少新手混淆，本手册推荐直接替换原版路径。

当前构建使用本地 ad-hoc 签名，未进行 Developer ID 公证。如 macOS 阻止打开，核对来源和文件校验值后，由你在“系统设置 → 隐私与安全性”中按系统提示允许该文件打开。不要关闭整个系统的安全检查；如果系统将文件报告为损坏或恶意内容，停止并重新核对文件。

安装位置固定之后再授权，避免先从下载目录运行，之后又移动 App，导致权限指向旧副本。

## 5. 把遥控器配对到这台 Mac

1. 如果遥控器正在连接旧 Mac，先在旧 Mac 中断开连接，或暂时关闭旧 Mac 的蓝牙，避免重新连回去。
2. 在新 Mac 打开“系统设置 → 蓝牙”。
3. 同时按住遥控器上的 **返回键（←）和 Home 键（房子）**，直到遥控器指示灯开始闪烁，再松手。
4. 在新 Mac 的附近设备中找到 **Chromecast Remote**，选择连接。
5. 回到 vRemoter，等待遥控器状态变为 **HID · BLE 已就绪**。

Google 的[官方说明](https://support.google.com/chromecast/answer/10109990?hl=en)确认“返回＋Home”进入配对状态；在 Mac 上发现和连接设备是本项目的使用方式，不是该官方电视设置教程的适配承诺。

配对状态与语音状态不是一回事：只有 HID 连接时，普通按键可能工作，但语音还需要 BLE 服务就绪。

## 6. 给 vRemoter 开启权限

按 App 提示操作，再到“系统设置 → 隐私与安全性”核对：

| 权限 | 授权给谁 | 用途 |
| --- | --- | --- |
| 麦克风 | vRemoter、Typeless | 采集电脑音源、读取语音输入 |
| 辅助功能 | vRemoter、Typeless | 发送快捷键、向输入框写入文字 |
| 输入监控 | vRemoter | 识别遥控器／键盘触发事件与按键映射 |
| 蓝牙 | vRemoter（系统要求时） | 接收遥控器 BLE 语音流 |

列表中可能显示 `vRemoter` 或 `vRemote`。确认条目对应“应用程序”中的定制 App。系统要求退出并重新打开时，照做。

使用 Typeless 不需要安装豆包，也不需要授予“打开豆包设置”的 App 管理权限。

## 7. 对齐 vRemoter 和 Typeless 的设置

### vRemoter 设置

在“按键映射”页设置：

| 设置项 | 值 |
| --- | --- |
| 语音工具 | **Typeless** |
| 遥控器模式 | **点按免持／按住说话** |
| 触发键 | **Fn / Globe** |

在“音频”页让 **MacBook 麦克风**和**遥控器麦克风**两个开关都打开。新安装 `.5` 默认使用上述工具、模式和触发键，但仍建议核对。

### Typeless 设置

1. 打开 Typeless 的 Settings。
2. 在 Keyboard shortcuts → **Dictate** 下，将 Fn／地球键设为语音输入快捷键。
3. 如果已经习惯右 Command，优先通过 **Add another** 添加 Fn，保留右 Command。录制快捷键时，在电脑键盘上轻按一次 Fn／地球键。
4. 在 **Audio → Microphone** 中明确选择 **`vRemoteDr 2ch`**，不要留在自动检测。
5. 确认 Typeless 的点按开始／结束方式可用。不同版本的界面可能变化，以本机设置为准；本 fork 会发送一次短 Fn 点击来开始，再发送一次来结束。

快捷键和麦克风的官方设置路径见 [Typeless Settings guide](https://www.typeless.com/help/quickstart/settings)。

关键条件：**vRemoter 的触发键必须等于 Typeless 的 Dictate 快捷键，Typeless 的麦克风必须是 `vRemoteDr 2ch`。** 不要把 Fn 录到 Translate 或 Ask anything。

不需要改变 Mac 的系统默认输入或扬声器输出设备；只修改 Typeless 内的麦克风选择即可。

## 8. 分三轮验收，避免“其实录的是电脑麦克风”

先在备忘录／文本编辑器中点击正文，保持光标可输入。不要一开始就在聊天输入框测试确认键，以免意外发送。

### A. 电脑快捷键继续可用

两个音源开关都打开，在电脑附近，用原来的 Typeless 快捷键说一句话。应正常出字，且不用切换麦克风。

### B. 遥控器独立收音

1. 暂时关闭 vRemoter 中的 **MacBook 麦克风**开关，只保留遥控器音源。
2. 按住遥控器语音键，靠近遥控器说约 8 秒，再松手。
3. 应在松手后出字；这轮通过才能证明音频来自遥控器。

### C. 点按免持

1. 继续保持只有遥控器音源。
2. 轻按一次语音键，立即松手，说约 8 秒，再轻按一次结束。
3. 成功后，再重复一轮约 30–40 秒，确认没有中途结束。
4. **测试结束后重新打开 MacBook 麦克风开关**，再用电脑原有快捷键说一句，确认恢复双音源日常状态。

本项目之前已在一台 M4 Pro Mac 上通过这三类测试，点按最长一轮约 37 秒。新 Mac 需要重新验收，不能把已有机器的结果视为新机器已通过。

## 9. 可选：配置 Codex 日常按键

语音验收完成后，再在 vRemoter“按键映射”中选择 Chromecast，开启“启用映射”，按下表逐项设置。配置文件样例在 [Examples/chromecast-codex.plist](../../Examples/chromecast-codex.plist)；它不会随 App 安装自动导入。

| 遥控器按键 | 映射 |
| --- | --- |
| 方向环 | 对应的方向键 |
| 中央确认 | Return |
| 返回 | Escape |
| Home | 切换应用 |
| YouTube | Tab |
| Netflix | Delete |
| 信源 | 粘贴（⌘V） |
| 音量＋／－、静音 | 对应系统声音功能 |
| 电源 | 禁用 |

映射作用于当前前台应用。先选择 Codex 并聚焦输入框，再用语音键出字；中央 Return 键可能发送当前输入。Escape 在普通文本框里常常没有可见效果，这不代表按键失效。静音控制的是扬声器，不是遥控器收音。

## 10. 常见问题与恢复

| 现象 | 按顺序检查 |
| --- | --- |
| 没有 `vRemoteDr 2ch` | 是否安装了原版 PKG；检查驱动目录；重启 Mac 后重新打开 Typeless |
| 语音键一两秒就停、没有出字 | 先核对定制版版本号、语音工具是否为 Typeless；不要误运行原版或旧版本 |
| Typeless 不启动，或只开出系统菜单 | 两边触发键是否均为 Fn；Typeless 是否添加在 Dictate；辅助功能与输入监控是否授权；检查系统 Fn 功能或其他快捷键软件是否冲突 |
| Typeless 启动，但录不到声音 | Typeless 是否选了虚拟麦克风；vRemoter 是否运行；遥控器音源开关是否打开；BLE 是否就绪 |
| 离电脑远一点就不出字 | 暂时关闭 Mac 音源做独立收音测试，确认不是一直在录电脑麦克风 |
| 遥控器按键正常，但语音不行 | 普通 HID 和 BLE 音频是两条链路；检查 BLE 状态、蓝牙权限，重开 vRemoter 后再试 |
| 电脑原来的语音快捷键没声音 | 打开 MacBook 麦克风混音；如果 vRemoter 已退出，把 Typeless 麦克风改回自动检测／电脑麦克风 |
| 录音开始／结束状态不同步 | 停止 Typeless 当前录音；用 vRemoter“结束录音”关闭遥控器会话；必要时退出重开两者，再从空闲状态开始 |
| 普通按键启用映射后不工作 | 检查输入监控权限；重开 vRemoter；查看日志中是否有 `[CAST-HID] manager open failed`。本 fork 未实现该权限失败的通用修复，可先关闭映射恢复原行为 |
| 新 Mac 搜不到遥控器 | 先断开旧 Mac 连接；重新按住返回＋Home进入配对；检查电池与距离 |

日志在：

```text
~/Library/Logs/vRemote/vRemote.log
```

需要诊断时，在 vRemoter 菜单中开启日志。日志有助于区分按键、BLE 和音源问题，不需要为了排查而开启原始录音保存。

### 先恢复电脑正常语音输入

不必先卸载驱动：

1. 在 Typeless 中结束当前录音。
2. 在 Typeless → Audio → Microphone 中改回自动检测或电脑内置麦克风。
3. 退出 vRemoter。
4. 用原有电脑快捷键验证出字。

### 日常启动与后续更新

验收完成后，可分别在 vRemoter 菜单和 Typeless 设置中开启登录自启。先运行 vRemoter，再使用已选虚拟麦克风的 Typeless。

更新时只替换定制 App，通常无需重装驱动。本 fork 的更新源指向自己的 GitHub Releases，但没有发布附件时，仍应手动复制新 App 或自行构建。不要重新运行原版 PKG 覆盖已装好的定制 App，除非确实需要修复驱动并准备再次替换 App。

## 附录：没有定制 ZIP 时，从源码构建 App

这条路线用于能使用终端的用户。**先完成第 3 节驱动安装**；只运行 App 构建脚本不会安装驱动。

1. 安装 Xcode Command Line Tools，等待系统安装完成：

```sh
xcode-select --install
```

2. 在终端中克隆代码并构建本手册对应版本：

```sh
git clone https://github.com/nettee/vRemoter.git
cd vRemoter
git checkout 87cfcb34bb0056b41c67a5da77ad69169b592d21
swift --version
swift run --disable-sandbox vRemote --voice-session-self-test
zsh Scripts/run-self-tests.sh
zsh Scripts/package-app.sh
```

这里固定提交以复现 `.5` 的代码。要使用后续版本，应先看对应 changelog。每条检查或构建命令成功后再继续；失败就停止，保留报错，不要安装不完整产物。首次构建需要网络下载 SwiftPM 依赖。

3. 构建成功后的 App 位于 `dist/build/vRemote.app`。按第 4 节退出原版、复制 App 到“应用程序”，再继续权限与 Typeless 配置。

不要把 `Scripts/build-pkg.sh` 当作新 Mac 的第一步：它额外依赖本机已安装的 `BlackHole2ch.driver`，驱动构建目前为二进制修改方案。普通安装路线应使用前面已核验的原版驱动 PKG。
