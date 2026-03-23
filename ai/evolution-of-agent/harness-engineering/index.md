<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Harness 工程
markmeta_categories: ai
markmeta_tags: ai,harness-engineering,agent,scaffolding,safety
-->

# 第3章 Harness 工程

Harness（线束/外壳）是围绕 LLM 的运行时系统——Agent 的"外层循环"。它管理工具调度、上下文组装、安全防护和会话持久化，是决定 Agent 在生产环境中能否可靠运行的关键。本章讲述通用架构原则，具体到 Claude Code 的实现详见[第8章](../claude-code-practices/)。

## 文档索引

| 文档 | 说明 |
|------|------|
| [Harness 工程总览](harness-engineering-overview.md) | 通用架构模式、工具系统设计、安全防御与渐进式降级 |

## 计划文章

- **Scaffolding vs Harness 辨析**：构建时组装 vs 运行时编排的边界与协作
- **工具注册与调度模式**：ToolRegistry、延迟外部发现（MCP）、鲁棒性增强
- **五层安全防御体系**：Prompt 护栏 → Schema 限制 → 运行时审批 → 工具验证 → 生命周期钩子
- **Martin Fowler 的三部分架构**：上下文工程层 + 架构约束层 + 周期性清理
- **运行时约束与渐进式降级**：Token 预算耗尽时的优雅降级策略
- **Harness 反模式**：过早构建复杂 Harness、安全层级过多、工具数量膨胀
