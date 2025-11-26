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

### 1.1. 路由
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
      "api_base_url": "https://api.deepseek.com/chat/completions",
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


## A. 感受

- 2025-11-10: claude code 模型在编码上的表现还是最优秀的
- 2025-09-10： 需要结合IDE有比较好的用户体验,但token消耗太快是一个比较大的问题


