<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: 上下文工程
markmeta_categories: ai
markmeta_tags: ai,context-engineering,agent,llm
-->

# 第2章 上下文工程

上下文工程（Context Engineering）是设计和构建动态系统，在正确的时间、以正确的格式提供正确的信息和工具，使 LLM 拥有完成任务所需的一切。本章聚焦信息设计原则，运行时机制详见[第3章 Harness 工程](../harness-engineering/)。

## 文档索引

| 文档 | 说明 |
|------|------|
| [上下文工程总览](context-engineering-overview.md) | 核心概念、七大要素、信息设计原则 |

## 计划文章

- **上下文的七大组成要素**：Instructions、User Prompt、State/History、Long-Term Memory、Retrieved Information、Tools、Structured Output
- **上下文窗口管理策略**：Compaction 压缩、Token Budget 分配、渐进式降级
- **Just-In-Time 检索 vs 预加载**：动态工具注入、按需信息检索
- **信噪比优化**：去噪策略、增信策略、最小可行 token 集合
- **上下文与记忆的边界**：单次请求信息管理 vs 跨会话知识积累
