#!/bin/bash
# ============================================
# 知识库自动同步脚本
# ============================================
# 功能：
#   1. 拉取远程最新内容
#   2. 提交本地所有变更
#   3. 推送到 GitHub
#   4. 记录同步日志
#
# 日志位置：~/Library/Logs/knowledge-base-sync.log
# ============================================

set -eo pipefail

# 由脚本自身位置推导仓库根目录：仓库可整体移动，无需修改脚本
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$HOME/Library/Logs/knowledge-base-sync.log"
MAX_LOG_SIZE=1048576  # 1MB

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 日志轮转：如果日志超过 1MB，备份旧日志
if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
  mv "$LOG_FILE" "${LOG_FILE}.old"
fi

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "========== 开始同步 =========="

cd "$VAULT" || {
  log "❌ 错误：无法进入知识库目录"
  exit 1
}

# 检查 git 仓库
if ! git rev-parse --git-dir &>/dev/null; then
  log "❌ 错误：不是 git 仓库"
  exit 1
fi

# 检查远程仓库
if ! git remote get-url origin &>/dev/null; then
  log "❌ 错误：未配置远程仓库"
  exit 1
fi

# 1. 先提交本地变更
#    必须在 pull 之前：工作区有未提交改动时 git pull --rebase 一定会失败，
#    而知识库几乎每次同步都有改动，先 pull 会让这一步形同虚设。
git add -A
CHANGED=$(git status --porcelain | wc -l | xargs)

if [ "$CHANGED" -gt 0 ]; then
  log "📝 检测到 $CHANGED 个文件变更，正在提交..."
  if git commit -m "backup: $(date '+%Y-%m-%d %H:%M:%S') auto sync" 2>&1 | tee -a "$LOG_FILE"; then
    log "✅ 提交成功"
  else
    log "❌ 提交失败"
    exit 1
  fi
else
  log "ℹ️  没有新的变更需要提交"
fi

# 2. 再拉取远程更新，变基到本地提交之上
log "📥 拉取远程更新..."
if git pull --rebase origin main 2>&1 | tee -a "$LOG_FILE"; then
  log "✅ 拉取成功"
else
  log "⚠️  拉取失败，放弃变基以避免仓库停在冲突状态"
  git rebase --abort 2>/dev/null || true
fi

# 3. 推送到远程
log "🚀 推送到 GitHub..."
if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
  log "✅ 推送成功"
else
  log "❌ 推送失败"
  exit 1
fi

log "========== 同步完成 =========="
log ""

exit 0
