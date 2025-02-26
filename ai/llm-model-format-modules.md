<!---
markmeta_author: titlwind
markmeta_date: 2025-02-19
markmeta_title: LLM 格式及模块
markmeta_categories: ai
markmeta_tags: ai,llm
-->


# LLM 格式及模块

> 注意: 部分内容来自AI生成，可能存在错误，如有发现，欢迎指正！


### **一、标准模型文件格式**
大模型文件通常以以下格式存储：
1. **PyTorch 格式** (`.pth`, `.pt`)
   - 包含完整的模型架构（`state_dict`保存参数）或仅参数
   - 支持动态计算图
2. **TensorFlow 格式** (`.pb`, SavedModel)
   - 包含计算图（GraphDef）、参数和元数据
3. **HDF5 格式** (`.h5`, `.hdf5`)
   - 支持分层存储参数和元数据（Keras 常用）
4. **ONNX 格式** (`.onnx`)
   - 跨框架的标准化中间表示，支持模型导出和部署
5. **GGUF/GGML 格式** (`.gguf`, `.ggml`)
   - 专为CPU推理优化的量化格式（Llama.cpp等使用）


### **二、模型内部核心模块**
以Transformer架构为例，典型模块包括：
1. **输入嵌入层** (Embedding Layer)
   - 将输入Token映射为高维向量
2. **位置编码模块** (Positional Encoding)
   - 添加位置信息（如绝对/相对位置编码）
3. **编码器/解码器堆叠层**
   - **自注意力子层** (Self-Attention)
     - 计算Query、Key、Value，生成上下文相关表示
   - **前馈网络子层** (Feed-Forward Network, FFN)
     - 非线性变换（如两层全连接+激活函数）
   - **残差连接与层归一化** (Residual + LayerNorm)
     - 稳定训练，缓解梯度消失
4. **交叉注意力层** (Decoder特有)
   - 在解码器中融合编码器输出信息
5. **输出层** (Output Projection)
   - 将隐状态映射到词表空间（Logits）


### **三、从输入到输出的处理流程**
以文本生成任务为例（如GPT类模型）：

#### **1. 输入处理阶段**
- **分词** (Tokenization)
  - 将原始文本切分为Token序列（如BPE算法）
- **嵌入层** (Embedding Layer)
  - Token → 向量表示（`[batch_size, seq_len, dim]`）
- **位置编码** (Positional Encoding)
  - 添加位置信息（如旋转位置编码RoPE）

#### **2. 编码器处理阶段**（仅Encoder或Encoder-Decoder架构）
- **多头自注意力计算**
  - 输入：嵌入向量 + 位置编码
  - 输出：上下文感知的隐状态
- **前馈网络变换**
  - 通过全连接层（可能含激活函数如GeLU）
- **残差连接与归一化**
  - `输出 = LayerNorm(输入 + 子层输出)`

#### **3. 解码器处理阶段**（仅Decoder或Encoder-Decoder架构）
- **掩码自注意力**
  - 防止未来信息泄漏（使用因果掩码）
- **交叉注意力**（Encoder-Decoder架构）
  - 融合编码器的输出信息
- **前馈网络与归一化**

#### **4. 输出生成阶段**
- **Logits计算**
  - 通过输出层将隐状态映射到词表空间（`[batch_size, seq_len, vocab_size]`）
- **概率分布生成**
  - Softmax归一化得到概率分布
- **采样策略**
  - 贪婪搜索（Greedy Search）、束搜索（Beam Search）或温度采样（Temperature Sampling）

### **四、附加模块与优化技术**
1. **缓存机制** (KV Cache)
   - 推理时缓存Key/Value矩阵，加速自回归生成
2. **量化压缩模块**
   - 参数精度压缩（如FP16→INT8）
3. **分布式训练模块**
   - 参数分片（如ZeRO优化）
4. **适配器模块** (Adapter)
   - 微调时插入小型可训练模块（如LoRA）


### **五、典型架构差异**
- **纯Encoder模型**（如BERT）：
  仅保留编码器，适用于理解任务（分类、NER）
- **纯Decoder模型**（如GPT）：
  仅保留解码器，适用于生成任务
- **Encoder-Decoder模型**（如T5）：
  两者结合，适用于翻译、摘要等任务


### **六、训练与推理差异**
| **阶段** | **关键操作**                          |
|----------|---------------------------------------|
| **训练** | 反向传播、梯度更新、Dropout激活       |
| **推理** | 禁用Dropout、使用KV缓存、内存优化     |

通过这一流程，模型将原始输入逐步转化为高层次的语义表示，最终生成结构化输出。
不同框架和模型的具体实现可能有所不同，但核心模块和流程遵循类似模式。