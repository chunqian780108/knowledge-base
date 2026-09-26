#!/bin/bash
# ============================================
# 卸载 macOS 自动同步定时任务
# ============================================

set -e

# 由脚本自身位置推导仓库路径
VAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PLIST_DST="$HOME/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist"
LABEL="com.chunqian.knowledge-base-sync"
UID_NUM="$(id -u)"

echo "📚 知识库自动同步 - 卸载"
echo "================================"
echo ""

# 卸载任务（bootout 对未加载的任务会返回非零，故忽略）
if launchctl print "gui/$UID_NUM/$LABEL" >/dev/null 2>&1; then
  launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
  echo "✅ 定时任务已停止"
else
  echo "ℹ️  定时任务未运行"
fi

# 禁用自动加载，避免下次登录时又被 launchd 拉起
launchctl disable "gui/$UID_NUM/$LABEL" 2>/dev/null || true

# 删除 plist 文件
if [ -f "$PLIST_DST" ]; then
  rm "$PLIST_DST"
  echo "✅ 配置文件已删除"
fi

echo ""
echo "👋 自动同步已关闭"
echo ""
echo "如需重新启用，运行："
echo "  bash \"$VAULT/scripts/install-sync.sh\""
