# LocalSend 主题定制指南

本文档介绍如何定制 LocalSend 应用的视觉外观，包括颜色、图标、字体和其他视觉元素的修改。

## 目录

- [主题定制基础](#主题定制基础)
- [修改应用名称](#修改应用名称)
- [修改配色方案](#修改配色方案)
- [替换应用图标和 Logo](#替换应用图标和-logo)
- [自定义字体](#自定义字体)
- [静态文本和国际化](#静态文本和国际化)
- [验证修改效果](#验证修改效果)
- [常见问题](#常见问题)

## 主题定制基础

LocalSend 作为一个 Flutter 应用，其视觉外观主要通过以下几个方面控制：

1. **主题配置**：在 Flutter 代码中定义的 `ThemeData` 对象
2. **资源文件**：包括图片、图标和字体等
3. **国际化文本**：存储在 `.arb` 文件中的文本字符串
4. **平台特定文件**：各平台的原生配置文件，如 `Info.plist`、`AndroidManifest.xml` 等

进行自定义时，您需要确保修改 `app/pubspec.yaml` 以声明新的资源文件，并在相应的代码中引用这些资源。

## 修改应用名称

应用名称出现在多个位置，包括主界面、窗口标题和操作系统的应用列表中。修改应用名称需要更新多个文件：

### 平台配置文件中的应用名称

- **iOS**:
  - `app/ios/Runner/Info.plist`: 修改 `CFBundleDisplayName` 的值。

- **macOS**:
  - `app/macos/Runner/Configs/AppInfo.xcconfig`: 修改 `PRODUCT_NAME` 的值。
  - `app/macos/Runner/Info.plist`: `CFBundleDisplayName` 和 `CFBundleName` 通常会引用 `PRODUCT_NAME`。
  - `app/macos/Runner/Base.lproj/MainMenu.xib`: 查找并修改 `window title="LocalSend"` 的值。
  
- **Android**:
  - `app/android/app/src/main/AndroidManifest.xml`: 查找并修改 `<application>` 标签下的 `android:label` 属性。
  - `app/android/app/src/debug/AndroidManifest.xml`: 针对调试版本的应用名称，修改 `android:label`。
  
- **Web**:
  - `app/web/manifest.json`: 修改 `name` 和 `short_name` 字段。
  
- **Windows**:
  - 应用名称可能在 `app/windows/runner/Runner.rc` 或相关的 `CMakeLists.txt` 文件中定义。
  
- **Linux**:
  - 应用名称通常在 `.desktop` 文件中定义，可以查看 `app/linux/CMakeLists.txt` 中 `BINARY_NAME` 的设置。

### 国际化文件中的应用名称

在 `app/lib/l10n/` 目录下的 `.arb` 文件（例如 `app_en.arb`, `app_zh.arb` 等）中查找并修改 `"appName"` 的值：

```json
{
  "@@locale": "zh",
  "appName": "我的新应用名称"
  // 其他字符串...
}
```

修改后，需要运行以下命令重新生成国际化文件：

```bash
fvm flutter gen-l10n
```

### Flutter 代码中的硬编码名称

在以下文件中搜索并修改硬编码的应用名称字符串：

- **`app/lib/pages/home_page.dart`**:
  查找 `Text('LocalSend', ...)` 并修改为你的新应用名称。
  
- **`app/lib/widget/local_send_logo.dart`**:
  查找 `const Text('LocalSend', ...)` 并修改为你的新应用名称。

## 修改配色方案

LocalSend 的配色主要在 Flutter 的 `ThemeData` 中定义，核心文件是 `app/lib/config/theme.dart`。

### 修改主色调

1. 打开 `app/lib/config/theme.dart`
2. 定位到 `_determineColorScheme` 函数
3. 修改 `ColorScheme.fromSeed(seedColor: Colors.teal, ...)` 中的 `seedColor` 为你想要的新颜色

例如，将蓝绿色 (Teal) 改为蓝色：
```dart
final defaultColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue, // 从 Colors.teal 修改为 Colors.blue
  brightness: brightness,
);
```

### 细化组件颜色

在 `getTheme` 函数返回的 `ThemeData` 对象中，你可以进一步调整特定 UI 组件的颜色和样式：

- `navigationBarTheme`
- `inputDecorationTheme` (输入框样式)
- `elevatedButtonTheme` (按钮样式)
- `textButtonTheme`
- `cardColor` (卡片背景色)
- `scaffoldBackgroundColor` (页面背景色)

### 修改 Android 启动背景

应用启动时的背景色和初始窗口颜色定义在以下 XML 文件中：

- `app/android/app/src/main/res/values/styles.xml` (日间模式)
- `app/android/app/src/main/res/values-night/styles.xml` (夜间模式)

修改这些文件中的 `LaunchTheme` 和 `NormalTheme`，以匹配你的新配色方案。

## 替换应用图标和 Logo

替换应用图标和 Logo 分为两部分：应用内部显示的 Logo 和各平台的应用图标。

### 内部 Logo 资源

1. 将你的新 Logo 图片放入 `app/assets/img/` 目录，例如 `logo-new.png`
2. 确保在 `app/pubspec.yaml` 中声明了 `assets/img/` 目录
3. 运行以下命令更新资源引用：
   ```bash
   fvm flutter pub get
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. 打开 `app/lib/widget/local_send_logo.dart`，修改以下代码：
   ```dart
   child: Assets.img.logo512.image( // 修改为新的引用
     width: 200,
     height: 200,
   ),
   ```
   改为：
   ```dart
   child: Assets.img.logoNew.image( // 使用新的引用名，可能因文件名而异
     width: 200,
     height: 200,
   ),
   ```

### 各平台应用图标

#### Android
- 替换 `app/android/app/src/main/res/mipmap-*/ic_launcher.png` 文件
- 对于自适应图标，修改 `app/android/app/src/main/res/drawable/ic_launcher_foreground.xml` 或相应 PNG 文件

#### iOS
- 替换 `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/` 目录下的图片文件
- 确保新图标与 `Contents.json` 中定义的尺寸相对应

#### macOS
- 替换 `app/macos/Runner/Assets.xcassets/AppIcon.appiconset/` 下的图片
- 替换 `app/macos/Runner/Assets.xcassets/StatusBarItemIcon.imageset/` 下的图片

#### Windows
- 替换 `app/windows/runner/resources/app_icon.ico` 文件

#### Linux
- 替换 `app/assets/img/` 目录下的 `logo-32.png`, `logo-128.png`, `logo-256.png`

#### Web
- 替换 `app/web/icons/` 目录下的 `Icon-192.png`, `Icon-512.png` 等文件

## 自定义字体

如果您想使用自定义字体：

1. 在 `app/assets/fonts/` 目录中放置字体文件（如 `.ttf`）
2. 在 `app/pubspec.yaml` 中声明字体：

```yaml
flutter:
  fonts:
    - family: MyCustomFont
      fonts:
        - asset: assets/fonts/MyCustomFont-Regular.ttf
        - asset: assets/fonts/MyCustomFont-Bold.ttf
          weight: 700
```

3. 在 `app/lib/config/theme.dart` 中设置全局字体：

```dart
return ThemeData(
  fontFamily: 'MyCustomFont',
  // 其他主题配置...
);
```

## 静态文本和国际化

1. 打开 `app/lib/l10n/` 目录下对应语言的 `.arb` 文件
2. 修改其中的文本字符串
3. 运行 `fvm flutter gen-l10n` 重新生成国际化代码

## 验证修改效果

1. **测试和热重载**：
   - 运行 `fvm flutter run -d <platform>` 进行测试
   - 对于代码修改，可以使用热重载 (按 `r`)
   - 对于资源或原生文件的修改，需要重新启动应用

2. **构建发布版本**：
   - 运行 `fvm flutter build <platform>` 生成发布版本

## 常见问题

### Q: 修改了 `theme.dart` 但颜色没有变化？
A: 确保你修改了正确的 `ColorScheme` 生成部分，并且使用热重载刷新 UI。

### Q: 替换了图片资源但没有显示新图片？
A: 确保运行了 `fvm flutter pub run build_runner build` 更新资源引用，并重启应用。

### Q: 应用名称在某些地方没有更新？
A: 应用名称存在于多个文件中，确保你已修改上面提到的所有位置。如果是原生平台文件的修改，需要重新构建应用。

### Q: 国际化字符串更新后没有生效？
A: 确保你运行了 `fvm flutter gen-l10n` 并重启应用。

---

通过以上步骤，您可以全面定制 LocalSend 的外观，使其符合您的品牌要求或个人喜好。如有进一步问题，请参考 [贡献指南](../developer/contributing.md) 或在 GitHub 仓库中提问。 