<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Agent 框架全景总览
markmeta_categories: ai
markmeta_tags: ai,agent,framework,langchain,langgraph,crewai,autogen,multi-agent
-->

# Agent 框架全景总览

## 1. 演进时间线

| 年份 | 关键事件 | 趋势 |
|------|---------|------|
| 2023 | RAG 之年；OpenAI Function Calling (6月) | 线性链式 Agent |
| 2024 | Agentic RAG；LangChain → LangGraph 转型；CrewAI 崛起 | 框架爆发 |
| 2025 | "Agent 之年"；Microsoft 合并 AutoGen + Semantic Kernel；企业部署 | 生产落地 |

## 2. 主流框架深度对比

### 2.1 LangChain / LangGraph

**演进**：LangChain（线性链）→ LangGraph（状态图）

LangGraph 是当前 LangChain 团队推荐的 Agent 构建方式：

```
状态图 (StateGraph)
├── 节点 (Node): 执行具体操作的函数
├── 边 (Edge): 节点之间的转换规则
├── 条件边: 基于状态决定下一步
└── 状态: 图中流转的数据
```

**核心优势**：
- 图驱动的工作流，Agent 可以回溯和循环
- Human-in-the-Loop 内置支持
- 与 LangSmith 集成的可观测性
- 适合需要复杂流程控制的 Agent

**局限**：
- 抽象层过多，简单任务反而复杂化
- 调试需要理解图的状态流转
- 学习曲线相对陡峭

### 2.2 CrewAI

**核心概念**：角色驱动的任务执行

```
Crew (团队)
├── Agent: Researcher (研究员)
│     └── Task: 调研竞品
├── Agent: Writer (写手)
│     └── Task: 撰写报告
└── Agent: Reviewer (审阅者)
      └── Task: 质量检查
```

**核心优势**：
- 角色-任务映射，直观的团队协作模型
- Fortune 500 中 60% 使用
- 10万+ Agent 执行/天
- 上手最快，概念最直观

**局限**：
- 角色设定依赖 Prompt，质量不稳定
- 复杂流程控制不如 LangGraph 灵活
- Agent 间通信模式相对固定

### 2.3 AutoGen (Microsoft)

**核心概念**：对话优先的多 Agent 框架

2025年10月与 Semantic Kernel 合并为统一的 Microsoft Agent Framework。

**核心优势**：
- Agent 之间通过对话协作
- 支持人类参与对话
- 灵活的对话模式（轮询、广播、选择性响应）
- 深度集成 Azure 生态

**局限**：
- 合并后 API 处于过渡期
- 对话驱动模式对于确定性工作流不够高效
- Azure 生态绑定较深

### 2.4 新兴框架

| 框架 | 来源 | 核心优势 | 适用场景 |
|------|------|---------|---------|
| OpenAI Agents SDK | OpenAI | 轻量、与 OpenAI API 深度集成 | OpenAI 生态用户 |
| Google ADK | Google | Vertex AI 集成、企业级安全 | GCP 生态用户 |
| Amazon Bedrock Agents | AWS | 托管服务、与 AWS 生态集成 | AWS 生态用户 |
| Claude Agent SDK | Anthropic | 与 Claude API 深度集成、类型安全 | Anthropic 生态用户 |

## 3. 框架横向对比

### 3.1 技术维度对比

| 维度 | LangGraph | CrewAI | AutoGen | OpenAI SDK |
|------|-----------|--------|---------|------------|
| 架构模式 | 状态图 | 角色-任务 | 对话驱动 | 轻量级链 |
| 多 Agent | 图节点 | Crew 团队 | 对话组 | Handoff |
| 流程控制 | 条件边、循环 | 顺序/并行 | 对话轮次 | 线性 |
| 可观测性 | LangSmith | 内置日志 | 对话记录 | OpenAI 平台 |
| 学习曲线 | 高 | 低 | 中 | 低 |
| 社区规模 | 最大 | 快速增长 | 中等 | 增长中 |

### 3.2 生产就绪度对比

| 维度 | LangGraph | CrewAI | AutoGen |
|------|-----------|--------|---------|
| 错误恢复 | 检查点 + 重试 | 基础重试 | 对话级重试 |
| 状态持久化 | 内置 | 需自建 | 内置 |
| 成本控制 | LangSmith 追踪 | 基础统计 | Azure 集成 |
| 安全模型 | Human-in-the-Loop | 基础权限 | 对话审批 |
| 部署方式 | LangServe / 自建 | Docker / Cloud | Azure / 自建 |

## 4. 多智能体协作模式

### 4.1 框架对协作模式的支持

| 模式 | LangGraph | CrewAI | AutoGen |
|------|-----------|--------|---------|
| 路由 (Router) | 条件边 | 不直接支持 | GroupChat |
| 编排 (Orchestrator) | 状态图 | Sequential/Hierarchical | 对话管理器 |
| 投票 (Voting) | 自定义节点 | 不直接支持 | 多回复投票 |
| 辩论 (Debate) | 循环图 | 不直接支持 | 自然支持 |
| 层级 (Hierarchy) | 子图嵌套 | Hierarchical Process | 嵌套对话 |

> 各协作模式的通用设计，详见[第4章 Agent 设计模式](../agent-design-patterns/)。

## 5. 选型决策指南

### 5.1 决策流程

```
你的 Agent 需求是什么？
│
├── 需要复杂流程控制（循环、分支、回溯）？
│   └── YES → LangGraph
│
├── 需要直观的多角色协作？
│   └── YES → CrewAI
│
├── 已深度绑定某个云生态？
│   ├── Azure → AutoGen / Microsoft Agent Framework
│   ├── AWS → Bedrock Agents
│   └── GCP → Google ADK
│
├── 需要最轻量级的方案？
│   ├── 用 OpenAI 模型 → OpenAI Agents SDK
│   └── 用 Claude 模型 → Claude Agent SDK
│
└── 不确定 / 原型验证阶段？
    └── CrewAI（上手最快）或 LangGraph（上限最高）
```

### 5.2 按团队规模选型

| 团队规模 | 推荐 | 原因 |
|---------|------|------|
| 个人/小团队 | CrewAI 或 OpenAI SDK | 上手快，概念简单 |
| 中型团队 | LangGraph | 灵活性高，可观测性好 |
| 大型企业 | LangGraph + LangSmith，或云厂商方案 | 完整工具链，企业级支持 |

### 5.3 常见选型误区

- **"选最流行的"**：LangChain 生态最大，但如果你的场景很简单，它的抽象层反而是负担
- **"选最新的"**：新框架 API 不稳定，社区资源少，踩坑成本高
- **"选全能的"**：没有万能框架，多数生产系统最终会组合使用
- **"忽略退出成本"**：框架绑定越深，迁移成本越高——优先选择核心逻辑可移植的方案

## 6. Agent 评测概览

### 6.1 常用 Benchmark

| Benchmark | 领域 | 评测内容 |
|-----------|------|---------|
| SWE-bench | 软件工程 | 从 GitHub Issue 到 PR 的全流程 |
| HumanEval | 编程 | 函数级代码生成 |
| GAIA | 通用 Agent | 多工具、多步骤任务 |
| WebArena | 网页操作 | 浏览器自动化任务 |

### 6.2 评测的局限

- Benchmark 分数不等于生产可用性
- 实际任务的复杂度远超 Benchmark
- 需要结合 Benchmark + 领域特定评测 + 用户反馈

> 评测体系的完整讨论，详见[第9章 评测、可观测性与安全](../agent-eval-observability/)。

## 参考

- [AI Agent Framework Landscape 2025](https://medium.com/@hieutrantrung.it/the-ai-agent-framework-landscape-in-2025-what-changed-and-what-matters-3cd9b07ef2c3)
- [Langfuse: Comparing Open-Source AI Agent Frameworks](https://langfuse.com/blog/2025-03-19-ai-agent-comparison)
- [Agentic RAG Survey (arXiv)](https://arxiv.org/abs/2501.09136)
- [Langflow: Complete Guide to Choosing an AI Agent Framework 2025](https://www.langflow.org/blog/the-complete-guide-to-choosing-an-ai-agent-framework-in-2025)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [CrewAI Documentation](https://docs.crewai.com/)
- [AutoGen Documentation](https://microsoft.github.io/autogen/)
