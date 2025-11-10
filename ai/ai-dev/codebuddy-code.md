<!--
markmeta_author: titlwind
markmeta_date: 2025-11-07
markmeta_title: CodeBuddy Code Development
markmeta_categories: ai
markmeta_tags: ai,codebuddy
-->

# CodeBuddy Code Development


-------------
## 1. install

```bash
npm install -g @tencent-ai/codebuddy-code
codebuddy --version

cd /path/to/your/project
codebuddy

> 我想给这个 React 组件添加一个加载状态
> 帮我重构这个函数，让它更易读
> 这段代码有什么潜在的性能问题？
> 为这个 API 接口写单元测试

# 添加到 ~/.bashrc 或 ~/.zshrc
alias cb="codebuddy"
alias cbp="codebuddy -p"
alias cbr="codebuddy --resume"

# 使用
cb "快速分析这个错误"
cbp "设计数据库架构"
cbr  # 恢复上次会话

# 查看当前配置
codebuddy config list

# 设置默认模型
codebuddy config set model gpt-5

# 获取特定配置
codebuddy config get model

# 命令行参数 (最高优先级)
├── 项目本地设置 (./.codebuddy/settings.local.json) # 不提交 (添加到 .gitignore)
├── 项目共享设置 (./.codebuddy/settings.json)       # 提交到 Git
└── 用户设置 (~/.codebuddy/settings.json)          # (最低优先级)

```

配置范例:

```json
{
  "model": "gpt-5",
  "cleanupPeriodDays": 30,
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "true"
  },
  "includeCoAuthoredBy": false,
  "permissions": {
    "allow": [
      "Read",                          // 允许读取文件
      "Edit",                          // 允许编辑文件
      "Bash(git:*)",                   // 允许所有 git 命令
      "Bash(npm:install,npm:test)",    // 允许特定 npm 命令
      "Edit(src/**/*.js)"              // 只允许编辑 src 目录下的 JS 文件
    ],
    "ask": [
      "Bash(curl:*)",                  // 询问后允许 curl 命令
      "WebFetch",                      // 询问后允许网络请求
      "Bash(docker:*)"                 // 询问后允许 Docker 命令
    ],
    "deny": [
      "Bash(rm:*)",                    // 禁止删除命令
      "Bash(sudo:*)",                  // 禁止 sudo 命令
      "Edit(**/*.env)",                // 禁止编辑环境变量文件
      "Read(/etc/**)"                  // 禁止读取系统配置文件
    ],
    "additionalDirectories": ["/tmp", "/var/log"],
    "defaultMode": "default"
  },
  "hooks": {
    "PreToolUse": "echo 'About to use tool: $TOOL_NAME'"
  },
  "enableAllProjectMcpServers": false,
  "enabledMcpjsonServers": ["filesystem", "git"],
  "disabledMcpjsonServers": ["dangerous-tool"],
  "autoCompactEnabled": true,
  "autoUpdates": true,
  "apiKeyHelper": "/usr/local/bin/get-api-key.sh"
}
```


-------------
## 2. 单次命令模式

```bash
# 直接提问
codebuddy -p "优化这个 SQL 查询的性能"

# 管道输入
cat error.log | codebuddy -p "分析这些错误日志"

# 文件分析（需要授权时必须添加 --dangerously-skip-permissions）
codebuddy -p "审查 src/utils.js 的代码质量" --dangerously-skip-permissions

# 项目重构（需要文件操作授权）
codebuddy -p "将所有组件从 class 组件迁移到函数组件" --dangerously-skip-permissions

# 代码规范（需要文件读取授权）
codebuddy -p "检查整个项目的 TypeScript 类型定义" --dangerously-skip-permissions

# 测试覆盖（需要文件操作授权）
codebuddy -p "为 services 目录下的所有文件添加单元测试" --dangerously-skip-permissions


```

## 3. 会话

```bash
# 恢复最近的对话
codebuddy --resume

# 恢复特定的对话会话
codebuddy --resume session-id-12345

```


## 4. 常见工作流

```bash
codebuddy
# 分析这个界面设计
# [拖拽图片到终端] # 自动识别图像文件并处理

> 根据这个设计稿实现 React 组件 @/path/to/design.png

# macOS
pbpaste | codebuddy -p "这个错误信息是什么意思？"

# 审查单个文件
codebuddy -p "审查这个文件的代码质量" src/components/UserForm.tsx

# 审查整个提交
git diff HEAD~1 | codebuddy -p "审查这次提交的代码变更"

# 审查 Pull Request
gh pr diff 123 | codebuddy -p "分析这个 PR 的影响和风险"

# 生成审查报告（JSON格式便于后续处理）
codebuddy -p "生成详细的代码审查报告" --output-format json > report.json

# 检查编码规范
codebuddy -p "检查 src/ 目录是否遵循团队的编码规范"
```

## 5. 自定义斜杠命令

自定义命令通过在特定目录中创建 .md (Markdown) 文件来定义。

- 项目级命令: 在您的项目根目录下创建 `.codebuddy/commands/` 文件夹。此处的命令对所有项目协作者可用。
- 个人全局命令: 在您的用户主目录下创建 `~/.codebuddy/commands/` 文件夹。此处的命令在您所有的项目中都可用。

创建一个命令,只需在上述任一目录中添加一个 .md 文件即可。例如,test.md 文件会自动注册为 /test 命令。

子目录命令:
```bash
commands/test.md → /test
commands/frontend/build.md → /frontend:build
commands/backend/deploy/staging.md → /backend:deploy:staging
```

-------------
范例1:
```
---
description: "为我的项目运行单元测试并报告结果。"
argument-hint: "[test-file]"
---

请为我运行 `npm run test -- [test-file]` 命令,并总结测试结果。如果未提供测试文件,则运行所有测试。
```

-------------
范例2:
```
---
description: "发送一个可定制的问候。"
argument-hint: "[name]"
---

向 **$1** 说"你好！"。如果 $1 为空,则向"世界"问好。
```

-------------
范例3:

```
---
description: "显示当前的 git 仓库状态并进行分析。"
---

!`git status`

请基于上面的 `git status` 输出,为我总结当前分支的状况。
```

## 6. 记忆

记忆范围
- 用户级（user）：存放与个人长期偏好和习惯相关的信息
- 项目级（project）：存放与当前项目共享的通用信息
对应文件位置：
- 用户级：~/.codebuddy/CODEBUDDY.md
- 项目级：./CODEBUDDY.md
记忆内容以章节形式追加到文件中的 `## CodeBuddy Added Memories` 段落。

记忆引用文件:
```
## CodeBuddy Added Memories
@./docs/team-conventions.md
- 项目默认分支为 main
```


## 7. sub-agents
支持两级来源，按优先级智能合并：
- 项目级：.codebuddy/agents/
- 个人全局：~/.codebuddy/agents/

标签:
- (project)：来自项目根的 .codebuddy/agents 目录
- (project:review)：来自 .codebuddy/agents/review/ 子目录
- (user)：来自 ~/.codebuddy/agents 目录
- (user:experiments:lint)：来自 ~/.codebuddy/agents/experiments/lint/ 子目录
该标签会自动拼接到 description 末尾，例如：代码审阅 (project:review)


范例1
```
---
name: "my-agent"
description: "负责代码审阅与建议"
model: "gpt-4o"
tools: "bash,fs,github"
color: "#4A90E2"
---

这里是该子代理的系统指令与工作说明……
```

