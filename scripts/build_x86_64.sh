#!/bin/bash
set -e

ARCH_DIR="./ipk/x86_64"
mkdir -p "$ARCH_DIR"

echo "模拟构建 x86_64 插件..."
echo "fake x86_64 ipk file content" > "$ARCH_DIR/luci-app-passwall_$(date +%s)_x86_64.ipk"
