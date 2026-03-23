<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Agent 记忆与自进化
markmeta_categories: ai
markmeta_tags: ai,memory,agent,rag,episodic,semantic,procedural,self-improving,openclaw
-->

# 第5章 Agent 记忆与自进化

记忆是 Agent 从无状态工具进化为有状态协作者的关键能力。自进化机制（以 OpenClaw 为案例）让 Agent 从经验中自主学习和进化。本章系统梳理记忆分类、生产框架对比，以及自进化的触发、存储、晋升和风险。

## 文档索引

| 文档 | 说明 |
|------|------|
| [Agent 记忆与自进化总览](agent-memory-overview.md) | 记忆分类、三类长期记忆、生产框架、OpenClaw 自进化案例 |

## 计划文章

- **情景记忆（Episodic Memory）实现**：对话历史 RAG、时间戳索引、情境关联
- **语义记忆（Semantic Memory）实现**：知识图谱、向量存储、事实提取
- **程序记忆（Procedural Memory）实现**：技能编码、函数化记忆、行为模式学习
- **生产级记忆框架对比**：Mem0、Letta/MemGPT、Zep 的深度对比与选型
- **Claude Code 的 6 层记忆实践**：从 Organization 到 Task 的完整层级设计
- **OpenClaw 自进化全流程**：触发条件、`.learnings/` 存储、知识晋升、Foundry 元进化
- **自进化的风险与约束**：学习偏差、规则冲突、晋升阈值、人类监督
- **记忆与 RAG 的关系**：RAG 作为记忆的实现方式、混合记忆架构
