<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-23
markmeta_title: Agent 设计模式总览
markmeta_categories: ai
markmeta_tags: ai,agent,design-patterns,react,taor,router,orchestrator
-->

# Agent 设计模式总览

## 1. 为什么需要设计模式

Agent 系统的架构选择直接决定其能力边界和可靠性。与软件工程中的设计模式类似，Agent 设计模式是从大量实践中提炼的可复用架构方案。选错模式会导致：过度复杂（调试困难）、能力不足（无法完成任务）、或安全失控（Agent 行为不可预测）。

## 2. 单 Agent 模式

### 2.1 ReAct（Reasoning + Acting）

所有 Agent 系统的基础范式。将推理和行动交织在循环中：

```
Thought: 分析当前状态，决定下一步
Action:  调用工具执行操作
Observation: 观察工具返回结果
→ 循环直到任务完成
```

**适用场景**：中等复杂度的单步/多步任务，工具集有限（5-10 个）。

**局限**：没有显式的自我验证环节，推理和执行交替进行可能导致"行动偏差累积"。

### 2.2 TAOR（Think-Act-Observe-Repeat）

Claude Code 对 ReAct 的扩展，增加了 Pre-check 和 Self-Critique 环节：

```
┌─────────────────────────────────┐
│  1. Pre-check & Compaction      │  ← 检查资源压力，必要时压缩
│  2. Thinking (可选深度思考)      │  ← 链式推理
│  3. Self-Critique (可选自检)     │  ← 推理过程自我验证
│  4. Action (LLM 调用)          │  ← 输出工具调用或最终回复
│  5. Tool Execution             │  ← 安全检查 + 执行
│  6. Post-processing            │  ← 决定继续或终止
│  ←── 循环 ──→                   │
└─────────────────────────────────┘
```

**关键区别**：
- **模型控制循环**：代码不决定何时调用工具、何时停止——模型自己决定
- **资源感知**：每轮循环前检查上下文压力
- **可选的思考深度**：简单任务跳过深度思考，复杂任务启用

**适用场景**：需要长时间运行的复杂任务，上下文窗口大（100K+ tokens）。

> TAOR 的完整实现细节，详见[第8章 Claude Code 深度解析](../claude-code-practices/)。

### 2.3 Plan-Then-Execute

先生成完整计划，再逐步执行：

```
需求 → Planner Agent → 结构化计划
                          ↓
                     Executor Agent → 逐步执行
                          ↓
                     Verifier → 验证结果
                          ↓
                     Human Approval → 审批
```

**代表实现**：Devin（全自主编程 Agent）。

**适用场景**：高自主性任务、需要人工审批门控的场景。

**局限**：计划可能因执行中的意外而失效，需要重新规划（re-planning）机制。

## 3. 多 Agent 协作模式

### 3.1 路由模式（Router）

中央调度器根据任务类型分配给专用 Agent：

```
用户请求 → Router Agent → 分类判断
                           ├── → 代码 Agent
                           ├── → 文档 Agent
                           └── → 数据分析 Agent
```

**适用场景**：多技能覆盖，任务类型多样但彼此独立。

**关键设计**：Router 的分类准确率决定整个系统的上限。

### 3.2 编排模式（Orchestrator）

指挥 Agent 按计划协调执行，Agent 之间有依赖关系：

```
Orchestrator
  ├── Step 1: Research Agent → 调研结果
  ├── Step 2: Analysis Agent (依赖 Step 1) → 分析报告
  └── Step 3: Writer Agent (依赖 Step 2) → 最终文档
```

**适用场景**：复杂工作流，步骤之间有明确的数据依赖。

### 3.3 投票模式（Voting）

多个 Agent 独立完成同一任务，通过投票选最优结果：

```
同一任务 → Agent A → 结果 A ─┐
         → Agent B → 结果 B ─┼→ 投票/评估 → 最终结果
         → Agent C → 结果 C ─┘
```

**适用场景**：需要高可靠性、结果可比较的任务（如代码生成、翻译）。

**代价**：成本和延迟乘以 Agent 数量。适合"宁可多花钱也不能出错"的场景。

### 3.4 辩论模式（Debate）

Agent 之间通过辩论推进推理：

```
Agent A: 我认为答案是 X，因为...
Agent B: 我不同意，Y 更合理，因为...
Agent A: 你说的有道理，但考虑到 Z...
→ 经过多轮辩论达成共识
```

**适用场景**：复杂推理、法律分析、策略制定等需要多角度论证的任务。

### 3.5 层级模式（Hierarchy）

管理 Agent 分解任务，委派给执行 Agent：

```
Manager Agent
  ├── Team Lead A
  │     ├── Worker A1
  │     └── Worker A2
  └── Team Lead B
        ├── Worker B1
        └── Worker B2
```

**适用场景**：大规模任务分解、企业级 Agent 系统。

### 3.6 Sub-Agent 隔离模式

主 Agent 派生一次性子 Agent，子 Agent 拥有独立上下文窗口，执行完毕返回摘要：

```
主 Agent (1M tokens context)
  ├── spawn Explore Agent → [独立上下文] → 返回 1-2K token 摘要
  ├── spawn Plan Agent → [独立上下文] → 返回结构化计划
  └── spawn General Agent → [独立上下文] → 返回任务结果
```

**关键收益**：
- 主 Agent 上下文不被子任务的中间结果污染
- 子 Agent 可以进行大量探索而不消耗主 Agent 的 token 预算
- 并行执行多个独立子任务

**与其他多 Agent 模式的区别**：Sub-Agent 是一次性的（spawn → execute → return），不需要复杂的 Agent 通信协议。这是多 Agent 协作中最简单但最实用的模式。

## 4. 选型决策树

根据任务特征选择合适的设计模式：

```
你的任务是什么？
│
├── 单一类型任务
│   ├── 简单（1-3 步）→ ReAct
│   ├── 复杂（多步、长时间运行）→ TAOR
│   └── 需要人工审批 → Plan-Then-Execute
│
├── 多类型任务（类型间独立）
│   └── Router + 专用 Agent
│
├── 多步骤工作流（步骤间有依赖）
│   └── Orchestrator
│
├── 高可靠性要求
│   └── Voting（多 Agent 投票）
│
└── 复杂推理 / 多角度论证
    └── Debate
```

**通用原则**：
- **从最简单的模式开始**。单 Agent + ReAct 能解决 80% 的场景
- **只在单 Agent 明确不够时才引入多 Agent**。多 Agent 的调试成本是指数级的
- **Sub-Agent 隔离是最安全的"加 Agent"方式**——不引入复杂通信，只是分担工作

## 5. 反模式：什么情况下不该用 Agent

并非所有问题都需要 Agent。以下场景使用 Agent 是过度工程化：

| 场景 | 为什么不需要 Agent | 更好的方案 |
|------|-------------------|-----------|
| 确定性流程（无需判断） | Agent 引入不必要的随机性 | 传统代码 / 工作流引擎 |
| 延迟敏感（<100ms） | Agent 推理至少数百毫秒 | 规则引擎 / 缓存 |
| 简单分类任务 | 杀鸡用牛刀 | 单次 LLM 调用 + 结构化输出 |
| 数据密集型计算 | LLM 不擅长大量数值计算 | 传统 ETL / SQL |

**Agent 工程的常见陷阱**：
- **Agent 套 Agent 套 Agent**：层级过深导致延迟爆炸和错误放大
- **用 Agent 替代单元测试**：Agent 验证代码正确性不如跑测试可靠
- **忽略失败路径**：只测试 happy path，生产中遇到异常就崩溃
- **上下文过载**：一次性注入所有信息，期望 Agent 自己筛选（它不会）

## 参考

- [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [ReAct: Synergizing Reasoning and Acting in Language Models (Yao et al., 2022)](https://arxiv.org/abs/2210.03629)
- [Building Effective AI Coding Agents for the Terminal (arXiv)](https://arxiv.org/html/2603.05344v3)
- [LangGraph: Multi-Agent Patterns](https://langchain-ai.github.io/langgraph/concepts/multi_agent/)
- [CrewAI: Agent Collaboration Patterns](https://docs.crewai.com/concepts/collaboration)
- [AutoGen: Conversation Patterns](https://microsoft.github.io/autogen/docs/tutorial/conversation-patterns)
