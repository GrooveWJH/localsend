# Windows 程序窗口标题修改指南

## 修改位置概览

Windows 程序的窗口标题主要在以下文件中设置：

### 1. 主要窗口标题 (最重要)
**文件**: `app/windows/runner/main.cpp`
**位置**: 第 28 行

### 2. 资源文件中的程序信息
**文件**: `app/windows/runner/Runner.rc`
**位置**: 版本信息区域

### 3. 可执行文件名称
**文件**: `app/windows/CMakeLists.txt`
**位置**: BINARY_NAME 变量

### 4. Flutter 应用标题
**文件**: `app/lib/main.dart`
**位置**: MaterialApp 的 title 属性

## 详细修改步骤

### 步骤 1：修改主窗口标题

修改 `app/windows/runner/main.cpp` 文件的第 28 行：

**当前代码**：
```cpp
if (!window.Create(L"LocalSend", origin, size)) {
```

**修改为**（例如改为 "MyApp"）：
```cpp
if (!window.Create(L"MyApp", origin, size)) {
```

### 步骤 2：修改资源文件中的程序信息

修改 `app/windows/runner/Runner.rc` 文件中的以下内容：

**当前代码**：
```rc
VALUE "CompanyName", "Tien Do Nam" "\0"
VALUE "FileDescription", "LocalSend" "\0"
VALUE "InternalName", "localsend_app" "\0"
VALUE "LegalCopyright", "Copyright (C) 2022-2024 Tien Do Nam. All rights reserved." "\0"
VALUE "OriginalFilename", "localsend_app.exe" "\0"
VALUE "ProductName", "LocalSend" "\0"
```

**修改为**：
```rc
VALUE "CompanyName", "Your Company" "\0"
VALUE "FileDescription", "MyApp" "\0"
VALUE "InternalName", "myapp" "\0"
VALUE "LegalCopyright", "Copyright (C) 2024 Your Company. All rights reserved." "\0"
VALUE "OriginalFilename", "myapp.exe" "\0"
VALUE "ProductName", "MyApp" "\0"
```

### 步骤 3：修改可执行文件名称

修改 `app/windows/CMakeLists.txt` 文件的第 7 行：

**当前代码**：
```cmake
set(BINARY_NAME "localsend_app")
```

**修改为**：
```cmake
set(BINARY_NAME "myapp")
```

### 步骤 4：修改 Flutter 应用标题

修改 `app/lib/main.dart` 文件中的 MaterialApp：

**查找当前代码**：
```dart
MaterialApp(
  title: t.appName,
```

如果你想让窗口标题和应用内标题保持一致，可以修改多语言文件中的 `appName`。

**文件位置**: `app/assets/i18n/en.json`（和其他语言文件）

**当前代码**：
```json
{
  "appName": "LocalSend",
  ...
}
```

**修改为**：
```json
{
  "appName": "MyApp",
  ...
}
```

## 修改示例

假设你要将程序名改为 "文件传输助手"，以下是完整的修改：

### 1. main.cpp
```cpp
if (!window.Create(L"文件传输助手", origin, size)) {
```

### 2. Runner.rc
```rc
VALUE "FileDescription", "文件传输助手" "\0"
VALUE "ProductName", "文件传输助手" "\0"
VALUE "OriginalFilename", "file_transfer_helper.exe" "\0"
```

### 3. CMakeLists.txt
```cmake
set(BINARY_NAME "file_transfer_helper")
```

### 4. en.json (和其他语言文件)
```json
{
  "appName": "文件传输助手",
  ...
}
```

## 重新编译

修改完成后，需要重新编译 Windows 版本：

```bash
cd app
flutter build windows
```

编译后的程序位于：
```
app/build/windows/x64/runner/Release/
```

## 验证修改

1. **窗口标题栏**: 查看程序运行时的标题栏是否显示新名称
2. **任务栏**: 查看 Windows 任务栏中显示的程序名
3. **文件属性**: 右键点击 .exe 文件 → 属性 → 详细信息，查看程序信息
4. **系统托盘**: 如果程序最小化到托盘，查看托盘提示信息

## 注意事项

1. **字符编码**: 
   - 在 `main.cpp` 中使用 `L"..."` 表示宽字符字符串
   - 支持中文等Unicode字符

2. **一致性**: 
   - 建议所有位置的程序名保持一致
   - 注意更新相关的版权信息

3. **文件名**: 
   - 可执行文件名应避免空格和特殊字符
   - 建议使用下划线或连字符

4. **多语言支持**: 
   - 如果使用多语言，需要更新所有语言文件中的 `appName`
   - 窗口标题可以设置为固定值或根据当前语言动态显示

## 高级设置：动态窗口标题

如果你想要根据应用状态动态更改窗口标题，可以在 Flutter 代码中使用：

```dart
import 'package:window_manager/window_manager.dart';

// 设置窗口标题
await windowManager.setTitle('新的窗口标题');
```

这种方式可以在运行时动态更改窗口标题，适用于显示当前操作状态等场景。 