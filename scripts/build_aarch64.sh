#!/bin/bash
set -e

# 创建临时构建目录
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

# 下载 OpenWrt SDK（官方地址，22.03 版本）
wget https://downloads.openwrt.org/releases/22.03.6/targets/rockchip/armv8/openwrt-sdk-22.03.6-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xf openwrt-sdk-22.03.6-rockchip-armv8_*.tar.xz
cd openwrt-sdk-22.03.6-rockchip-armv8_*

# 更新 feeds
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2" >> feeds.conf.default
echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default
echo "src-git openclash https://github.com/vernesong/OpenClash" >> feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

# 编译
make defconfig
make package/passwall/compile -j$(nproc)
make package/passwall2/compile -j$(nproc)
make package/shadowsocksr-libev/compile -j$(nproc)
make package/luci-app-ssr-plus/compile -j$(nproc)
make package/luci-app-openclash/compile -j$(nproc)

# 拷贝 .ipk 到项目目录
mkdir -p $GITHUB_WORKSPACE/ipk/aarch64_cortex-a53/
find bin/packages/ -name '*.ipk' -exec cp {} $GITHUB_WORKSPACE/ipk/aarch64_cortex-a53/ \;

