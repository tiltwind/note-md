<!---
markmeta_author: titlwind
markmeta_date: 2025-02-19
markmeta_title: LLM 词汇
markmeta_categories: ai
markmeta_tags: ai,llm,terms
-->


# LLM 词汇

## 预训练（Pre-training）

通过海量通用数据（如网页、书籍）学习语言的底层模式和知识（语法、逻辑、常识）。 
无监督或自监督学习（如预测被遮挡的词、生成下一句话）。  
需要巨量计算资源（数千张GPU/TPU）、长时间训练（数周至数月）。  
 通用基础模型（如GPT-3、BERT）。

## 微调（Fine-tuning）
在预训练模型基础上，用特定领域数据（如医学文献、法律合同）适配具体任务（分类、问答）。  
监督学习（使用标注数据调整模型参数）。  
资源消耗低（单卡或少量GPU）、训练时间短（几小时至几天）。  
领域专用模型（如医疗问答机器人）。

