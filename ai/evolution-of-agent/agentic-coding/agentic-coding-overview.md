<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-22
markmeta_title: Agentic Coding 实战总览
markmeta_categories: ai
markmeta_tags: ai,agentic-coding,claude-code,cursor,copilot,devin,windsurf
-->

# Agentic Coding 实战总览

## 1. 进化三阶段

### Phase 1: Autocomplete (2021-2023)

以 GitHub Copilot 为代表的行级/块级代码补全：

- **交互模式**：开发者编写代码，AI 预测下一行/块
- **上下文范围**：当前文件 + 少量相邻文件
- **自主性**：零——完全由开发者控制

### Phase 2: Chat-Assisted (2023-2024)

ChatGPT、Claude 等对话式编程助手：

- **交互模式**：开发者描述需求，AI 生成代码片段
- **上下文范围**：对话历史 + 手动粘贴的代码
- **自主性**：低——生成后需要开发者手动集成

### Phase 3: Agentic (2024-2025)

AI 理解整个代码库，自主规划、编写、测试、迭代：

- **交互模式**：开发者描述目标，AI 自主完成（多步骤）
- **上下文范围**：整个代码库 + 外部工具 + 运行时环境
- **自主性**：高——Plan → Code → Test → Debug → Iterate

## 2. 主流工具对比

| 工具 | 架构模式 | 上下文 | 核心优势 | 适合场景 |
|------|---------|--------|---------|---------|
| **Claude Code** | 终端 + TAOR 循环 | 1M tokens | 最深的代码理解、企业级安全 | 架构级重构、复杂任务 |
| **Cursor** | AI 原生 IDE | 中等 | 最佳 IDE 体验、社区生态 | 日常开发、快速迭代 |
| **GitHub Copilot** | IDE 插件 + Agent 模式 | 中等 | 普及度最高、与 GitHub 深度集成 | 团队协作、CI/CD 集成 |
| **Devin** | 全沙箱云环境 | 大 | 最强自主性、Plan-Execute-Debug | 独立任务、PR 级工作 |
| **Windsurf** | IDE 集成 Agent | 中等 | 专注工作流自动化 | 特定框架开发 |

### 2.1 常见组合模式

许多专业开发者采用多工具组合：

```
日常编码: Cursor / Copilot (快速补全 + 即时修改)
         +
架构工作: Claude Code (深度分析 + 多文件重构)
         +
独立任务: Devin (全自主 PR 级任务)
```

## 3. 编程 Agent 通用架构模式

### 3.1 单线程主循环（Claude Code 模式）

```
System Prompt + Tools → LLM → Tool Call → Execute → Result → LLM → ...
```

- 最简架构，最易调试
- 模型控制循环
- Sub-Agent 处理并行需求

> 详细架构解析，见[第8章 Claude Code 深度解析](../claude-code-practices/)。

### 3.2 Plan-Then-Execute（Devin 模式）

```
需求 → Plan Agent → 执行计划 → 验证 → 修正 → 提交
         ↑                         |
         └──── Human Approval ─────┘
```

- 先规划后执行
- 人工审批门控
- 适合高自主性场景

### 3.3 IDE 增强模式（Cursor 模式）

```
编辑器事件 → Context Builder → LLM → Inline Suggestion / Edit
                ↑
   当前文件 + LSP 信息 + 相关文件
```

- 深度集成编辑器事件
- LSP（Language Server Protocol）提供类型信息
- 实时反馈循环

> 更多架构模式的通用分析，见[第4章 Agent 设计模式](../agent-design-patterns/)。

## 4. 端到端实战案例：用 Claude Code 完成一个 Feature

以下是用编程 Agent 完成一个真实 Feature 的全过程——为 Go Web 服务添加速率限制（Rate Limiting）功能。

### 4.1 Phase 1: 需求理解与代码探索

```
开发者: "给 API 网关加一个基于 IP 的速率限制中间件，
        使用 Redis 做分布式计数，每 IP 每分钟 100 次请求"

Agent 行为:
├── 读取项目结构，理解目录布局
├── 读取现有中间件代码，理解注册模式
├── 读取 go.mod 确认依赖版本
└── 读取 Redis 连接配置
```

**关键点**：Agent 不会立即写代码。它先花 3-5 轮理解代码库结构和现有模式。

### 4.2 Phase 2: 方案设计

```
Agent 输出结构化计划:
1. 创建 middleware/ratelimit.go — 速率限制中间件
2. 创建 middleware/ratelimit_test.go — 单元测试
3. 修改 router/router.go — 注册中间件
4. 修改 config/config.go — 添加配置项
5. 修改 config/config_test.go — 配置测试

设计决策:
- 使用滑动窗口算法（而非固定窗口），避免边界突发
- 中间件签名与现有 AuthMiddleware 保持一致
- 可配置的限制参数（不硬编码）
```

### 4.3 Phase 3: 实现与自验证

```
Agent 行为:
├── 编写 ratelimit.go（~80 行）
├── 编写 ratelimit_test.go（~120 行）
├── 运行 go test ./middleware/... → 发现 Redis mock 问题
├── 修复测试中的 Redis mock 配置
├── 重新运行测试 → 全部通过
├── 修改 router.go 注册中间件
├── 运行 go build → 编译通过
├── 运行 go vet → 无警告
└── 运行完整测试套件 → 通过
```

**关键点**：Agent 自动运行测试并修复问题。开发者在这个阶段不需要介入。

### 4.4 Phase 4: 开发者 Review

开发者审查 Agent 产出的代码，关注点：

```
✅ 中间件签名与现有模式一致
✅ 滑动窗口算法实现正确
✅ 错误处理完整（Redis 不可用时降级放行）
⚠️ 需要补充 429 响应的 Retry-After 头
⚠️ 需要给日志加上结构化字段
```

开发者给出反馈，Agent 继续修改 → 再次 Review → 合并。

### 4.5 经验总结

| 环节 | 人工耗时 | Agent 耗时 | 说明 |
|------|---------|-----------|------|
| 需求描述 | 2 min | - | 开发者明确描述需求 |
| 代码探索 | - | 1 min | Agent 自动理解代码库 |
| 方案设计 | 1 min（确认） | 30 sec | Agent 提出方案，开发者确认 |
| 实现 | - | 3 min | Agent 编写 + 测试 + 修复 |
| Review | 5 min | 1 min（修改） | 开发者审查，Agent 修改 |
| **总计** | **~8 min** | **~5 min** | 传统方式约需 1-2 小时 |

## 5. 关键技术挑战

### 5.1 上下文管理

编程 Agent 面对的代码库往往远超上下文窗口。解决方案：
- **语义检索**：按任务相关性检索代码片段
- **Sub-Agent 探索**：专门的探索 Agent 读取代码并返回摘要
- **增量理解**：先读目录结构，再深入相关文件

### 5.2 代码正确性

LLM 生成的代码需要验证。常用手段：
- 自动运行测试套件
- Linter / Type Checker 静态检查
- 编译验证
- Agent 自我 Review

### 5.3 安全与权限

编程 Agent 拥有强大的文件系统和命令行访问权限：
- 区分读操作（安全）和写操作（需确认）
- 敏感文件保护（.env、credentials）
- 沙箱执行环境
- 操作审计日志

## 6. 开发者工作流最佳实践

### 6.1 信任校准

不同任务给予 Agent 不同程度的自主权：

| 任务类型 | 自主权 | Review 强度 |
|---------|--------|------------|
| 新增测试 | 高 | 轻度（测试能自验证） |
| Bug 修复 | 中高 | 中度（确认修复方向） |
| 新功能 | 中 | 较高（审查设计决策） |
| 架构重构 | 低 | 高（每步确认） |
| 安全相关 | 低 | 最高（逐行审查） |

### 6.2 有效的需求描述

差的需求描述：
```
"加个缓存"
```

好的需求描述：
```
"给 getUserProfile API 加 Redis 缓存：
- 缓存 key: user:{id}:profile
- TTL: 5 分钟
- 写入时同步更新缓存
- 参考 getProductDetail 的缓存实现模式"
```

关键要素：指明范围、给出约束、引用参考实现。

## 参考

- [Faros AI: Best AI Coding Agents 2026](https://www.faros.ai/blog/best-ai-coding-agents-2026)
- [Render: Testing AI Coding Agents 2025](https://render.com/blog/ai-coding-agents-benchmark)
- [AI Coding Agent Benchmark (GitHub)](https://github.com/murataslan1/ai-agent-benchmark)
- [Artificial Analysis: Coding Agents Comparison](https://artificialanalysis.ai/insights/coding-agents-comparison)
- [Building Effective AI Coding Agents for the Terminal (arXiv)](https://arxiv.org/html/2603.05344v3)
