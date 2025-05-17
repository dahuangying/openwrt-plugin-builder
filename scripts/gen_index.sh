#!/bin/bash
OUT="$GITHUB_WORKSPACE/index.html"
echo "<html><body><h2>插件下载</h2><ul>" > "$OUT"

for dir in "$GITHUB_WORKSPACE/ipk/"*/; do
  arch=$(basename "$dir")
  echo "<li><a href=\"$arch/\">$arch 点击进入</a></li>" >> "$OUT"
done

echo "</ul></body></html>" >> "$OUT"
