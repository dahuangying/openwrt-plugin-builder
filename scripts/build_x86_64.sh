#!/bin/bash
# ==========================================================
# 🔧 构建 x86_64 插件，Lienol 优先，Lean 备用
# 🧱 支持插件：PassWall、PassWall2、SSR-Plus、OpenClash
# ==========================================================

set -e

ARCH="x86_64"
WORKDIR="$GITHUB_WORKSPACE/build_sdk/$ARCH"
SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz"

# 进入工作目录
mkdir -p "$WORKDIR" && cd "$WORKDIR"

# 下载 SDK（如果未存在）
[ ! -d openwrt-sdk-* ] && wget -c "$SDK_URL" && tar -xf *.tar.xz

# 获取 SDK 解压目录名并进入
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

# 拉取 feeds，失败则切换 Lean 源
./scripts/feeds update -a || {
  echo "❌ Lienol 源失败，切换为 Lean 源..."
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

# 安装 feeds
./scripts/feeds install -a

# 应用配置文件
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig

# 要编译的插件（已确保是正确路径名）
PKGS=(
  luci-app-passwall
  luci-app-passwall2
  luci-app-ssr-plus
  luci-app-openclash
  shadowsocksr-libev
)

# 编译插件（支持失败自动重试）
for pkg in "${PKGS[@]}"; do
  echo "🔨 编译插件: $pkg"
  if [ -d "package/feeds" ]; then
    make package/$pkg/compile -j$(nproc) || make package/$pkg/compile -j1 V=s
  else
    echo "⚠️ 插件目录不存在: $pkg，跳过"
  fi
done

# 收集 ipk 输出
mkdir -p "$GITHUB_WORKSPACE/ipk/$ARCH"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/$ARCH/" \;

echo "✅ $ARCH 插件构建完成"



