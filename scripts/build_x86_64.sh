#!/bin/bash
set -e

# 创建临时构建目录
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

# 下载 OpenWrt SDK（22.03.6 x86_64）
wget https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xf openwrt-sdk-22.03.6-x86-64_*.tar.xz

# 进入 SDK 目录
SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-22.03.6-x86-64*" | head -n 1)
cd "$SDK_DIR"

# 配置 feeds
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2" >> feeds.conf.default
echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default
echo "src-git openclash https://github.com/vernesong/OpenClash" >> feeds.conf.default

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 复制自定义配置文件（提前准备好的）
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config

# 设置默认配置
make defconfig

# 编译插件（根据 config 中所选的）
make -j$(nproc)

# 拷贝 .ipk 到输出目录
mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;




