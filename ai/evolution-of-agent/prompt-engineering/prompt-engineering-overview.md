<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: 提示词工程总览
markmeta_categories: ai
markmeta_tags: ai,prompt-engineering,chain-of-thought,react,few-shot,zero-shot
-->

# 提示词工程总览

## 1. 演进时间线

| 年份 | 里程碑 | 影响 |
|------|--------|------|
| 2020 | GPT-3 发布 | Prompt Crafting 概念萌芽 |
| 2021 | Few-Shot Learning 形式化 | 通过示例引导模型成为标准技术 |
| 2022 | Chain-of-Thought (CoT) | "Let's think step by step" 革命性提升推理能力 |
| 2023 | 多模态 + ReAct 模式 | 视觉语言模型；Thought→Action→Observation 成为 Agent 基础 |
| 2024 | TCRTE 等高级框架标准化 | 组合技术成为工程标准 |
| 2025 | Context Engineering 兴起 | Prompt Engineering 被纳入更大的 Context Engineering 体系 |

## 2. 核心技术体系

### 2.1 基础技术

**Zero-Shot Prompting**

直接给出指令，不提供示例。依赖模型的预训练知识。

```
将以下文本翻译成英文：[文本]
```

适用场景：简单任务、模型能力足够强时。

**Few-Shot Prompting**

在 Prompt 中提供数个输入-输出示例，引导模型学习模式。

```
正面: 这个产品很棒！
负面: 完全浪费钱。
正面: 服务态度非常好。
[待分类文本]: ???
```

适用场景：需要特定输出格式、领域特定任务。

### 2.2 推理增强技术

**Chain-of-Thought (CoT)**

强制模型显式展示推理过程，而非直接给出答案。

```
Q: 餐厅有23个苹果，用了20个做午餐，又买了6个。还有多少？
A: 餐厅最初有23个苹果。用了20个后还剩23-20=3个。又买了6个，所以有3+6=9个。答案是9。
```

关键发现（Wei et al., 2022）：
- 在足够大的模型上（≥100B 参数）效果显著
- 对多步推理任务提升最大
- "Let's think step by step" 这一简单前缀就能激活 CoT

**Self-Consistency**

对同一问题生成多条 CoT 推理路径，通过多数投票选择最终答案。

```
同一问题 → CoT 路径 A → 答案: 9
          → CoT 路径 B → 答案: 9
          → CoT 路径 C → 答案: 7
多数投票 → 最终答案: 9
```

2025 年改进 — **Confidence-Improved Self-Consistency (CISC)**：按每条推理路径的置信度加权投票，在同等准确率下减少 46% 计算量。

### 2.3 Agent 基础范式

**ReAct (Reasoning + Acting)**

将推理和行动交织在循环中，是所有 Agent 系统的基础范式：

```
Thought: 我需要查找北京今天的天气
Action: search("北京今天天气")
Observation: 北京今天晴，最高温度25℃
Thought: 我已经获得了天气信息，可以回答用户
Action: respond("北京今天晴天，最高温度25℃")
```

ReAct 的突破在于：让 LLM 从"回答问题"进化为"执行任务"。模型不再是被动回应，而是主动规划、调用工具、观察结果、迭代推进。

**Tree-of-Thought (ToT)**

在推理过程中同时探索多条分支，类似 Beam Search：

```
问题 → 分支 A → 评估 → 继续/剪枝
     → 分支 B → 评估 → 继续/剪枝
     → 分支 C → 评估 → 继续/剪枝
```

适用场景：创意写作、策略规划、复杂数学问题等需要探索多种可能性的任务。

### 2.4 工具使用（Tool Use）

Tool Use Prompting 是 Agent 获得行动能力的关键。通过结构化 Schema 描述可用工具：

```json
{
  "name": "search_database",
  "description": "搜索产品数据库",
  "parameters": {
    "query": {"type": "string", "description": "搜索关键词"},
    "limit": {"type": "integer", "description": "返回结果数量", "default": 10}
  }
}
```

设计要点：
- 工具描述（description）要精确，模型靠它决定何时调用
- 参数描述要包含边界条件和示例
- 少而精优于多而杂——能力原语 > 专用工具

## 3. Prompt 调试实战案例

### 案例 1：代码审查 Prompt 的迭代优化

**初始 Prompt（失败）**：

```
请审查以下代码。
```

**问题**：输出过于泛泛，没有关注点，审查质量不稳定。

**第一次改进**：

```
请审查以下 Go 代码，关注：
1. 潜在的并发安全问题
2. 错误处理是否完整
3. 是否存在资源泄漏（未关闭的连接、文件句柄等）
```

**效果**：输出有结构，但经常误报——把正确的代码标记为问题。

**最终版本（成功）**：

```
你是一位资深 Go 工程师。请审查以下代码，仅报告你有高置信度的问题。

审查范围：
1. 并发安全：是否有无保护的共享状态访问？
2. 错误处理：是否有被忽略的 error 返回值？
3. 资源泄漏：是否有打开后未在 defer 中关闭的资源？

输出格式：
- 每个问题标注行号和严重程度（HIGH/MEDIUM/LOW）
- 如果代码没有上述问题，直接输出"未发现问题"
```

**关键教训**：
- 给出角色和专业度设定减少误报
- "仅报告高置信度问题"显著提升精确率
- 明确"没有问题时怎么输出"避免模型强行找问题

### 案例 2：从 Zero-Shot 到 Few-Shot 的数据提取

**初始 Prompt（Zero-Shot，失败）**：

```
从以下文本中提取公司名称、融资金额和日期。
文本：据悉，AI 初创公司 Anthropic 于近日完成了一轮 40 亿美元的融资。
```

**问题**：输出格式不一致——有时用列表，有时用自然语言，有时键名不同。

**改进版本（Few-Shot，成功）**：

```
从文本中提取结构化信息。

示例 1：
输入：OpenAI 在 2024 年 10 月获得 66 亿美元融资。
输出：{"company": "OpenAI", "amount": "66亿美元", "date": "2024-10"}

示例 2：
输入：据报道，Mistral AI 完成了 6 亿欧元的 B 轮融资。
输出：{"company": "Mistral AI", "amount": "6亿欧元", "date": null}

现在提取：
输入：据悉，AI 初创公司 Anthropic 于近日完成了一轮 40 亿美元的融资。
输出：
```

**关键教训**：
- 2 个示例就能稳定输出格式
- 示例中包含"缺失字段"的情况（date: null）教会模型如何处理不完整信息
- JSON 格式比自然语言更容易被程序消费

### 案例 3：CoT 解决复杂推理的失败与修复

**初始 Prompt（失败）**：

```
服务器 A 的 CPU 使用率是 80%，内存使用率 60%。服务器 B 的 CPU 使用率是 40%，内存使用率 90%。
新任务需要 30% CPU 和 20% 内存。应该分配给哪台服务器？
```

**问题**：模型直接输出答案"服务器 B"，但没有验证内存是否足够（90%+20%=110%，超出限制）。

**改进版本（CoT，成功）**：

```
分析服务器资源分配。请逐步推理，验证每个约束条件后再给出结论。

当前状态：
- 服务器 A: CPU 80%, 内存 60%
- 服务器 B: CPU 40%, 内存 90%

新任务需求: CPU 30%, 内存 20%

请按以下步骤分析：
1. 计算每台服务器分配后的资源使用率
2. 检查是否有任何资源超过 100%
3. 在满足约束的选项中，选择资源利用更均衡的方案
```

**关键教训**：
- 对于涉及多个约束条件的问题，直接问"应该怎么做"容易遗漏约束
- 分步验证让模型不会跳过关键检查
- 明确定义决策标准（"资源利用更均衡"）避免模型随意选择

## 4. 从 Prompt Engineering 到 Context Engineering

Prompt Engineering 的局限性：

1. **单次交互**：只关注一轮对话的输入文本
2. **静态性**：Prompt 是固定模板，无法动态适应
3. **信息不足**：仅靠 Prompt 无法携带足够的上下文信息

这些局限催生了 Context Engineering——不再仅关注"说什么"，而是设计整个信息传递系统：什么信息、什么时机、什么格式。

> "Prompt engineering is a subset of context engineering."
> — Anthropic

## 参考

- [Prompt Engineering Guide (DAIR.AI)](https://www.promptingguide.ai/)
- [Chain-of-Thought Prompting Elicits Reasoning in Large Language Models (Wei et al., 2022)](https://arxiv.org/abs/2201.11903)
- [ReAct: Synergizing Reasoning and Acting in Language Models (Yao et al., 2022)](https://arxiv.org/abs/2210.03629)
- [Tree of Thoughts: Deliberate Problem Solving with Large Language Models](https://arxiv.org/abs/2305.10601)
- [Mercity: Comprehensive Guide to ReAct Prompting](https://www.mercity.ai/blog-post/react-prompting-and-react-based-agentic-systems/)
- [Complete Prompt Engineering Guide 2025](https://aloaguilar20.medium.com/the-complete-prompt-engineering-guide-for-2025-mastering-cutting-edge-techniques-dfe0591b1d31)
