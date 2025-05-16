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

# ✅ 自动修复 Config.in 中缺失的类型（例如 bool）
echo "🔧 正在修复插件 Config.in 中缺失的 config 类型..."
for config_file in feeds/*/luci-app-*/Config.in; do
    [ -f "$config_file" ] || continue
    echo "修复: $config_file"

    awk '
    BEGIN { skip = 0 }
    /^config / {
        print $0
        skip = 1
        next
    }
    /^[ \t]*prompt / && skip == 1 {
        print "    bool \"\""
        print $0
        skip = 0
        next
    }
    { print $0 }
    ' "$config_file" > "$config_file.fixed" && mv "$config_file.fixed" "$config_file"
done
echo "✅ 修复完成"

# 复制 config 配置文件（你已有的 x86_64.config）
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config

# 设置默认配置
make defconfig

# ✅ 编译指定插件，避免触发不必要的系统包编译
make package/passwall/compile -j$(nproc) || make package/passwall/compile -j1 V=s
make package/passwall2/compile -j$(nproc) || make package/passwall2/compile -j1 V=s
make package/shadowsocksr-libev/compile -j$(nproc) || make package/shadowsocksr-libev/compile -j1 V=s
make package/luci-app-ssr-plus/compile -j$(nproc) || make package/luci-app-ssr-plus/compile -j1 V=s
make package/luci-app-openclash/compile -j$(nproc) || make package/luci-app-openclash/compile -j1 V=s

# 拷贝 .ipk 到项目目录
mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;






