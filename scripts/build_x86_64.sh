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

# ✅ 使用官方源 + 你自己的 feeds
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

# 更新 & 安装所有 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# ✅ 修复 Config.in 中缺失类型问题
echo "🔧 修复 Config.in 缺失类型..."
for config_file in feeds/*/*/Config.in; do
    [ -f "$config_file" ] || continue
    awk '
    BEGIN { skip = 0 }
    /^config / { print $0; skip = 1; next }
    /^[ \t]*prompt / && skip == 1 { print "    bool \"\""; print $0; skip = 0; next }
    { print $0 }
    ' "$config_file" > "$config_file.fixed" && mv "$config_file.fixed" "$config_file"
done

# ✅ 拷贝你自己的 config 文件（确保包含 luci base 等依赖）
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig

# ✅ 编译插件，失败时回退单线程输出详细日志
make package/passwall/compile -j$(nproc) || make package/passwall/compile -j1 V=s
make package/passwall2/compile -j$(nproc) || make package/passwall2/compile -j1 V=s
make package/shadowsocksr-libev/compile -j$(nproc) || make package/shadowsocksr-libev/compile -j1 V=s
make package/luci-app-ssr-plus/compile -j$(nproc) || make package/luci-app-ssr-plus/compile -j1 V=s
make package/luci-app-openclash/compile -j$(nproc) || make package/luci-app-openclash/compile -j1 V=s

# ✅ 拷贝 .ipk 到构建目录
mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;







