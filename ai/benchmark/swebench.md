# SWE-bench 测试指南

SWE-bench 是一个用于评估大型语言模型在真实软件问题上表现的基准测试框架。它通过执行驱动的评估框架（Evaluation Harness）来验证模型生成的补丁（Patch）能否真正修复问题。

## 准备工作：搭建环境与满足硬件需求

### 硬件配置

- **推荐配置**：至少拥有 **120GB 可用存储空间**、**16GB 内存** 和 **8个CPU核心**
- **高性能配置（可选）**：**32核CPU** 和 **128GB内存** 的机器，可以在1小时左右跑完 SWE-bench Verified 数据集

### 软件与依赖

- **Python 环境**：需要 **Python 3.9 或更高版本**，推荐使用 `venv` 创建虚拟环境
- **Docker**：**这是 SWE-bench 运行的基石**，评估全程在 Docker 容器中进行
- **系统架构**：**x86_64** 是最佳选择；**ARM64**（如 Mac M 系列芯片）仍为实验性支持

### 安装验证

```bash
# 克隆项目
git clone https://github.com/princeton-nlp/SWE-bench.git
# git clone https://gh-proxy.com/https://github.com/princeton-nlp/SWE-bench.git
cd SWE-bench

# 2. 创建 Python 虚拟环境（要求 Python 3.9+）
python3 -m venv venv

# 3. 激活虚拟环境
# Linux / macOS:
source venv/bin/activate
# Windows (PowerShell):
# .\venv\Scripts\Activate.ps1

# 安装核心包（-e 表示以可编辑模式安装）
pip install -e .
```

## 数据准备与配置

### 选择合适的数据集

| 数据集 | 规模 | 说明 |
|--------|------|------|
| **SWE-bench Lite** | 534个问题 | **推荐入门首选**，能快速完成评估迭代 |
| SWE-bench Verified | 500个问题 | 高质量验证集，经专家确认可解 |
| SWE-bench Multilingual | 300个任务 | 跨语言版本，包含9种编程语言、42个仓库 |
| SWE-bench Multimodal | - | 多模态版本，包含UI截图等视觉信息 |

### 加载数据集

```python
from datasets import load_dataset

# 加载 Lite 版本，split='test' 获取完整测试集
swebench_lite = load_dataset('princeton-nlp/SWE-bench_Lite', split='test')
```

### 数据集结构解析

每个数据实例包含以下关键字段：

- `instance_id`: 任务的唯一标识符，如 `"sympy__sympy-20590"`
- `repo`: 代码仓库名称，如 `"sympy/sympy"`
- `problem_statement`: GitHub Issue 的问题描述
- `patch`: 人工编写的正确补丁（仅在训练或验证流程时使用）
- `test_patch`: 用于验证补丁正确性的测试用例

## 生成模型预测（Model Prediction）

### 输入与输出

将 `problem_statement` 和 `repo` 的信息作为输入提供给 AI Agent，期待其输出一个用于修复问题的 `model_patch`。

### 输出格式要求

所有模型的预测结果必须整理成一个 **JSONL (JSON Lines)** 文件，每一行都严格遵循以下格式：

```json
{
  "instance_id": "sympy__sympy-20590",
  "model_name_or_path": "your-agent-name",
  "model_patch": "diff --git a/sympy/core/sympify.py b/sympy/core/sympify.py\n..."
}
```

### 利用官方模型进行测试

```bash
python -m swebench.inference.run_llama \
  --model_name_or_path princeton-nlp/SWE-Llama-13b \
  --dataset_name princeton-nlp/SWE-bench_Lite \
  --max_instances 10 \
  --output_dir <path_to_output>
```

## 运行评估与验证

### 基础评估命令

```bash
python -m swebench.harness.run_evaluation \
  --dataset_name princeton-nlp/SWE-bench_Lite \
  --predictions_path <your_predictions.jsonl> \
  --max_workers 8 \
  --run_id my_first_evaluation
```

### 关键参数说明

| 参数 | 说明 |
|------|------|
| `--dataset_name` | 指定使用的数据集 |
| `--predictions_path` | **必须**，指向预测 JSONL 文件 |
| `--max_workers` | 并行运行的工作线程数，建议设置为 `min(0.75 * CPU核心数, 24)` |
| `--instance_ids` | 指定一个或多个具体的 `instance_id`，用于只评估特定任务 |

### 验证安装的正确性

```bash
python -m swebench.harness.run_evaluation \
  --max_workers 1 \
  --instance_ids sympy__sympy-20590 \
  --predictions_path gold \
  --run_id validate-gold
```

**注意**：在 Mac M 系列等 ARM 架构机器上运行，请务必添加 `--namespace ''` 参数。

## 高级主题

### 云端评估

如果本地资源有限，SWE-bench 支持通过 Modal 平台进行云端评估：

```bash
pip install modal swebench[modal]
modal setup
python -m swebench.harness.run_evaluation \
  --dataset_name princeton-nlp/SWE-bench_Lite \
  --predictions_path <your_predictions.jsonl> \
  --modal true
```

### 自定义评估

- **评估自己的代码库**：使用 SWE-bench 的数据收集工具，为自己的代码库构建专属的评估数据集
- **编写自定义评估脚本**：直接使用 SWE-bench 的 Docker API，编写脚本控制容器的构建、补丁的应用和测试的运行

## 常见问题与技巧

### Docker 镜像拉取失败

**解决**：尝试在命令中添加 `--namespace ''` 参数，强制在本地构建镜像而非从 Docker Hub 拉取。

### 评估速度慢或资源不足

**解决**：适当减少 `--max_workers` 的值。同时，可以定期使用 `docker system prune` 清理无用的镜像和日志。

### 磁盘空间不足

**解决**：SWE-bench 的 Docker 镜像和日志文件会占用大量空间，评估完成后，注意清理 `logs/` 目录下的历史日志。

### 使用缓存提速

利用 `--cache_level` 参数（可选 `none`, `base`, `env`, `instance`）来控制 Docker 镜像的缓存级别，避免重复构建相同环境。

## 总结清单

- [ ] **硬件检查**：确认磁盘、内存和 CPU 满足最低要求（至少 120GB, 16GB, 8 核）
- [ ] **软件安装**：正确安装并配置 Python (≥3.9) 和 Docker
- [ ] **环境验证**：运行 `gold` 测试，确保评估工具（Harness）能正常工作
- [ ] **数据选择**：从 Hugging Face 加载数据集，初学者建议从 `SWE-bench Lite` 开始
- [ ] **生成预测**：让 Agent 为每个任务生成 `model_patch`，并按 JSONL 格式整理
- [ ] **运行评估**：使用 `run_evaluation` 命令，对预测结果进行自动化测试
- [ ] **分析结果**：检查评估输出和日志，分析 Agent 的性能表现

## 参考资源

- [SWE-bench GitHub 仓库](https://github.com/princeton-nlp/SWE-bench)
- [SWE-bench 官方文档](https://www.swebench.com/)
- [Hugging Face 数据集](https://huggingface.co/datasets/princeton-nlp/SWE-bench_Lite)
