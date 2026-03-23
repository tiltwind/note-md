<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Claude Code 深度解析
markmeta_categories: ai
markmeta_tags: ai,claude-code,agent,architecture,anthropic
-->

# 第8章 Claude Code 深度解析

> 本章是全书中 Claude Code 架构的**唯一深度解析入口**。其他章节涉及 Claude Code 时仅做简短引用并指向本章。

Claude Code 是 Anthropic 的官方终端 AI 编程助手，其架构设计是 Agent 工程的标杆实践。单线程主循环、能力原语工具系统、Sub-Agent 隔离架构，体现了"简洁制胜"的工程哲学。

## 文档索引

| 文档 | 说明 |
|------|------|
| [Claude Code 深度解析总览](claude-code-practices-overview.md) | 架构全景、核心设计原则与关键子系统 |

## 计划文章

- **TAOR 主循环架构详解**：Pre-check → Thinking → Self-Critique → Action → Tool Execution → Post-processing 六阶段详解
- **工具系统深度解析**：能力原语、ToolRegistry、Bash 万能适配器、延迟外部发现（MCP）、9-pass 模糊匹配
- **上下文管理四大子系统**：System Reminders、Prompt Composer、Memory、Compaction
- **Sub-Agent 架构与任务分发**：Explore / Plan / General-purpose Agent 的设计与隔离策略
- **6 层记忆体系**：Organization → Project → User → Auto-Learned Patterns 的完整层级
- **Claude Code 系统提示分析**：内置工具描述、子 Agent 提示、安全规则的设计哲学
- **Scaffolding vs Harness 在 Claude Code 中的体现**：启动阶段与运行时的分工
