---
tags:
  - 知识库
  - GitHub
  - 同步
created: 2026-08-29
updated: 2026-08-29
---

# GitHub 知识库同步规则

## 仓库信息

- **仓库地址**：https://github.com/chunqian780108/knowledge-base
- **可见性**：私有（Private）
- **主分支**：main

## 同步层级

### 第一层：Obsidian 插件自动同步（推荐，最常用）

通过 Obsidian Git 插件实现，打开 Obsidian 时生效。

| 触发方式 | 频率/时机 | 动作 |
|---------|----------|------|
| 定时备份 | 每 10 分钟 | 自动提交本地变更到 git |
| 定时推送 | 每 30 分钟 | 自动推送到 GitHub |
| 定时拉取 | 每 30 分钟 | 自动从 GitHub 拉取最新内容 |
| 文件保存后 | 每次保存 | 自动提交本地变更 |
| 文件变更后 | 每次变更 | 自动提交本地变更 |
| 打开 Obsidian 时 | 启动时 | 自动从 GitHub 拉取 |
| 关闭 Obsidian 时 | 退出前 | 自动提交并推送 |

**提交信息格式**：`backup: YYYY-MM-DD HH:mm:ss auto backup`

### 第二层：macOS 系统定时同步（备用方案）

通过 launchd 定时任务实现，即使不打开 Obsidian 也会自动同步。

| 项目 | 配置 |
|------|------|
| 同步频率 | 每 30 分钟 |
| 启动触发 | 登录后自动执行一次 |
| 同步动作 | 拉取 → 提交 → 推送 |
| 日志位置 | `~/Library/Logs/knowledge-base-sync.log` |

**安装方法**：
```bash
bash /Users/chq118/Library/Mobile Documents/com~apple~CloudDocs/KnowledgeBase/scripts/install-sync.sh
```

**卸载方法**：
```bash
bash /Users/chq118/Library/Mobile Documents/com~apple~CloudDocs/KnowledgeBase/scripts/uninstall-sync.sh
```

### 第三层：手动同步

#### macOS 终端
```bash
# 一键同步脚本
bash /Users/chq118/Library/Mobile Documents/com~apple~CloudDocs/KnowledgeBase/push-to-github.sh
```

#### Obsidian 快捷键
- `Ctrl/Cmd + P` → 输入 "Git: Push" 手动推送
- `Ctrl/Cmd + P` → 输入 "Git: Pull" 手动拉取
- `Ctrl/Cmd + P` → 输入 "Git: Create backup" 手动备份

## 凭证管理

- **存储位置**：macOS 钥匙串（Keychain）
- **用户名**：`x-access-token`
- **凭证助手**：`osxkeychain`
- **凭证验证**：`git ls-remote origin`

## 同步冲突处理

1. **自动合并**：Obsidian Git 使用 merge 策略，大多数情况下自动合并
2. **冲突文件**：如果同一行内容被两端同时修改，会产生冲突
3. **解决方法**：
   - 打开冲突文件，查找 `<<<<<<<` 标记
   - 选择保留哪一端的内容
   - 删除所有冲突标记（`<<<<<<<`、`=======`、`>>>>>>>`）
   - 保存后提交并推送

## 忽略规则（.gitignore）

以下文件不会同步到 GitHub：

- Obsidian 工作区配置（workspace.json 等）
- 插件缓存和日志
- 系统临时文件（.DS_Store 等）
- Excalidraw 临时文件
- *.tmp、*.bak、*.swp 等临时文件

## 常用命令

```bash
# 查看同步状态
git status

# 查看提交历史
git log --oneline -10

# 手动同步（提交+推送）
git add -A
git commit -m "描述"
git push origin main

# 手动拉取最新内容
git pull origin main

# 查看 launchd 任务状态
launchctl list | grep knowledge-base

# 查看同步日志
tail -f ~/Library/Logs/knowledge-base-sync.log
```

## 故障排查

### 推送失败
1. 检查网络连接
2. 验证凭证：`git ls-remote origin`
3. 查看详细错误：`git push origin main -v`

### 凭证过期
重新生成 Personal Access Token 后，运行一次 `git push`，系统会提示输入新凭证。

### launchd 任务不运行
1. 检查任务是否加载：`launchctl list | grep knowledge-base`
2. 查看错误日志：`cat ~/Library/Logs/knowledge-base-sync-stderr.log`
3. 重新加载：`launchctl unload ~/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist && launchctl load ~/Library/LaunchAgents/com.chunqian.knowledge-base-sync.plist`
