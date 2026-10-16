#!/bin/bash
# 使用方法：将 Cookie 写入 scripts/.cookie 文件（第一行即可）或设置 COOKIE 环境变量
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
COOKIE_FILE="$DIR/scripts/.cookie"
COOKIE="${COOKIE:-}"

if [ -z "$COOKIE" ] && [ -f "$COOKIE_FILE" ]; then
  COOKIE=$(head -n 1 "$COOKIE_FILE" | sed 's/[[:space:]]*$//')
fi

URL="https://rd-task-board.workspace-663903.chatgpt.site/api/bootstrap"

if [ -z "$COOKIE" ]; then
  echo "请设置 COOKIE 环境变量或将 Cookie 写入 scripts/.cookie"
  exit 1
fi

curl -s -L -H "Cookie: $COOKIE" -H "User-Agent: Mozilla/5.0" "$URL" -o "$DIR/data/task.json.tmp"
python3 -c "import json; d=json.load(open('$DIR/data/task.json.tmp')); json.dump(d, open('$DIR/data/task.json','w'), ensure_ascii=False, indent=2)"
mkdir -p "$DIR/dist/data"
cp "$DIR/data/task.json" "$DIR/dist/data/task.json"
rm -f "$DIR/data/task.json.tmp"
echo "done"
