#!/bin/bash

set -e

# 设置 OpenWrt SDK 根目录
SDK_DIR=$(pwd)
echo "当前SDK目录：$SDK_DIR"

# 更新和安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 打补丁/添加缺失的依赖（如果有）
# 示例：ln -sf /usr/include/pcap.h staging_dir/...

# 选择要编译的插件（按需修改）
PLUGINS=(
  passwall/luci-app-passwall
  passwall2/luci-app-passwall2
  helloworld/luci-app-ssr-plus
  openclash/luci-app-openclash
)

# 编译插件
for pkg in "${PLUGINS[@]}"; do
  echo "======================="
  echo "开始编译 feeds/$pkg"
  echo "======================="
  make package/feeds/$pkg/compile -j$(nproc) || make package/feeds/$pkg/compile -j1 V=s
done

# 打包输出文件
echo "======================="
echo "打包 bin 目录为 output_packages.tar.gz"
echo "======================="
tar -czf output_packages.tar.gz bin/

echo "✅ 所有插件编译完成，打包输出成功！"
