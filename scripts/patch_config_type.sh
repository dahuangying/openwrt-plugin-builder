#!/bin/bash
set -e

echo "🔧 自动修复所有 Config.in 中缺少类型定义的 config 项..."

# 遍历所有 feeds 的 luci-app 插件目录
for config_file in feeds/*/luci-app-*/Config.in; do
    [ -f "$config_file" ] || continue
    echo "处理: $config_file"

    # 对每个没有类型定义的 config 项添加 bool 类型
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

echo "✅ 所有 Config.in 修复完成"
