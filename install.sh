#!/bin/sh
set -e

# 自动检测 OpenWrt 架构
ARCH=$(opkg print-architecture | grep '^arch' | sort -k3 -n | tail -n1 | awk '{print $2}')

# 设置你的 GitHub Pages 软件源地址
BASE_URL="https://yourname.github.io/openwrt-packages"

# 校验可用架构
case "$ARCH" in
  x86_64|aarch64_cortex-a53)
    echo "✅ 检测到支持的系统架构: $ARCH"
    ;;
  *)
    echo "❌ 不支持的系统架构: $ARCH"
    echo "仅支持: x86_64 / aarch64_cortex-a53"
    exit 1
    ;;
esac

# 写入 OPKG 软件源（单独放在 customfeeds.conf 中）
echo "🔧 配置 OPKG 软件源..."
FEEDS_CONF="/etc/opkg/customfeeds.conf"
grep -q "openwrt-packages" "$FEEDS_CONF" 2>/dev/null || echo "src/gz openwrt-packages ${BASE_URL}/ipk/${ARCH}" >> "$FEEDS_CONF"

# 更新软件列表
echo "🔄 更新软件列表..."
opkg update

# 显示可选插件（可按需更改）
echo "📦 可用插件列表（如需安装请自行 opkg install）:"
opkg list | grep -E 'passwall|ssr|openclash|luci'

# 你也可以在下面自动安装特定插件，例如：
# opkg install luci-app-passwall

echo "✅ 安装准备完成，可使用 opkg install 安装插件"
