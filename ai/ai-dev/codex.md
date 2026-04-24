<!--
markmeta_author: tiltwind
markmeta_date: 2026-04-23
markmeta_title: Codex CLI 使用指南
markmeta_categories: ai
markmeta_tags: ai,codex,cli,agent,openai
-->

# Codex CLI 使用指南

本文基于本机 `codex-cli 0.123.0` 的帮助信息整理，重点覆盖终端中最常用的命令、权限控制和配置方式。

## 1. 基本信息

```bash
# 查看版本
codex -V

# 查看顶层帮助
codex --help
```

`codex` 顶层既支持直接进入交互模式，也支持通过子命令执行无交互任务、代码审查、MCP 管理、插件管理、会话恢复等操作。

## 2. 登录与状态

```bash
# 交互式登录
codex login

# 通过 API Key 登录
printenv OPENAI_API_KEY | codex login --with-api-key

# 设备授权方式
codex login --device-auth

# 查看登录状态
codex login status

# 登出
codex logout
```

## 3. 基本启动

```bash
# 在当前目录启动交互式 Codex
codex

# 启动时附带一条初始 prompt
codex "先阅读这个仓库并总结结构"

# 指定工作目录
codex -C /path/to/project

# 附带图片输入
codex -i screenshot.png "分析这个界面并给出修改建议"

# 指定模型
codex -m gpt-5.4

# 启用实时网页搜索
codex --search "查一下这个依赖最近的 breaking changes"
```

## 4. 会话恢复与分叉

```bash
# 恢复最近一次交互会话
codex resume --last

# 恢复指定会话
codex resume <session-id>

# 恢复时附带新的 prompt
codex resume --last "继续修复刚才失败的测试"

# 查看所有会话（不只当前目录）
codex resume --all

# 分叉最近一次会话，走另一条思路
codex fork --last
```

## 5. 无交互模式

`codex exec` 用于一次性执行任务并退出，适合脚本、自动化和批处理。

```bash
# 执行单条任务
codex exec "解释 src/main.go 的职责"

# 指定工作目录执行
codex exec -C /path/to/project "列出仓库里的 TODO"

# 从标准输入读取 prompt
echo "为 utils.ts 补单元测试" | codex exec -

# prompt 和 stdin 组合使用
cat error.log | codex exec "根据日志分析失败原因"

# 输出 JSONL 事件流
codex exec --json "分析当前仓库的模块边界"

# 将最终一条消息写入文件
codex exec -o /tmp/codex-last.txt "总结这次修改"

# 临时执行，不落盘会话
codex exec --ephemeral "快速检查这个目录的结构"

# 非 git 仓库中执行
codex exec --skip-git-repo-check "解释当前目录文件用途"
```

### 5.1 `codex review`

`codex review` 是专门的无交互代码审查入口。

```bash
# 审查当前未提交改动
codex review --uncommitted

# 审查相对某个基线分支的改动
codex review --base main

# 审查指定 commit
codex review --commit <sha>

# 附带额外审查要求
codex review --base main "重点检查性能回退和测试遗漏"
```

## 6. 权限与沙箱

Codex 的执行安全主要由两个维度控制：

1. `--sandbox`：限制命令执行环境
2. `--ask-for-approval`：控制何时向用户申请批准

### 6.1 沙箱模式

```bash
# 只读沙箱
codex -s read-only

# 默认推荐：工作区可写
codex -s workspace-write

# 完全访问
codex -s danger-full-access
```

三种模式说明：

| 模式 | 说明 |
| :--- | :--- |
| `read-only` | 只能读，不能修改工作区 |
| `workspace-write` | 可读写工作区，适合常规开发 |
| `danger-full-access` | 不受沙箱限制，风险最高 |

### 6.2 审批策略

```bash
# 仅信任命令免审批
codex -a untrusted

# 由模型决定何时申请批准
codex -a on-request

# 从不询问，失败后直接返回给模型
codex -a never
```

策略说明：

| 策略 | 说明 |
| :--- | :--- |
| `untrusted` | 只有受信任命令可直接执行 |
| `on-request` | 模型按需申请用户批准 |
| `never` | 不询问批准，常用于无交互执行 |

`on-failure` 在帮助中已标注为废弃，不建议新使用。

### 6.3 快捷模式

```bash
# 低摩擦自动执行（仍在沙箱内）
codex --full-auto

# 完全跳过审批与沙箱，极高风险
codex --dangerously-bypass-approvals-and-sandbox
```

适合自动化的常见组合：

```bash
# 在工作区可写沙箱中自动执行
codex exec --full-auto "修复 lint 问题并补测试"

# 非交互批处理常用
codex exec -a never -s workspace-write "更新 README 中的过时命令"
```

## 7. 配置文件与覆盖

Codex 默认使用配置文件：

```bash
~/.codex/config.toml
```

本机示例中可以看到 `mcp_servers` 和 `projects.<path>.trust_level` 等配置项。

```toml
[projects."/Users/hk/workspaces/github/tiltwind/note-md"]
trust_level = "trusted"
```

临时覆盖配置用 `-c key=value`：

```bash
# 临时指定模型
codex -c 'model="gpt-5.4"'

# 临时启用某个嵌套配置
codex -c 'shell_environment_policy.inherit=all'

# 临时切换 profile
codex -p default
```

常见控制参数：

```bash
# 只用某个 profile
codex -p work

# 忽略用户配置
codex exec --ignore-user-config "分析当前目录"

# 忽略 exec policy 规则文件
codex exec --ignore-rules "执行一次临时任务"
```

## 8. 多目录与工作区

```bash
# 主工作目录
codex -C /path/to/project

# 额外添加可写目录
codex --add-dir /path/to/shared-lib

# 多目录场景
codex -C /path/to/app --add-dir /path/to/docs "同步更新代码和文档"
```

## 9. MCP 服务管理

Codex 支持把外部 MCP Server 注册到本地配置中。

```bash
# 查看已配置 MCP
codex mcp list

# 查看单个 MCP 配置
codex mcp get <name>

# 添加一个 stdio MCP Server
codex mcp add my-server -- /path/to/mcp-server --port 3000

# 为 stdio MCP 设置环境变量
codex mcp add my-server --env API_KEY=xxx -- /path/to/mcp-server

# 添加一个 streamable HTTP MCP Server
codex mcp add remote-mcp --url https://example.com/mcp

# 为 HTTP MCP 指定 Bearer Token 环境变量
codex mcp add remote-mcp --url https://example.com/mcp --bearer-token-env-var MCP_TOKEN

# 登录 / 登出某些需要认证的 MCP
codex mcp login <name>
codex mcp logout <name>

# 删除配置
codex mcp remove <name>
```

### 9.1 MCP 配置目录与文件

MCP 的主配置文件是：

```bash
~/.codex/config.toml
```

MCP Server 会写在 `mcp_servers` 下，例如：

```toml
[mcp_servers.pencil]
command = "/Users/hk/.pencil/mcp/trae_cn/out/mcp-server-darwin-arm64"
args = ["--app", "trae_cn"]
```

也就是说：

| 位置 | 用途 |
| :--- | :--- |
| `~/.codex/config.toml` | MCP Server 注册入口 |
| `[mcp_servers.<name>]` | 单个 MCP 的配置块 |
| `command` / `args` | stdio 模式 MCP 启动命令 |
| `url` | HTTP MCP 地址（如果用 `--url` 添加） |

## 10. Subagent 与 Skill 目录

Codex 里这两类内容都以本地目录形式存在，不是统一塞进 `config.toml`。

### 10.1 Skill 目录与文件

本机实际看到的 Skill 目录有两类：

| 位置 | 用途 |
| :--- | :--- |
| `~/.codex/skills/` | Codex 自带或系统级技能 |
| `~/.agents/skills/` | 用户安装或外部同步的技能 |

每个 skill 的主入口文件都是：

```bash
<skill-dir>/SKILL.md
```

例如：

```bash
~/.codex/skills/.system/openai-docs/SKILL.md
~/.agents/skills/lark-base/SKILL.md
```

常见目录结构：

```text
<skill-name>/
  SKILL.md
  references/
  scripts/
  assets/
  agents/
```

其中：

| 文件/目录 | 作用 |
| :--- | :--- |
| `SKILL.md` | skill 的主说明与调用规则 |
| `references/` | 附加参考文档 |
| `scripts/` | skill 可调用的脚本 |
| `agents/` | skill 绑定的 agent 元信息 |

如果技能通过安装器安装，还会看到：

```bash
~/.agents/.skill-lock.json
```

它记录 skill 来源、安装时间和 `skillPath`。

### 10.2 Subagent / Agent 目录与文件

Codex 当前环境里，agent 定义通常直接跟随 skill 或 plugin 一起分发，常见位置有：

| 位置 | 用途 |
| :--- | :--- |
| `<skill-dir>/agents/` | skill 自带的 agent 元信息 |
| `<plugin-dir>/agents/` | plugin 提供的 agent 模板或角色定义 |

本机可见样例：

```bash
~/.codex/skills/.system/skill-creator/agents/openai.yaml
~/.codex/.tmp/plugins/plugins/test-android-apps/agents/openai.yaml
~/.codex/.tmp/plugins/plugins/vercel/agents/deployment-expert.md
```

常见文件形态：

| 文件 | 说明 |
| :--- | :--- |
| `agents/openai.yaml` | agent 的界面元信息、展示名、图标、默认 prompt |
| `agents/*.md` | 某个专用 agent 的提示词或模板 |
| `agents/*.md.tmpl` | agent 模板文件 |

也就是说，Codex 的 subagent 更偏“目录化定义”，不是单独在 `~/.codex/config.toml` 里维护一张 agents 列表。

## 11. 插件与 Marketplace

```bash
# 查看插件相关帮助
codex plugin --help

# 管理插件市场
codex plugin marketplace --help

# 添加 marketplace
codex plugin marketplace add <name> <url>

# 升级 marketplace 元数据
codex plugin marketplace upgrade <name>

# 移除 marketplace
codex plugin marketplace remove <name>
```

### 11.1 插件目录与关键文件

本机看到的 marketplace 同步目录在：

```bash
~/.codex/.tmp/plugins/
```

其中几个关键位置：

| 位置 | 用途 |
| :--- | :--- |
| `~/.codex/.tmp/plugins/.agents/plugins/marketplace.json` | marketplace 清单 |
| `~/.codex/.tmp/plugins/plugins/<plugin-name>/` | 单个插件目录 |
| `<plugin-dir>/.codex-plugin/plugin.json` | 插件主清单文件 |
| `<plugin-dir>/plugin.lock.json` | 插件锁定信息 |
| `<plugin-dir>/skills/` | 插件附带的 skills |
| `<plugin-dir>/agents/` | 插件附带的 agents |

例如：

```bash
~/.codex/.tmp/plugins/plugins/vercel/.codex-plugin/plugin.json
~/.codex/.tmp/plugins/plugins/test-android-apps/plugin.lock.json
```

`plugin.json` 里通常会声明 `skills`、`apps`、`interface` 等入口。

## 12. 其他常用命令

```bash
# 启动 Codex 作为 MCP Server
codex mcp-server

# 生成 shell 补全
codex completion zsh

# 在本地工作树应用最近一次 agent 生成的 diff
codex apply

# 查看功能开关
codex features

# 调试工具
codex debug --help
```

## 13. 常用命令速查

```bash
# 交互进入当前项目
codex

# 继续上次会话
codex resume --last

# 一次性执行任务
codex exec "为当前仓库生成架构说明"

# 审查未提交改动
codex review --uncommitted

# 自动执行，但限制在工作区沙箱
codex exec --full-auto "修复测试失败"

# 开启网页搜索
codex --search "查这个报错和官方文档"

# 在指定目录运行
codex -C /path/to/project "阅读并总结这个项目"
```

## 14. 使用建议

1. 日常开发优先用 `workspace-write + on-request`，安全性和效率比较平衡。
2. 脚本自动化优先用 `codex exec`，必要时配合 `--json` 或 `-o`。
3. 审查代码不要用通用 prompt 代替，直接用 `codex review` 更合适。
4. `--dangerously-bypass-approvals-and-sandbox` 只适合外部已经隔离好的环境。
5. 多仓库协同时，优先用 `-C` 和 `--add-dir`，避免让 agent 在错误目录工作。
