#!/bin/bash

# 清理旧环境
rm -rf openwrt-x86
mkdir openwrt-x86 && cd openwrt-x86

# 克隆官方 SDK
wget https://downloads.openwrt.org/releases/23.05.3/targets/x86/64/openwrt-sdk-23.05.3-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
tar -xJf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*

# 配置 feeds
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall" > feeds.conf.default
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2" >> feeds.conf.default
echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default
echo "src-git openclash https://github.com/vernesong/OpenClash" >> feeds.conf.default

# 更新并安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 编译所有插件
make defconfig
make package/passwall/compile -j$(nproc)
make package/passwall2/compile -j$(nproc)
make package/ssr-plus/compile -j$(nproc)
make package/luci-app-openclash/compile -j$(nproc)

# 复制 .ipk 文件
mkdir -p ../../../ipk/x86_64/
find bin/packages/ -name "*.ipk" -exec cp {} ../../../ipk/x86_64/ \;

