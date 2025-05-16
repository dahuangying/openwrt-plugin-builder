#!/bin/bash
set -e

SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
SDK_DIR="openwrt-sdk"

# 如果SDK目录不存在，就下载并解压
if [ ! -d "$SDK_DIR" ]; then
  echo "Downloading OpenWrt SDK..."
  wget -c $SDK_URL -O openwrt-sdk.tar.xz
  echo "Extracting SDK..."
  tar -xf openwrt-sdk.tar.xz
  mv openwrt-sdk-* $SDK_DIR
fi

cd $SDK_DIR

# 这里写自动修复 Makefile 的命令（替换成你需要的）
echo "Fixing feeds/helloworld/luci-app-ssr-plus/Makefile..."
sed -i 's/旧内容/新内容/' feeds/helloworld/luci-app-ssr-plus/Makefile

echo "准备完成，你可以开始编译了。"
