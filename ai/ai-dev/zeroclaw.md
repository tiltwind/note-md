<!--
markmeta_author: tiltwind
markmeta_date: 2026-02-24
markmeta_title: ZeroClaw 轻量级安全 AI Agent 运行时
markmeta_categories: ai
markmeta_tags: ai,zeroclaw,agent,rust
-->

# ZeroClaw 轻量级安全 AI Agent 运行时

ZeroClaw 是一个开源的、使用 Rust 编写的下一代 AI Agent 运行时框架。它将 AI Agent 压缩为约 3.4 MB 的系统守护进程，冷启动时间低于 10 毫秒，运行内存不到 5 MB，可以部署在从云服务器到仅有 10 美元的边缘硬件上。

项目由 Harvard、MIT 和 Sundai.Club 社区的贡献者发起，官方仓库位于 `github.com/zeroclaw-labs/zeroclaw`，采用 Apache-2.0 和 MIT 双许可证。

> 注意：ZeroClaw 与 `openagen/zeroclaw`、`zeroclaw.org`、`zeroclaw.net` 无关，这些域名指向冒充分支。请以 GitHub 官方仓库为准。

## 1. 架构

ZeroClaw 采用 **基于 Trait 的插件架构**（Trait-based Plugin Architecture），每个子系统实现一个可替换的 Rust Trait（接口），可以在不修改代码甚至不重启守护进程的情况下替换组件。

### 1.1 八大核心 Trait

| 组件 | Trait | 内置选项 |
|------|-------|----------|
| AI 模型 | `Provider` | OpenAI, Anthropic, OpenRouter, Ollama, DeepSeek 等 22+ |
| 通信渠道 | `Channel` | CLI, Telegram, Discord, Slack, Email, IRC, Matrix, Signal 等 10+ |
| 记忆存储 | `Memory` | SQLite, PostgreSQL, Markdown 文件, none |
| 工具 | `Tool` | Shell, 文件操作, Git, 浏览器, HTTP 请求, 图片分析 |
| 运行时 | `RuntimeAdapter` | Native, Docker (沙箱) |
| 安全策略 | `SecurityPolicy` | 配对认证, 沙箱, 允许列表, 速率限制 |
| 隧道 | `Tunnel` | Cloudflare, Tailscale, ngrok |
| 可观测性 | `Observability` | OpenTelemetry, Prometheus, Logging |

### 1.2 核心架构层

- **Agent Core**：中央编排层，管理记忆、LLM 输出解析和自主工具调度
- **Channel Layer**：适配器模式（Adapter Pattern），支持多种通信接口
- **Memory Backend**：可插拔存储，提供 `store()`、`recall()`、`get()`、`forget()`、`count()` 异步操作。内置全栈搜索引擎，集成向量嵌入、FTS5 关键词搜索（BM25 评分）和自定义加权混合排序，无需外部依赖
- **Provider Integration**：抽象 LLM 连接层，支持模型后端热切换
- **Tool/Runtime System**：沙箱化执行环境，具有严格的安全边界

### 1.3 三种运行模式

| 模式 | 命令 | 说明 |
|------|------|------|
| Agent | `zeroclaw agent` | CLI 交互模式或单消息模式 |
| Gateway | `zeroclaw gateway` | HTTP Webhook 服务器（默认 `127.0.0.1:42617`） |
| Daemon | `zeroclaw daemon` | 完整自主运行时，含 Gateway + Channels + 心跳 + 调度器 |

**Agent 模式** —— 本地开发和一次性任务：

```bash
# 交互式对话（类似 ChatGPT CLI）
zeroclaw agent

# 单条消息模式，执行完即退出
zeroclaw agent -m "帮我review一下 ~/workspaces/myapp/main.go 的代码"

# 管道模式，结合其他命令使用
cat error.log | zeroclaw agent -m "分析这段日志中的错误原因"
```

**Gateway 模式** —— 为其他应用提供 HTTP API：

```bash
# 启动 HTTP 服务（默认 127.0.0.1:42617）
zeroclaw gateway

# 其他应用通过 HTTP 调用
curl -X POST http://127.0.0.1:42617/v1/message \
  -H "Content-Type: application/json" \
  -d '{"message": "总结今天的待办事项"}'
```

适用于将 Agent 能力集成到内部工具、CI/CD 流水线或自定义 Web 应用中。

**Daemon 模式** —— 7×24 小时自主运行：

```bash
# 启动守护进程（包含 Gateway + 所有 Channel + 心跳 + 定时任务）
zeroclaw daemon
```

macOS 通过 launchd 实现开机自启：

```bash
# 创建 plist 文件
cat > ~/Library/LaunchAgents/com.zeroclaw.daemon.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.zeroclaw.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/hk/.cargo/bin/zeroclaw</string>
        <string>daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/zeroclaw.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/zeroclaw.err.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
    </dict>
</dict>
</plist>
EOF

# 加载并启动服务
launchctl load ~/Library/LaunchAgents/com.zeroclaw.daemon.plist

# 查看运行状态
launchctl list | grep zeroclaw

# 查看日志
tail -f /tmp/zeroclaw.out.log
tail -f /tmp/zeroclaw.err.log

# 停止并卸载服务
launchctl unload ~/Library/LaunchAgents/com.zeroclaw.daemon.plist
```

适用于长期在线的飞书/Telegram/Discord 机器人，Agent 通过 Channel 持续接收消息，并可执行 HEARTBEAT.md 中定义的定时任务（如每日站报、定期巡检）。

## 2. 优势

### 2.1 极致性能

ZeroClaw 与同类框架 OpenClaw 的对比：

| 指标 | ZeroClaw | OpenClaw |
|------|----------|----------|
| 二进制大小 | ~8.8 MB | 数百 MB |
| 运行内存 | < 5 MB | 1+ GB |
| 冷启动 | < 10 ms | 500+ ms |
| 4 GB 硬件实例数 | ~200 | ~2 |

### 2.2 核心特性

- **22+ LLM Provider**：支持 OpenAI、Anthropic、OpenRouter、Ollama（本地/远程）等，原生 Tool Calling
- **20+ 通信渠道**：CLI、Telegram、Discord、Slack、Email、IRC、Matrix、Signal、WhatsApp、Nostr 等
- **70+ 集成**：涵盖 Web API、文件操作、调度、平台集成、硬件工具等 9 个类别
- **Skills 系统**：通过 TOML 清单 + SKILL.md 指令文件扩展功能，支持社区技能包
- **Sub-agent 委派**：配置具有不同 Provider/Model 的子代理，支持递归深度控制
- **多平台**：Linux (x86_64, aarch64, armv7)、macOS (x86_64, aarch64)、Windows (x86_64)
- **本地优先**：通过 Ollama 集成可完全离线运行，无需云依赖
- **热更新配置**：Provider、Model、Temperature、API Key 等配置更改无需重启
- **成本追踪**：内置消费限额保护，支持日/月预算控制
- **OpenClaw 迁移**：通过 `zeroclaw migrate openclaw` 直接迁移
- **加密认证**：多账户凭证存储，使用 ChaCha20-Poly1305 加密

## 3. 安装

### 3.1 系统要求

- **运行时**：< 5 MB RAM，~20 MB 磁盘
- **编译**：2 GB RAM（推荐 4+ GB），6-10 GB 可用磁盘，Rust 1.70+ stable
- **依赖**：Linux 需要 `build-essential pkg-config`；macOS 需要 Xcode Command Line Tools

### 3.2 从源码编译

ZeroClaw 默认编译 `default = []`，不含 Lark/Matrix 等可选渠道。Homebrew、预编译二进制等安装方式不一定包含 `channel-lark` Feature，如果运行时出现以下警告：

```
WARN zeroclaw::channels: Lark channel is configured but this build was compiled without `channel-lark`; skipping Lark health check.
```

则需要从源码编译并显式启用 `channel-lark`：

```bash
git clone https://github.com/zeroclaw-labs/zeroclaw.git
cd zeroclaw
git checkout v0.1.6  # 选择一个稳定版本
cargo build --release --locked --features channel-lark
cargo install --path . --force --locked --features channel-lark
export PATH="$HOME/.cargo/bin:$PATH"

# 更新 pull 后重新编译安装
git pull
cargo build --release --locked --features channel-lark
cargo install --path . --force --locked --features channel-lark
zeroclaw --version   # 确认版本
zeroclaw doctor      # 运行诊断
```

组合多个 Feature Flag：

```bash
cargo build --release --locked --features "channel-lark,channel-matrix,browser-native,sandbox-landlock,memory-postgres,observability-otel"
```

### 3.3 安装后初始化

```bash
# 交互式向导
zeroclaw onboard

# 或自动化模式（以 DeepSeek 为例）
zeroclaw onboard --api-key sk-... --provider deepseek

# 验证安装
zeroclaw status
zeroclaw doctor
```

`zeroclaw doctor` 会执行：
- 迁移已弃用的配置键和旧文件位置
- 审核 DM 策略并警告高风险设置
- Gateway 健康检查
- 检测并迁移旧版 Gateway 服务
- Linux 上确保 systemd 用户 lingering

**热更新**：当 `zeroclaw channel start` 已运行时，`default_provider`、`default_model`、`default_temperature`、`api_key`、`api_url` 等配置变更会在下一条入站消息时自动生效，无需重启。


## 4. Skills 扩展

ZeroClaw 支持通过 Skills 系统扩展 Agent 能力。每个 Skill 是一个独立目录，包含 `SKILL.md`（指令文件）和可选的辅助脚本。

### 4.1 添加社区 Skills

以添加文档处理类 Skills（docx、xlsx、pptx）为例：

```bash
# 克隆 Skills 仓库
git clone https://github.com/anthropics/skills.git /tmp/anthropic-skills

# 创建 Skills 目录（如不存在）
mkdir -p ~/.zeroclaw/workspace/skills

# 复制需要的 Skills
cp -r /tmp/anthropic-skills/skills/docx ~/.zeroclaw/workspace/skills/
cp -r /tmp/anthropic-skills/skills/xlsx ~/.zeroclaw/workspace/skills/
cp -r /tmp/anthropic-skills/skills/pptx ~/.zeroclaw/workspace/skills/

# 清理临时文件
rm -rf /tmp/anthropic-skills

# 每个 Skill 可能需要额外的工具依赖
brew install pandoc # 文本提取
npm install -g docx # 创建新文档（docx-js）
brew install --cask libreoffice # PDF 转换和验证（可选）
brew install poppler    # pdftoppm 图片转换
pip install pandas openpyxl # 数据分析和表格操作
pip install "markitdown[pptx]" Pillow # 文本提取
npm install -g pptxgenjs # 从零创建演示文稿
```

### 4.3 验证 Skills 加载

```bash
# 查看已加载的 Skills
zeroclaw status

# 目录结构确认
ls ~/.zeroclaw/workspace/skills/
# 预期输出: docx/  xlsx/  pptx/
```

## 5. 配置

配置文件位于 `~/.zeroclaw/config.toml`，采用 TOML 格式。

### 5.1 配置优先级

CLI 标志 > 环境变量 > 配置文件 > 默认值

配置路径解析顺序：
1. `ZEROCLAW_WORKSPACE` 环境变量
2. `~/.zeroclaw/active_workspace.toml`
3. `~/.zeroclaw/config.toml`（默认）

### 5.2 核心配置项

**STEP 1. 配置deepseek**
```bash
zeroclaw onboard --api-key sk-xxxx --provider deepseek
```

**STEP 2. Channel 配置（以飞书为例）**

- 访问飞书开发者后台 `open.feishu.cn/app`
- 点击 **创建自建应用**（Custom App）
- 进入应用的 **添加应用能力** 页面， 添加 **Bot（机器人）** 能力
- 在应用的 **权限管理** 页面开启以下权限：
	- `im:message` — 获取与发送单聊、群组消息
	- `im:message.p2p_msg` — 读取用户发给机器人的单聊消息
	- `im:resource` — 获取消息中的资源文件（图片、文件等，按需开启）
- 进入应用，在 **凭证与基础信息** 页面获取 **App ID** 和 **App Secret**


```bash
zeroclaw onboard --channels-only  # 命令行配置channel ， 选择飞书渠道, 输入app id 和  app secrect, 如果是个人飞书 allowed_users 可以设置为*, 企业飞书可以设置指定用户； 当未授权用户发送消息时，日志会打印其 `open_id`

zeroclaw channel start feishu  # 启动 ZeroClaw 建立 WebSocket 连接
```

观察日志，确认连接成功：

```
INFO zeroclaw::channels::lark: Lark: WS connected
```

**STEP 3. 回到飞书开发者后台， 配置事件订阅（长连接）**

- 进入应用的 **事件订阅** 页面
- 选择接收方式为 **使用长连接接收事件**（WebSocket）
- 此时后台会检测 WebSocket 连接状态 —— 因为 Step 4 已启动 ZeroClaw，应显示为 **已连接**
- 添加事件 `im.message.receive_v1`（接收消息）


**STEP 4. 发布应用版本**

1. 进入 **版本管理与发布** 页面
2. 创建版本并提交发布
3. 等待管理员审批通过后，机器人正式上线

### 5.3 配置工作目录

ZeroClaw 默认启用 `workspace_only = true`，Agent 只能访问 `~/.zeroclaw/workspace/` 目录。
如需允许 Agent 读写其他目录（如项目代码、文档），需在 `~/.zeroclaw/config.toml` 中添加 `allowed_paths`：

```toml
[security.filesystem]
workspace_only = true          # 保持开启，限制默认访问范围
allowed_paths = [
    "~/workspaces",            # 项目代码目录
    "~/doc",                   # 文档目录
]
```


### 5.6 工作区目录结构

```
~/.zeroclaw/
├── config.toml                # 主配置文件
└── workspace/
    ├── IDENTITY.md            # Agent 身份定义
    ├── SOUL.md                # Agent 行为准则
    ├── USER.md                # 用户偏好
    ├── AGENTS.md              # Sub-agent 定义
    ├── BOOTSTRAP.md           # 启动引导指令
    ├── HEARTBEAT.md           # 心跳任务
    ├── MEMORY.md              # 记忆索引
    ├── TOOLS.md               # 工具配置
    ├── memory/                # 记忆存储
    │   ├── brain.db           # SQLite 记忆数据库
    │   ├── 2026-02-24.md      # 日期记忆文件
    │   └── archive/           # 归档记忆
    ├── sessions/              # 会话记录
    │   └── archive/
    ├── skills/                # 自定义 Skills 目录
    ├── cron/                  # 定时任务
    └── state/                 # 运行状态
        └── memory_hygiene_state.json
```

使用 `zeroclaw config schema` 可输出 JSON Schema (draft 2020-12) 用于配置校验。

## 6. 安全

ZeroClaw 遵循"安全默认"（Secure-by-Default）设计哲学，提供多层安全防护。

### 6.1 文件系统安全

- **工作区隔离**：`workspace_only = true` 默认开启，拒绝绝对路径（除非显式允许）
- **路径黑名单**：默认屏蔽 14 个系统目录 + 4 个敏感 dotfile
- **注入防护**：阻止 Null 字节注入
- **符号链接检测**：通过路径规范化 + 解析路径工作区校验检测符号链接逃逸

### 6.2 沙箱隔离

- **Docker 运行时**：`runtime.kind = "docker"` 模式，默认 `network: "none"`（仅 loopback 网络）
- **Landlock**：Linux 上基于 Landlock 的强制访问控制（通过 `sandbox-landlock` Feature Flag），阻止未授权的文件系统和网络访问
- **工具执行**：所有工具在沙箱环境中运行，具有严格的安全边界

### 6.3 网络安全

- **Gateway 绑定**：默认绑定 `127.0.0.1`，不允许 `0.0.0.0`（除非显式设置 `allow_public_bind = true` 或使用隧道）
- **随机端口**：Webhook 服务可绑定随机端口（`--port 0`）以减少扫描暴露
- **HTTP 默认拒绝**：空 `allowed_domains` 列表拒绝所有请求；即使使用通配符，私有目标也会被阻止

### 6.4 认证与访问控制

- **Gateway 配对**：需要认证配对，默认无任何公开暴露
- **Channel 允许列表**：Telegram、Discord、Nostr 等渠道需显式配置用户/ID 白名单，空列表 = 拒绝所有
- **Shell 命令白名单**：命令必须在 `autonomy.allowed_commands` 中显式授权
- **Shell 解析**：引号感知的分隔符解析，未加引号的操作符（`;`、`|`、`&&`、`||`、重定向）会被强制检查

### 6.5 加密保护

- **凭证加密**：ChaCha20-Poly1305 加密存储（`.secret_key` 权限 600）
- **多账户认证**：加密的 auth-profiles
- **原生 TLS**：通过 rustls 提供 HMAC、SHA2、TLS 支持

### 6.6 OTP 保护

```toml
[security.otp]
enabled = true
method = "totp"                # totp / pairing / cli-prompt
gated_actions = ["shell", "file_write", "browser_open", "memory_forget"]
gated_domains = []
gated_domain_categories = ["banking", "medical", "government", "identity_providers"]
```

对敏感操作（Shell 执行、文件写入、浏览器打开、记忆清除）和特定域名类别（银行、医疗、政府、身份提供商）实施一次性密码验证。

### 6.7 紧急停止

```bash
# 立即停止所有操作
zeroclaw estop

# 恢复需要 OTP 验证（默认）
```

配置：

```toml
[security.estop]
enabled = true
state_file = "~/.zeroclaw/estop.state"
require_otp_to_resume = true
```

### 6.8 自主性等级

| 等级 | 说明 |
|------|------|
| `read_only` | 禁止写入/执行操作 |
| `supervised` | 中/高风险操作需要审批 |
| `full` | 在配置限额内自主运行 |

配合速率限制（`max_actions_per_hour` 默认 20）和成本限制（`max_cost_per_day_cents` 默认 500）使用。

### 6.9 Rust 内存安全

ZeroClaw 完全使用 Rust 编写，通过 Rust 的类型系统和所有权模型，从根本上消除了内存损坏类漏洞（如缓冲区溢出、悬垂指针、数据竞争），无 C/C++ 运行时依赖。

## 参考

- [ZeroClaw GitHub 仓库](https://github.com/zeroclaw-labs/zeroclaw)
- [ZeroClaw Config Reference](https://github.com/zeroclaw-labs/zeroclaw/blob/main/docs/config-reference.md)
- [ZeroClaw Commands Reference](https://github.com/zeroclaw-labs/zeroclaw/blob/main/docs/commands-reference.md)
- [Deconstructing ZeroClaw - Substack](https://onepagecode.substack.com/p/deconstructing-zeroclaw-the-ultra)
- [ZeroClaw DeepWiki](https://deepwiki.com/zeroclaw-labs/zeroclaw)
