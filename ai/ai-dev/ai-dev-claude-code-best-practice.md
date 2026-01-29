<!--
markmeta_author: tiltwind
markmeta_date: 2026-01-22
markmeta_title: Claude Code Best Practices
markmeta_categories: ai
markmeta_tags: ai,claude-code,best-practice
-->

# Claude Code Best Practices

包括 Commands（自定义命令）、Sub-agents（子代理）、MCP（Model Context Protocol）和 Skills（技能）四大模块。

## 1. Commands（自定义命令）



## 2. Sub-agents（子代理）

### 2.1 为什么需要子代理

Sub-agents 是具有独立上下文和工具权限的专业化 AI 助手。
主代理（Claude）可以将特定任务委派给子代理处理，实现上下文隔离、专业分工和并行执行，特别适合代码审查、调试、文档生成等专业性任务。


## 3. MCP（Model Context Protocol）

### 3.1 为什么需要 MCP

MCP (Model Context Protocol) 是一种开放标准，允许 AI 助手安全地连接外部数据源和工具。
通过 MCP，Claude 可以访问数据库、API、文件系统、浏览器等外部资源，大幅扩展其能力边界。


## 4. Skills（技能）

### 4.1 为什么需要 Skills

Skills 是由模型自主调用的能力扩展模块。与需要用户显式触发的 Commands 不同，Skills 会根据用户请求自动激活。
适合定义团队的编码规范、框架使用指南、工作流程等持久性知识。


