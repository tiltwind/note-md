<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-18
markmeta_title: OpenClaw 自进化机制：如何越用越聪明而不是越来越混乱
markmeta_categories: ai
markmeta_tags: ai,openclaw,agent,memory,evolution
-->

# OpenClaw 自进化机制：如何越用越聪明而不是越来越混乱

一个长期运行的 AI Agent 面临一个核心矛盾：**它需要不断积累经验来变得更好用，但无限制的积累又会让它变得臃肿、混乱、甚至倒退**。OpenClaw 通过 Workspace 文件体系和记忆管理机制，提供了一套让 Agent "真正进化"的框架。

本文讨论如何用好这些机制，避免 Agent 从"聪明助手"退化成"混乱的记忆垃圾堆"。

## 1. 平台提供了什么 vs 需要你自己做什么

理解 OpenClaw 的进化能力，首先要区分**平台内置机制**和**需要用户配置的策略**：

### 1.1 平台内置机制（开箱即用）

以下是 OpenClaw 框架层面提供的能力，onboard 后即可工作：

| 机制 | 行为 | 触发方式 |
|------|------|---------|
| **Workspace 文件加载** | 每次会话自动加载 AGENTS.md、SOUL.md、USER.md、IDENTITY.md、TOOLS.md | 会话开始时 |
| **MEMORY.md 加载** | 私聊会话时自动加载长期记忆索引 | 私聊会话开始时 |
| **memory/ 记忆搜索** | Agent 可在对话中搜索和读写 memory/ 目录下的文件 | 对话过程中按需 |
| **HEARTBEAT.md 执行** | Agent 空闲时自动读取并执行清单中的任务 | 心跳唤醒时（可配置间隔） |
| **BOOT.md 执行** | Gateway 重启时自动执行启动仪式 | Gateway 启动时 |
| **IDENTITY.md 自动生成** | 首次引导（bootstrap）时自动生成 Agent 身份 | 首次启动 |
| **Skills 三级加载** | workspace skills → managed skills → bundled skills 按优先级加载 | 会话开始时 |
| **多 Agent Workspace 隔离** | 每个 Agent 拥有独立的 workspace、会话和记忆 | 配置 agents.list 后 |

> 关键：平台**保证这些文件会被加载和执行**，但**文件里写什么内容完全由用户决定**。

### 1.2 需要用户配置的策略（本文重点）

以下策略是本文提出的**最佳实践**，需要用户自己编写到对应文件中：

| 策略 | 写在哪里 | 平台提供了什么 |
|------|---------|---------------|
| 记忆分层结构 | MEMORY.md | 平台加载此文件，但不规定格式 |
| 定期记忆压缩和归档 | HEARTBEAT.md | 平台按心跳频率执行，但清单内容由你写 |
| 启动时身份校准 | BOOT.md | 平台在重启时执行，但仪式内容由你写 |
| 冲突检测和一致性检查 | HEARTBEAT.md | 同上 |
| 分级自主决策规则 | AGENTS.md | 平台每次会话加载，但规则由你写 |
| 进化自评 | HEARTBEAT.md | 同上 |
| 行为边界定义 | SOUL.md | 平台每次会话加载，但边界由你写 |
| 能力审计 | HEARTBEAT.md | 同上 |

换句话说：**OpenClaw 提供了"骨架"（文件会被加载和执行的机制），"血肉"需要你自己填**。一个空的 HEARTBEAT.md 不会产生任何自省行为，一个没有结构的 MEMORY.md 会自然退化为垃圾堆。

### 1.3 在哪里查看这些机制的文档

| 主题 | 文档来源 |
|------|---------|
| Workspace 文件体系 | [OpenClaw 官方文档 - Agent Workspace](https://docs.openclaw.ai/concepts/agent-workspace) |
| 记忆系统 | [OpenClaw 官方文档 - Memory](https://docs.openclaw.ai/concepts/memory) |
| Heartbeat 机制 | [OpenClaw 官方文档 - Heartbeat](https://docs.openclaw.ai/automation/heartbeat) |
| BOOT.md 启动仪式 | [OpenClaw 官方文档 - Bootstrap](https://docs.openclaw.ai/concepts/bootstrap) |
| Skills 系统 | [OpenClaw 官方文档 - Skills](https://docs.openclaw.ai/concepts/skills) |
| 多 Agent 配置 | [OpenClaw 官方文档 - Multi-Agent](https://docs.openclaw.ai/concepts/multi-agent) |
| 配置参考 | [OpenClaw 配置](openclaw-config.md)（本系列） |
| 自动化机制 | [OpenClaw 自动化与目录监控](openclaw-automation.md)（本系列） |

## 2. 进化的基础设施

### 2.1 Agent 的"大脑"结构

OpenClaw Agent 的认知体系由 Workspace 中的文件构成，每个文件承担不同的进化职责：

```
~/.openclaw/workspace/
├── IDENTITY.md       # 我是谁 ——  身份锚点，防止人格漂移
├── SOUL.md           # 我如何思考 —— 行为准则和价值观
├── USER.md           # 我服务谁 —— 用户画像和偏好
├── AGENTS.md         # 我如何工作 —— 操作规则和优先级
├── TOOLS.md          # 我能用什么 —— 工具能力说明
├── MEMORY.md         # 我记住了什么 —— 长期记忆索引
├── memory/           # 记忆存储
│   ├── 2026-03-01.md
│   ├── 2026-03-15.md
│   └── ...
├── HEARTBEAT.md      # 我该定期做什么 —— 巡检和自检任务
├── BOOT.md           # 我启动时做什么 —— 启动仪式
└── skills/           # 我学会了什么技能 —— 能力扩展
```

这不是一堆配置文件，而是一个**分层的认知架构**：

| 层次 | 文件 | 变化频率 | 类比 |
|------|------|---------|------|
| 身份层 | IDENTITY.md, SOUL.md | 极少变化 | 性格、价值观 |
| 关系层 | USER.md | 偶尔更新 | 对用户的了解 |
| 规则层 | AGENTS.md, TOOLS.md | 按需调整 | 工作方法论 |
| 经验层 | MEMORY.md, memory/ | 持续积累 | 记忆和经验 |
| 能力层 | skills/ | 按需扩展 | 新技能 |
| 习惯层 | HEARTBEAT.md, BOOT.md | 按需调整 | 日常习惯 |

**关键洞察**：上层稳定、下层活跃。身份和价值观几乎不变，但记忆每天都在增长。进化的挑战在于——**经验层的增长不能干扰上层的稳定性**。

### 2.2 记忆系统的工作方式

OpenClaw 的记忆系统包含两个部分：

**MEMORY.md** —— 长期记忆索引，每次**私聊会话**时加载：

```markdown
## 用户偏好

- 偏好中文沟通，技术术语保留英文
- 喜欢表格对比，不喜欢冗长段落
- 代码示例使用 Go 或 Python

## 项目上下文

- 主项目 myapp 使用 Go + PostgreSQL
- CI/CD 使用 GitHub Actions
- 部署环境：Debian 12，2 台生产服务器

## 已解决的问题

- 2026-03-01: myapp 数据库连接池泄漏 → 根因是未关闭 rows → 详见 memory/2026-03-01.md
- 2026-03-10: Nginx 502 间歇性发生 → upstream keepalive 配置不当 → 详见 memory/2026-03-10.md
```

**memory/ 目录** —— 日记忆文件，存储详细的交互记录和分析：

```markdown
# 2026-03-01

## 数据库连接池泄漏

用户报告 myapp 在高峰期出现 "too many connections" 错误。

**排查过程**：
1. `show processlist` 发现大量 Sleep 连接
2. 检查代码发现 `db.Query()` 后未调用 `rows.Close()`
3. 在 3 个文件中找到同类问题

**根因**：Go 的 `database/sql` 包中，`db.Query()` 返回的 `*Rows` 必须显式 Close，否则底层连接不会归还连接池。

**修复**：添加 `defer rows.Close()`，设置 `db.SetMaxOpenConns(25)`

**教训**：后续 review Go 数据库代码时，应检查所有 Query 调用是否正确关闭 Rows。
```

## 3. 进化的三种模式

### 3.1 被动进化：从对话中学习

Agent 在每次对话中自然积累经验。这是最常见也最容易失控的进化模式。

**良性被动进化**：

```
用户: 帮我检查 myapp 的日志
Agent: [执行 tail -100 /var/log/myapp/app.log]
Agent: 发现 3 个 ERROR 级别日志，集中在支付模块...
用户: 以后检查日志时直接用 journalctl -u myapp，不要看文件
Agent: [记住：myapp 日志通过 systemd journal 管理，使用 journalctl -u myapp 查看]
```

Agent 学到了一个具体的操作偏好，下次不会再犯同样的错误。

**有害的被动进化**：

```
# 随着时间推移，MEMORY.md 变成这样：
## 杂项记忆
- 用户说过"用 vim 编辑"
- 用户提到过"最近在看 Rust"
- 用户说"这个方案不好"（但没说哪个方案）
- 3月5日用户心情不好
- ...（数百条碎片化记忆）
```

碎片化记忆不仅无用，还会占用上下文窗口，稀释真正重要的信息。

### 3.2 主动进化：自我反思和知识整理

通过 HEARTBEAT.md 和 BOOT.md，Agent 可以定期进行自我反思和知识整理。

**在 HEARTBEAT.md 中定义自省任务**：

```markdown
## 记忆整理（每周日 10:00）

- 回顾本周的 memory/ 日记忆文件
- 将重复出现的模式提炼为通用经验，更新到 MEMORY.md
- 删除已过时或不再相关的记忆条目
- 如果 MEMORY.md 超过 200 行，进行压缩和归档
```

**在 BOOT.md 中定义启动检查**：

```markdown
## 启动自检

- 读取 MEMORY.md，确认内容结构清晰
- 检查最近 3 天的 memory/ 文件，快速回顾近期上下文
- 如发现 MEMORY.md 中有矛盾信息，标记并在下次对话时向用户确认
```

### 3.3 引导进化：用户主动塑造

用户可以直接编辑 Workspace 文件来引导 Agent 的进化方向，这是最可控的进化方式。

**示例：在一次糟糕的体验后调整 AGENTS.md**：

```markdown
## 规则

- 执行命令前先确认（特别是涉及生产环境的操作）
- 涉及文件删除或系统操作时请求授权
- **不要自作主张安装新软件包，先告诉我你需要什么，为什么需要**
- **执行数据库操作时，先展示 SQL 语句，等我确认后再执行**
- **修改配置文件前先备份：cp file file.bak.$(date +%s)**
```

每一条新规则通常都来自一次教训。这种进化是可追溯、可解释的。

## 4. 混乱的根源与对策

### 4.1 记忆膨胀：信息越多，质量越低

**问题**：MEMORY.md 和 memory/ 目录无限增长，Agent 每次会话都要加载大量低质量记忆，导致：
- 上下文窗口被垃圾信息占满
- 相关信息被无关信息淹没
- Agent 回复质量下降，响应变慢

**对策：分层记忆 + 定期压缩**

设计一个清晰的 MEMORY.md 结构，严格区分信息层次：

```markdown
## 核心事实（极少变更）

- 用户角色：后端工程师，主力语言 Go
- 主项目：myapp（Go + PostgreSQL + Redis）
- 部署环境：Debian 12 × 2，通过 GitHub Actions CI/CD

## 操作偏好（偶尔更新）

- 日志查看：journalctl -u <service>，不直接看文件
- 数据库操作：先展示 SQL，确认后执行
- 代码风格：遵循项目 .golangci.yml 配置

## 近期上下文（定期清理）

- [2026-03-15] 正在重构 myapp 的认证模块，从 JWT 迁移到 session
- [2026-03-10] Nginx 502 问题已修复（upstream keepalive）

## 经验教训（持续积累，定期归纳）

- Go 数据库代码 review 要检查 rows.Close()
- PostgreSQL 慢查询先看 EXPLAIN ANALYZE，不要猜
- Docker compose 修改后先 down 再 up，不要直接 restart
```

**自动化压缩策略**（通过 HEARTBEAT.md 定义）：

```markdown
## 记忆卫生（每周日 10:00）

1. 检查 MEMORY.md 行数，超过 150 行时执行压缩：
   - "近期上下文"中超过 30 天的条目移到 memory/ 归档
   - 合并重复或相似的经验教训
   - 删除已不相关的信息（已完成的项目、已离职的同事等）
2. 检查 memory/ 目录中超过 90 天的文件，归档到 memory/archive/
3. 压缩完成后报告变更摘要
```

### 4.2 人格漂移：Agent 越来越"不像自己"

**问题**：长期使用后，Agent 受大量对话上下文影响，行为风格逐渐偏离初始设定：
- 变得过于啰嗦或过于简略
- 忘记了 SOUL.md 中定义的边界
- 在不同对话中表现不一致

**对策：身份锚定**

IDENTITY.md 和 SOUL.md 是 Agent 的"宪法"，应当简洁、明确、不轻易修改：

```markdown
# IDENTITY.md

名称：Pi
角色：个人技术助手
核心原则：安全 > 准确 > 效率 > 便利
```

```markdown
# SOUL.md

## 性格

你是一个高效、专业的技术助手。回复简洁直接，避免冗余。

## 不可逾越的边界

- 不执行破坏性操作（rm -rf、drop database 等），除非用户明确确认
- 不访问或传输用户明确标记为敏感的数据
- 不确定时主动询问，不猜测
- 不在生产环境执行未经确认的变更

## 回复风格

- 优先使用表格和列表，减少段落叙述
- 代码块必须带语言标签
- 结论先行，细节按需展开
```

**启动时强化身份**（BOOT.md）：

```markdown
## 身份校准

- 重读 IDENTITY.md 和 SOUL.md，确认行为准则
- 如果近期对话中有偏离 SOUL.md 的行为，在下次对话中自我纠正
```

### 4.3 知识冲突：新旧信息打架

**问题**：Agent 记忆中存在矛盾信息，导致行为不一致：
- 旧记忆说"项目用 MySQL"，新记忆说"已迁移到 PostgreSQL"
- MEMORY.md 说"使用 Docker 部署"，实际已改为 systemd 直接运行
- 某条经验在当时成立，但环境变化后不再适用

**对策：时间戳 + 显式覆盖 + 冲突检测**

记忆条目必须带时间戳，新信息显式覆盖旧信息：

```markdown
## 部署方式

- ~~[2026-01] Docker Compose 部署~~ → [2026-03] 已改为 systemd 直接运行，原因：减少资源开销
```

在 HEARTBEAT.md 中添加冲突检测：

```markdown
## 信息一致性检查（每两周）

- 扫描 MEMORY.md，检查是否有互相矛盾的条目
- 对比 MEMORY.md 中的技术栈描述与实际项目状态
- 发现矛盾时，标记冲突并在下次对话中向用户确认
```

### 4.4 能力退化：Skills 积灰和配置腐烂

**问题**：
- 安装了很多 Skills 但大部分不再使用，占用加载时间
- 配置文件随时间积累了大量不再需要的规则
- HEARTBEAT.md 中的任务清单越来越长，部分任务已无意义

**对策：定期审计**

```markdown
## 能力审计（每月 1 日）

- 列出 skills/ 目录下所有技能，标注上次使用时间
- 超过 60 天未使用的技能，建议是否移除
- 检查 HEARTBEAT.md 中的任务，标注哪些仍有价值
- 检查 AGENTS.md 中的规则，是否有过时的条目
```

## 5. 进化实践模式

### 5.1 模式一：渐进式经验沉淀

每次对话后，Agent 不是简单地"记住发生了什么"，而是提炼出**可复用的经验**：

```
原始事件：用户让我检查 Nginx 日志，发现 502 错误是因为 upstream keepalive 超时

↓ 提炼为

经验教训：Nginx 502 排查清单 →
1. 先看 error.log 中的 upstream 相关错误
2. 检查 upstream keepalive 配置
3. 检查后端服务是否存活和响应时间
4. 检查连接数限制（worker_connections, upstream max_conns）
```

前者是流水账，后者是可复用的知识。

### 5.2 模式二：分级自主决策

不是所有进化都需要用户参与。根据影响范围分级：

| 级别 | 操作 | 是否需要用户确认 |
|------|------|-----------------|
| 低 | 记录操作偏好（如日志查看方式） | 不需要，静默记录 |
| 中 | 更新 MEMORY.md 结构 | 下次对话时简要告知 |
| 高 | 修改 AGENTS.md 规则 | 必须用户确认 |
| 极高 | 修改 SOUL.md 边界 | 必须用户明确授权 |

在 AGENTS.md 中定义：

```markdown
## 自进化规则

- 可以自主更新 memory/ 日记忆文件
- 可以自主整理 MEMORY.md（合并、归档），但需在下次对话时简要汇报变更
- 修改 AGENTS.md 必须先提出建议，用户确认后执行
- 禁止自主修改 IDENTITY.md 和 SOUL.md
```

### 5.3 模式三：启动仪式（Bootstrap Ritual）

通过 BOOT.md 定义 Agent 每次 Gateway 重启时的"启动仪式"，确保 Agent 始终从一个一致的状态开始：

```markdown
# BOOT.md

## 启动仪式

1. **身份确认**：重读 IDENTITY.md，确认"我是谁"
2. **规则加载**：重读 AGENTS.md 和 SOUL.md，确认行为边界
3. **上下文恢复**：扫描最近 3 天的 memory/ 文件，回顾近期交互
4. **环境检查**：运行关键服务健康检查，确认工作环境正常
5. **就绪报告**：通过 Telegram 发送简短启动报告
```

启动仪式的价值在于：即使 Agent 在上次会话中"跑偏"了，重启后也能回到正轨。

### 5.4 模式四：多 Agent 分工进化

在[多 Agent 配置](openclaw-multi-agent.md)中，不同角色的 Agent 可以各自独立进化，互不干扰：

```
workspace-analyst/    → 积累需求分析经验
workspace-architect/  → 积累架构设计经验
workspace-developer/  → 积累编码和调试经验
workspace-tester/     → 积累测试策略经验
```

每个 Agent 的记忆和经验都是领域专精的，不会因为跨领域信息而产生干扰。这类似于团队中每个人各自成长，但不需要一个人记住所有领域的知识。

## 6. 反模式：这些做法会让 Agent 越来越笨

### 6.1 什么都记

```markdown
# ❌ 反模式：MEMORY.md 变成流水账
- 3月1日帮用户写了个 Python 脚本
- 3月1日用户说了"谢谢"
- 3月2日查了一下天气
- 3月2日用户问了 Go 的 goroutine
- 3月3日...
```

**信噪比极低**，Agent 加载这些记忆时浪费了宝贵的上下文窗口。

### 6.2 从不清理

memory/ 目录里积累了 200 个日记忆文件，MEMORY.md 超过 500 行，Skills 目录里有 30 个技能但只用过 5 个。Agent 每次启动都要处理这些"认知包袱"。

### 6.3 频繁改变人格

```markdown
# ❌ 反模式：SOUL.md 每周改一次
# 第 1 周：你是一个简洁的助手
# 第 2 周：你是一个详细的教学助手
# 第 3 周：你是一个有趣的朋友
```

频繁修改身份定义会导致 Agent 行为不一致，用户也会失去对 Agent 的信任。

### 6.4 不分层的规则

```markdown
# ❌ 反模式：把所有规则塞进 AGENTS.md
- 使用 vim 编辑
- 数据库操作先确认
- 回复用中文
- myapp 的日志用 journalctl
- 上次 review 代码发现 rows 没 close
- PostgreSQL 慢查询用 EXPLAIN ANALYZE
- Docker 修改后先 down 再 up
- ...（100+ 条混在一起）
```

操作规则、个人偏好、经验教训、项目上下文全部混在一起，Agent 无法区分优先级。

## 7. 进化质量评估

如何判断 Agent 是在"进化"还是在"退化"？可以定期检查以下指标：

| 指标 | 进化 | 退化 |
|------|------|------|
| MEMORY.md 行数 | 稳定在 100-200 行 | 持续增长，超过 500 行 |
| 重复询问 | 同类问题不再重复问 | 反复问已回答过的问题 |
| 任务完成速度 | 常见任务一步到位 | 需要多次纠正才能完成 |
| 回复一致性 | 风格和判断标准稳定 | 同类问题回答差异大 |
| 上下文利用 | 主动引用相关记忆 | 忽略已有经验，从零开始 |
| Skills 利用率 | 安装的技能大部分在用 | 大量技能从未被触发 |

可以将这个检查表加入 HEARTBEAT.md，让 Agent 每月自评一次：

```markdown
## 进化自评（每月 15 日）

- 统计 MEMORY.md 当前行数，与上月对比
- 回顾本月对话，是否有重复询问的情况
- 检查 skills/ 使用频率
- 生成简要自评报告发送给用户
```

## 8. 总结

真正的进化不是"记住更多"，而是"知道什么重要"。

| 原则 | 实践 |
|------|------|
| **分层存储** | 身份/规则/经验/记忆严格分层，各司其职 |
| **定期压缩** | 通过 HEARTBEAT.md 自动化记忆清理和归纳 |
| **身份锚定** | IDENTITY.md 和 SOUL.md 是"宪法"，极少修改 |
| **经验提炼** | 从事件中提取可复用模式，而非记录流水账 |
| **显式覆盖** | 新信息明确替代旧信息，避免矛盾共存 |
| **分级自主** | 低影响的进化自主执行，高影响的进化需要确认 |
| **能力审计** | 定期检查 Skills 和规则的实际使用情况 |

Agent 的进化周期应该是：**积累 → 提炼 → 压缩 → 应用 → 再积累**，而不是**积累 → 积累 → 积累 → 崩溃**。

## 参考

- [OpenClaw 配置](openclaw-config.md) — Workspace 文件体系详解
- [OpenClaw 多 Agent 配置](openclaw-multi-agent.md) — 多 Agent 隔离进化
- [OpenClaw 自动化与目录监控](openclaw-automation.md) — Heartbeat 和 Cron 机制
- [OpenClaw 安全加固](openclaw-security.md) — 行为边界控制
