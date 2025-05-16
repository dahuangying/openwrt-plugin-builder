#!/bin/bash
BASE_DIR="./packages"
KEEP_NUM=10

echo "开始清理旧版本..."

for ARCH_DIR in "$BASE_DIR"/*/; do
  echo "处理目录：$ARCH_DIR"
  cd "$ARCH_DIR" || continue

  FILES_TO_DELETE=$(ls -1t *.ipk 2>/dev/null | tail -n +$((KEEP_NUM + 1)))

  if [[ -n "$FILES_TO_DELETE" ]]; then
    echo "删除旧文件："
    echo "$FILES_TO_DELETE"
    rm -f $FILES_TO_DELETE
  else
    echo "无旧文件需要删除"
  fi

  cd - > /dev/null
done

echo "清理完成！"


