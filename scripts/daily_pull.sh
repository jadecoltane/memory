#!/bin/bash
# 每天自动 git pull 记忆库,防止 Mac 上没开 Obsidian 时云端的更新
# (每日工作台、GC 等 GitHub Actions 产物)一直没拉下来,手机通过
# iCloud 也就一直看不到最新内容。
# 由 launchd 调度:~/Library/LaunchAgents/com.jade.memory-daily-pull.plist
# (每天 07:00,睡眠错过就在下次唤醒时补跑;plist 不在仓库里,重装机器
# 时按本文件头部注释重建)。
# 兜底优先:失败弹 macOS 通知 + 全程写日志,不允许静默失败。
set -u

VAULT="/Users/peiyaohuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/memory"
LOG="$HOME/Library/Logs/memory-daily-pull.log"

notify() {
  /usr/bin/osascript -e "display notification \"$1\" with title \"记忆库自动拉取\"" || true
}

{
  echo "=== $(date '+%F %T') ==="
  cd "$VAULT" || { notify "找不到 vault 目录,pull 没跑"; echo "cd failed"; exit 1; }
  export GIT_TERMINAL_PROMPT=0
  if git pull --no-rebase; then
    echo "pull ok"
  else
    notify "git pull 失败,详见 ~/Library/Logs/memory-daily-pull.log"
    echo "pull FAILED"
    exit 1
  fi
} >> "$LOG" 2>&1
