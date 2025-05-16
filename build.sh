#!/bin/bash
set -e

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

wget https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xf openwrt-sdk-22.03.6-x86-64_*.tar.xz

SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-22.03.6-x86-64*" | head -n 1)
cd "$SDK_DIR"

cat > feeds.conf.default << EOF
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/feed/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git

src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash
EOF

./scripts/feeds update -a
./scripts/feeds install -a

cp "$GITHUB_WORKSPACE/config/x86_64.config" .config

make defconfig

make package/feeds/passwall/luci-app-passwall/compile -j$(nproc)
make package/feeds/passwall2/luci-app-passwall2/compile -j$(nproc)
make package/feeds/helloworld/shadowsocksr-libev/compile -j$(nproc)
make package/feeds/helloworld/luci-app-ssr-plus/compile -j$(nproc)
make package/feeds/openclash/luci-app-openclash/compile -j$(nproc)

mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;
