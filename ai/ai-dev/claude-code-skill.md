<!--
markmeta_author: titlwind
markmeta_date: 2026-01-22
markmeta_title: Claude Code Skill 技能系统详解
markmeta_categories: ai
markmeta_tags: ai,claude-code,skill,agent
-->

# Claude Code Skill 技能系统详解

Claude Code 的 Skill（技能）系统是其最强大的扩展机制之一。Skill 本质上是一组结构化的提示词和指令，能够让 Claude 在特定场景下展现出"超能力"。本文将深入介绍 Skill 的工作原理、使用场景、最佳实践，以及社区中最具影响力的几个 Skill。

## 1. Skill 原理

### 1.1 什么是 Skill

Skill 是 Claude Code 的自定义扩展，通过创建一个包含 `SKILL.md` 文件的文件夹来定义。Claude 会将其添加到自己的工具箱中，在合适的时机自动调用或由用户手动触发。

**核心概念**：
- **Model-invoked（模型自主调用）**：与需要用户显式输入 `/command` 的命令不同，Skill 可以由 Claude 根据任务描述自主决定是否激活
- **渐进式披露（Progressive Disclosure）**：只在需要时加载详细指令，避免上下文浪费
- **上下文隔离**：通过 `context: fork` 可以在独立的子代理中运行，保持主对话清晰

### 1.2 工作流程

```
用户请求 → Claude 分析任务 → 匹配 Skill Description → 加载 SKILL.md → 按指令执行
```

1. Claude 接收用户请求
2. 检索所有可用 Skill 的 `description` 字段
3. 判断是否有匹配的 Skill
4. 如匹配，将 Skill 的完整 Prompt 加载到上下文
5. 按照 SKILL.md 中的规范执行任务

### 1.3 存放位置

| 位置 | 路径 | 作用范围 |
|:---|:---|:---|
| 个人级 | `~/.claude/skills/<skill-name>/SKILL.md` | 所有项目 |
| 项目级 | `.claude/skills/<skill-name>/SKILL.md` | 当前项目 |
| 插件提供 | `<plugin>/skills/<skill-name>/SKILL.md` | 插件启用处 |
| 企业级 | 托管设置 | 全组织用户 |

Claude Code 会自动发现嵌套的 `.claude/skills/` 目录，支持 monorepo 场景。

### 1.4 目录结构

```
my-skill/
├── SKILL.md           # 核心指令文件（必须）
├── template.md        # 模板文件
├── examples/
│   └── sample.md      # 示例输出
├── references/
│   └── api-spec.md    # 参考文档（按需加载）
└── scripts/
    └── validate.sh    # 可执行脚本
```

### 1.5 SKILL.md 格式

每个 Skill 需要一个包含 YAML Frontmatter 和 Markdown 正文的 `SKILL.md` 文件：

```yaml
---
name: explain-code                    # 唯一标识符，小写+连字符
description: |                        # 关键！Claude 根据此决定是否调用
  Explains code with visual diagrams and analogies.
  Use when explaining how code works.
argument-hint: [file-path]            # 参数提示
allowed-tools: Read, Grep             # 允许使用的工具
disable-model-invocation: false       # true 则仅手动调用
user-invocable: true                  # false 则对用户隐藏
context: fork                         # fork 表示在子代理中运行
agent: Explore                        # 子代理类型
---

# Explain Code Skill

## Instructions
When explaining code, always include:

1. **Start with an analogy**: Compare to everyday life
2. **Draw a diagram**: Use ASCII art to show flow
3. **Walk through the code**: Step-by-step explanation
4. **Highlight gotchas**: Common mistakes to avoid
```

**Frontmatter 字段说明**：

| 字段 | 必须 | 说明 |
|:---|:---|:---|
| `name` | 否 | Skill 名称，默认为目录名 |
| `description` | 推荐 | 描述用途和触发条件，Claude 据此决定是否自动加载 |
| `argument-hint` | 否 | 自动补全提示，如 `[issue-number]` |
| `allowed-tools` | 否 | 限制可用工具，如 `Read, Grep, Bash(git:*)` |
| `disable-model-invocation` | 否 | `true` 禁止自动调用，仅允许手动 `/name` |
| `user-invocable` | 否 | `false` 对用户隐藏，仅供 Claude 内部调用 |
| `context` | 否 | `fork` 在隔离子代理中运行 |
| `agent` | 否 | 子代理类型：`Explore`、`Plan`、`general-purpose` |

## 2. 为什么需要 Skill

### 2.1 解决 AI Agent 的核心问题

AI Agent 在处理复杂任务时面临几个关键挑战：

| 问题 | 表现 | Skill 解决方案 |
|:---|:---|:---|
| **上下文遗忘** | 工作在上下文重置后消失 | 通过文件持久化状态 |
| **目标漂移** | 多次工具调用后偏离原始目标 | 通过 hook 不断重读计划 |
| **隐藏失败** | 错误未被追踪，导致重复尝试 | 在计划文件中记录失败 |
| **步骤跳过** | 急于完成而忽略关键步骤 | 强制执行工作流程 |
| **上下文膨胀** | 所有信息塞入有限窗口 | 渐进式披露，按需加载 |

### 2.2 Skill 的独特价值

**1. 结构化的工作流程**

Skill 将最佳实践固化为可复用的指令集。例如，一个 TDD Skill 可以强制 Claude 先写测试再写代码，而不是让它自由发挥。

**2. 专业领域知识注入**

通过 Skill 可以将团队特定的编码规范、API 设计模式、安全检查清单等领域知识注入 Claude，使其输出更符合实际需求。

**3. 上下文高效利用**

Skill 的 `description` 始终在上下文中，但完整指令只在触发时加载。支持大型参考文档按需读取，避免浪费宝贵的上下文空间。

**4. 可复用与可共享**

项目级 Skill 可提交到 Git，团队成员自动获得一致的开发体验。企业级 Skill 可统一部署给全组织。

## 3. 何时使用 Skill

### 3.1 适用场景

| 场景 | 示例 | 推荐原因 |
|:---|:---|:---|
| **多步骤复杂任务** | 代码审查、重构、调试 | 需要系统化流程 |
| **需要专业知识** | API 设计、安全审计 | 注入领域专业知识 |
| **团队规范执行** | 代码风格、提交规范 | 确保一致性 |
| **重复性工作流** | PR 创建、部署、测试 | 减少重复配置 |
| **长时间自主工作** | 50+ 工具调用的任务 | 防止目标漂移 |

### 3.2 不适用场景

| 场景 | 原因 |
|:---|:---|
| 简单问答 | 无需额外指令 |
| 单文件小修改 | 开销不值得 |
| 快速查询 | 直接执行更高效 |
| 一次性任务 | 不值得创建 Skill |

### 3.3 调用方式

**手动调用**：
```bash
/skill-name [arguments]
```

**自动触发**：直接用自然语言描述任务，Claude 会根据 `description` 自动匹配：
```
帮我审查这个 PR 的代码质量
```

**查看可用 Skill**：
```
What skills are available?
```

## 4. 最佳实践

### 4.1 Description 编写

Description 是 Skill 最关键的部分，决定了触发时机。

**编写原则**：
- 从 Claude 的角度描述何时应该使用
- 包含具体的触发词和使用场景
- 明确说明能力边界

**好的示例**：
```yaml
description: |
  Generate Vue 3 components following team conventions.
  Use when: creating new Vue components, refactoring existing components,
  or when user mentions "Vue", "component", or "SFC".
```

**差的示例**：
```yaml
description: Vue component helper  # 太简短，触发不准确
```

### 4.2 指令结构化

**推荐结构**：
```markdown
# Skill Name

## Overview
简要说明这个 Skill 做什么

## Prerequisites
执行前的检查项

## Instructions
1. 第一步...
2. 第二步...

## Examples
具体的输入输出示例

## Error Handling
常见错误的处理方式

## Limitations
明确说明不能做什么
```

### 4.3 上下文管理

**核心原则**：Claude 已经很聪明，只添加它不知道的信息。

| 做法 | 原因 |
|:---|:---|
| SKILL.md 保持 < 500 行 | 避免上下文浪费 |
| 详细文档放 `references/` | 按需加载 |
| 使用简洁示例代替冗长解释 | 示例更有效 |
| 避免重复信息 | 信息只存一处 |

**引用外部文件**：
```markdown
## Additional Resources
- For complete API details, see [reference.md](reference.md)
- For usage examples, see [examples.md](examples.md)
```

### 4.4 工具权限控制

遵循**最小权限原则**：

```yaml
# 只读 Skill
allowed-tools: Read, Grep, Glob

# 代码修改 Skill
allowed-tools: Read, Edit, Write

# Git 操作 Skill
allowed-tools: Read, Bash(git:*)
```

### 4.5 测试与迭代

| 测试类型 | 方法 |
|:---|:---|
| 触发测试 | 用各种表述测试是否能正确激活 |
| 执行测试 | 验证输出是否符合预期 |
| 边界测试 | 测试超出范围的请求是否被正确拒绝 |

**调试技巧**：
- 如果不触发：扩展 description，添加更多触发词
- 如果触发太频繁：收窄 description，更具体
- 如果结果不一致：增加指令细节，添加验证步骤

## 5. 著名 Skill 介绍

### 5.1 Superpowers

**来源**：[github.com/obra/superpowers](https://github.com/obra/superpowers)

Superpowers 是一个组合式技能框架，实现了结构化的软件开发方法论。它解决了 Claude 跳过步骤的问题，提供了一整套测试、调试、规划的工作流。

**核心理念**：

| 原则 | 说明 |
|:---|:---|
| Test-Driven Development | 测试先于代码 |
| Systematic over ad-hoc | 流程驱动而非直觉 |
| Complexity reduction | 简单性是首要设计目标 |
| Evidence over claims | 验证后才算成功 |

**核心工作流**：

1. **Brainstorming（头脑风暴）**
   - 苏格拉底式设计精炼
   - 分段验证设计方案
   - 命令：`/superpowers:brainstorm`

2. **Planning（规划）**
   - 创建 2-5 分钟粒度的任务
   - 包含完整规格说明
   - 命令：`/superpowers:write-plan`

3. **Execution（执行）**
   - 子代理驱动开发
   - 两阶段代码审查
   - 命令：`/superpowers:execute-plan`

4. **Testing（测试）**
   - RED-GREEN-REFACTOR 循环
   - 强制测试先行
   - 不写测试则自动删除代码

5. **Code Review（代码审查）**
   - 基于严重程度的问题报告
   - 关键阻塞项标记

**安装**：
```bash
/plugin install superpowers@superpowers-marketplace
```

**特点**：
- 可以自主工作数小时而不偏离计划
- 自动触发 Skill，无需手动配置
- 强制 TDD，不写测试则删除代码
- 支持通过 worktree 并行开发
- 包含 15+ 技能覆盖测试、调试、协作

### 5.2 Planning with Files

**来源**：[github.com/OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files)

这是一个实现 Manus 风格持久化 Markdown 规划的 Skill。Manus 是被 Meta 以 $2B 收购的 AI Agent 公司，其核心工作流模式就是通过文件进行规划。

**核心理念**：

> 将文件系统当作永久磁盘存储，将上下文窗口当作易失性 RAM。重要的东西都要写入文件。

**三文件模式**：

| 文件 | 用途 |
|:---|:---|
| `task_plan.md` | 阶段、检查点、进度追踪 |
| `findings.md` | 研究结果和发现 |
| `progress.md` | 会话日志和测试结果 |

**工作原理**：

```
PreToolUse Hook → 重读计划 → 执行操作 → PostToolUse Hook → 更新进度
                                            ↓
                            Stop Hook → 验证任务完成
```

- **PreToolUse hook**：重大决策前重读计划
- **PostToolUse hook**：文件操作后提醒更新进度
- **Stop hook**：关闭前验证任务完成
- **Session recovery**：上下文满后 `/clear`，自动恢复未同步工作

**核心原则**：

| 原则 | 实现 |
|:---|:---|
| 文件系统即记忆 | 存入文件，而非上下文 |
| 注意力操控 | 决策前重读计划 |
| 错误持久化 | 在计划文件中记录失败 |
| 目标追踪 | 复选框显示进度 |
| 完成验证 | Stop hook 检查所有阶段 |

**安装**：
```bash
claude plugins install OthmanAdi/planning-with-files
cp -r ~/.claude/plugins/cache/planning-with-files/planning-with-files/*/skills/planning-with-files ~/.claude/skills/
```

**适用场景**：
- 多步骤任务
- 研究性工作
- 项目构建
- 需要 50+ 工具调用的任务

### 5.3 NotebookLM Skill

**来源**：[github.com/PleasePrompto/notebooklm-skill](https://github.com/PleasePrompto/notebooklm-skill)

这个 Skill 让 Claude Code 能够直接与 Google NotebookLM 交互，查询你上传的文档并获得有来源引用的回答。

**解决的问题**：

| 问题 | NotebookLM Skill 方案 |
|:---|:---|
| Token 消耗大 | 查询 NotebookLM 而非加载文档 |
| 检索不准确 | 利用 Gemini 的预处理 |
| 幻觉问题 | 答案仅来自上传文档 |
| 手动切换应用 | 自动化浏览器交互 |

**核心特性**：
- **来源驱动回答**：答案仅来自上传文档，大幅减少幻觉
- **浏览器自动化**：使用 Patchright 自动交互
- **持久认证**：一次 Google 登录，跨会话有效
- **本地库管理**：保存笔记本链接和元数据
- **自包含**：隔离的 Python 环境，无需全局安装

**工作流程**：

```
1. Claude 加载 SKILL.md 指令
2. 执行 Python 脚本进行认证或查询
3. 打开浏览器导航到 NotebookLM
4. 发送问题并捕获响应
5. 将答案返回给 Claude Code
```

**安装**：
```bash
mkdir -p ~/.claude/skills
cd ~/.claude/skills
git clone https://github.com/PleasePrompto/notebooklm-skill notebooklm
```

**使用方式**：

```bash
# 首次设置认证
"Set up NotebookLM authentication"

# 添加笔记本
"Query and add this notebook: [notebook-link]"

# 查询
"What does my React docs say about hooks?"
```

**对比其他方案**：

| vs 直接喂文档给 Claude | vs 本地 RAG |
|:---|:---|
| Token 成本极低 | 5 分钟 vs 数小时设置 |
| 专业合成能力 | 更优质的答案 |
| 多文档关联 | 无基础设施开销 |
| 自动引用标注 | 无需维护向量库 |

**限制**：
- 仅支持本地 Claude Code（Web UI 沙盒限制）
- 无会话持久化（每个问题独立）
- 文档需手动上传到 NotebookLM

### 5.4 其他著名 Skill

#### 官方 Skill（Anthropic）

| Skill | 说明 |
|:---|:---|
| `frontend-design` | 生成高质量 UI/UX 代码 |
| `skill-creator` | 辅助创建新 Skill |
| `docx` / `pptx` / `xlsx` | Office 文档操作 |
| `pdf` | PDF 文本提取和表单处理 |
| `algorithmic-art` | 使用 p5.js 创建生成艺术 |
| `mcp-builder` | 创建 MCP 服务器 |

#### 合作伙伴 Skill

| 来源 | Skill |
|:---|:---|
| **Vercel** | React 最佳实践、部署指南 |
| **Trail of Bits** | 安全审计、漏洞检测、智能合约分析 |
| **Sentry** | 代码审查、PR 创建、Bug 识别 |
| **Cloudflare** | Workers、Pages、存储参考 |
| **Hugging Face** | 模型评估、数据集处理、训练 |

#### 社区 Skill

| 类别 | Skill |
|:---|:---|
| **生产力** | Notion 集成、PPT 生成 |
| **开发** | Terraform、AWS、PostgreSQL、Playwright |
| **上下文工程** | 记忆系统、多代理模式、评估框架 |
| **自动化** | n8n 工作流、Git 操作 |

**Skill 资源汇总**：
- [VoltAgent/awesome-claude-skills](https://github.com/VoltAgent/awesome-claude-skills)
- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)
- [Anthropic 官方 Skills](https://github.com/anthropics/skills)

## 6. 创建自己的 Skill

### 6.1 快速开始

```bash
# 创建目录
mkdir -p ~/.claude/skills/my-skill

# 创建 SKILL.md
cat > ~/.claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: |
  Description of what this skill does.
  Use when: specific trigger conditions.
---

# My Skill

## Instructions
1. First step...
2. Second step...

## Examples
Input: ...
Output: ...
EOF

# 重启 Claude Code 或刷新配置
```

### 6.2 进阶技巧

**动态上下文注入**：
```yaml
---
name: pr-summary
description: Summarize pull request changes
context: fork
agent: Explore
allowed-tools: Bash(gh:*)
---

## Context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`

## Task
Summarize this pull request...
```

**启用深度思考**：
```yaml
---
name: deep-analysis
---

Ultrathink: Carefully analyze this code structure...
```

**使用参数**：
```yaml
---
name: fix-issue
argument-hint: [issue-number]
---

Fix GitHub issue $ARGUMENTS following our standards.
```

## 7. 总结

Claude Code Skill 是将 AI Agent 从"聪明助手"转变为"结构化协作者"的关键机制。通过 Skill：

- **固化最佳实践**：将经验沉淀为可复用的工作流
- **注入专业知识**：让 Claude 成为领域专家
- **保持目标聚焦**：防止在复杂任务中迷失
- **高效利用上下文**：渐进式披露，按需加载
- **团队知识共享**：统一开发规范和流程

选择合适的 Skill（如 Superpowers、Planning with Files）或创建自定义 Skill，能够显著提升 Claude Code 在复杂项目中的表现。

## 参考

- [Claude Code Skills 官方文档](https://code.claude.com/docs/en/skills)
- [How to create custom Skills - Claude Help Center](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Building Skills for Claude Code - Claude Blog](https://claude.com/blog/building-skills-for-claude-code)
- [Superpowers GitHub](https://github.com/obra/superpowers)
- [Planning with Files GitHub](https://github.com/OthmanAdi/planning-with-files)
- [NotebookLM Skill GitHub](https://github.com/PleasePrompto/notebooklm-skill)
- [Awesome Claude Skills](https://github.com/VoltAgent/awesome-claude-skills)
- [Agent Skills 开放标准](https://agentskills.io)
