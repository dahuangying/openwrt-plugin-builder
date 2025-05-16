#!/bin/bash
# scripts/build_packages.sh
# ------------------
# 自动构建 Packages.gz 文件供 OpenWrt 插件源使用

set -e

# 支持的架构
ARCH_LIST=(
  "x86_64"
  "aarch64_cortex-a53"
)

# 根目录，假设你在项目根目录执行该脚本
BUILD_ROOT="$(pwd)"
PKGROOT="${BUILD_ROOT}/ipk"

for ARCH in "${ARCH_LIST[@]}"
do
  ARCH_DIR="${PKGROOT}/${ARCH}"
  if [ -d "$ARCH_DIR" ]; then
    echo "\n👉 正在为架构 $ARCH 构建 Packages.gz ..."
    cd "$ARCH_DIR"

    # 清理旧索引文件
    rm -f Packages Packages.gz

    # 构建 Packages 文件和压缩版本
    opkg-make-index . > Packages
    gzip -9nc Packages > Packages.gz

    echo "✅ $ARCH: Packages.gz 构建完成"
  else
    echo "⚠️ 目录 $ARCH_DIR 不存在，跳过"
  fi
  cd "$BUILD_ROOT"
done

