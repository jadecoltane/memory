#!/bin/bash
# 本地定时 git 同步:拉取远端最新(让工作台等云端生成内容保持新鲜),
# 再把本地手动编辑的改动提交推送回 GitHub。只由 launchd 定时触发,
# 不依赖 Obsidian 的 Git 插件,避免和其他进程同时读写 .git。
set -e

VAULT="/Users/peiyaohuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/memory"
LOG="$VAULT/scripts/local_git_sync.log"

cd "$VAULT"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG"

git pull --no-rebase origin main >> "$LOG" 2>&1

git add -A
if ! git diff --cached --quiet; then
  git commit -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG" 2>&1
  git push origin main >> "$LOG" 2>&1
  echo "已提交并推送" >> "$LOG"
else
  echo "无本地改动,跳过提交" >> "$LOG"
fi
