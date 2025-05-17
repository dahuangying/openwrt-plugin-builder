#!/bin/bash
# =============================================
# 📅 Last updated: $(date)
# 🔧 Description: 构建 x86_64 插件，Lienol 优先，Lean 备用
# =============================================

set -e

ARCH="x86_64"
WORKDIR="$GITHUB_WORKSPACE/build_sdk/$ARCH"
SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 下载并解压 SDK（只做一次）
if [ ! -d openwrt-sdk-22.03.6-x86-64* ]; then
  echo "🔄 下载 OpenWrt SDK..."
  wget -c "$SDK_URL"
  tar -xf *.tar.xz
fi

SDK_DIR=$(ls -d openwrt-sdk-22.03.6-x86-64* 2>/dev/null | head -n 1)
if [ -z "$SDK_DIR" ]; then
  echo "❌ SDK 目录未找到，下载或解压失败"
  exit 1
fi
cd "$SDK_DIR"

# 写 feeds.conf.default，Lienol 源优先
cat > feeds.conf.default <<EOF
src-git packages https://github.com/Lienol/openwrt-packages
src-git luci https://github.com/Lienol/openwrt-luci
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash.git
EOF

# 更新 feeds，失败时切换为 Lean 源
if ! ./scripts/feeds update -a; then
  echo "❌ Lienol 源更新失败，切换 Lean 源..."
  cat > feeds.conf.default <<EOF
src-git packages https://github.com/coolsnowwolf/packages
src-git luci https://github.com/coolsnowwolf/luci
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash.git
EOF
  ./scripts/feeds update -a
fi

./scripts/feeds install -a

# 应用配置
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig

# 编译插件列表
PKGS=(
  openwrt-passwall
  openwrt-passwall2
  shadowsocksr-libev
  luci-app-ssr-plus
  luci-app-openclash
)

for pkg in "${PKGS[@]}"; do
  echo "📦 编译插件: $pkg"
  if ! make package/"$pkg"/compile -j"$(nproc)"; then
    echo "⚠️ 失败，重试单线程详细模式编译 $pkg"
    make package/"$pkg"/compile -j1 V=s
  fi
done

# 复制生成的 ipk 文件
mkdir -p "$GITHUB_WORKSPACE/ipk/$ARCH"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/$ARCH/" \;

echo "✅ $ARCH 插件编译完成."


