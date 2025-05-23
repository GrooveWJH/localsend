# 替换项目中所有图标为 app/assets/img/logo-new.png 并重新生成 Flutter 资产代码。
# 运行位置：仓库根目录
set -euo pipefail

logo_src="app/assets/img/logo-new.png"

if [ ! -f "$logo_src" ]; then
  echo "❌ 没找到 $logo_src ，请确认路径正确" >&2
  exit 1
fi

echo "🔄 复制 Flutter 资产目录图标…"
for name in logo-32.png logo-32-black.png logo-32-white.png logo-128.png logo-256.png logo-512.png; do
  cp "$logo_src" "app/assets/img/$name"
done

# 转 ICO（需要 ImageMagick）
if command -v convert >/dev/null 2>&1; then
  echo "🖼️  生成 ICO…"
  convert "$logo_src" -define icon:auto-resize=256,128,96,64,48,32,16 app/assets/img/logo.ico
else
  echo "⚠️  未安装 ImageMagick，跳过 ICO 生成 (brew install imagemagick)"
fi

echo "🔄 覆盖 Android mipmap 图标…"
for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  dst_dir="app/android/app/src/main/res/mipmap-${dir}"
  cp "$logo_src" "$dst_dir/ic_launcher.png"
  cp "$logo_src" "$dst_dir/ic_launcher_foreground.png" || true
  cp "$logo_src" "$dst_dir/ic_launcher_monochrome.png" || true
done
cp "$logo_src" app/android/app/src/main/ic_launcher-playstore.png

echo "🔄 覆盖 Windows ICO…"
if [ -f app/windows/runner/resources/app_icon.ico ]; then
  [ -f app/assets/img/logo.ico ] && cp app/assets/img/logo.ico app/windows/runner/resources/app_icon.ico
fi

echo "🔄 覆盖 AppImage 脚本里引用的 PNG…"
for f in scripts/appimage/*.png; do
  [ -f "$f" ] && cp "$logo_src" "$f"
done

echo "🚀 重新生成 Flutter 资产代码…"
(cd app && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs)

echo "✅ 图标已统一并生成完成！" 