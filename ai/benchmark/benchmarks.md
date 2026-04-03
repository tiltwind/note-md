# AI Agent Benchmarks 汇总

本文档汇总了各类用于评估 AI Agent 编程能力的基准测试（Benchmark），按测试重点分类整理。

---

## 🚀 工程级与仓库级

| 基准名称 | 核心测试内容 | 特点与适用场景 | 链接 |
| :--- | :--- | :--- | :--- |
| **SWE-bench** | 真实软件工程任务，如修复 GitHub issue、跨多文件代码变更 | **行业黄金标准**。最贴近真实开发，适合评估 Agent 的综合工程能力 | https://www.swebench.com/ |
| **SWE-bench-C** | C 语言版本的 SWE-bench | 针对 C 语言代码库的软件工程任务评估 | https://www.swebench.com/ |
| **SWE-bench Mobile** | 移动应用开发版本的 SWE-bench | 针对移动端开发的软件工程任务评估 | https://www.swebench.com/ |
| **SWE-bench Long** | 长周期任务的 SWE-bench 扩展 | 评估处理长期、复杂任务的能力 | https://www.swebench.com/ |
| **Scale-SWE** | 自动化、沙箱化的 SWE 数据集构建 | 提供更高质量、多样化的仓库级任务，适用于评估和训练 | - |
| **OmniCode** | 除代码生成外，还覆盖 bug 修复、测试生成、代码评审修复等 | 覆盖面广（Python, Java, C++），全面评估软件工程任务 | - |
| **AGENTbench** | 来自小众 GitHub 仓库的 138 个 Python 任务 | 避免了流行基准的常见偏差，提供更独特的测试视角 | - |
| **RepoBench** | 仓库级代码自动补全，测试跨文件的检索、补全和流水线能力 | 专注于代码补全系统，测试其理解项目上下文的能力 | - |
| **CodeTree** | LLM Agent 引导的树搜索代码生成 | 评测 Agent 在复杂代码生成中的路径搜索和决策能力 | - |
| **ProjectEval** | 通过模拟用户交互，评估项目级代码生成 | 模拟真实开发流程，评估从需求到项目产出的端到端能力 | - |

---

## ✍️ 代码生成基准

| 基准名称 | 核心测试内容 | 特点与适用场景 | 链接 |
| :--- | :--- | :--- | :--- |
| **HumanEval** | 164 个手写的 Python 编程问题，评估函数级代码生成 | **最经典的代码生成基准**。侧重功能正确性，易于上手 | https://github.com/openai/human-eval |
| **MBPP** | 约 1000 个面向初学者的 Python 编程问题 | 涵盖更广泛的基础编程场景，适合基础能力评估 | https://github.com/google-research/google-research/tree/master/mbpp |
| **APPS** | 约 5000 个编程问题，难度从入门到竞赛级 | 覆盖不同难度，适合评估模型处理复杂问题的能力 | https://github.com/hendrycks/apps |
| **CodeXGLUE** | 10 个任务、14 个数据集的代码理解和生成集合 | 综合性最强，涵盖翻译、搜索、补全等多种任务，支持多语言 | https://github.com/microsoft/CodeXGLUE |
| **CodeVisionary** | 首个基于 Agent 的复杂代码生成评估框架 | 模拟 Agent 行为模式，进行更动态、更具交互性的评估 | - |
| **LiveCodeBench Pro** | 来自 Codeforces 等平台的竞赛编程问题，持续更新 | 动态更新，可有效防止数据污染，难度较高，适合极限挑战 | https://livecodebench.github.io/ |
| **CodeElo** | 基于 Codeforces 竞赛评级系统的基准 | 采用 Elo 评分体系，提供与人类程序员对比的直观衡量标准 | - |

---

## 🛠️ 工具调用与函数执行

| 基准名称 | 核心测试内容 | 特点与适用场景 | 链接 |
| :--- | :--- | :--- | :--- |
| **τ²-bench (Tau²)** | 动态对话环境中的工具使用能力 | 模拟真实客服等场景，要求 Agent 在对话中动态调用 API | - |
| **BFCL (Berkeley Function Calling Leaderboard)** | 评估 LLM 的 Function Calling 能力 | 业界公认的工具调用基准，覆盖面广，参考价值高 | https://gorilla.cs.berkeley.edu/leaderboard.html |
| **ToolBench** | 基于约 1.6 万个真实 API 的多步工具调用 | 真实 API，任务复杂，适合评估多步规划和 API 编排 | https://github.com/OpenBMB/ToolBench |
| **Gorilla (APIBench)** | 训练和评估 LLM 准确调用 API 的能力 | 专注于 API 调用准确性，附带专门的评估数据集 APIBench | https://gorilla.cs.berkeley.edu/ |
| **MCPToolBench++** | 针对 MCP 协议的工具调用基准，覆盖 40+ 类别 | 关注新兴的 Model Context Protocol (MCP)，具有前瞻性 | - |

---

## 🧠 通用 Agent 能力

| 基准名称 | 核心测试内容 | 特点与适用场景 | 链接 |
| :--- | :--- | :--- | :--- |
| **GAIA** | Meta 与 Hugging Face 联合打造，测试长程规划、多模态、推理等 12 项核心能力 | **通用 Agent 的顶级试炼场**。难度高，Level 3 任务接近人类水平 | https://huggingface.co/spaces/gaia-benchmark/leaderboard |
| **WebArena** | 在模拟的电商、论坛等真实网站环境中完成网页任务 | 评估 Agent 在复杂、动态网页环境中的交互与任务执行能力 | https://webarena.dev/ |
| **MLAgentBench** | 机器学习实验任务，如读取文件、执行代码、分析结果等 | 面向 AI 研究助手，评估其在端到端机器学习实验中的自主性 | https://github.com/snap-stanford/MLAgentBench |
| **MINT** | 多轮交互，侧重工具使用和自然语言反馈学习 | 强调从错误中学习和迭代，适合评估自我修正能力 | - |

---

## 💡 如何选择

建议分两步走：

1. **快速原型验证**：初期可选择 **HumanEval** 和 **τ²-bench** 等上手快、反馈直接的基准，快速验证 Agent 的核心代码生成和基础工具调用能力。
2. **最终实力评估**：当功能稳定后，升级到 **SWE-bench** 和 **GAIA** 等更全面的基准，模拟真实开发场景，衡量其解决复杂工程问题的综合能力。
