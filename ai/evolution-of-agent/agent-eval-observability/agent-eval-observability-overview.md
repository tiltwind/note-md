<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-23
markmeta_title: 评测、可观测性与安全总览
markmeta_categories: ai
markmeta_tags: ai,agent,eval,observability,security,langsmith,langfuse,benchmark
-->

# 评测、可观测性与安全总览

## 1. 为什么这三个话题放在一起

评测（Eval）、可观测性（Observability）和安全（Security）是 Agent 从原型走向生产的三大门槛。它们共同回答一个问题：**如何确保 Agent 在生产环境中可靠、可控、可信地运行？**

```
开发阶段: Eval（你的 Agent 能力够吗？）
     ↓
部署阶段: Security（你的 Agent 安全吗？）
     ↓
运行阶段: Observability（你的 Agent 在做什么？出了问题能发现吗？）
```

## 2. Agent 评测体系（Eval）

### 2.1 常用 Benchmark

| Benchmark | 领域 | 评测内容 | 局限性 |
|-----------|------|---------|--------|
| SWE-bench | 软件工程 | 从 GitHub Issue 到 PR 的全流程 | 真实 repo 复杂度有限 |
| HumanEval | 编程 | 函数级代码生成 | 过于简单，不反映实际编程 |
| GAIA | 通用 Agent | 多工具、多步骤任务 | 场景覆盖有限 |
| WebArena | 网页操作 | 浏览器自动化任务 | 网站会变化 |
| TAU-bench | 多领域 | 航空、零售等真实业务场景 | 规模较小 |

### 2.2 Benchmark 的局限

核心矛盾：**Benchmark 分数 ≠ 生产可用性**。

- 72-80% 的企业 RAG 实现效果不及预期
- 实际任务的复杂度远超 Benchmark
- Agent 在 Benchmark 上的表现可能因为过拟合特定模式
- 多步骤任务的错误率随步骤数指数增长

### 2.3 实用的评测方法论

**三层评测体系**：

```
Layer 1: Benchmark（快速筛选）
│  SWE-bench、HumanEval 等标准化测试
│  作用：粗筛，淘汰明显不达标的方案
│
Layer 2: 领域 Eval（深度验证）
│  针对你的具体业务场景构建评测集
│  作用：验证 Agent 在你的场景中的实际表现
│
Layer 3: 用户反馈（持续监控）
   收集真实用户的满意度和错误报告
   作用：发现 Benchmark 和 Eval 无法覆盖的问题
```

**构建领域 Eval 的要点**：
- 从真实用户请求中采样，不要凭想象构造
- 包含正向（能做的）和负向（不该做的）案例
- 评测维度：正确性、完整性、安全性、效率、用户体验
- 自动化运行 + 人工抽检结合

### 2.4 评测的常见陷阱

- **只测 happy path**：Agent 在正常输入下表现良好，但异常输入就崩溃
- **评测数据泄露**：评测集中的样本与训练数据重叠
- **过度优化分数**：为了刷 Benchmark 分数引入过于复杂的 Prompt，在真实场景反而退化
- **忽略成本维度**：99% 准确率但每次调用花 $1 vs 95% 准确率每次 $0.01

## 3. 可观测性（Observability）

### 3.1 为什么 Agent 需要可观测性

传统软件的调试：看日志、看堆栈。Agent 的调试远比这复杂——LLM 的推理过程是黑盒，工具调用链路可能分叉，同样的输入不一定产生同样的输出。

Agent 可观测性需要回答：
- Agent 做了什么决策？为什么？
- 每步消耗了多少 token？总成本是多少？
- 哪个工具调用失败了？如何恢复的？
- 从请求到完成花了多长时间？瓶颈在哪？

### 3.2 可观测性工具

| 工具 | 定位 | 核心功能 |
|------|------|---------|
| **LangSmith** | LangChain 生态 | Trace 可视化、评测运行、Prompt 管理 |
| **Langfuse** | 开源替代 | Trace、评测、成本追踪、与框架无关 |
| **Helicone** | API 代理 | 请求日志、成本分析、缓存 |
| **Arize Phoenix** | ML 可观测性 | Trace、Span 分析、LLM 评估 |

### 3.3 关键指标

**性能指标**：
- 端到端延迟（P50/P95/P99）
- 每请求 token 消耗
- 工具调用成功率
- 任务完成率

**质量指标**：
- 输出正确性（自动评测 + 人工抽检）
- 幻觉率（生成不存在的事实或代码）
- 安全违规次数

**成本指标**：
- 每请求平均成本
- 每成功任务成本
- 成本随任务复杂度的增长曲线

### 3.4 Trace 设计

一个好的 Agent Trace 应该包含：

```
Trace: "给 API 加速率限制"
├── Span: 代码探索 (2.1s, 15K tokens)
│   ├── Tool: Glob("**/middleware/*.go")
│   ├── Tool: Read("middleware/auth.go")
│   └── Tool: Grep("func.*Middleware")
├── Span: 方案设计 (1.5s, 8K tokens)
│   └── LLM: 输出结构化计划
├── Span: 代码实现 (4.2s, 25K tokens)
│   ├── Tool: Write("middleware/ratelimit.go")
│   └── Tool: Write("middleware/ratelimit_test.go")
├── Span: 测试验证 (3.0s, 5K tokens)
│   ├── Tool: Bash("go test ./middleware/...")
│   ├── [FAIL] → 自动修复
│   └── Tool: Bash("go test ./middleware/...") → PASS
└── Span: 集成 (1.2s, 6K tokens)
    └── Tool: Edit("router/router.go")

Total: 12.0s, 59K tokens, $0.18
```

## 4. 安全纵深防御

### 4.1 Agent 特有的安全风险

Agent 比传统 LLM 应用多了执行能力，安全风险相应升级：

| 风险类型 | 传统 LLM 应用 | Agent 系统 |
|---------|-------------|-----------|
| Prompt 注入 | 输出不可信文本 | 执行恶意工具调用 |
| 信息泄露 | 输出敏感信息 | 读取并传输敏感文件 |
| 越权操作 | N/A | 删除文件、执行危险命令 |
| 供应链攻击 | N/A | 恶意 MCP 工具注入 |

### 4.2 五层纵深防御体系

```
Layer 1: Prompt 护栏
│  系统提示中的行为约束和安全规则
│  "NEVER delete files without explicit user confirmation"
│
Layer 2: Schema 限制
│  工具参数的类型和范围验证
│  file_path 必须在白名单目录内
│
Layer 3: 运行时审批
│  高危操作需用户确认
│  区分可逆（自动执行）和不可逆（需确认）操作
│
Layer 4: 工具验证
│  执行前检查（文件存在性、权限、安全扫描）
│  检测潜在的命令注入
│
Layer 5: 生命周期钩子
   执行前/后的自定义验证逻辑
   支持组织级安全策略注入
```

### 4.3 可逆性判断矩阵

| 操作类型 | 可逆性 | 影响范围 | 建议策略 |
|---------|--------|---------|---------|
| 读取文件 | 完全可逆 | 本地 | 自动执行 |
| 编辑文件 | 可通过 git 恢复 | 本地 | 自动执行（有 git 时） |
| 创建文件 | 可删除 | 本地 | 自动执行 |
| 删除文件 | 难恢复 | 本地 | 需确认 |
| git push | 影响他人 | 共享 | 需确认 |
| API 调用 | 不可逆 | 外部 | 需确认 |
| 执行脚本 | 不确定 | 不确定 | 需确认 |

### 4.4 Agent 失败模式分析

常见的 Agent 失败模式及应对策略：

| 失败模式 | 症状 | 根因 | 应对 |
|---------|------|------|------|
| 无限循环 | Agent 反复执行相同操作 | 缺少终止条件或结果判断 | 设置最大循环次数 |
| 幻觉工具 | 调用不存在的工具 | 工具 Schema 注入不当 | 严格的 Schema 验证 |
| 上下文遗忘 | 忘记之前的约束 | 上下文窗口溢出 | Compaction + 关键信息置顶 |
| 权限升级 | 尝试执行未授权操作 | Prompt 注入或规则模糊 | 分层权限 + 白名单 |
| 成本爆炸 | Token 消耗异常高 | 无效的探索循环 | Token 预算 + 告警 |

## 5. 从原型到生产的检查清单

在将 Agent 系统从原型推向生产之前，验证以下要点：

**评测**：
- [ ] 有领域特定的评测集，且覆盖边界情况
- [ ] 评测包含负向案例（Agent 应拒绝的请求）
- [ ] 评测可自动化运行，集成到 CI/CD

**可观测性**：
- [ ] 所有 LLM 调用和工具执行有完整 Trace
- [ ] 关键指标有告警（成本异常、成功率下降、延迟飙升）
- [ ] 可以按请求维度回溯完整执行链路

**安全**：
- [ ] 实施了分层安全防御（至少 3 层）
- [ ] 高危操作有人工审批门控
- [ ] 定期进行红队测试（Prompt 注入、越权操作）
- [ ] 敏感文件和凭证有访问保护

**运维**：
- [ ] Agent 失败时有优雅降级方案
- [ ] 有成本预算和自动熔断机制
- [ ] 日志保留足够的审计周期

## 参考

- [SWE-bench](https://www.swebench.com/)
- [LangSmith Documentation](https://docs.smith.langchain.com/)
- [Langfuse: Open Source LLM Observability](https://langfuse.com/)
- [Helicone: Open Source LLM Observability](https://www.helicone.ai/)
- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Anthropic: Responsible Scaling Policy](https://www.anthropic.com/index/anthropics-responsible-scaling-policy)
- [Arize AI: LLM Observability](https://docs.arize.com/phoenix)
