# Android 构建兼容性修复方案

## 问题分析

```
A problem occurred configuring project ':device_apps'.
> Namespace not specified. Specify a namespace in the module's build file.
```

**根本原因**: 更新到 Android Gradle Plugin 8.1.0 后，`device_apps` 插件不兼容新版本要求。

## 解决方案选择

### 方案 1：降级 AGP 版本（推荐）
保持功能完整性，降级到兼容版本。

### 方案 2：临时移除 device_apps 
暂时禁用 APK 选择功能，保持构建通过。

### 方案 3：手动修复插件
为 device_apps 添加 namespace 支持。

## 方案 1：降级 AGP 版本（推荐实施）

### 步骤 1：调整版本配置

修改 `app/android/settings.gradle`：

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "7.4.2" apply false
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}
```

### 步骤 2：相应调整 Gradle Wrapper

修改 `app/android/gradle/wrapper/gradle-wrapper.properties`：

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-all.zip
```

### 版本兼容性矩阵

| AGP 版本 | Gradle 版本 | Kotlin 版本 | 兼容性 |
|----------|-------------|-------------|---------|
| 7.4.2    | 7.6         | 1.8.22      | ✅ 推荐 |
| 8.0.0    | 8.0         | 1.8.22      | ⚠️ 部分兼容 |
| 8.1.0    | 8.0         | 1.9.0       | ❌ device_apps 不兼容 |

## 方案 2：临时移除 device_apps

### 步骤 1：注释依赖

在 `app/pubspec.yaml` 中：

```yaml
dependencies:
  # device_apps: 2.2.0  # 临时禁用
```

### 步骤 2：条件编译代码

创建兼容性包装器：

```dart
// lib/util/device_apps_helper.dart
class DeviceAppsHelper {
  static bool get isAvailable => false; // 临时禁用
  
  static Future<List<Application>> getInstalledApplications() async {
    throw UnsupportedError('device_apps 功能暂时不可用');
  }
}
```

## 方案 3：手动修复插件

### 为 device_apps 添加 namespace

在 `~/.pub-cache/hosted/pub.dev/device_apps-2.2.0/android/build.gradle` 中添加：

```gradle
android {
    namespace "fr.g123k.deviceapps"
    // ... 其他配置
}
```

**注意**: 这种方法在 `flutter clean` 后会失效。

## 推荐实施方案

由于保持功能完整性很重要，建议采用 **方案 1：降级 AGP 版本**。

### 具体操作步骤

1. **恢复兼容的版本配置**
2. **测试构建流程**
3. **确认功能正常**
4. **后续跟进插件更新**

### 长期解决方案

1. **关注 device_apps 插件更新**
2. **考虑替代插件**
3. **或贡献修复到开源项目**

## 验证步骤

修改后验证：

```bash
cd app
flutter clean
flutter pub get
flutter build apk --debug
```

## 注意事项

1. **功能影响**: device_apps 用于 APK 选择功能
2. **构建优先级**: 保证构建通过是第一优先级
3. **版本追踪**: 定期检查插件更新
4. **备选方案**: 准备功能降级策略 