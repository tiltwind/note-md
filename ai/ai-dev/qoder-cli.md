<!--
markmeta_author: tiltwind
markmeta_date: 2026-04-23
markmeta_title: Qoder CLI 使用指南
markmeta_categories: ai
markmeta_tags: ai,qoder,cli,agent
-->

# Qoder CLI 使用指南

Qoder CLI (`qoder`) 是 Qoder 的终端 AI 编程助手，支持交互模式、无交互批量执行、Quest 自主编码模式等多种用法。

## 1. 安装与更新

```bash
curl -fsSL https://qoder.com/install | bash
ln -sf /Users/hk/.local/bin/qodercli /Users/hk/.local/bin/qoder

# 自更新到最新版本
qoder update

# 查看版本
qoder -v

# 查看账户与 CLI 状态
qoder status
```

## 2. 基本启动

```bash
# 交互模式（默认）
qoder

# 指定工作目录启动
qoder -w /path/to/project

# 继续上次会话
qoder -c

# 恢复指定会话（提供 session ID）
qoder -r <session-id>
```

## 3. 无交互模式（Headless / Print 模式）

通过 `-p` / `--print` 参数指定 prompt，执行完毕后直接退出，适合脚本自动化。

```bash
# 执行单条 prompt 并输出结果
qoder -p "解释这段 Go 代码的并发模型"

# 指定工作目录并执行
qoder -w /path/to/project -p "列出所有 TODO 注释"

# 输出为 JSON 格式（便于脚本解析）
qoder -p "分析 main.go 中的函数" -f json

# 流式 JSON 输出
qoder -p "重构 utils.go" -f stream-json

# 静默模式（隐藏 spinner）
qoder -p "生成单元测试" -q

# 限制 agent 最大迭代轮次（防止无限循环）
qoder -p "修复所有 lint 错误" --max-turns 20

# 管道组合使用
echo "优化以下 SQL 查询：$(cat query.sql)" | qoder -p -
```

## 4. 权限控制

### 4.1 跳过所有权限确认（YOLO 模式）

`--yolo` / `--dangerously-skip-permissions` 跳过所有工具执行的权限弹窗，自动批准所有操作。**仅在受信任环境中使用。**

```bash
# 跳过权限确认，自动执行所有操作
qoder --yolo

# 结合 print 模式实现全自动执行
qoder --yolo -p "修复 src/ 下所有 TypeScript 类型错误"

# CI/CD 场景中常用写法
qoder --dangerously-skip-permissions -p "运行测试并修复失败用例" --max-turns 30
```

### 4.2 指定允许/禁止的工具

通过 `--allowed-tools` 和 `--disallowed-tools` 精确控制本次会话可用的工具范围。

```bash
# 只允许读取文件和搜索（只读模式）
qoder --allowed-tools "Read,Grep,Glob" -p "找出所有使用了废弃 API 的地方"

# 允许读写但禁止执行 Shell 命令
qoder --allowed-tools "Read,Edit,Write,Grep"

# 禁止网络访问
qoder --disallowed-tools "WebSearch,WebFetch"

# 只允许 git 相关操作
qoder --allowed-tools "Bash,Read" -p "提交并推送当前更改"
```

### 4.3 通过配置文件持久化权限规则

配置文件路径（优先级从低到高）：
1. `~/.qoder/settings.json` — 用户全局配置
2. `<project>/.qoder/settings.json` — 项目共享配置
3. `<project>/.qoder/settings.local.json` — 项目本地配置（不提交 Git）

支持三种策略：**Allow**（直接执行）、**Deny**（直接拒绝）、**Ask**（弹窗确认）。

```json
{
  "permissions": {
    "allow": [
      "Read(~/**)",
      "Edit(~/workspaces/**)",
      "Write(~/workspaces/**)",
      "WebSearch",
      "WebFetch",
      "Bash(git *)",
      "Bash(npm run *)",
      "Bash(go *)",
      "Bash(make *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ],
    "ask": [
      "Bash(docker *)"
    ]
  }
}
```

常用权限规则速查：

| 规则 | 说明 |
| :--- | :--- |
| `Read(~/workspaces/**)` | 允许读取工作区所有文件 |
| `Edit(~/workspaces/**)` | 允许编辑工作区所有文件 |
| `Write(~/workspaces/**)` | 允许写入/创建工作区文件 |
| `WebSearch` | 允许网页搜索 |
| `WebFetch` | 允许网页抓取 |
| `Bash(git *)` | 允许所有 git 命令 |
| `Bash(npm run *)` | 允许所有 npm run 脚本 |
| `Bash(go *)` | 允许所有 go 命令 |
| `Bash(docker *)` | 允许所有 docker 命令 |
| `Bash(make *)` | 允许所有 make 命令 |

## 5. Quest 模式（自主编码）

Quest Mode 是多 Agent 协作的自主开发模式，能够从需求到代码完整执行，包括需求澄清、方案设计、编码、测试。

### 5.1 在 TUI 中启用 Quest

在交互会话中输入：

```
/quest
```

### 5.2 通过命令行直接触发 Quest

```bash
# headless 模式启动 Quest
qoder -p "/quest"

# Quest + 具体任务描述
qoder -p "/quest 实现用户注册和登录的 REST API，使用 Go + Gin 框架"

# Quest + 跳过权限确认（全自动）
qoder --yolo -p "/quest 添加单元测试覆盖 service 层所有方法"

# Quest + 限制轮次
qoder --yolo -p "/quest 重构 database 包，使用连接池" --max-turns 50
```

## 6. 模型选择

```bash
# 使用指定模型档位启动
qoder --model ultimate         # 最强模型
qoder --model performance      # 性能模型
qoder --model efficient        # 效率模型（速度快、成本低）
qoder --model auto             # 自动选择（默认）

# 结合 print 模式
qoder --model efficient -p "生成这个函数的注释"
```

模型档位参考：

| 档位 | 说明 |
| :--- | :--- |
| `ultimate` | 最强推理，适合复杂架构设计 |
| `performance` | 高性能，适合复杂编码任务 |
| `efficient` | 高效率，适合简单问答和注释 |
| `auto` | 自动根据任务选择（默认） |

## 7. 并发任务（Worktree 模式）

通过 `--worktree` 在独立 git worktree 中并行运行任务，不影响当前工作区。

```bash
# 在新 worktree 中执行任务
qoder --worktree -p "实现功能 A"

# 指定 worktree 分支名
qoder --worktree --branch feature/new-api -p "开发新 API 端点"

# 指定 worktree 路径
qoder --worktree --path /tmp/my-worktree -p "重构模块 B"

# 查看正在运行的并发任务
qoder jobs

# 移除已完成的任务
qoder rm <job-id>
```

## 8. ACP 协议模式（IDE 集成）

通过 ACP (Agent Client Protocol) 将 qoder 作为服务端运行，供 IDE 或其他工具调用。

```bash
# 启动 ACP 服务
qoder --acp

# 结合权限控制启动 ACP
qoder --acp --yolo
```

## 9. 附件与多模态输入

```bash
# 附加图片文件（可多次指定）
qoder --attachment screenshot.png -p "分析这个 UI 截图的问题"

# 同时附加多个文件
qoder --attachment error.png --attachment schema.png -p "根据截图修复布局"
```

## 10. 输出控制

```bash
# 限制输出 token 数量
qoder --max-output-tokens 32k -p "生成完整的 API 文档"
qoder --max-output-tokens 16k -p "生成单元测试"

# 指定输入格式（适合流式管道）
qoder --input-format stream-json -p "处理输入"
```

## 11. 加载 Claude Code 兼容配置

```bash
# 加载 .claude/ 目录下的 skills、commands、subagents 配置
qoder --with-claude-config

# 常见用途：复用已有 Claude Code 项目的 skills 和命令
qoder --with-claude-config -p "/custom-command 执行自定义任务"
```

## 12. Skills（技能）

Qoder 的 Skill 是一类可被模型自动触发的能力扩展。一个 Skill 本质上就是一个目录，入口文件为 `SKILL.md`；当用户请求与 `description` 匹配时，Qoder 会自动加载并使用它。

### 12.1 Skill 目录与优先级

| 位置 | 路径 | 作用域 |
| :--- | :--- | :--- |
| 用户级 | `~/.qoder/skills/{skill-name}/SKILL.md` | 当前用户的所有项目 |
| 项目级 | `.qoder/skills/{skill-name}/SKILL.md` | 当前项目 |

同名冲突时，**项目级 Skill 优先于用户级 Skill**。

### 12.2 Skill 最小示例

```md
---
name: api-doc-generator
description: Generate API documentation from code. Use when documenting endpoints, request/response schema, or OpenAPI specs.
---

# API Documentation Generator

1. Identify routes and handlers
2. Extract request / response schema
3. Describe authentication and error handling
4. Generate examples when needed
```

其中：

| 字段 | 必填 | 说明 |
| :--- | :--- | :--- |
| `name` | 是 | Skill 唯一标识，只能用小写字母、数字和连字符 |
| `description` | 是 | 告诉模型“这个 Skill 什么时候该被触发” |

### 12.3 常见目录结构

```text
<skill-name>/
  SKILL.md
  REFERENCE.md
  EXAMPLES.md
  scripts/
  templates/
```

只有 `SKILL.md` 是必需的，其他文件通常作为渐进加载的参考资料或辅助脚本存在。

### 12.4 查看与调用 Skills

```bash
# 在 TUI 中查看可用 Skills
/skills

# 手动触发某个 Skill
/api-doc-generator

# 查看本地 Skill 文件
ls ~/.qoder/skills/*/SKILL.md
ls .qoder/skills/*/SKILL.md
```

## 13. Subagent（子代理）

Subagent 是 Qoder 中的专用子代理，拥有独立上下文窗口、单独的系统提示词和可选的工具权限，适合把复杂任务拆给不同角色处理。

### 13.1 内置与自定义 Subagent

官方文档列出的内置 Subagent 包括：

| 名称 | 用途 |
| :--- | :--- |
| `code-reviewer` | 本地代码审查 |
| `design-agent` | 产出设计方案和设计文档 |
| `general-purpose` | 通用任务处理 |
| `task-executor` | 按设计文档执行开发 |

在 TUI 里可以通过 `/agents` 查看 BuiltIn、User、Project 三类 agent。

### 13.2 Subagent 目录与优先级

| 位置 | 路径 | 优先级 |
| :--- | :--- | :--- |
| 项目级 | `.qoder/agents/<agentName>.md` | 高 |
| 用户级 | `~/.qoder/agents/<agentName>.md` | 低 |

同名冲突时，**项目级 Subagent 优先于用户级 Subagent**。

### 13.3 Subagent 配置示例

```md
---
name: api-reviewer
description: Review API designs for RESTful compliance and best practices.
tools: Read,Grep,Glob
---

You are an expert API design reviewer specializing in RESTful API conventions.

Focus on:
1. Resource naming
2. HTTP method selection
3. Status code usage
4. URL hierarchy and versioning
5. Response and error format consistency
```

字段说明：

| 字段 | 必填 | 说明 |
| :--- | :--- | :--- |
| `name` | 是 | Subagent 唯一名称 |
| `description` | 是 | 子代理职责描述，供模型匹配使用 |
| `tools` | 否 | 逗号分隔的工具列表；缺省时继承主 Agent 的全部工具 |

### 13.4 使用方式

```bash
# 在 TUI 中查看 / 创建 agent
/agents

# 显式指定 subagent
qoder -p "Use the code-reviewer subagent to review this code"

# 让模型隐式选择 subagent
qoder -p "Review this code"

# 链式调用多个 subagent
qoder -p "First use general-purpose subagent to complete the design, then use code-reviewer subagent to review the generated code" --max-turns 10
```

## 14. 配置目录与关键文件

Qoder CLI 的常用本地目录与文件主要分成权限设置、记忆、MCP、命令、Skills、Subagents 六类。

| 位置 | 用途 |
| :--- | :--- |
| `~/.qoder/settings.json` | 用户级配置，适用于所有项目 |
| `.qoder/settings.json` | 项目级共享配置，可提交到 Git |
| `.qoder/settings.local.json` | 项目本地配置，优先级最高，通常加入 `.gitignore` |
| `~/.qoder/AGENTS.md` | 用户级记忆文件 |
| `AGENTS.md` | 项目级记忆文件 |
| `~/.qoder.json` | 用户级 MCP 配置文件 |
| `.mcp.json` | 项目级 MCP 配置文件 |
| `~/.qoder/commands/*.md` | 用户级自定义命令 |
| `.qoder/commands/*.md` | 项目级自定义命令 |
| `~/.qoder/skills/<skill-name>/SKILL.md` | 用户级 Skill |
| `.qoder/skills/<skill-name>/SKILL.md` | 项目级 Skill |
| `~/.qoder/agents/<agentName>.md` | 用户级 Subagent |
| `.qoder/agents/<agentName>.md` | 项目级 Subagent |

### 14.1 settings.json 负责什么

`settings.json` 主要承载：

1. 权限控制（`permissions`）
2. Hooks 配置（`hooks`）
3. 其他用户 / 项目级行为设置

优先级从低到高依次为：

```bash
~/.qoder/settings.json
.qoder/settings.json
.qoder/settings.local.json
```

### 14.2 MCP 配置文件在哪里

通过 `qoder mcp add` 添加的 MCP Server，会落到下面两个文件之一：

```bash
# 用户级 / 不提交
~/.qoder.json

# 项目级 / 通常提交
.mcp.json
```

### 14.3 记忆文件在哪里

Qoder CLI 会自动加载 `AGENTS.md` 作为记忆上下文：

```bash
# 用户级
~/.qoder/AGENTS.md

# 项目级
AGENTS.md
```

可以在 TUI 中通过 `/init` 初始化项目级记忆文件，或者通过 `/memory` 进行编辑。

## 15. 自定义 Agent

```bash
# 通过 JSON 定义临时 agent
qoder --agents '{"reviewer": {"description": "代码审查专家", "prompt": "你是一名专注于安全性和性能的代码审查员"}}' \
  -p "审查 auth.go 中的安全问题"
```

## 16. MCP 服务器管理

```bash
# 列出已配置的 MCP 服务器
qoder mcp list

# 添加用户级 MCP 服务器
qoder mcp add my-server -s user -- node /path/to/server.js

# 移除 MCP 服务器
qoder mcp remove my-server -s user

# 启动时动态加载 MCP 工具（实验性）
qoder --experimental-mcp-load
```

## 17. 常用组合范例

```bash
# 全自动代码审查（无需确认）
qoder --yolo --allowed-tools "Read,Grep,Glob" -p "审查 src/ 目录下所有文件的安全问题" -q

# CI 自动修复 lint 错误
qoder --dangerously-skip-permissions --model efficient \
  -p "运行 npm run lint，修复所有错误，然后运行 npm run build 确认通过" \
  --max-turns 15

# 只读分析模式（确保不修改文件）
qoder --allowed-tools "Read,Grep,Glob,WebSearch" \
  -p "分析项目架构并生成架构文档"

# Quest 全自动新功能开发
qoder --yolo --worktree --branch feature/user-auth \
  -p "/quest 实现基于 JWT 的用户认证模块，包含登录、注册、Token 刷新接口，并编写测试" \
  --max-turns 80

# 管道：将文件内容作为 prompt 的一部分
qoder --yolo -p "根据以下需求文档生成实现代码：$(cat requirements.md)" \
  --max-turns 30 -f json
```

## A. 参考

- [Qoder CLI 官方文档](https://docs.qoder.com/cli/using-cli)
- [Qoder CLI 命令参考](https://docs.qoder.com/zh/cli/command)
- [Quest Mode 说明](https://docs.qoder.com/user-guide/quest-mode)
- [ACP 协议文档](https://docs.qoder.com/cli/acp)
- [Qoder 论坛 - 权限配置](https://forum.qoder.com/t/qoder-cli-permission/2997)
