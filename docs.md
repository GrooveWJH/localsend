# LocalSend 技术文档

## 1. 总体架构概述

### 1.1 项目简介

LocalSend 是一个开源的跨平台文件传输应用，专注于在局域网内实现安全、高效的文件和消息传输。项目采用 Flutter 框架开发，支持 Android、iOS、macOS、Windows 和 Linux 等多个平台。

### 1.2 核心设计理念

- **去中心化通信**: 采用点对点（P2P）通信模式，无需中央服务器
- **安全性**: 使用 HTTPS 加密通信，动态生成 TLS/SSL 证书
- **跨平台**: 使用 Flutter 实现统一的用户界面，Rust 实现核心功能
- **高性能**: 支持高速文件传输，针对不同平台优化性能
- **协议版本**: 当前使用 2.1 版本协议，保持向下兼容性

## 2. 文件结构和代码组织

### 2.1 主要目录结构

```
localsend/
├── app/                    # 主应用程序目录
│   ├── lib/               # Flutter 应用代码
│   │   ├── config/       # 应用配置
│   │   ├── model/        # 数据模型
│   │   ├── pages/        # UI 页面
│   │   ├── provider/     # 状态管理
│   │   ├── util/         # 工具类
│   │   └── widget/       # 可重用组件
│   ├── assets/           # 资源文件
│   └── platform/         # 平台特定代码
├── common/                # 共享代码库
│   └── lib/
│       ├── model/        # 共享数据模型
│       ├── src/          # 核心实现
│       └── util/         # 共享工具类
└── cli/                  # 命令行工具
```

### 2.2 技术栈

- **前端框架**: Flutter
- **后端/核心**: Rust
- **状态管理**: Refena
- **路由管理**: Routerino
- **国际化**: Flutter Localizations

## 3. 关键组件及其功能

### 3.1 核心通信模块

- **协议版本**: 支持 1.0、2.0、2.1 版本
- **默认端口**: 53317
- **多播组**: 224.0.0.167
- **发现超时**: 500ms

### 3.2 安全机制

- 动态生成 TLS/SSL 证书
- HTTPS 加密通信
- 本地网络权限管理

### 3.3 平台适配

#### Android
- 最低支持版本: Android 5.0
- SAF (Storage Access Framework) 集成
- 后台服务管理

#### iOS/macOS
- 最低支持版本: iOS 12.0 / macOS 11
- 本地网络权限处理
- 沙盒文件系统适配

#### Windows
- 最低支持版本: Windows 10
- 托盘图标支持
- 便携模式支持

#### Linux
- 多发行版支持
- AppImage 打包
- Snap 包支持

## 4. 开发与构建流程

### 4.1 开发环境设置

1. 安装依赖:
   - Flutter (参考 .fvmrc 版本)
   - Rust
   - 平台特定 SDK

2. 获取代码:
   ```bash
   git clone https://github.com/localsend/localsend.git
   cd app
   flutter pub get
   ```

### 4.2 构建命令

#### Android
```bash
flutter build apk          # 构建 APK
flutter build appbundle    # 构建 App Bundle
```

#### iOS/macOS
```bash
flutter build ipa          # iOS
flutter build macos       # macOS
```

#### Windows
```bash
flutter build windows     # 常规构建
flutter pub run msix:create  # MSIX 包
```

#### Linux
```bash
flutter build linux       # 常规构建
appimage-builder --recipe AppImageBuilder.yml  # AppImage
```

## 5. 安全机制和网络配置

### 5.1 防火墙配置

| 流量类型 | 协议    | 端口   | 动作 |
|---------|---------|--------|------|
| 入站    | TCP,UDP | 53317  | 允许 |
| 出站    | TCP,UDP | 任意   | 允许 |

### 5.2 网络要求

- 禁用 AP 隔离
- 配置为"专用"网络（Windows）
- 启用"本地网络"权限（iOS/macOS）

## 6. 二次开发参考

### 6.1 扩展点

1. 自定义传输协议
2. 新增文件类型支持
3. 用户界面定制
4. 平台特定功能

### 6.2 调试指南

1. 启用调试日志:
   ```dart
   debugPrint('调试信息');
   ```

2. 网络调试:
   - 使用 Wireshark 监控通信
   - 检查 HTTPS 证书生成
   - 验证多播发现

3. 性能分析:
   - Flutter DevTools
   - 平台特定性能工具

### 6.3 常见问题

1. 设备发现问题
   - 检查网络权限
   - 验证防火墙配置
   - 确认多播设置

2. 传输速度优化
   - 使用 5GHz Wi-Fi
   - 禁用加密（可选）
   - 优化缓冲区大小

3. 平台特定问题
   - Android SAF 性能
   - iOS 权限处理
   - Windows 托盘集成 