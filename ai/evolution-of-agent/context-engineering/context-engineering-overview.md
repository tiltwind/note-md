<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: 上下文工程总览
markmeta_categories: ai
markmeta_tags: ai,context-engineering,prompt-engineering,agent,llm
-->

# 上下文工程总览

## 1. 什么是上下文工程

### 1.1 定义

**Shopify CEO Tobi Lutke**：
> "The art of providing all the context for the task to be plausibly solvable by the LLM."

**Andrej Karpathy**：
> "In every industrial-strength LLM app, context engineering is the delicate art and science of filling the context window with just the right information for each step."

**Anthropic 正式定义**：
> "设计和构建动态系统，在正确的时间、以正确的格式提供正确的信息和工具，使 LLM 拥有完成任务所需的一切。"

### 1.2 与 Prompt Engineering 的区别

| 维度 | Prompt Engineering | Context Engineering |
|------|-------------------|-------------------|
| 关注点 | 单次指令文本 | 整个信息传递系统 |
| 范围 | 静态模板 | 动态系统 |
| 核心挑战 | 措辞与格式 | 信息筛选与时机 |
| 时间维度 | 单轮交互 | 跨轮次、跨会话 |
| 包含内容 | 文本指令 | 指令 + 记忆 + 工具 + 检索 + 状态 |

> "Prompt engineering is a subset of context engineering." — Anthropic

## 2. 上下文的七大组成要素

```
┌─────────────────────────────────────────────┐
│              Context Window                  │
│                                             │
│  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Instructions │  │ User Prompt          │ │
│  │ (System)     │  │                      │ │
│  └──────────────┘  └──────────────────────┘ │
│  ┌──────────────┐  ┌──────────────────────┐ │
│  │ State/History│  │ Long-Term Memory     │ │
│  │              │  │                      │ │
│  └──────────────┘  └──────────────────────┘ │
│  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Retrieved    │  │ Available Tools      │ │
│  │ Information  │  │                      │ │
│  └──────────────┘  └──────────────────────┘ │
│  ┌──────────────────────────────────────────┐│
│  │ Structured Output Specifications        ││
│  └──────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

1. **Instructions / System Prompt**：定义 Agent 的身份、行为规则、限制条件
2. **User Prompt**：当前用户输入
3. **State / History**：对话历史、当前任务状态
4. **Long-Term Memory**：跨会话持久化的记忆（用户偏好、项目知识、反馈规则）
5. **Retrieved Information**：通过 RAG 或工具调用动态获取的外部信息
6. **Available Tools**：当前可用的工具 Schema 定义
7. **Structured Output**：期望的输出格式规范

## 3. 核心原则

### 3.1 上下文是有限资源

上下文窗口有物理上限（即使是 1M token 的模型也有限）。更关键的是，模型准确率随 token 数量增加而下降——**Context Rot**（上下文腐烂）是真实存在的问题。

**指导规则**：找到最小可行的高信噪比 token 集合，最大化期望输出质量。

### 3.2 System, Not String

上下文不是一个静态字符串，而是由多个动态系统协同产生：

```
CLAUDE.md 文件 ─┐
记忆系统 ────────┤
工具 Schema ─────┤──→ Prompt Composer ──→ Context Window
对话历史 ────────┤
RAG 检索结果 ────┘
```

### 3.3 Just-In-Time 而非预加载

不要一次性塞入所有可能需要的信息。按需注入：

- **工具 Schema**：只注入当前步骤可能用到的工具定义（语义工具搜索）
- **记忆**：只加载与当前任务相关的记忆条目
- **文件内容**：使用 Agent 按需读取，而非预先全部加载

### 3.4 从最简开始

Anthropic 的建议：
1. 用最强模型 + 最少指令测试
2. 观察失败模式
3. 针对性添加上下文（指令、示例、工具）
4. 迭代直到满足要求
5. 然后考虑迁移到更小/更快的模型

## 4. 上下文管理策略

### 4.1 Compaction（压缩）

当对话历史接近上下文窗口限制时，自动压缩历史消息：

```
原始对话 (50K tokens) → 压缩摘要 (5K tokens) + 最近消息
```

Claude Code 在约 50% 使用率时触发自动压缩。

### 4.2 信噪比优化

上下文不是越多越好。核心策略：

**去噪**：
- 移除与当前任务无关的历史消息
- 压缩冗长的工具返回结果（只保留关键信息）
- 避免重复注入相同的背景知识

**增信**：
- 在关键决策点注入针对性的行为指导（System Reminders）
- 将大段文档替换为精炼的摘要
- 使用结构化格式（表格、列表）替代散文式描述

**度量**：找到最小可行的高信噪比 token 集合，最大化期望输出质量。

### 4.3 上下文与记忆的边界

上下文工程关注**单次请求的信息管理**——如何在一个上下文窗口内组装最优信息。记忆系统（详见[第5章](../agent-memory/)）关注**跨会话的知识积累**——如何持久化和检索历史经验。

两者的协作关系：

```
长期记忆 (跨会话持久化)
    ↓ 按需检索
上下文工程 (单次请求组装)
    ↓ 注入
上下文窗口 → LLM 推理 → 输出
    ↓ 提炼
长期记忆 (新知识写回)
```

> 更多关于 Sub-Agent 上下文隔离、结构化笔记等运行时机制，详见[第3章 Harness 工程](../harness-engineering/)和[第8章 Claude Code 深度解析](../claude-code-practices/)。

## 参考

- [Anthropic: Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Philipp Schmid: The New Skill in AI is Context Engineering](https://www.philschmid.de/context-engineering)
- [Karpathy on X (context engineering)](https://x.com/karpathy/status/1937902205765607626)
- [Simon Willison: Context Engineering](https://simonwillison.net/2025/jun/27/context-engineering/)
- [Gartner: Context Engineering](https://www.gartner.com/en/articles/context-engineering)
- [Prompting Guide: Context Engineering Guide](https://www.promptingguide.ai/guides/context-engineering-guide)
- [Neo4j: Context Engineering vs Prompt Engineering](https://neo4j.com/blog/agentic-ai/context-engineering-vs-prompt-engineering/)
