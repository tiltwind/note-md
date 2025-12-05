<!--
markmeta_author: titlwind
markmeta_date: 2025-12-02
markmeta_title: Eino Guide
markmeta_categories: ai
markmeta_tags: ai,agent
-->

# Eino Guide —— LLM 应用开发指南

面向专业 Go 开发者的从入门到深入的 Eino 开发手册。通过简洁文字与带解释说明的代码片段，帮助你快速上手并逐步掌握编排、智能体、流式处理、调试与生产实践。

## 目录
- 1. 概览与定位
- 2. 快速上手
- 3. 编排基础（Chain / Graph / Workflow）
- 4. 智能体（ReAct Agent）与工具（Tool）
- 5. 流式与并发
- 6. 可靠性与调试（错误、超时、追踪与评估）
- 7. 生产实践（配置、部署、安全）
- 8. 进阶主题（循环图、多模型、性能优化）
- 9. 测试与评估
- 10. API 速查与参考链接
- 11. 与 Google ADK 的对比

---

## 1. 概览与定位
- Eino 是一个用 Go 编写的 LLM 应用开发框架，强调简洁、可扩展、可靠与有效。
- 提供组件抽象与实现、强大的编排框架（类型检查、流式处理、并发管理、切面注入、选项赋值）、简明 API，以及 DevOps 工具与最佳实践。
- 编排 API 分为三类：
  - Chain：简单链式有向图，仅前进。
  - Graph：循环或非循环有向图，灵活强大。
  - Workflow：非循环图，支持在结构体字段级别进行数据映射。

---

## 2. 快速上手

### 2.1 安装与准备
- 获取依赖：根据实际版本选择对应的模块路径与适配器（例如 OpenAI）。
- 环境变量：准备你的模型密钥（勿硬编码到代码中）。

```go
cfg := Config{APIKey: "<安全来源>"}
model, _ := openai.NewChatModel(ctx, cfg)
messages := []*Message{
    SystemMessage("你是一名乐于助人的助手"),
    UserMessage("未来的 AI 应用会是什么样？"),
}
resp, _ := model.Generate(ctx, messages)
```

### 2.2 使用 Chain 组合模板与模型
```go
chain, _ := NewChain[map[string]any, *Message]().
           AppendChatTemplate(prompt).
           AppendChatModel(model).
           Compile(ctx)
out, _ := chain.Invoke(ctx, map[string]any{"query": "你的名字是？"})
```

---

## 3. 编排基础（Chain / Graph / Workflow）

### 3.1 Chain：最简有向链
- 使用场景：线性、一步接一步，没有分支与循环。
- 特性：最易上手，适合模板→模型的直连流程。

```go
ch, _ := NewChain[map[string]any, *Message]().
    AppendChatTemplate(prompt).
    AppendChatModel(chatModel).
    Compile(ctx)
out, _ := ch.Invoke(ctx, map[string]any{"query": "今天天气如何？"})
```

### 3.2 Graph：灵活的有向图（支持循环）
- 使用场景：需要条件分支、循环或复杂拓扑时。
- 常用节点类型：ChatTemplateNode、ChatModelNode、ToolsNode、LambdaNode。
- 分支：根据模型输出判断走向（如调用工具或直接给出答案）。

```go
g := NewGraph[map[string]any, *Message]()
_ = g.AddChatTemplateNode("node_template", chatTpl)
_ = g.AddChatModelNode("node_model", chatModel)
_ = g.AddToolsNode("node_tools", tools)
_ = g.AddLambdaNode("node_converter", takeOne)
_ = g.AddEdge(START, "node_template")
_ = g.AddEdge("node_template", "node_model")
_ = g.AddBranch("node_model", branch)
_ = g.AddEdge("node_tools", "node_converter")
_ = g.AddEdge("node_converter", END)
compiled, _ := g.Compile(ctx)
_, _ := compiled.Invoke(ctx, map[string]any{"query": "周末北京天气"})
```

### 3.3 Workflow：字段级映射的非循环图
- 使用场景：需要在结构体字段之间进行灵活的数据映射、组合多个 Lambda/Model。

```go
wf := NewWorkflow[[]*schema.Message, *schema.Message]()
wf.AddChatModelNode("model", m).AddInput(START)
wf.AddLambdaNode("lambda1", InvokableLambda(lambda1)).
    AddInput("model", MapFields("Content", "Input"))
wf.AddLambdaNode("lambda2", InvokableLambda(lambda2)).
    AddInput("model", MapFields("Role", "Role"))
wf.AddLambdaNode("lambda3", InvokableLambda(lambda3)).
    AddInput("lambda1", MapFields("Output", "Query")).
    AddInput("lambda2", MapFields("Output", "MetaData"))
wf.End().AddInput("lambda3")
r, _ := wf.Compile(ctx)
_, _ := r.Invoke(ctx, []*schema.Message{ schema.UserMessage("kick start this workflow!") })
```

---

## 4. 智能体（ReAct Agent）与工具（Tool）

### 4.1 ReAct Agent 概览
- 由 ChatModel 与若干 Tool 组成，Agent 能自主决定是调用 Tool 还是直接给出答案。
- 工具执行结果会被作为新的消息输入到模型中，形成多轮决策。
- Eino 在 `flow/agent/react` 提供了开箱即用的实现（可直接复用）。

### 4.2 示例：简单的 ReAct Agent
```go
tools := []Tool{WeatherTool{}}
agent := flowagentreact.New(chatModel, tools)
out, _ := agent.Invoke(ctx, []*Message{ UserMessage("这个周末北京天气？") })
```

### 4.3 自定义 Tool 设计要点
- 输入/输出类型要与编排节点契合，简洁明了。
- 避免在 Tool 内部持久化敏感信息；参数校验与错误处理要充分。
- 保障可观察性：合理日志与可选的追踪埋点。

---

## 5. 流式与并发
- 编排框架原生支持流式处理与并发管理，适合实时反馈与高吞吐场景。
- 流式响应：在生成阶段不断输出增量内容，提升交互体验。
- 并发管理：在图或工作流中并行执行独立节点。

```go
stream, _ := chatModel.GenerateStream(ctx, []*Message{UserMessage("讲一个短故事")})
for chunk := range stream.Ch() {
    fmt.Print(chunk.Content)
}
_ = stream.Err()
```

---

## 6. 可靠性与调试（错误、超时、追踪与评估）
- 错误处理：对外返回明确错误；内部区分重试型与非重试型错误。
- 超时控制：通过 `context.Context` 设置每步超时，避免阻塞。
- 追踪与评估：利用 Eino DevOps 工具进行可视化开发、在线追踪与效果评估。

```go
ctxWithTimeout, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
out, err := r.Invoke(ctxWithTimeout, In{})
```

---

## 7. 生产实践（配置、部署、安全）
- 配置管理：通过环境变量、配置中心或密钥管理系统注入敏感配置。
- 部署：将编排逻辑封装为服务，提供 HTTP/gRPC 接口；合理设置资源与并发限额。
- 安全：不在日志中输出密钥；对外接口进行鉴权与速率限制；隔离外部 Tool 的访问权限。

---

## 8. 进阶主题（循环图、多模型、性能优化）
- 循环图：Graph 支持循环，用于多轮对话与自我反思。
- 多模型编排：在分支中选择不同模型，或根据任务类型路由到不同模型。
- 性能优化：批量请求、缓存常用中间结果、合理并行与背压控制。

```go
if role == "draft" { return fast }
return accurate
```

---

## 9. 测试与评估
- 单元测试：为每个节点与 Tool 编写可控输入输出的测试。
- 集成测试：覆盖关键路径与异常分支；模拟外部服务不可用场景。
- 评估：对对话质量设定指标，结合 DevOps 工具进行线上效果评估与迭代。

```go
return "question", nil
```

---

## 10. API 速查与参考链接
- 核心概念：Message、ChatTemplate、BaseChatModel、ToolsNode、LambdaNode、Chain、Graph、Workflow、Runnable。
- 常用操作：AddNode / AddEdge / AddBranch / Compile / Invoke / InvokeStream。
- 参考：
  - Eino 官方文档：`https://www.cloudwego.io/zh/docs/eino/`
  - 源码与示例：`https://github.com/cloudwego/eino/blob/v0.7.4/README.zh_CN.md`

---

## 11. 与 Google ADK 的对比

**定位与语言**
- Eino：核心语言为 `Go`，聚焦 Go 生态的 LLM/AI 应用开发，强调简洁、可扩展、可靠与有效。
- ADK：多语言支持（`Python`、`Go`、`Java`），优化 `Gemini` 与 Google 生态，同时宣称模型与部署环境无关。

**编排与架构**
- Eino：提供 `Chain`、`Graph`（支持循环）、`Workflow`（字段级映射，Alpha）三类编排；组件抽象丰富（ChatModel、Tool、Retriever 等），可实现 `ReAct` 与多 Agent 协作。
- ADK：支持顺序、并行、循环等确定性流程与 `LLM` 驱动的动态路由；原生多 Agent 架构，模块化且易于扩展与委托。

**流式与工具**
- Eino：内建透明的流处理机制，支持 `Invoke`、`Stream`、`Collect`、`Transform` 的范式，自动处理拼接与分发。
- ADK：支持 `Streaming Agent` 与双向流（Bidi-streaming），便于音频与 WebSockets 等实时场景；工具生态覆盖 Google 与第三方服务。

**DevOps/MLOps**
- Eino：通过回调/切面扩展日志、追踪与指标，文档中提及 DevOps（可视化开发、调试、评估）。
- ADK：提供部署就绪（Vertex AI Agent Engine、Cloud Run、GKE）、可观测性（Cloud Trace、AgentOps、Phoenix）、内置评估与安全保障的完整工具链。

**优劣势（简述）**
- Eino 优势：`Go` 高并发与可靠性、编译期强类型检查、透明流处理；劣势：语言栈受限、部分高级功能（如 Workflow）成熟度在提升中。
- ADK 优势：多语言与完整 MLOps/DevOps 体系、原生多 Agent 架构与生态集成；劣势：对非 Google 生态用户的集成复杂度、Python 版本要求与性能需场景评估。

**选择建议**
- 团队以 `Go` 为主、追求高并发稳定后端与类型安全：选 `Eino`。
- 需要多语言与生产级 MLOps/DevOps、一体化部署与评估：选 `ADK`。
- 构建复杂多 Agent 协作、深度集成 Google 生态：优先 `ADK`。

**总结**
- `Eino` 聚焦 Go 生态的“快、稳、强”。
- `ADK` 面向工程化的“全、广、深”。

## 附录：实践建议速览
- 从 Chain 入手，快速打通模板→模型→输出的闭环。
- 在 Graph 中加入分支与工具，逐步演化为可实用的 ReAct Agent。
- 使用 Workflow 做字段映射，清晰表达数据依赖与组合关系。
- 全程以 `context.Context` 控制超时与取消，确保可靠性。
- 接入 DevOps 工具进行可视化调试与评估，建立持续改进闭环。

## APPENDIX. 参考

— 本文档示例为概念性代码，导入路径与具体类型以所选版本与适配器的实际实现为准；涉及密钥的部分请务必通过安全的配置来源注入并进行合规处理。
