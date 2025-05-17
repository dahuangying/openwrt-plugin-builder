#!/bin/bash
set -e

ARCH=aarch64_cortex-a53
SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/mediatek/mt7622/openwrt-sdk-22.03.6-mediatek-mt7622_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
SDK_ARCHIVE="${SDK_URL##*/}"
SDK_DIR_NAME="${SDK_ARCHIVE%.tar.xz}"

WORKDIR="$GITHUB_WORKSPACE/build_sdk"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

# 下载 SDK（只下载一次）
if [ ! -d "$SDK_DIR_NAME" ]; then
  echo "🔽 下载 SDK..."
  wget -c "$SDK_URL"
  tar -xf "$SDK_ARCHIVE"
fi

cd "$SDK_DIR_NAME"

# 写入 feeds.conf.default
cat > feeds.conf.default <<EOF
src-git packages https://github.com/coolsnowwolf/packages
src-git luci https://github.com/coolsnowwolf/luci
src-git helloworld https://github.com/fw876/helloworld
src-git lienol https://github.com/Lienol/openwrt-package
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git openclash https://github.com/vernesong/OpenClash.git
EOF

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 应用 .config
cp "$GITHUB_WORKSPACE/config/aarch64.config" .config
make defconfig

LOG="$GITHUB_WORKSPACE/build.log"

# 编译关键插件
for pkg in \
  openwrt-passwall \
  openwrt-passwall2 \
  luci-app-ssr-plus \
  luci-app-openclash; do
  echo "📦 正在编译 $pkg..."
  make package/$pkg/compile -j$(nproc) >"$LOG" 2>&1 || (cat "$LOG"; make package/$pkg/compile -j1 V=s)
done

# 拷贝 .ipk 到输出目录
OUTDIR="$GITHUB_WORKSPACE/ipk/$ARCH"
mkdir -p "$OUTDIR"
find bin/packages/ -name '*.ipk' -exec cp {} "$OUTDIR/" \;

echo "✅ $ARCH 插件构建完成"


