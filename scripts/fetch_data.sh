#!/bin/bash
# 使用方法：export COOKIE="..." 或直接在此填入登录后的 Cookie
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
COOKIE="${COOKIE:-}"
URL="https://rd-task-board.workspace-663903.chatgpt.site/api/bootstrap"

if [ -z "$COOKIE" ]; then
  echo "请设置 COOKIE 环境变量（从浏览器 DevTools 复制）"
  exit 1
fi

curl -s -L -H "Cookie: $COOKIE" -H "User-Agent: Mozilla/5.0" "$URL" -o "$DIR/data/task.json.tmp"
python3 -c "import json; d=json.load(open('$DIR/data/task.json.tmp')); json.dump(d, open('$DIR/data/task.json','w'), ensure_ascii=False, indent=2)"
mkdir -p "$DIR/dist/data"
cp "$DIR/data/task.json" "$DIR/dist/data/task.json"
rm -f "$DIR/data/task.json.tmp"
echo "done"
