<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Claude Code 深度解析总览
markmeta_categories: ai
markmeta_tags: ai,claude-code,agent,taor,architecture,anthropic
-->

# Claude Code 深度解析总览

> 本章是全书中 Claude Code 架构的**唯一深度解析入口**。其他章节在涉及 Claude Code 时仅做简短引用并指向本章。

## 1. 设计哲学

Claude Code 的成功来自一个反直觉的洞察：

> **LLM 本身已经足够难以调试——额外的复杂性（多 Agent、复杂交接、精心设计的 RAG）会让调试指数级变难。**

核心原则：**做能工作的最简单方案**。

具体体现：
- 单线程主循环，约 50 行核心逻辑
- 模型控制循环，而非代码控制
- 能力原语取代专用工具
- Sub-Agent 严格隔离

## 2. TAOR 主循环

Think-Act-Observe-Repeat (TAOR) 是 Claude Code 的核心架构，扩展了 ReAct 范式（详见[第4章 Agent 设计模式](../agent-design-patterns/)中的模式对比）：

```
┌─────────────────────────────────────────────────┐
│                  TAOR Loop                       │
│                                                 │
│  1. Pre-check & Compaction                      │
│     - 消耗注入的消息                              │
│     - 检查内存压力，必要时压缩                     │
│                                                 │
│  2. Thinking (可选)                              │
│     - 链式思维推理                                │
│     - 深度可配置                                  │
│                                                 │
│  3. Self-Critique (可选)                         │
│     - 推理过程自我验证                            │
│                                                 │
│  4. Action                                      │
│     - LLM 调用，携带完整工具 Schema               │
│     - 输出工具调用或最终回复                       │
│                                                 │
│  5. Tool Execution                              │
│     - 通过 ToolRegistry 分发                     │
│     - 安全检查 + 权限验证                         │
│                                                 │
│  6. Post-processing                             │
│     - 决定继续迭代或终止                          │
│     - 结果注入下一轮上下文                        │
│                                                 │
│  ←────── 循环 ──────→                            │
└─────────────────────────────────────────────────┘
```

关键设计：**模型控制循环**。代码不决定何时调用工具、何时停止——模型自己决定。运行时只负责执行模型的指令并返回结果。

## 3. 工具系统

### 3.1 能力原语 > 专用集成

Claude Code 没有 100 个专用工具，而是提供 4 个能力原语：

| 原语 | 代表工具 | 覆盖范围 |
|------|---------|---------|
| Read | Read, Glob, Grep | 信息获取 |
| Write | Write, Edit | 内容创建与修改 |
| Execute | Bash | 系统操作（万能适配器） |
| Connect | Agent, WebFetch | 子任务分发与外部交互 |

**Bash 作为万能适配器**：任何无法通过原语直接完成的操作，都可以通过 Bash 执行。这使得工具集极简但覆盖面极广。

> 工具系统的通用设计原则（Registry-Based Dispatch、延迟发现等），详见[第3章 Harness 工程](../harness-engineering/)。

### 3.2 ToolRegistry

中央注册表将工具名映射到类型化处理器：

```
用户请求 → LLM 输出工具调用 → ToolRegistry 查找 → Handler 执行 → 结果返回
```

设计要点：
- 内置工具在启动时急切注册（Scaffolding 阶段）
- MCP 外部工具延迟发现（按需加载）
- 语义搜索按需注入工具 Schema（节省上下文空间）

### 3.3 模糊匹配编辑

Edit 工具使用 9-pass 匹配链，从严格到宽松逐步尝试：

```
Pass 1: 精确字符串匹配
Pass 2: 空白字符归一化
Pass 3: 缩进偏移补偿
...
Pass 9: 最宽松的模糊匹配
```

这解决了 LLM 输出代码时常见的微小格式差异问题。

## 4. Sub-Agent 架构

### 4.1 内置子 Agent 类型

| Agent 类型 | 工具权限 | 用途 |
|-----------|---------|------|
| Explore | 只读（Glob, Grep, Read） | 快速代码库探索 |
| Plan | 只读 | 架构设计与实现规划 |
| General-purpose | 全部工具 | 复杂多步骤任务 |

### 4.2 上下文隔离

每个子 Agent 运行独立的 TAOR 循环，拥有独立的上下文窗口：

```
主 Agent (1M tokens context)
  │
  ├── spawn Explore Agent ──→ [独立上下文] ──→ 返回 1-2K token 摘要
  │
  ├── spawn Plan Agent ──→ [独立上下文] ──→ 返回结构化计划
  │
  └── spawn General Agent ──→ [独立上下文] ──→ 返回任务结果
```

关键收益：
- 主 Agent 上下文不被子任务的中间结果污染
- 子 Agent 可以进行大量探索而不消耗主 Agent 的 token 预算
- 并行执行多个独立子任务

> Sub-Agent 隔离作为通用设计模式的分析，详见[第4章 Agent 设计模式](../agent-design-patterns/)。

## 5. 上下文管理

### 5.1 四大子系统

1. **System Reminders**：在对话流中的决策点注入针对性指导
2. **Prompt Composer**：启动时模块化组装系统提示
3. **Memory**：6 层记忆体系实现跨会话连续性
4. **Compaction**：约 50% 使用率时自动压缩历史

> 上下文管理的通用原则（Just-In-Time、信噪比优化等），详见[第2章 上下文工程](../context-engineering/)。

### 5.2 6 层记忆体系

```
Layer 1: Organization (组织级)
Layer 2: Project (项目级 - CLAUDE.md)
Layer 3: User (用户级 - 偏好、反馈)
Layer 4: Auto-Learned Patterns (自动学习)
Layer 5: Session (会话级 - 当前对话)
Layer 6: Task (任务级 - 当前任务进度)
```

从持久到临时，从宽范围到窄范围，构成完整的记忆层级。

关键设计：
- **文件即记忆**：记忆存储为 Markdown 文件，可读、可编辑、可版本控制
- **记忆索引**：MEMORY.md 作为索引，避免一次性加载所有记忆
- **记忆分类**：user / feedback / project / reference 四种类型
- **自动过期**：记忆可能过时，使用前需验证当前有效性

> 记忆系统的学术分类和生产级框架对比，详见[第5章 Agent 记忆与自进化](../agent-memory/)。

### 5.3 语义工具搜索

不是一次性将所有工具 Schema 注入上下文，而是：

1. 维护工具描述的向量索引
2. 根据当前任务语义搜索相关工具
3. 只注入匹配的工具 Schema

这在工具数量多时显著节省上下文空间。

## 6. Scaffolding 与 Harness

Claude Code 清晰体现了 Scaffolding/Harness 的分工：

| 阶段 | Claude Code 中的体现 |
|------|---------------------|
| Scaffolding（启动前） | Prompt Composer 组装系统提示、ToolRegistry 注册内置工具、初始化子 Agent 类型 |
| Harness（运行时） | TAOR 循环运行、工具调度与执行、上下文压缩、安全检查与审批 |

> Scaffolding vs Harness 的通用概念辨析，详见[第3章 Harness 工程](../harness-engineering/)。

## 7. 安全模型

- **可逆性评估**：本地可逆操作自动执行；不可逆或影响共享状态的操作需用户确认
- **权限模式**：用户选择自动允许的操作类型
- **Hooks**：在工具执行前后插入自定义验证逻辑
- **沙箱**：Bash 命令在受限环境中执行

> 安全纵深防御的完整体系，详见[第9章 评测、可观测性与安全](../agent-eval-observability/)。

## 8. 为什么 Claude Code 成为标杆

Claude Code 在 2025 年末成为主导编程 Agent 的关键因素：

1. **1M Token 上下文**：Opus 4.6 的百万 token 上下文窗口意味着可以一次性理解整个中大型代码库
2. **Agent Teams**：真正的多 Agent 协作，并行处理不同方面的任务
3. **架构简洁性**：单线程 TAOR 循环，约 50 行核心逻辑，极易理解和调试
4. **能力原语**：4 个基础工具覆盖所有场景，Bash 作为万能适配器
5. **企业定价策略**：积极的价格策略推动企业采用

核心启示：**简洁架构 + 强模型 > 复杂架构 + 弱模型**。当模型足够强时，减少工程复杂性反而能获得更好的效果。

## 参考

- [Building Effective AI Coding Agents for the Terminal (arXiv)](https://arxiv.org/html/2603.05344v3)
- [Claude Code Architecture (Reverse Engineered)](https://vrungta.substack.com/p/claude-code-architecture-reverse)
- [What Makes Claude Code So Damn Good](https://minusx.ai/blog/decoding-claude-code/)
- [ZenML: Claude Code Agent Architecture](https://www.zenml.io/llmops-database/claude-code-agent-architecture-single-threaded-master-loop-for-autonomous-coding)
- [Claude Code System Prompts (GitHub)](https://github.com/Piebald-AI/claude-code-system-prompts)
