#!/bin/bash
for dir in "$GITHUB_WORKSPACE/ipk/"*/; do
  find "$dir" -name '*.ipk' -printf '%T@ %p\n' | sort -nr | tail -n +16 | cut -d' ' -f2- | xargs -r rm -f
done



