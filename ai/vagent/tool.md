# 工具系统 (Tool)

`tool` 包提供工具注册、执行和 Agent-as-Tool 机制。

## 1. 核心接口

### ToolHandler

工具处理函数类型。

```go
type ToolHandler func(ctx context.Context, name, args string) (schema.ToolResult, error)
```

### ToolExecutor

工具执行器接口。

```go
type ToolExecutor interface {
    Execute(ctx context.Context, name, args string) (schema.ToolResult, error)
}
```

### ExternalToolCaller

外部工具调用接口（MCP 远程工具）。

```go
type ExternalToolCaller interface {
    CallTool(ctx context.Context, name, args string) (schema.ToolResult, error)
}
```

### ToolRegistry

工具注册表接口，内嵌 ToolExecutor。

```go
type ToolRegistry interface {
    ToolExecutor
    Register(def schema.ToolDef, handler ToolHandler) error
    Unregister(name string) error
    Get(name string) (schema.ToolDef, bool)
    List() []schema.ToolDef
    Merge(defs []schema.ToolDef)  // 合并外部工具定义（MCP 来源）
}
```

## 2. Registry 实现

线程安全的内存工具注册表。

```go
func NewRegistry(opts ...RegistryOption) *Registry
func WithExternalCaller(c ExternalToolCaller) RegistryOption
```

| 方法                  | 说明                                                       |
| --------------------- | ---------------------------------------------------------- |
| `Register`            | 注册工具定义和处理函数                                     |
| `Unregister`          | 注销工具                                                   |
| `Get`                 | 获取工具定义                                               |
| `List`                | 列出所有已注册工具                                         |
| `Merge`               | 合并外部工具定义，跳过已存在的（不覆盖本地工具）           |
| `Execute`             | 执行工具：优先本地 handler，回退到 ExternalToolCaller      |
| `SetExternalCaller`   | 设置外部工具调用器（MCP Client）                           |
| `RegisterIfAbsent`    | 原子检查重复并注册工具                                     |

## 3. 工具生命周期

```
定义 ──→ 注册 ──→ 暴露给 LLM ──→ LLM 选择调用 ──→ 执行 ──→ 结果返回
```

### 注册与执行流程

```
┌──────────────┐     ┌──────────────┐     ┌────────────────┐
│  本地工具    │      │  MCP Client  │     │  ToolRegistry  │
│  (用户注册)  │────→ │  (远程发现)   │────→│  (统一注册表)    │
└──────────────┘     └──────────────┘     └───────┬────────┘
                                                  │
                                                  ▼
                                          ┌───────────────┐
                                          │  aimodel.Tool │
                                          │  (传给 LLM)   │
                                          └───────┬───────┘
                                                  │
                                          LLM 返回 ToolCall
                                                  │
                                                  ▼
                                          ┌───────────────┐
                                          │ ToolExecutor  │
                                          │ (路由到处理器)  │
                                          └───────┬───────┘
                                            ┌─────┴─────┐
                                            ▼           ▼
                                       本地执行     MCP CallTool
```

## 4. 与 aimodel 集成

### 工具定义映射

| vagent ToolDef     | aimodel 类型                              | 说明                     |
| ------------------ | ----------------------------------------- | ------------------------ |
| Name               | FunctionDefinition.Name                   | 工具函数名               |
| Description        | FunctionDefinition.Description            | 功能描述                 |
| Parameters         | FunctionDefinition.Parameters             | JSON Schema 参数定义     |
| —                  | Tool.Type = "function"                    | 固定值                   |

### 辅助函数

```go
func ToAIModelTools(defs []schema.ToolDef) []aimodel.Tool    // 转为 aimodel.Tool 格式
func FilterTools(defs []schema.ToolDef, names []string) []schema.ToolDef  // 白名单过滤
```

LLM 返回的 `aimodel.ToolCall` 直接映射到工具执行器。执行结果封装为 `aimodel.Message`（Role=tool）回传给 LLM。

## 5. Agent-as-Tool

允许一个 Agent 被注册为另一个 Agent 的工具，实现 Agent 嵌套调用。

```
┌─────────────────────────────────────────────┐
│  Coordinator Agent                          │
│  Tools: [search_tool, SubAgent-A, SubAgent-B]│
│                                              │
│  LLM 选择调用 SubAgent-A                    │
│       │                                      │
│       ▼                                      │
│  ┌────────────────┐                         │
│  │  SubAgent-A    │ (作为 Tool 执行)         │
│  │  独立 Run 调用 │                          │
│  └───────┬────────┘                         │
│          │ 返回 ToolResult                   │
│          ▼                                   │
│  继续推理循环...                             │
└─────────────────────────────────────────────┘
```

### 注册方式

```go
agenttool.Register(registry, subAgent, opts ...agenttool.Option)
```

### agenttool.Option

```go
func WithName(name string) Option              // 覆盖工具名（默认 agent.Name()）
func WithDescription(desc string) Option       // 覆盖描述（默认 agent.Description()）
func WithParameters(params any) Option         // 覆盖 JSON Schema 参数
func WithArgExtractor(fn ArgExtractor) Option  // 自定义参数提取
```

### ArgExtractor

```go
type ArgExtractor func(parsed map[string]any) (string, error)
```

默认提取 `"input"` 字段。默认参数 Schema 为 `{"type":"object","properties":{"input":{"type":"string"}},"required":["input"]}`。

### 错误处理策略

Agent 执行错误转为 `ToolResult{IsError: true}`，而非 Go error，保持 LLM 工具调用循环可见性。

## 6. 工具安全机制

### 6.1 共享路径验证 (toolkit.ValidatePath)

所有文件工具（read、write、edit）共享的路径验证函数，执行以下检查：

1. **UNC 路径拦截** — 拒绝 `\\server\share` 和 `//server/share` 格式的网络路径，防止代理被诱导访问远程网络共享。
2. **绝对路径要求** — 路径必须为绝对路径。
3. **允许目录限制** — 路径必须在配置的允许目录列表内。

### 6.2 Edit 工具安全流水线

Edit 工具在执行文件修改前按顺序执行多阶段安全检查，任一阶段失败即终止并返回可操作的错误信息：

```
JSON 解析 → ValidatePath (含 UNC 检查) → 拒绝规则检查 → 读取前置检查 → 文件锁 → os.Stat → 写权限检查 → 文件大小检查 → 执行替换
```

#### 配置选项

```go
func WithMaxFileBytes(n int64) Option              // 最大文件大小（默认 10 MB）
func WithDenyRules(patterns ...string) Option      // 拒绝规则（glob 模式，匹配 basename）
func WithReadTracker(tracker toolkit.ReadTracker) Option  // 读取前置检查
```

#### 拒绝规则 (Deny Rules)

通过 `WithDenyRules` 配置 glob 模式列表（如 `*.env`、`*.lock`、`credentials.json`），匹配文件 basename。匹配的文件被禁止编辑，错误信息包含匹配的规则名。

#### ReadTracker（读取跟踪器）

```go
type ReadTracker interface {
    HasRead(path string) bool
    RecordRead(path string)
}
```

- `MemoryReadTracker`：线程安全的内存实现，支持 `maxEntries` 上限（达到上限后清空重置）。
- Read 工具在成功读取文件后调用 `RecordRead`；Edit 工具在编辑前调用 `HasRead` 检查。
- 同一 `ReadTracker` 实例需同时注入 Read 和 Edit 工具。
- 未配置时两个工具行为与之前一致（向后兼容）。

#### 写权限预检

在 `os.Stat` 成功后检查 owner write bit，只读文件返回包含文件权限模式的错误信息。

#### 错误信息改进

所有错误信息统一使用 `"edit tool: "` 前缀，并包含可操作的指导：
- `old_string` 未找到 → 提示可能的空白/缩进不匹配或文件已变更。
- 文件大小超限 → 同时显示实际大小和限制大小。
- 拒绝规则匹配 → 显示匹配的模式名。
