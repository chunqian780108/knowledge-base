# ============================================
# 知识库 Git 推送脚本 (Windows PowerShell 版)
# ============================================
# 用法：右键点击 → "使用 PowerShell 运行"
#   或在 PowerShell 中执行：powershell -ExecutionPolicy Bypass -File push-to-github.ps1
#
# 前提条件：
#   1. 已安装 Git for Windows (https://git-scm.com/download/win)
#   2. 已创建 GitHub Personal Access Token
#   3. 已 git clone 本仓库到本地
# ============================================

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "📚 知识库 Git 推送工具 (Windows)" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# 检查远程仓库是否已配置
$remoteUrl = git remote get-url origin 2>$null
if (-not $remoteUrl) {
    Write-Host "⚠️  远程仓库未配置，请先运行：" -ForegroundColor Yellow
    Write-Host "   git remote add origin https://github.com/chunqian780108/knowledge-base.git"
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "远程仓库: $remoteUrl"
Write-Host ""

# 添加所有变更
git add -A
$changed = (git status --porcelain).Count

if ($changed -gt 0) {
    Write-Host "📝 有 $changed 个文件变更，正在提交..." -ForegroundColor Yellow
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    git commit -m "backup: $date auto backup"
    Write-Host "✅ 提交完成" -ForegroundColor Green
} else {
    Write-Host "ℹ️  没有新的变更需要提交" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🚀 推送到远程仓库..." -ForegroundColor Cyan
Write-Host ""

git push -u origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 推送成功！你的知识库已备份到 GitHub。" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 仓库地址: https://github.com/chunqian780108/knowledge-base"
} else {
    Write-Host ""
    Write-Host "❌ 推送失败，可能的原因：" -ForegroundColor Red
    Write-Host ""
    Write-Host "  1. 需要输入凭证 → 首次会弹出输入框，用户名填 chunqian780108，密码填 PAT"
    Write-Host "  2. 创建 PAT → https://github.com/settings/tokens → 勾选 repo 权限"
    Write-Host ""
    Write-Host "  首次运行后凭证自动保存到 Windows 凭据管理器，之后无需重复输入"
}

Write-Host ""
Read-Host "按回车键退出"
