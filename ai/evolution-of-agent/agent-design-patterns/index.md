<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-23
markmeta_title: Agent 设计模式
markmeta_categories: ai
markmeta_tags: ai,agent,design-patterns,react,taor,router,orchestrator
-->

# Agent 设计模式

Agent 设计模式是从大量实践中提炼的可复用架构方案。本章系统归纳单 Agent 模式（ReAct、TAOR、Plan-Then-Execute）和多 Agent 协作模式（Router、Orchestrator、Voting、Debate），并提供选型决策树。

## 文档索引

| 文档 | 说明 |
|------|------|
| [Agent 设计模式总览](agent-design-patterns-overview.md) | 核心模式归纳、选型决策树与反模式 |

## 计划文章

- **ReAct 模式深度解析**：Thought-Action-Observation 循环的实现变体与优化
- **TAOR 循环详解**：Pre-check、Self-Critique、Compaction 等扩展环节的设计考量
- **Plan-Then-Execute 模式**：Planner/Executor 分离、Re-planning 策略、人工审批门控
- **多 Agent 协作实战**：Router/Orchestrator/Voting 的实现示例与对比
- **Sub-Agent 隔离模式**：上下文窗口隔离、摘要返回、并行执行的工程实践
- **Agent 反模式集锦**：过度 Agent 化、上下文过载、失败路径缺失等常见陷阱
