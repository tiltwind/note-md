<!--
markmeta_author: titlwind
markmeta_date: 2025-11-07
markmeta_title: Claude Code Development
markmeta_categories: ai
markmeta_tags: ai,claude-code
-->

# claude code development


## 1. 安装
```bash
sudo npm install -g @anthropic-ai/claude-code

# upgrade
sudo npm install -g @anthropic-ai/claude-code@latest
```

## 1.1 使用deepseek模型

配置环境变量，直接使用 DeepSeek API 接入 Claude Code。

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=${DEEPSEEK_API_KEY}
export API_TIMEOUT_MS=600000
export ANTHROPIC_MODEL=deepseek-chat
export ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# 启动
claude
```

## 1.2 使用deepseek模型(自定义命令)

通过创建自定义脚本，实现独立的 DeepSeek 调用命令，互不影响。

```bash
mkdir -p ~/claude-model/bin
# 将 bin 目录加入 PATH，例如在 ~/.zshrc 中添加:
# export PATH="$HOME/claude-model/bin:$PATH"
```

**创建脚本** `~/claude-model/bin/claude-deepseek`
```bash
#!/usr/bin/env bash
# Wrapper for Claude Code CLI using DeepSeek API

CLAUDE_BIN="$(which claude)"

# 配置 DeepSeek 环境变量
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="YOUR_DEEPSEEK_API_KEY"
export ANTHROPIC_MODEL="deepseek-chat"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"
export API_TIMEOUT_MS=600000
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# 使用独立的配置目录，避免与原版配置冲突
export CLAUDE_CONFIG_DIR="$HOME/.claude-deepseek"

exec "$CLAUDE_BIN" "$@"
```

**赋予权限并使用**
```bash
chmod +x ~/claude-model/bin/claude-deepseek

# 使用新命令
claude-deepseek
```


## 1.3. 路由代理访问方式
```bash
sudo npm install -g @musistudio/claude-code-router@latest
```

`vi ~/.claude-code-router/config.json`, more config see https://github.com/musistudio/claude-code-router: 
```json
{
  "PROXY_URL": "http://127.0.0.1:7890",
  "LOG": true,
  "API_TIMEOUT_MS": 600000,
  "NON_INTERACTIVE_MODE": false,
  "Providers": [
    {
      "name": "deepseek",
      "api_base_url": "https://api.deepseek.com/anthropic",
      "api_key": "sk-xxx",
      "models": ["deepseek-chat", "deepseek-reasoner"],
      "transformer": {
        "use": ["deepseek"],
        "deepseek-chat": {
          "use": ["tooluse"]
        }
      }
    }
  ],
  "Router": {
    "default": "deepseek,deepseek-chat",
    "background": "deepseek,deepseek-chat",
    "think": "deepseek,deepseek-reasoner",
    "longContext": "deepseek,deepseek-reasoner",
    "longContextThreshold": 60000
  }
}
```

**通过代理启动claud code**: `ccr code`

## 2. 基本使用
- go to project directory
- 初始化配置：通过在项目根目录创建 CLAUDE.md 文件（可使用 `/init` 命令），可以为 Claude 提供项目结构、技术栈、编码规范等信息，这有助于它做出更准确的修改。

### 2.1. 计划模式
- “计划模式”：对于不熟悉的代码库或复杂操作，可以先让 Claude 进入“计划模式”（通过 `--plan` 参数或在指令前加 `think`/`ultrathink` 关键词）。在此模式下，Claude 仅进行分析和规划而不会直接执行更改，方便你确认其理解是否正确
- 使用 Shift+Tab 切换到 Plan 模式，让 Claude 先阐述它的计划再执行，这对于复杂操作很实用。

### 2.2. 风格
- 通过 /output-style 命令切换输出风格（如 explanatory 或 learning）


## 3. 链接IDE
安装： Claude Code for VSCode 插件, 通过 `/ide` 命令链接ide， 链接 IDE 功能是什么
- 感知上下文：直接获取你在 IDE 中打开的文件、选中的代码段以及项目的整体结构，使其分析和操作更精准。
- 在 IDE 中显示差异：代码的更改可以直接在 IDE 的差异查看器（diff viewer）中显示，而不是仅仅在终端中，更便于查看和审核。
- 使用快捷键快速引用：可以通过快捷键（如 Mac 上的 Cmd+Option+K 或 Windows/Linux 上的 Alt+Ctrl+K）快速插入文件引用（例如 @File#L1-99）。
- 共享诊断信息：IDE 中的诊断错误（如 lint 错误、语法错误等）可以在你工作时自动与 Claude Code 共享，帮助它更好地理解问题。


## 4. Agents（子代理）

Claude Code 的 **Sub-agents（子代理）** 功能，可以根据特定任务创建专属的AI助手，它们拥有独立的上下文和精密的工具权限，非常适合处理代码审查、调试、UI设计等专业性强的任务。

几个典型场景：

| **场景** | **主代理 (Claude)** | **子代理 (Sub-agent)** | **优势** |
| :--- | :--- | :--- | :--- |
| **代码审查** | 接收编写新功能的指令 | 被**自动委派**或**显式调用**，专门检查代码规范、安全性 | **上下文隔离**：主对话线程不被审查细节干扰，保持清晰 |
| **博客写作** | 负责撰写文章核心内容 | 被调用以生成博客封面图或SVG图标 | **专业化处理**：每个代理专注于其最擅长的领域，输出质量更高 |
| **复杂探索** | 将任务（如为项目生成文档）分解 | **并行启动**多个子代理，分别处理不同模块 | **高效并行**：将潜在耗时的单线程任务拆解为高效并行流程 |

### 🛠️ 如何配置与使用 Sub-agents

#### 创建 Sub-agent
1.  **打开管理界面**：在 Claude Code 会话中输入命令 `/agents`。
2.  **创建新代理**：选择 "Create New Agent"。
3.  **定义代理属性**：你需要配置以下几个核心要素：
    - **`name`**：代理的唯一标识符（小写字母+连字符），如 `code-reviewer`。
    - **`description`**：清晰描述代理的用途和触发场景，这决定了Claude何时会自动委派任务。
    - **`tools`**：授予其必要的工具权限列表（如 `Read, Grep, Bash`），遵循**权限最小化**原则以保证安全。
    - **`system prompt`**：在Markdown文件中编写详细的行为规范、工作流程和约束条件，这是代理的"灵魂"。

配置路径:
 - Project (.claude/agents/)
 - Personal (~/.claude/agents/)

参考社区 sub-agents 配置:
- https://github.com/vijaythecoder/awesome-claude-agents
- https://github.com/0xfurai/claude-code-subagents
- https://github.com/zhsama/claude-sub-agent

#### 调用 Sub-agent
- **自动委派**：当你提出的任务描述与某个子代理的 `description` 匹配时，Claude Code 会自动将任务委派给它。
- **显式调用**：你可以直接在对话中通过自然语言指定，例如：**`> 使用 code-reviewer 子代理检查我最近的更改`** 或 **`> 让 debugger 子代理分析这个测试失败`**。

### 💡 进阶技巧与最佳实践

- **链式调用**：对于复杂任务，你可以串联多个子代理。例如，你可以发出指令：**`> 先用 code-analyzer 查找性能问题，再用 optimizer 修复`**。这能让不同专家按顺序协作，提升任务完成的准确性。
- **迭代优化**：Sub-agent 的效果并非一蹴而就。一个有效的建议是"**Recommended: Generate with Claude first, then customize**"。即先让 Claude 在普通聊天中尝试执行该专业任务，然后将表现优秀的回答作为子代理系统提示词的初版，再不断根据实际使用效果进行编辑和优化。
- **安全第一**：在配置 `tools` 时，务必坚持权限最小化原则。例如，一个只负责审查代码的代理，通常只应授予其 `Read` 权限，从根本上杜绝它越界修改代码的可能。

希望这份指南能帮助你快速上手 Claude Code 的 Sub-agents 功能。如果你在创建第一个子代理时遇到问题，比如不确定某个任务应该配置哪些工具权限，可以随时追问。

## 5. 自定义命令

在 Claude Code 中创建自定义命令（Custom Commands）可以让你把一些复杂或常用的指令固化下来，极大地提升工作效率。下面我将为你介绍如何创建和使用它们，并提供一个包含多种场景的实用范例表格。

自定义命令通过创建特定的 Markdown (`.md`) 文件来实现，你需要根据命令的适用范围，将其放在正确的目录下：

*   **项目级命令**：仅在当前项目内可用。
    创建路径：`项目根目录/.claude/commands/你的命令名.md`
*   **全局命令**：在你所有的项目中都可用。
    创建路径：`~/.claude/commands/你的命令名.md` (你的用户主目录下)

创建文件并编辑后，**重启 Claude Code** 即可通过输入 `/` 来看到并使用你新创建的命令。


### 💡 高级用法与技巧

除了上面表格中的基础用法，自定义命令还支持一些高级功能，可以让你的命令更加强大和智能。

*   **参数传递**：在你的命令提示词中，可以使用 **`$ARGUMENTS`** 作为占位符来接收用户输入。例如，一个查询天气的命令提示词可以是：`查询 $ARGUMENTS 的天气`。当你使用 `/weather 北京` 时，Claude 收到的指令就是"查询 北京 的天气"。也支持类似 Shell 脚本的 **`$1`**, **`$2`** 位置参数。
*   **执行 Bash 命令**：在自定义命令中，你可以通过 **!`command`** 的语法在执行时运行 Bash 命令，并将其输出作为上下文。这在获取 Git 状态、文件列表等信息时非常有用。请注意，这通常需要在 Frontmatter 中通过 `allowed-tools` 字段授予相应的 `Bash` 工具权限。
*   **文件引用**：在命令中，使用 **`@文件名`** 可以引用当前工作目录下的文件内容。例如，`请总结 @README.md 的主要内容`。
*   **使用 Frontmatter 精细控制**：在 Markdown 文件顶部的 `---` 区域内（称为 Frontmatter），你可以设置更多选项：
    *   `description`：命令的简短描述，会在命令列表中显示。
    *   `argument-hint`：参数的提示信息，例如 `[commit message]`。
    *   `allowed-tools`：明确此命令可以使用的工具列表，例如 `Bash(git add:*)`，遵循权限最小化原则。
    *   `model`：指定执行此命令时使用的模型。

### ⚠️ 温馨提示

*   **权限安全**：在授予 `allowed-tools` 权限，尤其是 `Bash` 和 `Edit`（文件编辑）时，请务必谨慎，确保命令本身是安全可靠的。
*   **迭代优化**：自定义命令的效果可能需要你根据实际使用反馈，不断调整和优化提示词，就像优化其他 AI 提示词一样。

希望这些范例和说明能帮助你更好地利用 Claude Code 的自定义命令功能。如果你对实现某个特定功能的命令有疑问，或者想了解更复杂的组合用法，随时可以再问我。


## 6. 配置 MCP (Model Context Protocol)

MCP (Model Context Protocol) 是一种开放标准，允许 AI 助手（如 Claude）安全地连接到本地或远程的数据源和工具。通过配置 MCP 服务器，你可以让 Claude 访问数据库、文件系统、API 等外部资源。

配置路径:
- 用户级别: `~/.claude.json` 文件的 mcpServers 字段
- 项目级别: 项目目录下 `.mcp.json` 文件

配置文件的基本结构如下：

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable-command",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

命令添加:
```bash
# 通过 -s user 指定用户级别
claude mcp add <MCP服务器名称> -s user <启动命令>
claude mcp remove <MCP服务器名称> -s user

claude mcp add chrome-devtools -s user -- npx chrome-devtools-mcp@latest
```

以下是几个常见的 MCP 服务器配置范例：

#### 6. Chrome DevTools (浏览器调试)
允许 Claude 控制 Chrome 浏览器进行调试、页面分析等。
需要先安装：`npm install -g chrome-devtools-mcp`

添加: `claude mcp add chrome-devtools -s user -- npx chrome-devtools-mcp@latest`

手动配置:
```json
"mcp__chrome-devtools": {
  "command": "npx",
  "args": [
    "-y",
    "chrome-devtools-mcp@latest"
  ]
}
```

### 6.3 调试与验证
配置完成后，重启 Claude Code。你可以通过询问 Claude "列出当前可用的 MCP 工具" 来验证服务器是否加载成功。


### 6.3 调试与验证
配置完成后，重启 Claude Code。你可以通过询问 Claude "列出当前可用的 MCP 工具" 来验证服务器是否加载成功。


## 7. Plugins (插件)

Claude Code 的插件系统（Plugins）允许你扩展其能力，包括自定义命令、Agents、Skills 和 MCP 服务器等。

### 7.1 安装与使用

#### 7.1.1 发现插件
你可以通过以下两种方式查看市场上有哪些可用的插件：

1.  **命令行交互界面**：
    在 Claude Code 中输入 `/plugin` 命令，会打开一个交互式界面。使用 `Tab` 键在不同标签页之间切换（如 Discover, Installed, Marketplaces）。在 **Discover** 标签页中，你可以浏览所有已添加市场的插件列表。

2.  **网页浏览**：
    访问非官方的插件索引站 [claude-plugins.dev](https://claude-plugins.dev/) 浏览社区插件，或者直接查看 [Anthropic 官方 GitHub 仓库](https://github.com/anthropics/claude-code/tree/main/plugins)。

#### 7.1.2 安装插件
安装插件最简单的方法是使用 `/plugin install` 命令。

**推荐安装方式：项目级别 (Project Scope)**
建议使用 `--scope project` 参数将插件安装到当前项目。这样做的好处是：
*   **隔离性**：不同项目可以使用不同版本的插件，避免冲突。
*   **团队共享**：配置会保存在项目的 `.claude/settings.json` 中，团队成员拉取代码后可以获得一致的开发环境。

**项目级安装后的文件变化**：
当你使用 `--scope project` 安装插件（例如 `frontend-design`）后，你的项目目录中通常会生成或更新以下配置文件：

1.  **.claude/settings.json**: 记录已启用的插件及其配置。
    ```json
    {
      "plugins": {
        "frontend-design": {
          "enabled": true,
          "scope": "project"
        }
      }
    }
    ```
2.  **（可选）插件相关文件**: 取决于插件类型，某些插件可能会在 `.claude/` 目录下生成特定的配置文件或缓存。
    *注意：实际的插件源码通常缓存在全局目录中，项目内仅保存引用配置。*

**基本语法**：
```bash
/plugin install <plugin-id> --scope project
```

**示例**：
安装官方提供的 Frontend Design 插件到当前项目：
```bash
/plugin install frontend-design@claude-code-plugins --scope project
```
或者
```bash
/plugin install @anthropics/claude-code-plugins/frontend-design --scope project
```

如果不加 `--scope project`，默认会安装到**用户级别 (User Scope)**，即对该用户的所有项目生效。

#### 7.1.3 常用命令参考
以下是 `/plugin` 命令的常用用法：

*   **交互式管理**：
    *   `/plugin` - 打开全功能交互界面（浏览、安装、管理）。

*   **安装与卸载**：
    *   `/plugin install <id> [--scope project]` - 安装插件。
    *   `/plugin uninstall <id> [--scope project]` - 卸载插件。
    *   `/plugin enable <id>` - 启用插件。
    *   `/plugin disable <id>` - 禁用插件。

*   **查看信息**：
    *   `/plugin list` - 列出所有已安装的插件。
    *   `/plugin update` - 更新所有插件。

*   **市场管理**：
    *   `/plugin marketplace add <repo>` - 添加插件市场（如 GitHub 仓库）。
    *   `/plugin marketplace list` - 列出已配置的市场。
    *   `/plugin marketplace update <name>` - 更新特定市场的插件列表。

### 7.2 常用插件推荐

| 插件名 | ID | 说明 |
| :--- | :--- | :--- |
| **Frontend Design** | `frontend-design@claude-code-plugins` | 专注于生成高质量、非通用的前端界面代码，包含设计审美和最佳实践。 |
| **Commit Commands** | `@anthropics/claude-code-plugins/commit-commands` | 包含 git 提交、推送和创建 PR 的相关命令。 |
| **Code Review** | `@anthropics/claude-code-plugins/code-review` | 自动化的代码审查插件，提供基于置信度的审查意见。 |

### 7.3 使用建议

1.  **按需安装**：不要一次性安装过多插件，以免造成环境混乱或上下文过载。根据当前项目的需求选择合适的插件。
2.  **查看文档**：许多插件（特别是官方插件）在 GitHub 上有详细的 `SKILL.md` 或说明文档，安装前建议阅读以了解其具体能力和触发方式。
3.  **插件管理**：
    *   列出已安装插件：`/plugin list` (或使用 `npx claude-plugins list`)
    *   移除插件：`/plugin remove <plugin-id>`
    *   更新插件：通常需要重新安装最新版本。

> **提示**：插件本质上是 Skills、Prompts 和工具配置的集合。如果你发现某个插件特别好用，可以研究其源码（通常是开源的），学习如何编写更好的 System Prompts 和 Skills。

## 8. Skills (技能)

Skills 是 Claude Code 中用于扩展模型能力的一种机制。与由用户显式触发的“命令”(`/command`)不同，**Skills 是由模型自主决定调用的**。

### 8.1 什么是 Skills
Skills 本质上是一组结构化的提示词（Prompts）和指令，告诉 Claude 如何处理特定类型的任务。当你在对话中提出请求时，Claude 会根据已安装 Skill 的描述（Description），判断是否需要激活某个 Skill 来辅助完成任务。

*   **特点**：模型自主调用 (Model-invoked)，无需用户记忆复杂命令。
*   **用途**：定义团队特定的工作流、复杂的代码生成规范、或集成特定的知识库。

### 8.2 创建与存放位置
Skills 以文件夹的形式存在，核心是一个 `SKILL.md` 文件。

你可以将 Skills 存放在以下两个位置：

1.  **个人级 (Personal)**：`~/.claude/skills/`
    *   对你个人的所有项目生效。
2.  **项目级 (Project)**：`.claude/skills/` (位于项目根目录)
    *   仅对当前项目生效，且可以提交到 Git 仓库与团队共享。

**目录结构示例**：
```
.claude/
└── skills/
    └── my-custom-skill/      <-- Skill 文件夹名称
        ├── SKILL.md          <-- 核心定义文件 (必须)
        ├── reference.md      <-- (可选) 额外的参考文档
        └── scripts/          <-- (可选) 辅助脚本
            └── helper.py
```

### 8.3 SKILL.md 文件格式
`SKILL.md` 由两部分组成：**YAML Frontmatter** (元数据) 和 **Markdown 正文** (指令)。

**基本模板**：
```
---
name: skill-name-id            # 唯一标识符，只能包含小写字母、数字和连字符
description: 简短描述这个 Skill 是做什么的，以及 Claude 何时应该使用它。 # 关键字段！Claude 根据此描述决定是否调用
allowed-tools: [Read, Grep]    # (可选) 限制该 Skill 运行时允许使用的工具，提高安全性
---

# Skill 名称

## Instructions (指令)
在这里详细说明 Claude 应该如何执行这个任务。
1. 第一步...
2. 第二步...

## Examples (示例)
提供具体的输入输出示例，帮助 Claude 理解预期效果。
- 用户输入: ...
- 期望行为: ...
```

### 8.4 实战示例：创建一个 "Vue3 组件生成器" Skill
假设我们希望 Claude 在生成 Vue 组件时，始终遵循团队特定的 `<script setup>` 风格。

1.  创建目录：`mkdir -p .claude/skills/vue-component-gen`
2.  创建文件：`.claude/skills/vue-component-gen/SKILL.md`
3.  写入内容：

```
---
name: vue-component-gen
description: Generate Vue 3 components following team best practices. Use this whenever the user asks to create or refactor a Vue component.
---
```

# Vue 3 Component Generator

## Instructions
When generating Vue 3 components, you MUST follow these rules:

1.  **Syntax**: Always use `<script setup lang="ts">`.
2.  **Naming**: Use PascalCase for component filenames (e.g., `UserProfile.vue`).
3.  **Structure**:
    - `<script setup>` first
    - `<template>` second
    - `<style scoped>` last
4.  **Props**: Use interface-based prop definitions with `defineProps<Props>()`.

## Examples

User: "Create a button component"

Output:
```vue
<script setup lang="ts">
interface Props {
  label: string;
  disabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
});

const emit = defineEmits<{
  (e: 'click', event: MouseEvent): void;
}>();
</script>

<template>
  <button :disabled="props.disabled" @click="emit('click', $event)">
    {{ props.label }}
  </button>
</template>

<style scoped>
button {
  /* styles */
}
</style>
```

### 8.5 如何使用
创建好 Skill 后（通常需要重启 Claude Code 或重新加载配置），你**不需要**输入任何特殊命令。

直接用自然语言提问：
> "帮我写一个展示用户信息的 Vue 组件"

Claude 会：
1.  分析你的请求。
2.  检索所有可用 Skills 的 `description`。
3.  发现 `vue-component-gen` 的描述匹配请求。
4.  加载该 Skill 的 Prompt 到上下文中。
5.  按照 `SKILL.md` 中的规范生成代码。

**查看已加载的 Skills**：
你可以直接问 Claude：
> "What skills are available?"


## 9. 常用快捷键 (Shortcuts)

熟练使用快捷键可以大幅提升 Claude Code 的交互效率。

### 9.1 通用控制
| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| **Ctrl+C** | 取消/中断 | 取消当前输入或中断正在生成的回答。 |
| **Ctrl+D** | 退出 | 发送 EOF 信号，退出 Claude Code 会话。 |
| **Ctrl+L** | 清屏 | 清除终端屏幕显示，但保留对话历史。 |
| **Ctrl+O** | 切换详细模式 | 显示/隐藏工具执行的详细日志 (Verbose Output)。 |
| **Ctrl+R** | 搜索历史 | 交互式反向搜索命令历史 (Reverse Search)。 |
| **Esc + Esc** | 回退 (Rewind) | 快速回退对话和代码到上一个状态（撤销最近的更改）。 |
| **Shift+Tab** | 切换模式 | 在自动批准 (Auto-Accept)、计划模式 (Plan Mode) 和普通模式间切换。 |

### 9.2 输入与编辑
| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| **Option+Enter** | 换行 | (macOS 默认) 在输入框中插入新行，而不是发送消息。 |
| **\ + Enter** | 快速换行 | 在所有终端通用的换行方式。 |
| **Up/Down** | 历史导航 | 浏览上一条/下一条输入的命令。 |
| **Ctrl+V** | 粘贴图片 | (macOS/Linux) 将剪贴板中的图片或图片路径粘贴到输入框。 |

### 9.3 进阶操作
*   **后台运行 (Ctrl+B)**：当 Claude 执行 Bash 命令时，按 `Ctrl+B` 可将其转为后台运行，让你能继续与 Claude 对话。
*   **切换模型 (Option+P)**：快速切换当前使用的模型 (如 Sonnet/Opus)。
*   **Vim 模式**：如果你习惯 Vim 键位，可以使用 `/vim` 命令开启 Vim 模式 (支持 `h/j/k/l` 导航, `i/a` 插入, `dd` 删除行等)。

> **提示**：不同终端模拟器可能会拦截某些快捷键（如 `Option` 键）。如果遇到问题，请检查终端的 Meta/Option 键配置，或运行 `/terminal-setup` 进行自动配置。


## A. 感受

- 2025-11-10: claude code 模型在编码上的表现还是最优秀的
- 2025-09-10： 需要结合IDE有比较好的用户体验,但token消耗太快是一个比较大的问题


