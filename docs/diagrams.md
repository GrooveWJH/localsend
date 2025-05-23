# LocalSend 架构与流程图表

本文档使用 Mermaid 图表来可视化展示 LocalSend 的架构、组件关系和工作流程。所有图表均遵循 mermaid.live 标准。

## 目录

- [整体架构](#整体架构)
- [设备发现流程](#设备发现流程)
- [文件传输流程](#文件传输流程)
- [组件关系](#组件关系)
- [应用状态转换](#应用状态转换)
- [开发流程](#开发流程)
- [项目结构](#项目结构)

## 整体架构

下图展示了 LocalSend 的整体架构，包括主要组件和它们之间的关系：

```mermaid
flowchart TD
    subgraph UI层
        ReceiveTab["接收标签页"]
        SendTab["发送标签页"]
        SettingsTab["设置标签页"]
        HomePage["主页面"]
      
        HomePage --> ReceiveTab
        HomePage --> SendTab
        HomePage --> SettingsTab
    end
  
    subgraph 业务逻辑层
        DiscoveryService["设备发现服务"]
        TransferService["文件传输服务"]
        SettingsService["设置服务"]
      
        SendTab --> TransferService
        ReceiveTab --> DiscoveryService
        SettingsTab --> SettingsService
    end
  
    subgraph 网络层
        UDPMulticast["UDP多播"]
        HTTPSServer["HTTPS服务器"]
        HTTPClient["HTTP客户端"]
      
        DiscoveryService --> UDPMulticast
        TransferService --> HTTPSServer
        TransferService --> HTTPClient
    end
  
    subgraph 数据层
        DeviceModel["设备模型"]
        FileModel["文件模型"]
        SettingsModel["设置模型"]
      
        DiscoveryService --> DeviceModel
        TransferService --> FileModel
        SettingsService --> SettingsModel
    end
  
    subgraph 平台特定层
        iOSPlatform["iOS实现"]
        AndroidPlatform["Android实现"]
        WindowsPlatform["Windows实现"]
        MacOSPlatform["macOS实现"]
        LinuxPlatform["Linux实现"]
      
        DiscoveryService -.-> iOSPlatform & AndroidPlatform & WindowsPlatform & MacOSPlatform & LinuxPlatform
        TransferService -.-> iOSPlatform & AndroidPlatform & WindowsPlatform & MacOSPlatform & LinuxPlatform
    end
  
    style UI层 fill:#d1ecf1,stroke:#156070
    style 业务逻辑层 fill:#d4edda,stroke:#155724
    style 网络层 fill:#fff3cd,stroke:#856404
    style 数据层 fill:#f8d7da,stroke:#721c24
    style 平台特定层 fill:#e2e3e5,stroke:#383d41
```

## 设备发现流程

下面的序列图描述了设备发现的完整流程：

```mermaid
sequenceDiagram
    participant 设备A as 设备A
    participant 多播网络 as 局域网 (多播)
    participant 设备B as 设备B
  
    Note over 设备A,设备B: 设备发现阶段
  
    设备A->>多播网络: 发送多播消息 (announce=true)
    多播网络->>设备B: 接收多播消息
    设备B->>多播网络: 发送响应消息 (announce=false)
    多播网络->>设备A: 接收响应消息
  
    Note over 设备A: 更新可用设备列表
  
    设备A->>设备A: 在UI中显示设备B
  
    Note over 设备A,设备B: 重复过程以保持发现状态最新
  
    loop 每30秒
        设备A->>多播网络: 发送多播消息
        多播网络->>设备B: 接收多播消息
        设备B->>多播网络: 发送响应消息
        多播网络->>设备A: 接收响应消息
    end
```

## 文件传输流程

以下图表展示了完整的文件传输流程：

```mermaid
sequenceDiagram
    participant 发送方
    participant 接收方
  
    Note over 发送方,接收方: 1. 初始化传输会话
  
    发送方->>接收方: POST /api/send (文件元数据)
    接收方-->>接收方: 显示接收请求通知
  
    alt 用户接受
        接收方->>接收方: 用户点击"接受"
        接收方-->>发送方: 返回 {status: "接受", sessionId: "xxx"}
    else 用户拒绝
        接收方->>接收方: 用户点击"拒绝"
        接收方-->>发送方: 返回 {status: "拒绝"}
        Note over 发送方,接收方: 传输结束
    end
  
    Note over 发送方,接收方: 2. 等待确认接收
  
    loop 直到状态为"接受"
        发送方->>接收方: GET /api/send/{sessionId}
        接收方-->>发送方: 返回 {status: "等待|接受|拒绝"}
        alt 状态为"拒绝"
            Note over 发送方: 显示传输被拒绝
            Note over 发送方,接收方: 传输结束
        end
    end
  
    Note over 发送方,接收方: 3. 传输文件内容
  
    loop 每个文件
        发送方->>接收方: POST /api/send/{sessionId}/{fileId} (文件二进制数据)
        接收方-->>接收方: 保存文件数据
        接收方-->>发送方: 返回 {status: "成功"}
    end
  
    Note over 发送方,接收方: 4. 完成传输
  
    发送方->>接收方: POST /api/send/{sessionId}/complete
    接收方-->>接收方: 传输完成处理
    接收方-->>发送方: 返回 {status: "成功"}
  
    Note over 发送方: 显示传输完成
    Note over 接收方: 显示接收完成
```

## 组件关系

下面的类图展示了 LocalSend 主要组件之间的关系：

```mermaid
classDiagram
    class App {
        +主界面 HomePage
        +初始化应用()
    }
  
    class HomePage {
        +当前标签页 currentTab
        +切换标签()
    }
  
    class ReceiveTab {
        +设备列表 deviceList
        +刷新设备列表()
        +显示接收请求()
    }
  
    class SendTab {
        +选中文件 selectedFiles
        +选择文件()
        +发送文件()
    }
  
    class SettingsTab {
        +应用设置 settings
        +修改设置()
    }
  
    class DeviceDiscoveryService {
        +发现设备()
        +监听设备广播()
        +发送广播消息()
    }
  
    class FileTransferService {
        +发送文件(目标, 文件列表)
        +接收文件(会话ID)
        +处理传输错误()
    }
  
    class SettingsService {
        +保存设置()
        +加载设置()
    }
  
    class DeviceModel {
        +设备名称 name
        +设备IP ip
        +设备类型 deviceType
        +协议版本 version
    }
  
    class FileModel {
        +文件ID id
        +文件名 fileName
        +文件大小 size
        +文件类型 fileType
        +文件路径 path
    }
  
    class SettingsModel {
        +设备名称 deviceName
        +下载目录 downloadDirectory
        +主题模式 themeMode
        +自动接收 autoAccept
    }
  
    App *-- HomePage
    HomePage *-- ReceiveTab
    HomePage *-- SendTab
    HomePage *-- SettingsTab
  
    ReceiveTab --> DeviceDiscoveryService
    ReceiveTab --> FileTransferService
  
    SendTab --> FileTransferService
    SendTab --> DeviceDiscoveryService
  
    SettingsTab --> SettingsService
  
    DeviceDiscoveryService --> DeviceModel
    FileTransferService --> FileModel
    SettingsService --> SettingsModel
```

## 应用状态转换

下面的状态图展示了 LocalSend 应用在文件传输过程中的状态转换：

```mermaid
stateDiagram-v2
    [*] --> 空闲
  
    state 空闲 {
        [*] --> 可发现
        可发现 --> 设备隐藏: 关闭可发现性
        设备隐藏 --> 可发现: 开启可发现性
    }
  
    空闲 --> 发送中: 用户选择文件并发送
    空闲 --> 接收请求: 收到传输请求
  
    state 发送中 {
        [*] --> 等待接收方确认
        等待接收方确认 --> 传输文件: 接收方接受
        等待接收方确认 --> 传输被拒绝: 接收方拒绝
        传输文件 --> 传输完成: 所有文件传输完成
        传输文件 --> 传输错误: 网络错误
    }
  
    state 接收请求 {
        [*] --> 显示接收对话框
        显示接收对话框 --> 接收中: 用户接受
        显示接收对话框 --> 拒绝传输: 用户拒绝
    }
  
    state 接收中 {
        [*] --> 保存文件
        保存文件 --> 接收完成: 所有文件接收完成
        保存文件 --> 接收错误: 存储错误
    }
  
    传输被拒绝 --> 空闲
    传输完成 --> 空闲
    传输错误 --> 空闲: 用户确认
  
    拒绝传输 --> 空闲
    接收完成 --> 空闲
    接收错误 --> 空闲: 用户确认
```

## 开发流程

下面的甘特图展示了 LocalSend 的典型开发流程：

```mermaid
gantt
    title LocalSend 开发流程
    dateFormat  YYYY-MM-DD
  
    section 规划阶段
    需求分析           :a1, 2023-01-01, 7d
    架构设计           :a2, after a1, 10d
    UI/UX设计         :a3, after a2, 14d
  
    section 实现阶段
    核心协议实现       :b1, after a3, 21d
    UI组件开发         :b2, after a3, 28d
    设备发现实现       :b3, after b1, 14d
    文件传输实现       :b4, after b3, 21d
    设置功能实现       :b5, after b2, 14d
  
    section 测试阶段
    单元测试           :c1, after b4, 14d
    集成测试           :c2, after c1, 14d
    跨平台兼容性测试   :c3, after c2, 21d
    用户测试           :c4, after c3, 14d
  
    section 发布阶段
    文档编写           :d1, after c4, 14d
    版本打包           :d2, after d1, 7d
    发布上线           :d3, after d2, 3d
    维护和支持         :d4, after d3, 60d
```

## 项目结构

下面的树图展示了 LocalSend 项目的目录结构：

```mermaid
graph TD
    A[localsend] --> B[app]
    A --> C[common]
    A --> D[cli]
    A --> E[docs]
    A --> F[scripts]
  
    B --> B1[lib]
    B --> B2[android]
    B --> B3[ios]
    B --> B4[macos]
    B --> B5[windows]
    B --> B6[linux]
    B --> B7[assets]
  
    B1 --> B1a[config]
    B1 --> B1b[gen]
    B1 --> B1c[l10n]
    B1 --> B1d[model]
    B1 --> B1e[pages]
    B1 --> B1f[provider]
    B1 --> B1g[util]
    B1 --> B1h[widget]
    B1 --> B1i["main.dart"]
  
    C --> C1[lib]
    C1 --> C1a[model]
    C1 --> C1b[src]
    C1 --> C1c[util]
  
    C1b --> C1b1[protocol]
    C1b --> C1b2[discovery]
  
    E --> E1[user-guide]
    E --> E2[developer]
    E --> E3[technical]
    E --> E4[platforms]
    E --> E5[customization]
    E --> E6[diagrams.md]
  
    click B href "#" "app目录"
    click C href "#" "common目录"
    click D href "#" "cli目录"
    click E href "#" "docs目录"
    click F href "#" "scripts目录"
  
    style A fill:#f9f9f9,stroke:#333,stroke-width:2px
    style B fill:#d1ecf1,stroke:#156070
    style C fill:#d4edda,stroke:#155724
    style D fill:#fff3cd,stroke:#856404
    style E fill:#f8d7da,stroke:#721c24
    style F fill:#e2e3e5,stroke:#383d41
    style E6 fill:#ffeeba,stroke:#533f03,stroke-width:2px,stroke-dasharray:5 5
```

## 饼图：协议使用统计

以下饼图展示了 LocalSend 协议版本的使用分布：

```mermaid
pie title LocalSend 协议版本使用分布
    "协议 V2.1" : 68.2
    "协议 V2.0" : 19.5
    "协议 V1.0" : 12.3
```

## 象限图：功能优先级

```mermaid
quadrantChart
    title "功能优先级矩阵"
    x-axis "实现难度" "低" --> "高"
    y-axis "用户价值" "低" --> "高"
    quadrant-1 "优先实现"
    quadrant-2 "计划实现"
    quadrant-3 "可选实现"
    quadrant-4 "谨慎评估"
    "文件传输": [0.2, 0.9]
    "设备发现": [0.3, 0.8]
    "文件夹传输": [0.5, 0.7]
    "加密传输": [0.6, 0.8]
    "断点续传": [0.7, 0.6]
    "远程传输": [0.9, 0.5]
    "历史记录": [0.4, 0.4]
    "传输压缩": [0.7, 0.4]
    "自动接收": [0.3, 0.3]
    "主题定制": [0.2, 0.3]
    "断点续传": [0.7, 0.6]
    "远程传输": [0.9, 0.5]
    "历史记录": [0.4, 0.4]
    "传输压缩": [0.7, 0.4]
    "自动接收": [0.3, 0.3]
    "主题定制": [0.2, 0.3]
```
