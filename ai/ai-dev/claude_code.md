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


## 4. 感受

- 2025-09-10： 需要结合IDE有比较好的用户体验,但token消耗太快是一个比较大的问题


