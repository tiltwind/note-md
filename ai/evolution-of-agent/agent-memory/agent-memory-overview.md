<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Agent 记忆与自进化总览
markmeta_categories: ai
markmeta_tags: ai,memory,agent,episodic,semantic,procedural,self-improving,openclaw,mem0,letta,zep
-->

# Agent 记忆与自进化总览

## 1. 为什么记忆是关键

没有记忆的 Agent 是**无状态工具**——每次对话都从零开始，无法积累经验，无法适应用户。有了记忆，Agent 才能成为**有状态的协作者**：

- 记住用户偏好和工作习惯
- 从错误中学习，避免重复犯错
- 积累项目知识，提升效率
- 维持跨会话的上下文连续性

## 2. 记忆的学术分类

### 2.1 按存储介质分类

| 类型 | 存储位置 | 特点 | 示例 |
|------|---------|------|------|
| Token 级 | 上下文窗口中的显式文本 | 可读、可编辑、有容量限制 | 对话历史、System Prompt |
| 参数级 | 模型权重 | 隐式、通过训练获得 | Fine-tuning、RLHF |
| 隐式/潜在级 | 隐藏状态和激活 | 中间计算、不可直接访问 | Attention 缓存、KV Cache |

对于 Agent 系统（不做 fine-tuning），主要关注 **Token 级记忆**的工程实现。

### 2.2 按功能分类：三类长期记忆

借鉴认知心理学的分类：

| 类型 | 内容 | 人类类比 | Agent 实现 |
|------|------|---------|-----------|
| 情景记忆（Episodic） | "上周二，方案 X 因为 Z 失败了" | 个人经历 | 对话历史 RAG、`.learnings/` |
| 语义记忆（Semantic） | "条件 A+B 时方案 X 效果最好" | 知识百科 | 知识图谱、向量库、CLAUDE.md |
| 程序记忆（Procedural） | "如何执行部署流程" | 肌肉记忆 | 函数/技能、Tool 定义、代码 |

## 3. 三类长期记忆的实现

### 3.1 情景记忆（Episodic Memory）

存储具体事件，包含时间、地点、情境、结果等上下文信息。

**实现方式**：
- **对话历史 RAG**：将历史对话存入向量数据库，新对话时检索相关历史
- **结构化事件日志**：如 OpenClaw 的 `.learnings/ERRORS.md`，结构化的情景记忆
- **时间戳索引**：按时间排序，支持"最近一周的相关经验"类查询

**应用场景**：
```
用户: "上次我们怎么解决了 Docker 权限问题来着？"
Agent: [检索情景记忆] "2026-03-15 我们通过将用户添加到 docker group 解决了此问题"
```

### 3.2 语义记忆（Semantic Memory）

从具体经验中提炼出的通用知识和事实。

**实现方式**：
- **向量数据库 + RAG**：Pinecone、Weaviate、Chroma 等存储知识片段
- **知识图谱**：Zep 的 Graphiti 引擎，用图结构关联实体和关系
- **结构化文件**：CLAUDE.md 中的项目规则就是语义记忆

**应用场景**：
```
Agent 知道: "本项目使用 PostgreSQL 16，测试不允许 mock 数据库"
→ 这是从多次经验中提炼出的通用规则
```

### 3.3 程序记忆（Procedural Memory）

"如何做"的知识——已学会的技能和行为模式。

**实现方式**：
- **Tool 定义**：工具 Schema 就是编码化的程序记忆
- **Skill 文件**：OpenClaw 的 Skill 系统
- **代码模板**：常用操作的代码片段和流程脚本

**应用场景**：
```
Agent 面对 "部署到生产环境" 的请求，自动执行：
1. 运行测试 → 2. 构建镜像 → 3. 推送到 Registry → 4. 更新 K8s 配置
```

## 4. 生产级记忆框架

### 4.1 Mem0

**定位**：SaaS 记忆层，为 AI 应用提供即插即用的记忆能力。

| 特性 | 详情 |
|------|------|
| 核心能力 | 从对话中自动提取记忆，用于个性化 |
| 性能 | p95 延迟降低 91%，token 成本节约 90%+ |
| 架构 | 云 API，无需自建基础设施 |
| 适用 | 需要快速集成记忆能力的产品 |

Y Combinator 支持，目前生产就绪度最高。

### 4.2 Letta（前 MemGPT）

**定位**：记忆即 Agent 状态——记忆是 Agent 的一等公民，而非附加功能。

| 特性 | 详情 |
|------|------|
| 核心能力 | 可编辑的记忆块、有状态的记忆运行时 |
| 特色 | Agent 可以自主管理自己的记忆 |
| 架构 | 自部署，完全控制数据 |
| 适用 | 需要深度记忆定制的 Agent 系统 |

MemGPT 论文的核心思想：将操作系统的虚拟内存概念应用到 LLM 上下文管理。

### 4.3 Zep

**定位**：情景 + 时序记忆，基于知识图谱。

| 特性 | 详情 |
|------|------|
| 核心能力 | Graphiti 引擎，多层记忆（情景 + 语义 + 群组） |
| 特色 | 时间感知的记忆检索 |
| 架构 | 自部署，图数据库后端 |
| 适用 | 需要复杂关系建模的记忆场景 |

### 4.4 选型建议

| 你的需求 | 推荐框架 |
|---------|---------|
| 快速集成，不想自建基础设施 | Mem0 |
| Agent 需要自主管理记忆，深度定制 | Letta |
| 需要复杂关系建模和时序查询 | Zep |
| 轻量级，文件即记忆 | 自建（参考 Claude Code 的文件记忆模式） |

## 5. 实践案例：Claude Code 的 6 层记忆

Claude Code 实现了从宏观到微观的 6 层记忆体系：

```
┌─────────────────────────────────────────────┐
│ Layer 1: Organization  (组织级 - 全局规则)    │
├─────────────────────────────────────────────┤
│ Layer 2: Project  (项目级 - CLAUDE.md)       │
├─────────────────────────────────────────────┤
│ Layer 3: User  (用户级 - 偏好、反馈)          │
├─────────────────────────────────────────────┤
│ Layer 4: Auto-Learned  (自动学习 - 模式识别)  │
├─────────────────────────────────────────────┤
│ Layer 5: Session  (会话级 - 当前对话)         │
├─────────────────────────────────────────────┤
│ Layer 6: Task  (任务级 - 当前任务进度)        │
└─────────────────────────────────────────────┘
```

关键设计：
- **文件即记忆**：记忆存储为 Markdown 文件，可读、可编辑、可版本控制
- **记忆索引**：MEMORY.md 作为记忆索引文件，避免一次性加载所有记忆
- **记忆分类**：user / feedback / project / reference 四种类型
- **自动过期**：记忆可能过时，使用前需验证当前有效性

> Claude Code 记忆系统的完整架构，详见[第8章 Claude Code 深度解析](../claude-code-practices/)。

## 6. Agent 自进化机制

记忆的更高阶应用是让 Agent 从经验中**自主学习和进化**——不是模型微调，而是通过修改加载到上下文窗口的文件内容来改变 Agent 行为。

### 6.1 自进化触发条件

Agent 在以下场景中触发自我改进：

| # | 触发条件 | 示例 |
|---|---------|------|
| 1 | 命令/操作意外失败 | Docker 命令因权限不足失败 |
| 2 | 用户纠正 Agent | "不要用 mock，要用真实数据库" |
| 3 | 用户请求缺失功能 | "你能不能监控目录变化？" |
| 4 | 外部 API/工具失败 | GitHub API 返回 rate limit 错误 |
| 5 | Agent 发现自身知识过时 | 尝试使用已废弃的 API |
| 6 | 发现更优方法 | 找到比当前方案更高效的命令 |

### 6.2 案例：OpenClaw 的自进化体系

OpenClaw 是 Agent 自进化机制的典型实现，展示了完整的"学习→存储→晋升→进化"流程。

**存储架构**：

```
.learnings/
├── LEARNINGS.md          # 通用学习记录
├── ERRORS.md             # 错误模式与修复方案
└── FEATURE_REQUESTS.md   # 用户请求的功能追踪
```

每条学习记录包含结构化元数据（唯一 ID、时间戳、优先级、状态、领域标签），支持后续检索和统计。

**知识晋升机制**：

学习记录不会永远停留在 `.learnings/` 目录。当某条学习被验证为高价值且具有普遍性时，它被"晋升"到 Workspace 级别：

```
.learnings/ (临时学习)
    │  验证 + 泛化
    ▼
Workspace 文件 (持久化行为规则)
├── CLAUDE.md    → 项目级指令
├── AGENTS.md    → Agent 配置
└── SOUL.md      → 人格与沟通风格
```

晋升条件：同类错误出现 3+ 次，或用户反复给出相同纠正。一旦写入 Workspace 文件，该规则在所有未来会话中自动加载。

**Foundry 元进化**——"构建 Agent 的 Agent"：

当某个操作模式达到 5+ 次使用且 70%+ 成功率时，OpenClaw Foundry 将其自动结晶为独立的 Skill/工具，包含工具定义、执行逻辑、测试用例和文档。这实现了 Agent 能力的自主扩展。

**ZeroClaw**：OpenClaw 的 Rust 轻量级替代方案，保留核心自进化机制，二进制仅 3.4MB，冷启动 <10ms，面向生产环境和安全敏感场景。

### 6.3 自进化的风险与约束

自进化不是无条件的好事：

- **学习偏差**：如果早期错误样本有偏，Agent 会学到错误的规则
- **规则冲突**：不同时期学到的规则可能矛盾
- **晋升阈值**：过低的阈值导致噪声规则进入 Workspace，过高则学习太慢
- **需要人类监督**：关键规则的晋升应有人工确认环节

## 7. 高级架构

### 7.1 MAGMA

Multi-Graph based Agentic Memory Architecture——基于多图结构的 Agent 记忆架构，将不同类型的记忆组织在关联的图结构中。

### 7.2 混合记忆架构

生产系统通常组合多种记忆类型：

```
短期记忆 (上下文窗口)
    ↕ 压缩/检索
中期记忆 (会话级缓存)
    ↕ 提炼/索引
长期记忆 (向量库 + 知识图谱 + 文件)
```

## 参考

- [Memory in the Age of AI Agents (Survey)](https://arxiv.org/abs/2512.13564)
- [Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory](https://arxiv.org/abs/2504.19413)
- [3 Types of Long-Term Memory AI Agents Need](https://machinelearningmastery.com/beyond-short-term-memory-the-3-types-of-long-term-memory-ai-agents-need/)
- [Letta (GitHub)](https://github.com/letta-ai/letta)
- [Redis: AI Agent Memory Architecture](https://redis.io/blog/ai-agent-memory-stateful-systems/)
- [AWS: AgentCore Long-Term Memory Deep Dive](https://aws.amazon.com/blogs/machine-learning/building-smarter-ai-agents-agentcore-long-term-memory-deep-dive/)
- [Self-Improving Agent — ClawHub](https://clawhub.ai/pskoett/self-improving-agent)
- [OpenClaw Foundry (GitHub)](https://github.com/lekt9/openclaw-foundry)
- [OpenClaw vs ZeroClaw Comparison](https://sparkco.ai/blog/openclaw-vs-zeroclaw-which-ai-agent-framework-should-you-choose-in-2026)
