#!/bin/bash

# 需要清理的插件根目录
BASE_DIR="./packages"

# 保留最新多少个版本
KEEP_NUM=10

echo "开始清理旧版本..."

for ARCH_DIR in "$BASE_DIR"/*/; do
  echo "处理平台目录：$ARCH_DIR"
  cd "$ARCH_DIR" || continue

  # 找出所有ipk文件，按修改时间倒序排序，保留前KEEP_NUM个，其他删除
  FILES_TO_DELETE=$(ls -1t *.ipk 2>/dev/null | tail -n +$((KEEP_NUM+1)))

  if [[ -z "$FILES_TO_DELETE" ]]; then
    echo "无需要清理的文件"
  else
    echo "删除旧文件："
    echo "$FILES_TO_DELETE"
    # 安全删除，避免文件名空格等问题
    echo "$FILES_TO_DELETE" | xargs -r -d '\n' rm -f --
  fi

  cd - > /dev/null || exit
done

echo "清理完成！"

