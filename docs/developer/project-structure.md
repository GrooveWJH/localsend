# LocalSend 项目结构

本文档详细描述了 LocalSend 项目的目录结构、代码组织和关键组件，帮助开发者快速了解项目架构。

## 目录

- [顶层目录结构](#顶层目录结构)
- [App 目录结构](#app-目录结构)
- [Common 库](#common-库)
- [CLI 工具](#cli-工具)
- [配置文件](#配置文件)
- [平台特定目录](#平台特定目录)
- [资源管理](#资源管理)
- [国际化](#国际化)

## 顶层目录结构

LocalSend 项目的顶层目录结构如下：

```
localsend/
├── app/                    # 主应用程序目录 (Flutter)
├── common/                 # 共享代码库
├── cli/                    # 命令行工具
├── scripts/                # 构建和发布脚本
├── .fvm/                   # Flutter 版本管理
├── .github/                # GitHub 工作流和配置
├── docs/                   # 文档目录
├── README.md               # 项目主要说明
├── CONTRIBUTING.md         # 贡献指南
├── CHANGELOG.md            # 版本变更日志
└── LICENSE                 # 许可证文件
```

### 主要组件职责

- **app/**: Flutter 应用程序的主目录，包含应用逻辑、UI、资源等
- **common/**: 跨平台共享的代码库，包含核心数据模型和通用工具类
- **cli/**: 命令行工具，提供脚本集成能力
- **scripts/**: 自动化脚本，用于构建、测试和发布流程
- **docs/**: 项目文档

## App 目录结构

Flutter 应用程序的结构如下：

```
app/
├── android/                # Android 平台特定代码
├── ios/                    # iOS 平台特定代码
├── linux/                  # Linux 平台特定代码
├── macos/                  # macOS 平台特定代码
├── windows/                # Windows 平台特定代码
├── web/                    # Web 平台支持
├── lib/                    # Dart 代码目录
│   ├── config/             # 配置文件
│   ├── gen/                # 生成的代码（不要手动修改）
│   ├── l10n/               # 国际化资源
│   ├── model/              # 数据模型
│   ├── pages/              # 应用页面
│   │   ├── home_page.dart  # 主页
│   │   ├── tabs/           # 主页中的标签页
│   │   └── ...             # 其他页面
│   ├── provider/           # 状态管理提供者
│   ├── util/               # 工具类
│   ├── widget/             # 可重用组件
│   └── main.dart           # 应用入口点
├── assets/                 # 静态资源
│   ├── img/                # 图像资源
│   └── fonts/              # 字体资源（如果有）
├── test/                   # 测试文件
└── pubspec.yaml            # Flutter 依赖和配置
```

### 关键目录详解

#### `lib/config/`

配置目录包含应用程序的配置设置，例如：

- **theme.dart**: 主题配置，包括颜色方案和组件样式
- **init.dart**: 应用程序初始化逻辑
- **app_constants.dart**: 应用常量（如默认端口、超时设置等）

#### `lib/model/`

存放应用程序的数据模型，包括：

- **dto/**: 数据传输对象，用于 API 通信
- **persistence/**: 持久化数据模型，用于本地存储
- **state/**: 应用状态相关模型

#### `lib/pages/`

包含应用程序的所有页面和视图：

- **home_page.dart**: 主页面，包含主要导航和标签
- **tabs/**: 主页中各标签页的实现
  - **receive_tab.dart**: 接收文件标签
  - **send_tab.dart**: 发送文件标签
  - **settings_tab.dart**: 设置标签
- **about/**: 关于页面相关内容
- **progress/**: 传输进度相关页面
- **troubleshoot/**: 故障排除页面

#### `lib/provider/`

使用 Refena 状态管理框架的提供者：

- **persistence_provider.dart**: 持久化数据管理
- **network_provider.dart**: 网络状态管理
- **selection/**: 文件选择相关状态

#### `lib/util/`

工具类和辅助函数：

- **native/**: 与平台原生功能交互的工具
- **ui/**: UI 相关工具（如动态颜色、平台检查）
- **file_converter.dart**: 文件处理工具
- **platform_strings.dart**: 平台相关的字符串工具

#### `lib/widget/`

可重用的 UI 组件：

- **local_send_logo.dart**: 应用程序 Logo 组件
- **custom_dropdown_button.dart**: 自定义下拉按钮
- **responsive_builder.dart**: 响应式布局构建器
- 其他通用 UI 组件

## Common 库

`common/` 目录包含跨组件共享的代码：

```
common/
├── lib/
│   ├── model/              # 共享数据模型
│   │   ├── device.dart     # 设备模型
│   │   ├── transfer.dart   # 传输相关模型
│   │   └── ...
│   ├── src/                # 核心实现
│   │   ├── protocol/       # 通信协议
│   │   ├── discovery/      # 设备发现
│   │   └── ...
│   └── util/               # 共享工具类
└── pubspec.yaml            # Common 库依赖和配置
```

这个库实现了 LocalSend 的核心功能，包括设备发现、通信协议和数据传输逻辑。

## CLI 工具

`cli/` 目录包含命令行工具的实现：

```
cli/
├── lib/                    # CLI 代码
│   ├── src/
│   │   ├── commands/       # CLI 命令实现
│   │   └── ...
│   └── main.dart           # CLI 入口点
└── pubspec.yaml            # CLI 依赖和配置
```

CLI 工具允许从命令行或脚本使用 LocalSend 的核心功能。

## 配置文件

项目根目录中的配置文件：

- **.fvmrc**: 指定 Flutter 版本（使用 Flutter 版本管理工具）
- **.gitignore**: Git 忽略规则
- **.gitmodules**: Git 子模块配置（如果有）

## 平台特定目录

每个平台目录（如 `app/android/`, `app/ios/` 等）包含特定平台的配置和代码：

### Android (`app/android/`)

关键文件包括：

- **app/src/main/AndroidManifest.xml**: 应用程序清单
- **app/src/main/kotlin/...**: Kotlin 源代码
- **app/src/main/res/**: 资源文件（图标、启动画面等）

### iOS (`app/ios/`)

关键文件包括：

- **Runner/Info.plist**: 应用程序配置
- **Runner/Assets.xcassets/**: 图像资源

### macOS (`app/macos/`)

关键文件包括：

- **Runner/Info.plist**: 应用程序配置
- **Runner/Assets.xcassets/**: 图像资源
- **Runner/Configs/AppInfo.xcconfig**: 应用程序元数据
- **Runner/Base.lproj/MainMenu.xib**: 主菜单配置

### Windows (`app/windows/`)

关键文件包括：

- **runner/resources/**: 资源文件
- **runner/Runner.rc**: 资源配置

### Linux (`app/linux/`)

关键文件包括：

- **my_application.cc**: 应用程序实现
- **CMakeLists.txt**: 构建配置

## 资源管理

项目资源管理主要通过以下方式：

1. **Flutter 资源**:
   - 在 `app/assets/` 目录中存储
   - 在 `app/pubspec.yaml` 中声明
   - 通过生成的 `app/lib/gen/assets.gen.dart` 在代码中引用

2. **平台特定资源**:
   - 存储在各平台目录下的特定位置
   - 例如 Android 的 `app/android/app/src/main/res/`
   - 例如 iOS/macOS 的 `app/*/Runner/Assets.xcassets/`

## 国际化

LocalSend 使用 Flutter 的国际化系统：

1. **源文件**:
   - 位于 `app/lib/l10n/` 目录
   - 使用 `.arb` (Application Resource Bundle) 格式
   - 每种语言一个文件（如 `app_en.arb`、`app_zh.arb` 等）

2. **生成的代码**:
   - 使用 `flutter gen-l10n` 命令生成
   - 生成的代码位于 `app/lib/gen/` 目录
   - 在代码中通过 `t.keyName` 访问本地化字符串

## 开发工具与构建系统

LocalSend 项目使用以下工具和系统：

1. **FVM (Flutter Version Management)**:
   - 确保使用一致的 Flutter 版本
   - 通过 `.fvmrc` 配置

2. **Build Runner**:
   - 用于代码生成
   - 运行 `flutter pub run build_runner build` 更新生成的代码

3. **CI/CD**:
   - GitHub Actions 用于自动化测试和构建
   - 脚本位于 `.github/workflows/` 目录

如需更详细了解特定组件的实现，请参考源代码和相关注释。要了解构建和发布流程，请查看 [构建指南](build.md)。 