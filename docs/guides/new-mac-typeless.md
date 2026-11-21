# 新 Mac 安装手册：Chromecast 遥控器接入 Typeless

更新日期：2026-11-21。适用定制版：`1.2.3-typeless.7`。

目标：按一下遥控器语音键，松手说话，再按一下结束出字；也能按住说话、松开结束。电脑原有 Typeless 快捷键可以继续使用。

## 1. 准备什么

- 一台 Apple 芯片 Mac（M 系列），拥有管理员验证权限。
- Chromecast Voice Remote，装好电池。已实测型号为 `18D1:9450`、固件 `26.5`；不需要把 Chromecast 投屏器接到电脑。
- Typeless 账号和网络连接。
- 本 fork 的独立安装包：**`vRemoter-1.2.3-typeless.7-AppleSilicon.pkg`**。

**只安装这个定制 PKG 即可，它同时安装 App 和虚拟麦克风驱动。不需要原版 vRemoter，不需要单独安装 BlackHole，也不需要 Xcode。** Typeless 需要另外从官网下载。

该 PKG 限制 Apple 芯片和 macOS 12+。完整语音链路此前在 M4 Pro、macOS 15.7.1、Typeless 2.11.0 上实测；其他系统仍需满足所安装 Typeless 版本的要求。Intel Mac 不在本安装包的支持范围内。

### 下载

- [定制版 Release](https://github.com/nettee/vRemoter/releases/tag/v1.2.3-typeless.7)：下载 `.pkg` 和 `SHA256SUMS.txt`。
- [Typeless 官方下载](https://www.typeless.com/downloads)：下载 macOS 版。

GitHub 的“Download ZIP”是源码，不是安装包。Release 中的 `vRemoteDriver-source-…tar.gz` 是驱动源码，只用于审阅和自行构建，普通安装不需要解压它。

可在终端输入 `shasum -a 256 `，拖入 PKG 后回车，将输出与该 Release 的 `SHA256SUMS.txt` 核对。

## 2. 安装 Typeless，先确认电脑本身能出字

1. 打开 Typeless DMG，将 App 拖到“应用程序”，从那里启动并登录。
2. 按提示授权 Typeless 的“麦克风”和“辅助功能”，可在“系统设置 → 隐私与安全性”核对。
3. 暂时使用自动检测／电脑麦克风，在备忘录或文本编辑器里用 Typeless 键盘快捷键说一句话。
4. 确认电脑本身可以出字，再继续接入遥控器。

[Typeless 官方安装说明](https://www.typeless.com/help/installation-and-setup)

## 3. 直接安装定制版 PKG

1. 结束当前通话、录音等工作，安装会短暂重启系统音频服务。
2. 双击 **`vRemoter-1.2.3-typeless.7-AppleSilicon.pkg`**。
3. 在安装器中继续，选择安装到这台电脑，为所有用户安装。
4. 完成 macOS 的管理员／触控 ID 验证，等待安装器显示安装成功。
5. 安装器会尝试启动 App；如未自动打开，从“应用程序”中启动 **vRemote**。

安装位置：

```text
/Applications/vRemote.app
/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver
```

当前 App 和驱动使用本地 ad-hoc 签名，PKG 未进行 Developer ID 签名及公证。macOS 如阻止打开，核对来源和校验值后，由你在“系统设置 → 隐私与安全性”中按提示允许该文件打开。不要关闭系统安全检查；如果系统报告文件损坏或恶意内容，先停止并核对文件。

新 Mac 不需要先装任何旧版。已有用户也可运行同一个 PKG 升级；安装会替换上述固定路径的 App 与驱动，保留偏好设置。如果以前另存过 `vRemote-Typeless.app`，升级后只运行新安装的 `vRemote.app`，并检查登录自启指向的副本，避免启动旧版。

## 4. 确认 App 和驱动都就绪

1. 打开 vRemoter 控制台，版本号应显示 **`1.2.3-typeless.7`**。
2. 在控制台检查驱动状态：应显示 **vRemoteDr 2ch 可用**。
3. 在“系统设置 → 声音 → 输入”确认存在 **`vRemoteDr 2ch`**。只需确认存在，不必改变系统默认麦克风。
4. 如果 Typeless 安装前就已打开，重新打开它，再选择新出现的虚拟麦克风。

如没有设备，先重启 Mac 再检查。仍未出现时，重新运行本 fork 的独立 PKG 修复安装；不要改装原版。App 单独复制、源码 ZIP 或普通 BlackHole 不能替代这个安装包中的专用驱动。

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

在“音频”页让 **MacBook 麦克风**和**遥控器麦克风**两个开关都打开。`.7` 的两个开关表示允许使用各自音源，不会同时混音：遥控器语音键只输出遥控器；物理右 Command / Fn 只输出电脑，并关闭残留遥控器音频。控制台显示当前独占音源。所选音源关闭或断流时不会改用另一音源。新安装 `.7` 默认使用上述工具、模式和触发键，但仍建议核对。

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

之前的双音源版本在 M4 Pro Mac 上通过了这些测试，点按最长约 37 秒。独占收音实现的本机预发布版又在 macOS 26.5.1 / Typeless 2.12.0 上完成 3 轮遥控器／右 Command 交替口述，共 6 段正常。新 Mac 仍需重新验收；这些有限结果不能替代新机器测试。

### D. 遥控器与电脑交替使用

恢复两个音源开关后，连续做 3 轮：用遥控器语音键开始／结束一句话，等出字后把遥控器放远，用电脑右 Command 开始／结束另一句话。确认每段文字正常、控制台音源切换正确。先结束当前录音再开始下一段；电脑键盘接管不会自动结束旧录音后另起一段。

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
| 没有 `vRemoteDr 2ch` | 是否安装了本 fork 的独立 PKG；检查驱动目录；重启 Mac 后重新打开 Typeless |
| 语音键一两秒就停、没有出字 | 先核对定制版版本号、语音工具是否为 Typeless；不要误运行原版或旧版本 |
| Typeless 不启动，或只开出系统菜单 | 两边触发键是否均为 Fn；Typeless 是否添加在 Dictate；辅助功能与输入监控是否授权；检查系统 Fn 功能或其他快捷键软件是否冲突 |
| Typeless 启动，但录不到声音 | Typeless 是否选了虚拟麦克风；vRemoter 是否运行；遥控器音源开关是否打开；BLE 是否就绪 |
| 离电脑远一点就不出字 | 暂时关闭 Mac 音源做独立收音测试，确认不是一直在录电脑麦克风 |
| 遥控器按键正常，但语音不行 | 普通 HID 和 BLE 音频是两条链路；检查 BLE 状态、蓝牙权限，重开 vRemoter 后再试 |
| 电脑原来的语音快捷键没声音 | 打开 MacBook 麦克风音源；如果 vRemoter 已退出，把 Typeless 麦克风改回自动检测／电脑麦克风 |
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

后续升级优先使用本 fork 新版独立 PKG，它会更新 App 和驱动。不要重新安装原版来覆盖定制 App。更新源指向本 fork 的 GitHub Releases。

## 附录：自行从源码构建独立安装包

普通用户下载 Release PKG 即可。下面仅供需要构建的人使用：构建机安装 Apple 开发工具，App 的 SwiftPM 依赖首次需要联网；驱动源码已随仓库提供，不读取本机已安装的 BlackHole 或旧版驱动。

```sh
xcode-select --install
```

等待工具安装完成，再逐条运行（失败即停止，不安装不完整产物）：

```sh
git clone https://github.com/nettee/vRemoter.git
cd vRemoter
git checkout v1.2.3-typeless.7
swift run --disable-sandbox vRemote --audio-routing-self-test
swift run --disable-sandbox vRemote --voice-session-self-test
zsh Scripts/run-self-tests.sh
zsh Scripts/build-pkg.sh
zsh Scripts/test-package.sh
```

产物为 `dist/vRemoter-1.2.3-typeless.7-AppleSilicon.pkg`。`build-pkg.sh` 会同时构建 App、源码驱动，检查驱动音频环回，然后封装为一个安装包。安装这个产物即可，无需另装旧版。

驱动 GPL 源码、修改说明和构建方法见 [Driver/README.md](../../Driver/README.md)。
