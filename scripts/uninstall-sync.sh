#!/bin/bash
# ============================================
# 卸载 macOS 自动同步定时任务
# ============================================

set -e

PLIST_DST="$HOME/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist"
LABEL="com.chunqian.knowledge-base-sync"

echo "📚 知识库自动同步 - 卸载"
echo "================================"
echo ""

# 卸载任务
if launchctl list | grep -q "$LABEL"; then
  launchctl unload "$PLIST_DST" 2>/dev/null || true
  echo "✅ 定时任务已卸载"
else
  echo "ℹ️  定时任务未运行"
fi

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
