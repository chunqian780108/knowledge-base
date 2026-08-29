#!/bin/bash
# ============================================
# 安装 macOS 自动同步定时任务
# ============================================

set -e

VAULT="/Users/chq118/Library/Mobile Documents/com~apple~CloudDocs/KnowledgeBase"
SCRIPT="$VAULT/scripts/sync-to-github.sh"
PLIST_SRC="$VAULT/scripts/com.chunqian.knowledge-base-sync.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist"
LABEL="com.chunqian.knowledge-base-sync"

echo "📚 知识库自动同步 - 安装向导"
echo "================================"
echo ""

# 1. 给脚本添加执行权限
chmod +x "$SCRIPT"
echo "✅ 同步脚本已就绪"

# 2. 检查 git 凭证
if ! git -C "$VAULT" ls-remote origin &>/dev/null; then
  echo ""
  echo "⚠️  Git 凭证未配置"
  echo "   首次同步需要你手动执行一次 git push 来保存凭证到钥匙串"
  echo ""
  echo "   请运行："
  echo "   cd \"$VAULT\" && git push origin main"
  echo ""
  echo "   用户名：chunqian780108"
  echo "   密码：你的 GitHub Personal Access Token"
  echo ""
  read -p "完成后按回车继续... "
fi

# 3. 复制 plist 到 LaunchAgents
cp "$PLIST_SRC" "$PLIST_DST"
echo "✅ 定时任务配置已复制"

# 4. 加载定时任务
if launchctl list | grep -q "$LABEL"; then
  launchctl unload "$PLIST_DST" 2>/dev/null || true
fi

launchctl load "$PLIST_DST"
echo "✅ 定时任务已加载"

# 5. 验证
sleep 1
if launchctl list | grep -q "$LABEL"; then
  echo ""
  echo "🎉 安装成功！"
  echo ""
  echo "📋 同步规则："
  echo "   - 每 30 分钟自动同步一次"
  echo "   - 开机/登录后自动同步一次"
  echo "   - 同步日志：~/Library/Logs/knowledge-base-sync.log"
  echo ""
  echo "🔧 常用命令："
  echo "   查看状态：launchctl list | grep knowledge-base"
  echo "   立即同步：bash \"$SCRIPT\""
  echo "   查看日志：tail -f ~/Library/Logs/knowledge-base-sync.log"
  echo "   卸载任务：bash \"$VAULT/scripts/uninstall-sync.sh\""
else
  echo "❌ 安装失败，请检查配置"
  exit 1
fi
