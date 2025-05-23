# GitHub Actions APK 构建错误修复方案

## 问题分析

根据错误日志，主要有两个问题：

### 1. Kotlin 版本兼容性问题

```
Module was compiled with an incompatible version of Kotlin. 
The binary version of its metadata is 1.8.0, expected version is 1.6.0.
```

### 2. Android 签名配置缺失

```
SigningConfig "release" is missing required property "storeFile".
```

## 解决方案

### 修复方案 1：更新 Kotlin 版本

更新 `app/android/settings.gradle` 文件中的 Kotlin 版本：

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.0" apply false
    id "org.jetbrains.kotlin.android" version "1.9.0" apply false
}
```

**变更说明**：

- Kotlin 版本从 `1.8.21` 升级到 `1.9.0`
- Android Gradle Plugin 从 `7.2.0` 升级到 `8.1.0`

### 修复方案 2：配置 GitHub Secrets

在 GitHub 仓库中配置以下 Secrets：

#### 2.1 生成 Android 签名密钥

如果你还没有签名密钥，先生成一个：

```bash
# 生成密钥库
keytool -genkey -v -keystore android-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias localsend

# 将密钥库文件转换为 base64
base64 -i android-keystore.jks | tr -d '\n' > android-keystore.base64
```

#### 2.2 创建 key.properties 文件

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=localsend
storeFile=../secrets/android-keystore.jks
```

#### 2.3 转换为 base64

```bash
base64 -i key.properties | tr -d '\n' > key.properties.base64
```

#### 2.4 在 GitHub 仓库中添加 Secrets

在 GitHub 仓库 → Settings → Secrets and variables → Actions 中添加：

- `ANDROID_KEY_PROPERTIES`: key.properties.base64 文件的内容
- `ANDROID_KEY_STORE`: android-keystore.base64 文件的内容

### 修复方案 3：修改工作流（可选）

如果你暂时不想配置签名，可以修改工作流生成 debug 版本：

```yaml
- name: Build APK (Debug)
  working-directory: ${{ env.APK_BUILD_DIR }}/app
  run: flutter build apk --debug --split-per-abi
```

### 修复方案 4：添加签名配置检查

在 `app/android/app/build.gradle` 中添加更安全的签名配置：

```gradle
signingConfigs {
    release {
        def keystoreProperties = new Properties()
        def keystorePropertiesFile = rootProject.file('key.properties')
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
          
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        } else {
            // 如果没有签名配置，使用 debug 签名
            keyAlias 'androiddebugkey'
            keyPassword 'android'
            storeFile file('../../../' + System.getProperty('user.home') + '/.android/debug.keystore')
            storePassword 'android'
        }
    }
}
```

## 完整修复步骤

### 步骤 1：更新 Kotlin 配置

修改 `app/android/settings.gradle`：

```gradle
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.0" apply false
    id "org.jetbrains.kotlin.android" version "1.9.0" apply false
}

include ":app"
```

### 步骤 2：更新 Gradle Wrapper（可选）

如果需要，更新 `app/android/gradle/wrapper/gradle-wrapper.properties`：

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

### 步骤 3：配置签名密钥

按照上述方案 2 的步骤配置 GitHub Secrets。

### 步骤 4：验证修复

提交更改并触发 GitHub Action 来验证修复是否成功。

## 临时解决方案

如果你暂时不想配置签名，可以修改工作流构建 debug 版本：

修改 `.github/workflows/compile_apk.yml` 中的构建命令：

```yaml
- name: Build APK (Debug)
  working-directory: ${{ env.APK_BUILD_DIR }}/app
  run: flutter build apk --debug --split-per-abi
```

并更新上传路径：

```yaml
- name: Upload APK
  uses: actions/upload-artifact@v4
  with:
    name: apk-result
    path: |
      ${{ env.APK_BUILD_DIR }}/app/build/app/outputs/flutter-apk/app-armeabi-v7a-debug.apk
      ${{ env.APK_BUILD_DIR }}/app/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
      ${{ env.APK_BUILD_DIR }}/app/build/app/outputs/flutter-apk/app-x86_64-debug.apk
```

## 验证清单

- [ ] 更新 Kotlin 版本到 1.9.0
- [ ] 更新 Android Gradle Plugin 版本
- [ ] 配置 GitHub Secrets（如果需要 release 版本）
- [ ] 测试构建流程
- [ ] 确认 APK 可以正常生成和安装

## 注意事项

1. **签名密钥安全**：

   - 不要将私钥提交到代码仓库
   - 使用 GitHub Secrets 安全存储敏感信息
2. **版本兼容性**：

   - 确保 Flutter、Kotlin、Gradle 版本相互兼容
   - 更新版本后可能需要清理缓存
3. **测试建议**：

   - 先在本地测试构建流程
   - 确认新版本在目标设备上运行正常

## 常见问题

**Q: 更新 Kotlin 版本后仍有兼容性问题？**
A: 尝试清理构建缓存，或者检查是否有依赖需要同步更新。

**Q: 如何生成用于发布的签名密钥？**
A: 使用 keytool 命令生成，并妥善保管密钥库文件和密码。

**Q: Debug 版本和 Release 版本有什么区别？**
A: Debug 版本用于开发测试，Release 版本用于正式发布，需要签名且经过优化。
