<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Agent 进化论：总览
markmeta_categories: ai
markmeta_tags: ai,agent,evolution,prompt-engineering,context-engineering,harness-engineering,memory
-->

# Agent 进化论：总览

## 1. 为什么谈 Agent 进化

从 2023 年的 RAG 热潮到 2025 年被称为"Agent 之年"，AI Agent 正在从"会对话的工具"进化为"能自主行动的协作者"。这一进化不仅是模型能力的提升，更是围绕模型的**工程体系**在持续演进：

- **Prompt Engineering** → 如何与模型对话
- **Context Engineering** → 如何为模型提供正确的信息
- **Harness Engineering** → 如何构建模型运行的外部系统

Agent 的进化本质上是在探索：**如何让 Software 3.0 可靠地工作**。

## 2. Agent 架构全景图

```
┌──────────────────────────────────────────────────────────────┐
│                    用户 / 外部系统                              │
├──────────────────────────────────────────────────────────────┤
│  第三篇：实践层                                                │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ Agentic      │ │ Claude Code  │ │ 评测 / 可观测性 /    │  │
│  │ Coding (ch7) │ │ 深度解析(ch8)│ │ 安全 (ch9)          │  │
│  └──────┬───────┘ └──────┬───────┘ └──────────┬───────────┘  │
├─────────┼────────────────┼────────────────────┼──────────────┤
│  第二篇：架构层                                                │
│  ┌──────┴───────┐ ┌──────┴───────┐ ┌─────────┴──────────┐   │
│  │ Harness 工程 │ │ 设计模式     │ │ 记忆与自进化        │   │
│  │ (ch3)        │ │ (ch4)        │ │ (ch5)              │   │
│  └──────┬───────┘ └──────┬───────┘ └─────────┬──────────┘   │
│         │    ┌───────────┴───────────┐       │              │
│         │    │  Agent 框架全景 (ch6)  │       │              │
│         │    └───────────────────────┘       │              │
├─────────┼────────────────────────────────────┼──────────────┤
│  第一篇：基础层                                                │
│  ┌──────┴──────────────────┐ ┌───────────────┴──────────┐   │
│  │ 提示词工程 (ch1)         │ │ 上下文工程 (ch2)         │   │
│  └─────────────────────────┘ └──────────────────────────┘   │
├──────────────────────────────────────────────────────────────┤
│                       LLM (大语言模型)                        │
└──────────────────────────────────────────────────────────────┘
```

## 3. 全书结构导读

### 第一篇：基础——与模型对话的艺术

- **第1章 提示词工程**：从 Zero-Shot 到 ReAct 的技术演进，包含 Prompt 调试实战案例。这是 Agent 的基石。
- **第2章 上下文工程**：从"写好一句 Prompt"升级到"设计整个信息系统"。聚焦上下文的七大要素和信息设计原则。

### 第二篇：架构——构建 Agent 运行时

- **第3章 Harness 工程**：Agent 外层循环的通用架构——工具调度、安全防护、渐进式降级。
- **第4章 Agent 设计模式**：系统归纳 ReAct、TAOR、Plan-Then-Execute、Router/Orchestrator 等核心模式，提供选型决策树。
- **第5章 Agent 记忆与自进化**：记忆使 Agent 从无状态工具变为有状态协作者，自进化机制（以 OpenClaw 为案例）让 Agent 从经验中学习。
- **第6章 Agent 框架全景**：LangGraph、CrewAI、AutoGen 等主流框架深度对比与选型指南。

### 第三篇：实践——Agent 在生产中的样子

- **第7章 Agentic Coding 实战**：编程 Agent 进化三阶段、工具对比、端到端开发工作流案例。
- **第8章 Claude Code 深度解析**：全书唯一的 Claude Code 深度剖析入口——TAOR 循环、工具系统、6 层记忆、安全模型。
- **第9章 评测、可观测性与安全**：Eval 体系、LangSmith/Langfuse 监控、安全纵深防御、Agent 失败模式分析。
- **第10章 趋势与展望**：自主性滑块、Software 3.0 框架、多模态 Agent、Agent-to-Agent 协议。

## 4. 贯穿主题

1. **简洁制胜**：Claude Code 的成功来自架构简洁而非复杂。"做能工作的最简单方案。"
2. **上下文是瓶颈**：Agent 系统中每个重大设计决策都可追溯到有限上下文窗口的管理
3. **从 Prompt 到 System**：行业从"雕琢单条 Prompt"进化到"工程化整个上下文传递系统"
4. **Harness 即产品**：围绕 LLM 的外层系统比模型本身更决定生产系统的质量
5. **记忆使能连续性**：没有记忆架构，Agent 只是无状态工具；有了记忆，Agent 才成为进化中的协作者
6. **自主性滑块**：让用户控制赋予 Agent 多少自主权，而非全有或全无

## 附录：术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 提示词工程 | Prompt Engineering | 设计和优化输入给 LLM 的文本指令，以获得期望输出 |
| 上下文工程 | Context Engineering | 设计动态系统，在正确时间以正确格式提供正确信息和工具给 LLM |
| Harness | Harness | 围绕 LLM 的运行时编排系统，管理工具调度、上下文、安全的"外层循环" |
| Scaffolding | Scaffolding | 构建时（启动前）的系统组装——系统提示、工具 Schema、子 Agent 注册 |
| 上下文窗口 | Context Window | LLM 单次推理能处理的最大 token 数量 |
| 工具调用 | Tool Use / Function Calling | LLM 通过结构化输出调用外部工具的能力 |
| 记忆 | Memory | Agent 跨会话持久化信息的机制，包括情景、语义、程序三类 |
| 自进化 | Self-Improvement | Agent 从错误和反馈中自动学习并改进行为的机制 |
| TAOR | Think-Act-Observe-Repeat | Claude Code 的核心循环架构，扩展自 ReAct 范式 |
| ReAct | Reasoning + Acting | 将推理和行动交织在循环中的 Agent 基础范式 |
| Sub-Agent | Sub-Agent | 主 Agent 派生的子任务执行者，拥有独立上下文窗口 |
| Compaction | Compaction | 自动压缩对话历史以回收上下文窗口空间的机制 |
| MCP | Model Context Protocol | 模型上下文协议，用于连接外部工具和数据源 |
| Skill | Skill | 封装特定能力的可复用模块（如 OpenClaw 的技能系统） |
| Eval | Evaluation | Agent 能力评测体系，包括 Benchmark 和领域特定测试 |

## 参考

- [Building Effective AI Coding Agents for the Terminal (arXiv)](https://arxiv.org/html/2603.05344v3)
- [Anthropic: Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [Karpathy: Software Is Changing (Again)](https://www.latent.space/p/s3)
- [Memory in the Age of AI Agents (arXiv)](https://arxiv.org/abs/2512.13564)
- [Prompt Engineering Guide (DAIR.AI)](https://www.promptingguide.ai/)
