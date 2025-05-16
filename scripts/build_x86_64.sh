#!/bin/bash
set -e

# 创建临时构建目录
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

# 下载 OpenWrt SDK（官方地址，22.03 版本）
wget https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xf openwrt-sdk-22.03.6-x86-64_*.tar.xz

# 获取解压后的目录名
SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-22.03.6-x86-64*" | head -n 1)
cd "$SDK_DIR"

# 添加插件源
cp "$GITHUB_WORKSPACE/feeds.conf.default" feeds.conf.default

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 复制 config 配置文件（你已有的 x86_64.config）
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig

# 设置默认配置
make defconfig

# 只编译需要的插件包，避免触发系统组件错误（重点！）
make package/passwall/compile -j$(nproc)
make package/passwall2/compile -j$(nproc)
make package/shadowsocksr-libev/compile -j$(nproc)
make package/luci-app-ssr-plus/compile -j$(nproc)
make package/luci-app-openclash/compile -j$(nproc)

# 拷贝 .ipk 到项目目录
mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;





