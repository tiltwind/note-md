<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-23
markmeta_title: 趋势与展望总览
markmeta_categories: ai
markmeta_tags: ai,agent,trends,autonomy,software-3,multimodal,a2a
-->

# 趋势与展望总览

## 1. Software 3.0 框架

Andrej Karpathy 提出的 Software 3.0 框架描述了软件开发的范式转变：

| 阶段 | 核心 | 特征 | 开发者角色 |
|------|------|------|-----------|
| Software 1.0 | 传统代码 | 确定性逻辑，人类编写每一行 | 作者 |
| Software 2.0 | 神经网络权重 | 学习型逻辑，人类提供数据和目标 | 训练师 |
| Software 3.0 | 自然语言 + LLM | 意图驱动，人类描述"做什么"而非"怎么做" | 导演 |

Agent 是 Software 3.0 的核心交付形态。Agent 的进化本质上是在探索：**如何让 Software 3.0 可靠地工作**——从提示词工程到上下文工程再到 Harness 工程，每一层都是让"意图驱动"更可靠的工程手段。

## 2. 自主性滑块（Autonomy Slider）

Karpathy 提出的核心概念——用户控制赋予 Agent 多少自主权：

```
完全手动 ←──────────────────────────────────→ 完全自主
  │                                                │
  │  人类编写代码    Agent 建议    Agent 自主执行     │
  │  AI 补全        人类审批      人类事后审查       │
```

**关键洞察**：不是全有或全无，而是按任务、按风险级别灵活调整。

**实践中的自主性分级**：

| 级别 | 描述 | 适用场景 | 代表产品 |
|------|------|---------|---------|
| L0 | 人类完全控制，AI 仅提供建议 | 高风险决策、安全审计 | ChatGPT |
| L1 | AI 执行，人类逐步审批 | 代码修改、文件操作 | Cursor |
| L2 | AI 自主执行低风险操作，高风险操作需审批 | 日常开发、文档编写 | Claude Code |
| L3 | AI 完全自主，人类事后审查 | 独立 PR、自动化测试 | Devin |
| L4 | AI 自主运行 + 自主学习，人类仅设定目标 | 持续集成、监控响应 | 未来 |

当前 Agent 系统大多处于 L1-L2，正在向 L3 演进。L4 是中长期愿景。

## 3. 框架整合

### 3.1 当前趋势

- **Microsoft 合并 AutoGen + Semantic Kernel**：统一为 Microsoft Agent Framework
- **LangChain 重心从 Chain 转向 LangGraph**：图驱动替代线性链
- **小型框架被吸收或淘汰**：市场向头部集中

### 3.2 整合的驱动力

| 驱动力 | 影响 |
|--------|------|
| 企业客户需要统一方案 | 框架需要提供完整解决方案而非拼凑 |
| 运维复杂度 | 多框架混用的运维成本太高 |
| 生态锁定 | 云厂商推自家 Agent 方案 |
| 标准化需求 | A2A (Agent-to-Agent) 协议推动互操作 |

## 4. 自改进 Agent

Agent 从"执行工具"进化为"学习者"是最重要的趋势之一。

**核心机制**：Agent 通过经验积累自主扩展能力，不依赖模型微调，而是通过上下文工程实现进化——修改加载到上下文窗口的文件内容来改变行为。

**代表实现**：
- **OpenClaw Foundry**：".learnings/ → 知识晋升 → Workspace 文件"的自进化流水线（详见[第5章 Agent 记忆与自进化](../agent-memory/)）
- **Claude Code Memory**：从用户反馈中自动学习偏好和项目规则

**关键挑战**：
- 学习偏差：早期错误样本可能导致错误规则固化
- 规则冲突：不同时期学到的规则可能矛盾
- 验证困难：如何确保自学的规则是正确的？

## 5. 多模态 Agent

### 5.1 视觉理解

Agent 正在获得"看"的能力：

- **屏幕理解**：直接理解 UI 截图，执行 GUI 操作
- **文档理解**：解析 PDF、图表、手写笔记
- **代码可视化**：从架构图生成代码骨架

### 5.2 语音交互

- 实时语音 Agent（如 OpenAI 的 Advanced Voice Mode）
- 电话客服 Agent
- 会议记录 + 行动项提取

### 5.3 多模态的工程挑战

- 多模态输入消耗更多上下文空间（一张图 ≈ 数千 tokens）
- 不同模态的信息可能冲突（图和文字描述不一致）
- 延迟增加：多模态处理比纯文本慢

## 6. Agent-to-Agent（A2A）协议

### 6.1 为什么需要 A2A

当前 Agent 之间的协作依赖框架内部机制（LangGraph 的图、CrewAI 的 Crew）。A2A 协议的目标是让不同框架、不同厂商的 Agent 能够互操作。

### 6.2 关键协议

| 协议 | 发起者 | 目标 |
|------|--------|------|
| MCP (Model Context Protocol) | Anthropic | 模型与工具/数据源的标准接口 |
| A2A Protocol | Google | Agent 之间的通信标准 |
| OpenAI Function Calling | OpenAI | 模型与工具的调用规范 |

### 6.3 影响

A2A 标准化将导致：
- Agent 可以"雇佣"其他 Agent 完成子任务
- 企业可以构建 Agent 市场（类似 API 市场）
- 专业化分工：不同 Agent 专注不同领域

## 7. 从原型到生产

2025-2026 年的核心挑战不再是"能不能做"而是"能不能可靠地做"：

| 维度 | 原型阶段 | 生产阶段 |
|------|---------|---------|
| 可靠性 | "大部分时候能用" | 99.9% 可用性 |
| 成本 | 不关心 | 每请求成本可控 |
| 安全 | 基础防护 | 纵深防御 + 合规审计 |
| 可观测性 | 看日志 | 完整 Trace + 告警 + 仪表盘 |
| 评测 | 手动验证 | 自动化 Eval + CI/CD 集成 |

> 从原型到生产的完整检查清单，详见[第9章 评测、可观测性与安全](../agent-eval-observability/)。

## 8. 什么不会变

在快速变化的 Agent 领域，以下原则可能是持久的：

1. **上下文窗口仍然是稀缺资源**：即使窗口继续扩大，信噪比管理永远重要
2. **简洁架构优于复杂架构**：复杂性是 Agent 系统最大的敌人
3. **人类需要保持控制权**：完全自主的 Agent 在可预见的未来不现实
4. **安全不是可选项**：随着 Agent 能力增强，安全要求只会更高
5. **评测驱动进化**：不能度量就不能改进

## 参考

- [Karpathy: Software Is Changing (Again)](https://www.latent.space/p/s3)
- [Google: Agent-to-Agent Protocol](https://google.github.io/a2a/)
- [Anthropic: Model Context Protocol](https://modelcontextprotocol.io/)
- [AI Agent Framework Landscape 2025](https://medium.com/@hieutrantrung.it/the-ai-agent-framework-landscape-in-2025-what-changed-and-what-matters-3cd9b07ef2c3)
- [State of AI Report 2025](https://www.stateof.ai/)
- [Lenny's Newsletter: AI Agents Are Coming](https://www.lennysnewsletter.com/p/ai-agents-are-coming)
