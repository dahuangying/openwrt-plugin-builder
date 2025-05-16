#!/bin/bash
set -e

WORKDIR="$GITHUB_WORKSPACE/build_sdk"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 下载并解压 SDK（如果不存在）
if [ ! -d openwrt-sdk-22.03.6-x86-64* ]; then
  wget -c https://downloads.openwrt.org/releases/22.03.6/targets/x86/64/openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz
  tar -xf openwrt-sdk-22.03.6-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz
fi

SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-22.03.6-x86-64*")
cd "$SDK_DIR"

# 写 feeds.conf.default，添加 passwall 和 passwall2 feeds
cat > feeds.conf.default << EOF
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://github.com/openwrt/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
src-git helloworld https://github.com/fw876/helloworld
src-git openclash https://github.com/vernesong/OpenClash.git
src-git passwall https://github.com/xiaorouji/openwrt-passwall
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2
EOF

# 更新并安装所有feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 修复 luci-app-ssr-plus 的 Makefile 防止类型错误（例子）
SSR_PLUS_MK="feeds/helloworld/luci-app-ssr-plus/Makefile"
if [ -f "$SSR_PLUS_MK" ]; then
  sed -i 's/LUCI_DEPENDS:=.*/LUCI_DEPENDS:=+iptables-mod-tproxy/' "$SSR_PLUS_MK"
fi

# 修复 Config.in 缺失类型
echo "🔧 修复 Config.in 缺失类型..."
find feeds -type f -name Config.in | while read -r config_file; do
  awk '
    BEGIN { in_config=0 }
    /^config / { in_config=1; print; next }
    /^[ \t]*prompt / && in_config==1 {
      if (getline next_line > 0) {
        if (next_line !~ /^[ \t]*(bool|tristate|string|hex|int)/) {
          print "    bool \"\""
        }
        print next_line
      }
      in_config=0
      next
    }
    { print }
  ' "$config_file" > "$config_file.fixed" && mv "$config_file.fixed" "$config_file"
done

# 复制自定义配置文件
cp "$GITHUB_WORKSPACE/config/x86_64.config" .config
make defconfig

LOGFILE="$GITHUB_WORKSPACE/build.log"

# 编译指定软件包（用 feed 的包名）
for pkg in \
  openwrt-passwall \
  openwrt-passwall2 \
  shadowsocksr-libev \
  luci-app-ssr-plus \
  luci-app-openclash; do
  echo "编译 $pkg ..."
  make package/$pkg/compile -j$(nproc) >"$LOGFILE" 2>&1 || (cat "$LOGFILE"; make package/$pkg/compile -j1 V=s)
done

# 复制编译好的 ipk
mkdir -p "$GITHUB_WORKSPACE/ipk/x86_64/"
find bin/packages/ -name '*.ipk' -exec cp {} "$GITHUB_WORKSPACE/ipk/x86_64/" \;










