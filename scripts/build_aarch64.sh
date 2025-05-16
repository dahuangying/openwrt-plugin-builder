#!/bin/bash
set -e

ARCH_DIR="./packages/aarch64_cortex-a53"
mkdir -p "$ARCH_DIR"

echo "正在模拟构建 aarch64 插件..."

# 模拟构建生成 .ipk 文件
echo "fake aarch64 ipk file content" > "$ARCH_DIR/luci-app-openclash_$(date +%s)_aarch64.ipk"
