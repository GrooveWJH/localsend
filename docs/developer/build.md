# 在 macOS 上编译 Android APK 与 Windows 可执行文件指南

本指南针对 **macOS** 开发者，说明如何在本地或使用 CI/CD 工具为 LocalSend 编译：

1. **Android** 平台的 `APK` / `AAB` 安装包。
2. **Windows** 平台的 `EXE / MSIX` 可执行文件（需借助 CI 或 Windows 虚拟机）。

> 说明：Flutter **目前不支持** 在非 Windows 主机直接生成 Windows 桌面应用，因此在 macOS 上构建 Windows 版本需要使用 GitHub Actions、远程 Windows 机器或虚拟机。

---

## 一、环境准备

| 工具 | 版本 / 说明 | 用途 |
|------|-------------|------|
| Flutter | 建议使用 `.fvmrc` 指定的版本（`fvm install`） | 跨平台开发框架 |
| FVM | `brew install fvm` or `dart pub global activate fvm` | Flutter 版本管理 |
| Xcode | 最新稳定版 | iOS/macOS 构建（可选） |
| Android Studio + SDK | `Android SDK 34` 及以上，需 **Command-line Tools** | 构建 Android APK/AAB |
| Java 17 SDK | 可通过 `brew install openjdk@17` | Android Gradle 构建环境 |
| GitHub Actions | 使用 `windows-latest` 运行器 | 远程构建 Windows EXE |
| (可选) Windows 10/11 虚拟机 | Parallels / VMware / UTM | 本地测试 Windows 版本 |

### 1. 安装 Flutter (FVM)

```bash
# 安装 fvm（首次）
brew install fvm # 或使用 dart pub global activate fvm

# 项目根目录
cd localsend

# 安装 .fvmrc 指定版本
fvm install

# 使用该版本 Flutter
fvm flutter doctor
```

### 2. 配置 Android SDK

1. 安装 **Android Studio**，在首选项中安装 `Android SDK`、`SDK Platform 34` 和 **Command-line Tools**。
2. 在 `~/.zprofile` 或 `~/.bash_profile` 中设置环境变量：

```bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
```

3. 接受许可：

```bash
sdkmanager --licenses
```

4. 再次运行 `fvm flutter doctor --android-licenses` 解决剩余许可。

### 3. 生成签名 (Release)

如需发布到 Google Play，需要为 APK/AAB 签名：

1. 在 `app/android/` 目录执行：

```bash
keytool -genkeypair -v -keystore keystore.jks -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. 在 `app/android/key.properties` 中写入：

```properties
storePassword=********
keyPassword=********
keyAlias=release
storeFile=keystore.jks
```

3. `app/android/app/build.gradle` 已包含读取 `key.properties` 的逻辑，无需额外修改。

---

## 二、编译 Android APK / AAB

在项目 `app/` 目录下执行：

```bash
# Debug 版（本地调试，无签名）
fvm flutter run -d android

# Release APK（.apk）
fvm flutter build apk --release

# Google Play 推荐的 App Bundle（.aab）
fvm flutter build appbundle --release
```

生成的文件路径：

* APK: `app/build/outputs/flutter-apk/app-release.apk`
* AAB: `app/build/outputs/bundle/release/app-release.aab`

---

## 三、在 macOS 上生成 Windows 版本

### 方案一：GitHub Actions 自动构建（推荐）

项目已包含工作流 `.github/workflows/windows_build.yml`，会在 `push tag` 或手动触发时：

1. 使用 `windows-latest` 运行器安装 Flutter。
2. 执行 `flutter build windows --release`。
3. 产物位于 `build/windows/runner/Release`，并通过 `actions/upload-artifact` 上传。

**步骤：**

```bash
# 推送 Tag 触发
git tag v1.0.0
git push origin v1.0.0

# 或在 GitHub Actions 页面手动 Dispatch windows_build.yml
```

构建完成后，在 **Actions → latest run → Artifacts** 下载 `localsend_windows.zip`。

### 方案二：使用 Windows 虚拟机 / 物理机

1. 在 Windows 中安装以下工具：
   - Flutter (same version)
   - Visual Studio 2022 Desktop C++ 工具集
2. 克隆仓库并运行：

```powershell
fvm flutter pub get
fvm flutter build windows --release
```

3. 可使用 [msix](https://pub.dev/packages/msix) 打包：

```powershell
fvm flutter pub run msix:create
```

生成文件位置：

* EXE: `build/windows/runner/Release/localsend_app.exe`
* MSIX: `build/windows/x64/release/msix/` 目录

---

## 四、常见问题

| 问题 | 解决方案 |
|------|----------|
| `Could not determine java version` | 确认使用 Java 17 (JDK) 并在 `PATH` 中优先 |
| `SDK location not found` | 配置 `ANDROID_SDK_ROOT` 并重启终端 |
| Android 构建卡在 `:app:lintVitalRelease` | 在 `gradle.properties` 增加 `android.disableAutomaticComponentCreation=true` |
| `toolchain not found` (Windows) | 安装 Visual Studio Desktop C++ 工作负载，并重启 PowerShell |

---

## 五、后续步骤

1. 了解 [主题定制](../customization/themes.md) 如何换肤
2. 阅读 [协议规范](../technical/protocol.md) 深入理解通信机制
3. 提交 PR 前请查看 [贡献指南](contributing.md)

祝你编译顺利 🚀 