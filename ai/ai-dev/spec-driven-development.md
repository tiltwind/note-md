<!--
markmeta_author: titlwind
markmeta_date: 2025-11-07
markmeta_title: Spec-Driven Development
markmeta_categories: ai
markmeta_tags: ai,spec
-->

# Spec-Driven Development 规范驱动开发

## 1. 背景

随着 AI 编码能力的增强，一个常见模式是：你描述目标，AI 返回代码块，看起来正确但常常无法直接运行。
这种“氛围编程” (vibe-coding) 方法适合快速原型，但对于严肃、关键任务的应用或在现有代码库中工作时，可靠性较低。

问题不在于 AI 的编码能力，而在于我们的方法。
我们像对待搜索引擎一样对待 AI 编码，而实际上应该把它们看作是需要明确指令的“结对程序员”。

为了解决这个问题，规范驱动开发 (Spec-Driven Development, SDD) 应运而生。
它将规范 (specifications) 重新定义为动态的、可执行的工件，随项目一同演进，成为共享的真理来源。

> 扩展: TDD (Test-Driven Development) 也是一种流行的AI编程模式, 它的核心思想是先写测试用例，然后根据测试用例编写代码，确保代码符合预期。

## 2. 定义

规范驱动开发 (Spec-Driven Development, SDD) 是一种软件开发方法，它将传统的开发流程颠倒过来。
规范不再是编码开始后就被丢弃的脚手架，而是成为可执行的，能直接生成工作实现的核心。

**在这种模式下，开发者首先与 AI 协作，创建一份详细、清晰且可执行的规范文档，这份文档定义了要构建什么以及为什么构建。然后，这份规范将驱动技术规划、任务分解和最终的代码实现。**

**核心优势**
- **统一团队目标**: 共享的规范文档确保所有人对目标有统一理解。
- **减少返工成本**: 前置规划减少因需求不明确导致的返工。
- **提升代码质量**: 基于严谨规范生成的代码通常结构更合理。
- **加速开发周期**: 规范确定后，代码生成和开发效率大幅提升。

**本质上，SDD是一种编程上下文工程方法，提供更清晰的上下文，确保 AI 生成的代码符合预期。**


### 2.1 核心观点

- **权力反转**：规范为王，代码服务规范。PRD 与技术计划不是“指导编码”的文档，而是生成实现的源头。
- **消除鸿沟**：让“规范—实现计划—代码”成为可执行的连续体，消除传统上规范与代码之间的断裂。
- **AI 赋能但需结构**：AI 能理解并实现复杂规范，但如果缺少结构化规范与实现计划，生成会失控。SDD 提供结构与约束。
- **意图驱动开发**：团队的开发意图以自然语言、设计资产、原则表达；代码只是最后一公里的表达形式。
- **维护即演化规范**：调试意味着修正规范与实现计划；重构意味着提升清晰度；增量开发从规范的更新开始。


### 2.2 为什么重要（当下的必要性）

- **一致性与可追溯**：每个技术决策都能追溯到明确的需求与验收标准。
- **让 SDLC 连续化**：需求与设计不再是一次性阶段，而是贯穿开发的持续活动。
- **组织治理自动化**：数据库、认证、部署等组织约束能够自动融入规范与计划。
- **质量提升**：一致性验证、歧义检测与缺口识别贯穿规范与计划的迭代过程。
- **快速试错**：早期代码生成用于验证规范的可行性与可测试性，从而更快收敛到正确的实现。


### 2.3 核心原则

- **规范是唯一事实来源**：规范与实现计划共同构成真实的源头，代码是它们的表达。
- **规范必须可执行、完整、无歧义**：具备清晰目标、用户故事、验收标准与边界条件。
- **实现计划是技术映射**：从规范到架构、模型、接口、错误处理、测试与部署的具体定义。
- **一致性验证贯穿始终**：持续检查规范、计划与任务之间的内在一致性。
- **变更从规范开始**：先调整规范与计划，再重生成代码，而非直接“手改代码”。
- **分支化协作**：规范与计划像代码一样可审查、版本化、合并。


### 2.4 实现方法（操作要点）

- **规范结构**：阐明目标、用户场景与故事、验收标准、非功能性要求、边界条件。
- **实现计划结构**：选择架构与模式、定义数据模型与接口、错误与异常策略、测试方案、部署与回滚策略。
- **审查清单**：完整性、无歧义、可测试性、一致性、可追溯性与风险说明。
- **验证循环**：小步生成→运行验证→收集反馈→精炼规范与计划→再生成。
- **研究代理集成**：调研库兼容性、性能、安全与组织约束；将结果自动应用于规范。
- **变更管理**：规范更新后，计划自动标记受影响的技术决策与任务，确保变更范围可控。


## 3. 使用方式 (流程)

规范驱动开发通常遵循一个结构化的流程，每个阶段都有明确的任务和验证点。
开发者在其中扮演引导和验证的角色，而 AI 则负责大部分的撰写工作。

一个典型的流程分为四个阶段：

1.  **Specify (规范)**: 开发者提供高层次描述（用户旅程、体验、成功标准），AI 生成详细的功能规范。这个阶段关注 **“什么”** 和 **“为什么”**，而不是技术实现。
2.  **Plan (规划)**: 开发者提供技术栈、架构和约束，AI 生成全面的技术计划。这个阶段关注 **“如何”** 构建。
3.  **Tasks (任务)**: AI 将规范和计划分解为小的、可审查、可独立测试的工作单元。
4.  **Implement (实现)**: AI 逐一完成任务。开发者审查的是专注、解决特定问题的代码变更，而不是庞大的代码转储。

在每个阶段，开发者都需要 **验证和修正** AI 生成的产出，确保其符合真实需求和约束。

### 3.1 工作流细化（与团队协作）

- **从想法到 PRD**：通过与 AI 的迭代对话形成完整、可执行的 PRD，包含验收标准与边界场景。
- **从 PRD 到实现计划**：将需求映射为技术决策，每个选择记录理由并可追溯到具体需求。
- **一致性验证**：在规范、计划与任务之间持续执行歧义检测、矛盾分析与缺口识别。
- **代码生成与探索性迭代**：在规范与计划足够稳定时开始生成；早期生成用于试探与验证规范合理性。
- **版本化协作**：规范与计划在分支中评审与合并，成为团队的共享事实来源。

### 3.2 实践建议（落地到工具）

- **与 Spec-Kit 对齐**：按 specify/plan/tasks/implement 组织步骤；结合 constitution 先立原则，clarify 解决歧义，analyze 做一致性检查。
- **任务粒度**：拆成可独立测试的小单元，保证每步都能审查与回滚。
- **质量门槛**：在每次计划变更后运行 checklist 验证规范质量与可测试性。
- **Bug 修复纳入规范**：记录→分析根因→更新规范与计划→生成修复→验证；避免仅在代码层面“打补丁”。
- **变更先于实现**：任何重大重构或功能扩展，先更新规范与计划，再生成并审查代码。


## 4. Spec-Kit

`Spec-Kit` 是 GitHub 推出的开源工具包，旨在将规范驱动开发带入开发者的 AI 工作流中。

### 4.1 Spec-Kit 核心功能

`Spec-Kit` 提供了一系列命令行工具和模板，与 Cursor、Claude Code、Gemini CLI 等 AI 编码工具深度集成。它包含四阶段核心工作流和一些辅助命令。

**核心工作流**
- `/speckit.specify`: 将功能需求转化为清晰的规范文档。
- `/speckit.plan`: 制定功能的技术实现方案。
- `/speckit.tasks`: 将技术方案分解为可执行的任务清单。
- `/speckit.implement`: 按任务清单逐步实现功能代码。

**辅助命令**
- `/speckit.constitution`: 定义项目的核心原则和开发规范。
- `/speckit.clarify`: 解决规范中的模糊和歧义问题。
- `/speckit.analyze`: 检查规范、计划、任务的一致性。
- `/speckit.checklist`: 生成需求质量验证清单。

### 4.2 Spec-Kit 使用方式

1.  **安装 `specify-cli`**:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# upgrade
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```
    
2.  **初始化项目**:

在项目目录中，使用 AI 助手（如 Cursor）运行初始化命令，并指定 AI 代理。

```bash
specify init . --ai cursor
```
    
3.  **执行工作流**:

在 AI 助手的聊天框中，依次使用 `/speckit.*` 命令来完成开发流程。

```bash
# 1. 创建规范
/speckit.specify 开发一个用户注册功能...

# 2. 制定计划
/speckit.plan 使用 React 和 aaaa UI 库...

# 3. 分解任务
/speckit.tasks

# 4. 实现代码
/speckit.implement
```
    

## 5. Claude Code Spec Workflow

`claude-code-spec-workflow` 是一个针对 Claude Code 的自动化工作流项目，它实现了规范驱动开发和 Bug 修复的流程。

> **注意**: 该项目的开发重点已转移到提供更强功能和更广泛兼容性的 MCP (Model Context Protocol) 版本。

### 5.1 Claude Code Spec Workflow 核心功能

该工作流为 Claude Code 提供了智能任务执行、专用代理、实时仪表盘等功能。

**规范工作流 (新功能)**
- `/spec-create`: 一键完成从需求 -> 设计 -> 任务 -> 命令生成的完整流程。
- `/spec-execute`: 手动执行单个任务。

**Bug 修复工作流**
- `/bug-create`: 记录 Bug。
- `/bug-analyze`: 分析根本原因。
- `/bug-fix`: 实现解决方案。
- `/bug-verify`: 验证修复。

### 5.2 Claude Code Spec Workflow 使用方式

1.  **全局安装**:

```bash
npm i -g @pimzino/claude-code-spec-workflow
```
    
2.  **在项目中设置**:

```bash
claude-code-spec-workflow

# This will create:
#   .claude/ directory structure
#   14 slash commands (9 spec workflow + 5 bug fix workflow)
#   Auto-generated task commands for existing specs
#   Intelligent orchestrator for automated execution
#   Document templates
#   NPX-based task command generation
#   Complete workflow instructions embedded in each command
#   Claude Code sub-agents (mandatory)
# 
# ✔ Installation completed!
# 
# Spec Workflow installation completed successfully!

tree .claude
# .claude
# ├── agents
# │   ├── spec-design-validator.md
# │   ├── spec-requirements-validator.md
# │   ├── spec-task-executor.md
# │   └── spec-task-validator.md
# ├── bugs
# ├── commands
# │   ├── bug-analyze.md
# │   ├── bug-create.md
# │   ├── bug-fix.md
# │   ├── bug-status.md
# │   ├── bug-verify.md
# │   ├── spec-create.md
# │   ├── spec-execute.md
# │   ├── spec-list.md
# │   ├── spec-status.md
# │   └── spec-steering-setup.md
# ├── settings.local.json
# ├── specs
# ├── steering
# └── templates
#     ├── bug-analysis-template.md
#     ├── bug-report-template.md
#     ├── bug-verification-template.md
#     ├── design-template.md
#     ├── product-template.md
#     ├── requirements-template.md
#     ├── structure-template.md
#     ├── tasks-template.md
#     └── tech-template.md
# 
# 7 directories, 24 files
```
    
3.  **使用斜杠命令**:

使用斜杠命令来驱动工作流。例如，开发一个新功能：
```bash
# 创建项目上下文文档
/spec-steering-setup

# 描述需求后，一键创建规范和任务
/spec-create lingolearn-app "开发一个单词卡片应用..."

# 逐个执行生成的任务
/spec-execute 1 lingolearn-app
```
    

#### 执行效果说明

- `/spec-steering-setup`
  - 初始化项目“共同上下文”与指导文档：项目背景与目标、组织/技术约束、核心原则、命名与目录约定、质量门槛等。
  - 建立工作流所需的基本配置，供后续规范与实现计划的生成复用。

- `/spec-create <app> "<需求>"`
  - 生成并持久化以下可审查工件（通常以 Markdown 文档形式保存，便于版本化与评审）：
    - PRD/规范：目标、用户故事、验收标准、非功能需求、边界条件。
    - 技术实现计划：架构与模块设计、数据模型/接口契约、异常与错误处理策略、测试方案、部署与回滚策略。
    - 任务清单：按可独立测试的粒度拆分的任务列表，带有依赖关系与验收要点。
    - 命令脚本草案：为各任务生成建议的运行与验证命令（如 build/test/lint 等）。
  - 同步建立规范、计划与任务之间的追溯关系，确保每个技术决策都能回溯到明确需求。

- `/spec-execute <taskId> <app>`
  - 执行指定任务，生成对应的代码变更以及必要的测试用例草稿与运行步骤。
  - 在 Claude Code 面板中呈现变更 diff 与命令输出，供审查、接受或回退；失败时给出问题诊断与下一步建议。
  - 更新任务状态与相关文档的引用，维持“规范—计划—任务—代码”的闭环与一致性。


## APPENDIX. 参考

- GitHub 博客：Spec-Driven Development 概览与工具包 — https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- 官方文档：Specification-Driven Development 详解 — https://github.com/github/spec-kit/blob/main/spec-driven.md
- GitHub 项目：Spec-Kit 开源工具集 — https://github.com/github/spec-kit
- 中文资源：Spec-Kit 中文版与文档 — https://github.com/888888888881/spec-kit-chinese
- 项目仓库：Claude Code Spec Workflow — https://github.com/Pimzino/claude-code-spec-workflow
- 中文解读：Claude Code Spec Workflow 工作流介绍 — https://zhuanlan.zhihu.com/p/1948519805884805722

