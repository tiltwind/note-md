<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-23
markmeta_title: 评测、可观测性与安全
markmeta_categories: ai
markmeta_tags: ai,agent,eval,observability,security
-->

# 评测、可观测性与安全

Agent 从原型到生产的三大门槛：评测验证能力、可观测性追踪行为、安全防御保障可控。本章系统梳理评测体系、监控工具、安全纵深防御，以及 Agent 常见失败模式的应对策略。

## 文档索引

| 文档 | 说明 |
|------|------|
| [评测、可观测性与安全总览](agent-eval-observability-overview.md) | 评测方法论、可观测性工具、安全纵深防御体系 |

## 计划文章

- **Agent 评测方法论**：Benchmark 选择、领域 Eval 构建、自动化评测流水线
- **可观测性工具对比**：LangSmith、Langfuse、Helicone、Arize Phoenix 的选型与集成
- **Trace 设计最佳实践**：Span 划分、token 成本追踪、异常链路回溯
- **Agent 安全红队测试**：Prompt 注入攻击、工具越权、MCP 供应链攻击的测试方法
- **Agent 失败模式手册**：无限循环、幻觉工具、上下文遗忘等常见问题的诊断与修复
- **从原型到生产检查清单**：评测、安全、可观测性、运维四维度的上线前验证
