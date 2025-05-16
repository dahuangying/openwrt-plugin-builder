#!/bin/bash
set -e

SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
SDK_ARCHIVE="openwrt-sdk.tar.xz"
SDK_DIR="openwrt-sdk"

# 下载 SDK（如果不存在）
if [ ! -f "$SDK_ARCHIVE" ]; then
  echo "📦 Downloading OpenWrt SDK..."
  wget -c "$SDK_URL" -O "$SDK_ARCHIVE"
fi

# 解压 SDK 并重命名为统一目录
if [ ! -d "$SDK_DIR" ]; then
  echo "📂 Extracting SDK..."
  tar -xf "$SDK_ARCHIVE"
  EXTRACTED_DIR=$(tar -tf "$SDK_ARCHIVE" | head -1 | cut -f1 -d"/")
  echo "🔍 Renaming extracted directory $EXTRACTED_DIR to $SDK_DIR"
  mv "$EXTRACTED_DIR" "$SDK_DIR"
fi

cd "$SDK_DIR"

# 示例：自动修复 luci-app-ssr-plus 的 Makefile（你可按需替换下面内容）
echo "🛠 Fixing feeds/helloworld/luci-app-ssr-plus/Makefile..."
if [ -f feeds/helloworld/luci-app-ssr-plus/Makefile ]; then
  # ⚠️ 修改这一行替换旧内容为新内容（你可以根据实际错误写 sed）
  sed -i 's/PKG_VERSION:=.*$/PKG_VERSION:=latest/' feeds/helloworld/luci-app-ssr-plus/Makefile
fi

echo "✅ SDK 准备完成，你可以开始编译了。"

