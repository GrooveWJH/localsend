# LocalSend 架构概述

本文档描述了 LocalSend 的整体技术架构、核心组件和设计理念。

## 目录
- [设计理念](#设计理念)
- [技术栈](#技术栈)
- [系统架构](#系统架构)
- [核心组件](#核心组件)
- [通信流程](#通信流程)
- [安全模型](#安全模型)

## 设计理念

LocalSend 的设计围绕以下核心理念展开：

### 去中心化通信
- 采用点对点（P2P）直接设备间通信
- 无需中央服务器或互联网连接
- 减少潜在的安全风险和单点故障

### 跨平台兼容性
- 使用 Flutter 实现统一的用户界面
- 处理不同平台的文件系统和权限差异
- 提供一致的用户体验

### 安全性优先
- HTTPS 加密所有通信
- 动态生成 TLS/SSL 证书
- 明确的用户确认机制

### 开源透明
- 完全开源的代码库
- 社区驱动的开发模式
- 透明的安全和隐私政策

## 技术栈

LocalSend 基于以下技术构建：

### 前端 / UI
- **框架**: [Flutter](https://flutter.dev/)
- **状态管理**: [Refena](https://github.com/refena/refena)
- **路由管理**: [Routerino](https://github.com/larsb24/routerino)
- **国际化**: [Flutter Localizations](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

### 后端 / 核心
- **服务器**: 内置 HTTP 服务器
- **通信协议**: 自定义 REST API (HTTP/HTTPS)
- **加密**: TLS/SSL

### 平台特定集成
- **Android**: Kotlin 扩展
- **iOS/macOS**: Swift 扩展
- **Windows**: Win32 API 集成
- **Linux**: GTK 集成

## 系统架构

LocalSend 采用了模块化的架构设计，主要分为以下几层：

### UI 层
- **页面 (Pages)**: 应用的各个屏幕/视图
- **小部件 (Widgets)**: 可重用的 UI 组件
- **状态管理 (State)**: 使用 Refena 管理的应用状态

### 业务逻辑层
- **服务 (Services)**: 处理核心业务逻辑
- **提供者 (Providers)**: 提供状态和数据
- **模型 (Models)**: 数据模型和业务实体

### 网络通信层
- **设备发现**: 通过网络发现协议
- **文件传输**: 使用 HTTP/HTTPS 协议
- **连接管理**: 处理连接的建立、维护和关闭

### 数据层
- **持久化存储**: 文件系统和应用设置
- **缓存管理**: 临时文件和传输状态
- **资源管理**: 应用资源和资产

## 核心组件

### 多播发现服务
- 使用 UDP 多播 (224.0.0.167:53317) 发现局域网内的设备
- 处理设备广告和扫描响应
- 维护可发现设备的列表

### HTTP 服务器
- 内置 HTTP/HTTPS 服务器
- 动态生成 TLS 证书
- 处理并发连接和请求

### 文件传输管理器
- 分块传输大文件
- 显示传输进度
- 处理传输错误和恢复

### 平台适配器
- 处理不同平台的文件系统访问
- 管理平台特定的权限
- 提供统一的 API 接口

## 通信流程

LocalSend 的典型通信流程如下：

1. **设备发现阶段**
   - 发送设备广播多播消息
   - 接收设备响应
   - 建立可用设备列表

2. **初始连接阶段**
   - 选择目标设备
   - 建立 HTTPS 连接
   - 交换元数据

3. **文件传输阶段**
   - 发送文件元数据
   - 接收方确认接收
   - 分块传输文件内容
   - 验证传输完整性

4. **完成阶段**
   - 确认所有文件传输完成
   - 关闭连接
   - 更新 UI 状态

## 安全模型

### 加密
- 所有通信使用 HTTPS 加密
- 动态生成的 TLS 证书
- 证书指纹验证

### 权限控制
- 明确的用户确认机制
- 传输请求必须被接收方确认
- 防止未经授权的访问

### 隐私保护
- 仅在局域网内传输数据
- 不收集用户数据
- 无需账户或用户识别信息

### 安全限制
- 默认拒绝自动接收
- 可选的访问控制设置
- 可配置的接收文件夹

## 平台特定考虑

### 移动平台
- 后台服务管理
- 电池优化处理
- 推送通知集成

### 桌面平台
- 系统托盘集成
- 拖放文件支持
- 开机自启动选项

## 性能优化

- 块大小优化
- 并行传输管理
- 内存和磁盘缓存策略

如需更多详细信息，请参阅以下文档：
- [协议规范](protocol.md)
- [API 文档](api.md)
- [安全性设计](security.md) 