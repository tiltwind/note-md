# HumanEval 测试指南

HumanEval 是 OpenAI 发布的经典代码生成基准测试，包含 164 个手写 Python 编程问题，用于评估模型的函数级代码生成能力。

---

## 📋 环境要求

- Python 3.7 或更高版本
- 支持 Unix/Linux/macOS 系统（Windows 需使用 WSL）

---

## 🚀 安装步骤

### 1. 创建虚拟环境（推荐）

```bash
# 使用 conda
conda create -n humaneval python=3.7
conda activate humaneval

# 或使用 venv
python3 -m venv humaneval_env
source humaneval_env/bin/activate
```

### 2. 克隆仓库并安装

```bash
# 克隆仓库
git clone https://github.com/openai/human-eval.git
cd human-eval

# 安装依赖
pip install -e .
```

---

## 📝 数据集说明

HumanEval 数据集位于 `data/` 目录下：

- `data/HumanEval.jsonl.gz` - 包含 164 个编程问题
- 每个问题包含：任务描述、函数签名、测试用例等

数据格式示例：
```json
{
  "task_id": "HumanEval/0",
  "prompt": "def has_close_elements(numbers: List[float], threshold: float) -> bool:\n    \"\"\" Check if in given list of numbers, are any two numbers closer to each other than...",
  "entry_point": "has_close_elements",
  "canonical_solution": "...",
  "test": "def check(has_close_elements):\n    assert has_close_elements([1.0, 2.0, 3.0], 0.5) == False\n    ..."
}
```

---

## 🧪 运行测试

### 基本用法

```bash
# 评估生成的代码
human-eval \
  --input-file <generated_samples.jsonl> \
  --output-file <results.jsonl>
```

### 输入文件格式

`generated_samples.jsonl` 每行应包含：
```json
{"task_id": "HumanEval/0", "completion": "    for i in range(len(numbers)):\n        for j in range(i+1, len(numbers)):\n            if abs(numbers[i] - numbers[j]) < threshold:\n                return True\n    return False\n"}
```

### 完整示例流程

```bash
# 1. 准备模型生成的代码文件
# 格式：每行一个 JSON，包含 task_id 和 completion

# 2. 运行评估
human-eval \
  --input-file my_model_generations.jsonl \
  --output-file results.jsonl

# 3. 查看结果
# 结果文件包含每个任务的 pass@k 分数
```

---

## 📊 评估指标

HumanEval 主要使用 **pass@k** 指标：

- **pass@1**: 模型生成 1 个答案时的通过率
- **pass@10**: 生成 10 个答案中至少 1 个通过的概率
- **pass@100**: 生成 100 个答案中至少 1 个通过的概率

计算公式：
```
pass@k = E[1 - C(n-c, k) / C(n, k)]
```
其中 n 为生成样本数，c 为正确样本数。

---

## ⚠️ 安全注意事项

HumanEval 会执行生成的代码，存在安全风险：

1. **在隔离环境中运行**（Docker/WSL/虚拟机）
2. **不要直接运行不信任模型生成的代码**
3. 可以使用沙箱工具如 [Riza](https://riza.io/) 进行安全执行

### 使用 Docker 隔离运行

```bash
# 创建 Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.7-slim

WORKDIR /app
RUN git clone https://github.com/openai/human-eval.git
WORKDIR /app/human-eval
RUN pip install -e .

ENTRYPOINT ["human-eval"]
EOF

# 构建并运行
docker build -t humaneval .
docker run -v $(pwd)/data:/data humaneval \
  --input-file /data/generations.jsonl \
  --output-file /data/results.jsonl
```

---

## 🔗 相关资源

- **官方仓库**: https://github.com/openai/human-eval
- **论文**: [Evaluating Large Language Models Trained on Code](https://arxiv.org/abs/2107.03374)
- **Hugging Face 评估**: 可使用 `evaluate` 库加载 HumanEval 数据集

```python
# 使用 Hugging Face evaluate 加载
from evaluate import load
code_eval = load("openai_humaneval")
```

---

## 💡 最佳实践

1. **温度参数**: 生成多个样本时建议使用 temperature > 0
2. **样本数量**: 计算 pass@1 建议生成 1 个样本；pass@100 建议生成 200 个样本
3. **结果复现**: 记录随机种子以确保结果可复现
4. **并行评估**: 可使用多进程加速评估过程
