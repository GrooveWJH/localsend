# localsend 项目 CI/CD 工作流解读

以下内容概述了 `localsend` 仓库目前全部 GitHub Actions 工作流（CI/CD）的功能、触发条件与产出。

## 工作流总览

| 序号 | YAML 文件 | 工作流名称（`name:`） | 触发方式 | 运行环境 | 核心产物 / 作用 |
| :--: | -------- | --------------------- | -------- | -------- | --------------- |
| 1 | `.github/workflows/release.yml` | Release Draft | 手动 `workflow_dispatch` | 多平台（Ubuntu / Windows / 自托管 ARM64） | 一次性编译全平台产物（APK、tar.gz、deb、AppImage、Windows zip）并创建草稿版本 |
| 2 | `.github/workflows/compile_apk.yml` | Compile APK | 手动 | Ubuntu-22.04 | 仅编译 Android APK（三种 ABI）并输出为 artifact |
| 3 | `.github/workflows/linux_build.yml` | Linux build | 手动 | Ubuntu-22.04 | 先生成代码，再打包 x86_64 AppImage |
| 4 | `.github/workflows/test_rpm.yml` | Build rpm package | 手动 | Fedora 38（容器） | 使用 `flutter_distributor` 打包 `.rpm`（x86_64） |
| 5 | `.github/workflows/test_zip.yml` | Build windows zip | 手动 | Windows-latest | 编译 Windows 版并压缩为 ZIP（含依赖 DLL） |
| 6 | `.github/workflows/ci.yml` | CI | ① `push` 到 main<br>② `pull_request` 指向 main | Ubuntu-latest | 格式检查、静态分析、单元测试，以及 pubspec 与 Inno Setup 版本一致性校验 |
| 7 | `.github/workflows/clear_workflows.yml` | Delete old workflow runs | 手动（可传参控制天数等） | Ubuntu-latest | 调用社区 Action 自动清理旧的工作流运行记录 |
| 8 | `.github/workflows/compile_arm64_appimage.yml` | Build arm64 AppImage | 手动 | 自托管 Linux ARM64 | 编译 ARM64 AppImage（需本地安装 Flutter ARM64 版） |
| 9 | `.github/workflows/test_arm64_deb.yml` | Build arm64 deb | 手动 | 自托管 Linux ARM64 | 打包 ARM64 `.deb`，并手动修正 Architecture 字段 |
| 10 | `.github/workflows/test_arm64_tar.yml` | Build arm64 tar | 手动 | 自托管 Linux ARM64 | 编译 ARM64 Linux 并封装为 `tar.gz` |
| 11 | `.github/workflows/winget.yml` | Publish to WinGet | 当 GitHub Release 发表时 (`release` → `released`) | Ubuntu-latest | 调用第三方 Action 将 Windows 安装包提交至 WinGet |

## 详细解读

1. **Release Draft**  
   此工作流是发布核心。第一步读取 `pubspec.yaml` 获取版本号，然后分别启动多平台子任务：  
   - Android APK（需解密 key.properties & keystore）  
   - Linux x86_64 tar.gz / deb / AppImage  
   - Linux ARM64 tar.gz / deb（自托管）  
   - Windows x86_64 ZIP  
   全部产物上传后，最后一步通过 `release-drafter` 创建「草稿发布」，并把产物作为 Release Asset 附加。

2. **Compile APK**  
   与 Release 里的 APK 部分几乎一致，但只做 Android，适合快速验证签名 & 构建链是否正常。

3. **Linux build**  
   先运行 `build_runner` 生成代码（并上传生成后的 `lib/`），再下游使用这些生成文件打包 x86_64 AppImage；保证产物包含最新生成代码。

4. **Build rpm package**  
   基于 Fedora 容器，用 `flutter_distributor package --platform linux --targets rpm` 生成 `.rpm`；额外做了 PATH / 安全目录调整来配合容器环境。

5. **Build windows zip**  
   Windows-latest 虚拟机中执行 `flutter build windows`，随后复制所需 VC++ 运行时 DLL，再以 PowerShell `Compress-Archive` 打包为 ZIP。

6. **CI**  
   三个 job：  
   - `format`：Dart/Flutter 格式检查（`dart format --set-exit-if-changed`）。  
   - `test`：静态分析 `flutter analyze / dart analyze` + 单元测试。  
   - `packaging`：对比 `pubspec.yaml` 与 Inno Setup 脚本里的版本号，防止版本不一致。

7. **Delete old workflow runs**  
   维护性脚本；通过输入参数控制保留天数、最少保留次数、状态过滤等，避免仓库 Actions 历史占用过多空间。

8. **Build arm64 AppImage / deb / tar**  
   这三个工作流均依赖自托管 ARM64 Runner，因为官方 Flutter 暂无 ARM64 Linux 发行版。流程与 x86_64 类似，只是不走 `flutter-action`（需手动预装）。

9. **Winget**  
   监听正式 Release，一旦发布就用 `vedantmgoyal9/winget-releaser` 自动向 [winget-pkgs](https://github.com/microsoft/winget-pkgs) 提交 PR，让 Windows 用户可通过 `winget install localsend` 安装最新版。

---

借助上述多工作流组合，`localsend` 项目实现了：

* 代码提交 → 自动格式检查、测试（CI）  
* 一键触发 → 生成并签名各平台安装包 / 二进制（CD）  
* 发布 Release → 自动同步到 WinGet  
* 后期维护 → 自动清理旧的工作流运行

整体既覆盖日常开发的静态质量保障，也兼顾跨平台发行、包管理生态（Deb、RPM、WinGet）与仓库运维。 