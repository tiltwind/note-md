<!---
markmeta_author: 斜风
markmeta_date: 2023-03-28
markmeta_title: ChatGPT
markmeta_categories: 思考
markmeta_tags: think
-->

# 认识 ChatGPT

## GPT

Generative Pre-training Transformer （生成式预训练Transfomer模型）, 它基于 Transformer 架构，GPT模型先在大规模语料上进行无监督预训练、再在小得多的有监督数据集上为具体任务进行精细调节（fine-tune）的方式。先训练一个通用模型，然后再在各个任务上调节，这种不依赖针对单独任务的模型设计技巧能够一次性在多个任务中取得很好的表现。

- Generative, 生成式。 在机器学习里，有判别式模式(discriminative model)和生成式模式(Generative model)两种区别。生成式模型相比判别式模型更适合大数据学习 ，后者更适合精确样本(人工标注的有效数据集）。GPT是单向生成，即根据上文生成下文。
- Pre-Trained, 预训练
- Transformer, 在Transformer模型出来前，RNN模型(循环神经网络)是典型的NLP模型架构，基于RNN还有其他一些变种模型（忽略其名字，Transformer出来后，已经不再重要了），但是都存在相同的问题，并没能很好解决。RNN的基本原理是，从左到右浏览每个单词向量(比如说this is a dog)，保留每个单词的数据，后面的每个单词，都依赖于前面的单词。RNN的关键问题：前后需要顺序、依次计算。可以想象一下，一本书、一篇文章，里面是有大量单词的，而又因为顺序依赖性，不能并行，所以效率很低。2017年6月，Google发布论文《Attention is all you need》，首次提出Transformer模型，成为GPT发展的基础。GPT的Transformer相比google论文原版Transformer是简化过的，只保留了Decoder部分。通过大量的无监督预训练(Unsupervised pre-training)，再通过少量有监督微调（Supervised fine-tunning)，奖励模型训练Reward Model，增强学习优化RPO。

chatGPT 只是 GPT 模型的一个应用，是一个对话式的交互接口。

## 发展历史

- 2017年，谷歌发布论文《Attention is all you need》，提出Transformer模型，为GPT铺就了前提。
- 2018年6月，OpenAI发布了GPT生成式预训练模型，通过BooksCorpus大数据集（7000本书）进行训练，并主张通过大规模、无监督预训练（pre-training)+有监督微调(fine-tuning)进行模型构建。
- 2019年2月，OpenAI发布GPT-2模型，进一步扩大了训练规模(使用了40GB数据集，最大15亿参数(parameters))。同时在思路上，去掉了fine-tuning微调过程，强调zero-shot(零次学习)和multitask(多任务)。但是最终zero-shot效果显著比不上fine-tuning微调。
- 2020年5月，OpenAI发布GPT-3模型，进一步扩大了**训练规模(使用了570GB数据集，和1750亿参数)**。同时采取了few-shot(少量样本）学习的模式，取得了优异效果。 当然，在实验中同步对比了fine-tuning，比fine-tuning效果略差。
- 2022年2月，OpenAI发布Instruction GPT模型，此次主要是在GPT-3的基础上，增加了监督微调(Supervised Fine-tuning)环节，并且基于此，进一步加入了Reward Model奖励模型，通过RM训练模型来对学习模型进行RPO增强学习优化。
- 2022年11月30日，OpenAI发布ChatGPT模型，可以理解为一个多轮迭代训练后的InstructionGPT，并在此基础上增加了Chat对话聊天功能。


## 相关论文

- 2017年6月，Google发布论文《Attention is all you need》，首次提出Transformer模型，成为GPT发展的基础。 论文地址： https://arxiv.org/abs/1706.03762
- 2018年6月,OpenAI 发布论文《Improving Language Understanding by Generative Pre-Training》(通过生成式预训练提升语言理解能力)，首次提出GPT模型(Generative Pre-Training)。论文地址： https://paperswithcode.com/method/gpt 。
- 2019年2月，OpenAI 发布论文《Language Models are Unsupervised Multitask Learners》（语言模型应该是一个无监督多任务学习者），提出GPT-2模型。论文地址: https://paperswithcode.com/method/gpt-2
- 2020年5月，OpenAI 发布论文《Language Models are Few-Shot Learners》(语言模型应该是一个少量样本(few-shot)学习者，提出GPT-3模型。论文地址： https://paperswithcode.com/method/gpt-3
- 2022年2月底，OpenAI 发布论文《Training language models to follow instructions with human feedback》（使用人类反馈指令流来训练语言模型），公布Instruction GPT模型。论文地址： https://arxiv.org/abs/2203.02155


## 参考

1. 知乎搞懂GPT, https://zhuanlan.zhihu.com/p/403469926
2. 理解ChatGPT的技术逻辑及演进, https://www.freebuf.com/articles/others-articles/352202.html
3. 十分钟理解Transformer, https://zhuanlan.zhihu.com/p/82312421
4. 台大教授李宏毅的视频《ChatGPT是怎么炼成的？GPT社会化过程》。https://www.inside.com.tw/article/30032-chatgpt-possible-4-steps-training
5. Generative Model, https://en.wikipedia.org/wiki/Generative_model