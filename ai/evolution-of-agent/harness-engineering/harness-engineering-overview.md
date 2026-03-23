<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Harness 工程总览
markmeta_categories: ai
markmeta_tags: ai,harness-engineering,agent,scaffolding,tool-registry,safety
-->

# Harness 工程总览

## 1. 什么是 Harness 工程

Harness（线束）是围绕 LLM 的**运行时编排系统**。如果说 LLM 是引擎，Harness 就是整辆车——底盘、传动、制动、导航。

Martin Fowler 的定义：
> Harness Engineering 是用于保持 AI Agent 可控的工具和实践——管理工具执行、消息历史、上下文和安全的"外层循环"。

### 1.1 Scaffolding vs Harness

这两个概念经常混用，但有明确的时间维度区别：

| 概念 | 时机 | 职责 | 类比 |
|------|------|------|------|
| Scaffolding | 构建时（启动前） | 组装系统提示、工具 Schema、子 Agent 注册 | 搭建舞台 |
| Harness | 运行时（启动后） | 协调工具执行、管理上下文、安全执行、会话持久化 | 演出导演 |

典型的 Agent 系统中，两者分工明确：
- Scaffolding 阶段：通过 Prompt Composer 组装系统提示，注册工具，初始化子 Agent
- Harness 阶段：主循环运行，调度工具，管理上下文压缩，执行安全检查

> 具体到 Claude Code 的 Scaffolding/Harness 实现，详见[第8章 Claude Code 深度解析](../claude-code-practices/)。

## 2. 三部分架构（Martin Fowler / OpenAI）

### 2.1 上下文工程层

Harness 的第一职责是管理上下文的组装和维护：

- **System Reminders**：上下文感知的行为指导，在决策点动态注入
- **Prompt Composer**：模块化系统提示组装
- **Memory**：跨会话连续性（详见[第5章 Agent 记忆与自进化](../agent-memory/)）
- **Compaction**：对话历史压缩，回收 token 预算

### 2.2 架构约束层

通过确定性工具而非 LLM 来强制执行规则：

- Linter 检查代码风格和安全规则
- 结构化测试验证输出格式
- Schema 验证工具调用参数
- 类型系统约束工具返回值

关键洞察：**不要让 LLM 自己判断是否遵守规则——用代码强制执行**。

### 2.3 周期性清理

自主 Agent 对抗熵增：

- 自动发现文档不一致
- 清理过时的记忆和配置
- 验证外部依赖的可用性
- 更新缓存和索引

## 3. 工具系统设计

### 3.1 Registry-Based Dispatch

中央 ToolRegistry 将工具名映射到类型化的处理器：

```
ToolRegistry
├── read    → ReadHandler (file_path, offset, limit)
├── write   → WriteHandler (file_path, content)
├── execute → ExecuteHandler (command, timeout)
└── connect → ConnectHandler (target, payload)
```

通用设计原则：
- **能力原语 > 专用工具**：少量基础能力（Read、Write、Execute、Connect）覆盖大多数场景
- **万能适配器**：无法通过原语完成的操作通过 Shell 兜底
- **延迟外部发现**：外部工具（如 MCP 协议工具）按需发现，避免启动时加载过多

### 3.2 工具描述设计

工具描述（description）是 LLM 决定何时调用工具的唯一依据：

- 描述要精确说明"什么时候用"和"什么时候不用"
- 参数描述包含边界条件和示例值
- 少而精优于多而杂——过多工具会稀释 LLM 的选择准确率

### 3.3 鲁棒性增强

LLM 输出的工具调用参数可能存在微小偏差。生产系统需要容错机制：

- 代码编辑使用多 pass 模糊匹配（从严格到宽松逐步尝试）
- 参数类型自动转换（字符串 "10" → 整数 10）
- 缺失可选参数使用默认值填充

## 4. 安全防御体系

五层纵深防御（Defense-in-Depth）：

```
Layer 1: Prompt 护栏
│  系统提示中的行为约束和规则
│
Layer 2: Schema 限制
│  工具参数的类型和范围验证
│
Layer 3: 运行时审批
│  高危操作需用户确认（destructive actions）
│
Layer 4: 工具验证
│  执行前检查（文件存在性、权限、安全扫描）
│
Layer 5: 生命周期钩子
   执行前/后的自定义逻辑（pre-hook, post-hook）
```

关键设计决策：
- **可逆性判断**：区分本地可逆操作（自动执行）和不可逆/共享操作（需确认）
- **权限模式**：用户选择自动允许的操作范围
- **爆炸半径评估**：考虑操作影响的范围和可恢复性

> 安全体系的完整讨论，包括评测和可观测性，详见[第9章 评测、可观测性与安全](../agent-eval-observability/)。

## 5. 运行时约束与渐进式降级

当资源（token、时间、工具调用次数）接近上限时，Harness 执行渐进式降级：

1. **上下文压缩**：自动总结历史对话
2. **工具限制**：减少可用工具集合
3. **任务分解**：将剩余工作拆分给子 Agent
4. **优雅终止**：保存进度，提示用户继续

原则："当 Agent 挣扎时，不是 Agent 的问题——是 Harness 缺少了什么（工具、护栏、文档），把缺失的东西补上。"

## 6. 什么情况下不需要复杂 Harness

并非所有 Agent 系统都需要重型 Harness：

- **单轮问答**：无需会话管理和上下文压缩
- **低风险内部工具**：安全要求低，可简化权限模型
- **原型验证阶段**：先验证核心逻辑，再逐步加固 Harness

**常见陷阱**：
- 过早构建复杂 Harness，而核心 Agent 逻辑还没验证
- 安全层级过多导致正常操作也需要频繁确认，降低用户体验
- 工具数量膨胀——先用 4-5 个能力原语试试，再考虑专用工具

## 7. 实践建议

- 预期 5+ 个月的专注 Harness 开发
- 通过运行时约束限制解空间，而非让 LLM 无限制生成
- Harness 的质量决定了生产系统的质量——**Harness 即产品**
- 迭代反馈：观察 Agent 失败模式 → 补充缺失的上下文/工具/约束 → 重新测试

## 参考

- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [OpenAI: Harness Engineering — Leveraging Codex](https://openai.com/index/harness-engineering/)
- [LangChain Blog: Improving Deep Agents with Harness Engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
- [NxCode: Harness Engineering Complete Guide](https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026)
- [Hugo Bowne: AI Agent Harness, 3 Principles for Context Engineering](https://hugobowne.substack.com/p/ai-agent-harness-3-principles-for)
