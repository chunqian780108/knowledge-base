#!/bin/bash
# ============================================
# 安装 macOS 自动同步定时任务
# ============================================
# 从脚本自身位置推导仓库路径，仓库可整体移动。
# 安装前会校验仓库是否位于 launchd 无权访问的受保护目录。
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$VAULT/scripts/sync-to-github.sh"
PLIST_SRC="$VAULT/scripts/com.chunqian.knowledge-base-sync.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist"
LABEL="com.chunqian.knowledge-base-sync"
UID_NUM="$(id -u)"

echo "📚 知识库自动同步 - 安装向导"
echo "================================"
echo "仓库位置：$VAULT"
echo ""

# ---------- 0. 守卫：仓库不能位于受 macOS TCC 保护的目录 ----------
# launchd 后台任务访问 iCloud Drive / 桌面 / 文档 / 下载 会返回
# "Operation not permitted"，任务必然失败，故直接拦截并给出迁移建议。
case "$VAULT" in
  *"/Library/Mobile Documents/"*)
    echo "❌ 无法安装：仓库位于 iCloud Drive 内。"
    echo "   macOS 不允许 launchd 后台任务读写 iCloud Drive（TCC 限制）。"
    echo ""
    echo "   请先迁移仓库，例如："
    echo "     ditto \"$VAULT\" \"$HOME/KnowledgeBase\" && rm -rf \"$VAULT\""
    echo "     bash \"$HOME/KnowledgeBase/scripts/install-sync.sh\""
    exit 1
    ;;
  "$HOME/Desktop"*|"$HOME/Documents"*|"$HOME/Downloads"*)
    echo "❌ 无法安装：仓库位于受保护目录（桌面/文档/下载）。"
    echo "   请移动到不受保护的位置，例如 $HOME/KnowledgeBase"
    exit 1
    ;;
esac

# ---------- 1. 脚本执行权限 ----------
chmod +x "$SCRIPT" "$VAULT/push-to-github.sh" 2>/dev/null || true
echo "✅ 同步脚本已就绪"

# ---------- 2. 远程仓库可达性（非交互，失败仅提示） ----------
if git -C "$VAULT" ls-remote origin &>/dev/null; then
  echo "✅ 远程仓库可达，凭证正常"
else
  echo ""
  echo "⚠️  无法访问远程仓库（凭证未配置或网络不可用）"
  echo "   首次使用请手动执行一次以保存凭证到钥匙串："
  echo "     cd \"$VAULT\" && git push origin main"
  echo "   用户名：chunqian780108"
  echo "   密码：你的 GitHub Personal Access Token"
  echo ""
fi

# ---------- 3. 由模板生成 plist（替换 __VAULT__ 占位符） ----------
mkdir -p "$HOME/Library/LaunchAgents"
sed "s|__VAULT__|$VAULT|g" "$PLIST_SRC" > "$PLIST_DST"
echo "✅ 定时任务配置已生成：$PLIST_DST"

# ---------- 4. 加载任务（现代 bootstrap 接口，兼容曾被 disable 的情况） ----------
launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
launchctl enable "gui/$UID_NUM/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_DST"
echo "✅ 定时任务已加载"

# ---------- 5. 验证：确认任务存在且首次运行未报错 ----------
sleep 3
if ! launchctl print "gui/$UID_NUM/$LABEL" >/dev/null 2>&1; then
  echo "❌ 安装失败：任务未出现在 launchd 中"
  exit 1
fi

LAST_EXIT="$(launchctl print "gui/$UID_NUM/$LABEL" 2>/dev/null \
  | awk -F'= ' '/last exit code/ {print $2}' | tr -d ' ')"

echo ""
if [ -n "$LAST_EXIT" ] && [ "$LAST_EXIT" != "0" ]; then
  echo "⚠️  任务已加载，但首次运行退出码为 $LAST_EXIT"
  echo "   查看错误日志："
  echo "     cat ~/Library/Logs/knowledge-base-sync-stderr.log"
  exit 1
fi

echo "🎉 安装成功！"
echo ""
echo "📋 同步规则："
echo "   - 每 30 分钟自动同步一次"
echo "   - 开机/登录后自动同步一次"
echo "   - 同步日志：~/Library/Logs/knowledge-base-sync.log"
echo ""
echo "🔧 常用命令："
echo "   查看状态：launchctl print gui/$UID_NUM/$LABEL"
echo "   立即同步：bash \"$SCRIPT\""
echo "   查看日志：tail -f ~/Library/Logs/knowledge-base-sync.log"
echo "   卸载任务：bash \"$VAULT/scripts/uninstall-sync.sh\""
