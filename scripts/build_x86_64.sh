#!/bin/bash
# 构建 x86_64 插件，Lienol 优先，Lean 备用

set -e
ARCH="x86_64"
WORKDIR="$GITHUB_WORKSPACE/build_sdk/$ARCH"
SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz"

mkdir -p "$WORKDIR" && cd "$WORKDIR"
[ ! -d openwrt-sdk-* ] && wget -c "$SDK_URL" && tar -xf *.tar.xz

SDK_DIR=$(ls -d openwrt-sdk-22.03.6-x86-64* | head -n 1)
cd "$SDK_DIR"

# 设置 feeds（Lienol 优先）
cat > feeds.conf.default <<EOF
src-git packages https://github.com/Lienol/openwrt-packages
src-git luci https://github.com/Lienol/openwrt-luci
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash.git
EOF

./scripts/feeds update -a || {
  echo "切换为 Lean 源..."
  cat > feeds.conf.default <<EOF
src-git packages https://github.com/coolsnowwolf/packages
src-git luci https://github.com/coolsnowwolf/luci
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash.git
EOF
  ./scripts/feeds update -a
}
./scripts/feeds install -a

# 加载配置并启用 Lua 支持（解决 lucihttp 缺 lua.h 报错）
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig
echo -e "CONFIG_PACKAGE_liblua=y\nCONFIG_PACKAGE_lua=y" >> .config
make defconfig

# 编译插件
for pkg in openwrt-passwall openwrt-passwall2 shadowsocksr-libev luci-app-ssr-plus luci-app-openclash; do
  echo "编译 $pkg"
  make package/$pkg/compile -j$(nproc) || make package/$pkg/compile -j1 V=s
done

# 拷贝生成的 ipk
mkdir -p "$GITHUB_WORKSPACE/ipk/$ARCH"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/$ARCH/" \;




