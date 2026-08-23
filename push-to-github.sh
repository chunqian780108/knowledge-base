#!/bin/bash
# ============================================
# 知识库 Git 推送脚本
# ============================================
# 用法：在终端中运行 bash push-to-github.sh
#
# 前提条件：
#   1. 已在 GitHub 上创建名为 knowledge-base 的仓库
#   2. 已创建 Personal Access Token (PAT)
#
# 创建 PAT 的步骤：
#   1. 访问 https://github.com/settings/tokens
#   2. 点击 "Generate new token (classic)"
#   3. 勾选 "repo" 权限
#   4. 生成后复制 token
#
# 首次运行时会提示输入用户名和密码：
#   - Username: chunqian780108
#   - Password: 粘贴你的 PAT token
#   - 之后会自动保存到 macOS 钥匙串，无需重复输入
# ============================================

set -e

VAULT="/Users/chq118/Library/Mobile Documents/com~apple~CloudDocs/KnowledgeBase"
cd "$VAULT"

echo "📚 知识库 Git 推送工具"
echo "========================"
echo ""

# 检查远程仓库是否已配置
if ! git remote get-url origin &>/dev/null; then
  echo "⚠️  远程仓库未配置，请先运行："
  echo "   git remote add origin https://github.com/chunqian780108/knowledge-base.git"
  exit 1
fi

echo "远程仓库: $(git remote get-url origin)"
echo ""

# 添加所有变更
git add -A
CHANGED=$(git status --porcelain | wc -l | xargs)

if [ "$CHANGED" -gt 0 ]; then
  echo "📝 有 $CHANGED 个文件变更，正在提交..."
  git commit -m "backup: $(date '+%Y-%m-%d %H:%M:%S') auto backup"
  echo "✅ 提交完成"
else
  echo "ℹ️  没有新的变更需要提交"
fi

echo ""
echo "🚀 推送到远程仓库..."
echo ""

# 尝试推送
if git push -u origin main 2>&1; then
  echo ""
  echo "✅ 推送成功！你的知识库已备份到 GitHub。"
  echo ""
  echo "📋 仓库地址: https://github.com/chunqian780108/knowledge-base"
else
  echo ""
  echo "❌ 推送失败，可能的原因："
  echo ""
  echo "  1. 仓库尚未创建 → 访问 https://github.com/new 创建 knowledge-base 仓库"
  echo "  2. 需要输入凭证 → 运行时会提示，用户名填 chunqian780108，密码填 PAT token"
  echo "  3. 创建 PAT → 访问 https://github.com/settings/tokens 勾选 repo 权限"
  echo ""
  echo "  创建仓库后重新运行此脚本即可。"
fi
