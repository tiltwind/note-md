<!---
markmeta_author: titlwind
markmeta_date: 2023-06-30
markmeta_title: Note for ChatGPT Prompt Engineering for Developers (Andrew Ng)
markmeta_categories: ai
markmeta_tags: ai,prompt-engineering
-->

# Note for ChatGPT Prompt Engineering for Developers (Andrew Ng)


## 1. Introduction

**Base LLM(基础大语言模型)**: Predicts next word, based on text training data

```
**Once upon a time, there was a unicorn** that lived in a magical forest with all her unicorn friends

**What is the capital of France?**

当输入为“法国的首都在哪里?”时，例如 GPT-2 的基础大语言模型会将这段话视为一段话的开头，尝试模仿这个问句预测后面几句话，输出“法国最大的城市在哪里？法国的人口有多少？”

What is France's largest city?
What is France's population?
What is the currency of France?
```

**Instruction Tuned LLM(指令微调大语言模型)**: 
- Tries to follow instructions
- Fine-tune on instructions and good attempts at following those instructions.
- RLHF: Reinforcement Learning with Human Feedback
- Helpful, Honest, Harmless

```
What is the capital of France?

ChatGPT (GPT-3.5) 则会将其视为指令给出这个问句的答案“法国的首都在巴黎”。

The capital of France is Paris.
```


## 2. Principle 1: Write clear and specific instructions

应当通过提供尽可能明确和具体的指令来表达我们希望模型执行的操作。这将引导模型获得所需的输出，并减少获得不相关或不正确响应的可能性。 注意不要混淆“明确的提示”和“简短的提示”，因为在许多情况下，较长的提示实际上为模型提供了更多的清晰度和上下文，这实际上可以带来更详细和相关的输出。


### 2.1. 策略一：使用定界符清楚地指示输入的不同部分

定界符可以是任何明确的标点符号，将需要处理的的文本片段与指令部分分开，让模型非常清楚它应该处理的确切文本。


### 2.2. 策略二：请求结构化的输出

为了更轻松地解析模型的输出，我们可以请求模型以 HTML 或 JSON 这样的结构化格式输出信息。

```
Prompt: Generate a list of three made-up book titles along with their authors and genres. Provide them in JSON format with the following keys: book_id, title, author, genre.

Response: [ { "book_id": 1, "title": "The Lost City of Zorath", "author": "Aria Blackwood", "genre": "Fantasy" }, { "book_id": 2, "title": "The Last Survivors", "author": "Ethan Stone", "genre": "Science Fiction" }, { "book_id": 3, "title": "The Secret Life of Bees", "author": "Lila Rose", "genre": "Romance" } ]

```


### 2.3. 策略三：让模型检查条件是否满足

如果执行一项任务需要满足一定的前提条件，那么我们可以告诉模型首先检查这些条件是否被满足，只有满足时才执行任务，不满足时则输出提示信息。


### 2.4. 策略四：“少样本”提示
“少样本”（few-shot）可以理解为模型利用少量未知领域的样本举一反三的能力。
当我们对模型的输出有一个比较明确的预期时，我们可以通过举一些例子告诉模型我们期望得到怎样的输出。
之后模型将会根据我们给出的少量样本执行更多的任务。


## 3. Principle 2: Give the model time to think

ChatGPT 建立在基本大语言模型的基础上，其原理依旧是依据前文不断预测下一个输出的单词。
所以，我们有两种方式让它得出结论：
- 仅通过用户的问题直接逐个单词预测答案；
- 先让模型输出一段思考过程，再根据问题和思考过程作为前文预测答案。

类比于我们解复杂的数学题总是要一步一步做一样，让模型先输出一段思考过程的第二种方式效果往往都会优于直接得出答案的第一种方式。
因此留给模型充足的“思考时间”是一项很重要的原则。


### 3.1. 策略一：让模型分步骤完成任务


### 3.2. 策略二：让模型先给出自己的解决方案，再下结论
例子：
- 给出一道题和一段解答，判断解答是否正确 让模型直接判断正误：
- 让模型先自己给一个题解，再判断我们给的题解是否正确：
- 输出：判断成功，得出了正确的题解并且判断给定题解是错的

> 在论文《Large Language Models are Zero-Shot Reasoners》中，作者发现只要在提示语中里加上一句“Let's think step by step”就能提高 Chatgpt 回答的逻辑性，这一方法也被称为「思维链」(Chain of Thought, CoT)。

### 3.3. 模型的局限性：幻觉 (Hallucinations)
ChatGPT 的一项局限性在于，它并不十分清楚自己知识的边界在哪里。这意味着它可能会在回答某些话题时编造一些看似合理实则不正确的信息（口胡）。
这种模型虚构的信息被称作“幻觉”（Hallucinations）。 
为了避免模型幻觉，我们
- 首先应当确保自己的提示里不包含误导性的错误信息；
- 其次避免让模型回答一些生僻的或前置条件不够的知识性问题，而更多让模型基于我们的文本给出回答；
- 最后，为了避免模型输出偏离我们给出的文本，我们可以要求模型在生成回答的同时引用原文以提高准确性。


## 4. 使用迭代开发策略改进你的提示语


### 4.1. 提示应用的开发理论
当我们为了解决任务构造合适的提示语时，我们实际上已经处在开发一个提示应用（prompt application）的过程中。在这个过程中，我们往往不能一次性找到最合适的那个提示语，而需要根据模型的输出不断调整和修改。我们可以借鉴软件工程的思想，用迭代策略（iterative strategy）系统化我们改进提示语的过程，而这和大语言模型开发的迭代过程是非常相进的。

大语言模型的迭代开发过程：点子->实现->实验结果->错误分析->回到点子->...

提示应用的开发过程：

1. 给出明确且具体的指令； 
2. 查看模型的输出； 
3. 分析为什么没有得到想要的输出，是因为指令不够明确，还是没有给模型足够的思考时间？ 
4. 改进思路和提示语，进一步明确指令，给模型更多思考时间。 
5. 回到第一步继续，直到得到满意的结果。


例子：从产品说明书生成营销文案。现在，我们有如下的产品说明书，我们需要利用 ChatGPT 来根据它生成一段营销文案。

- 第一轮迭代：使用基本的提示生成营销文案
- 第二轮迭代：一段带有长度限制的提示
- 第三轮迭代：关注于特定受众偏好的提示语
- 最后一轮迭代：明确要求长度限制、关注点、输出格式和额外信息的提示语

使用更多样本进行迭代
上例中，我们使用了一段产品说明书来评估提示的好坏，进而分析提示不足的原因展开迭代。但对于一些复杂的应用程序，则往往需要通过一个批次（10 个甚至 50 个以上）的样本评估，才能选出最终效果最佳的提示语。不过，一般而言也只有在大型提示应用开发的最后几个步骤才会用到大量的样本来改进提示效果，而对于个人用户而言，很多提示语是都是一次性的，只在自己的文本上进行评估迭代就足够了。


## 5. 文本摘要
摘要或是 ChatGPT 的一项非常实用的应用，它可以帮助我们快速从长文本中找到自己需要的信息，而无需花时间亲自读完整段文本，从而大大加快我们我们查资料、了解信息的过程。 在商业中，文本摘要技术也存在广泛的应用。以下是一段客户对商品的评价，我们将代替商家总结出这篇评价中的主要部分，以便于商家快速浏览这些评价，找出商品在市场上的优势和不足之处。


```
Your task is to generate a short summary of a product review from an ecommerce site. 

Summarize the review below, delimited by triple backticks, in at most 30 words. 

Review: \`\`\`{prod_review}\`\`\`
```


## 6. 推断任务
情感分析、实体识别与主题提取是三种常见的推断工作。
以往的深度学习工程师如果需要实现这三个任务，则至少要用不同的数据集把模型训练为三种不同的权重。
而 ChatGPT 搭配合适的提示语把这些曾经麻烦的任务变得唾手可得。


### 6.1. 情感分析任务
情感分析是指由模型推断一句话的情感倾向（正面/中立/负面）或所包含的情感（欢快、愤怒等），具有非常广泛的应用。在下面的例子中，我们通过编写合适的提示语让 ChatGPT 为我们分析商品评价的情感色彩，进而可以把这些评价按消极/积极归类起来，留作不同用途。


判断商品评价的整体情感倾向:
```
What is the sentiment of the following product review, 
which is delimited with triple backticks?

Give your answer as a single word, either "positive" \
or "negative".

Review text: '''{lamp_review}'''
```

分析商品评价表露的情绪有哪些
```
Identify a list of emotions that the writer of the \
following review is expressing. Include no more than \
five items in the list. Format your answer as a list of \
lower-case words separated by commas.

Review text: '''{lamp_review}'''
```

分析这段商品评价是否包含愤怒情绪
```
Is the writer of the following review expressing anger?\
The review is delimited with triple backticks. \
Give your answer as either yes or no.

Review text: '''{lamp_review}'''
```

### 6.2. 实体识别
如果我们需要提取出句子中提到的特定事物的名称，则可以采用类似如下例子的提示语：

例子：提取商品评价中提到的商品名和公司名
```
Identify the following items from the review text: 
- Item purchased by reviewer
- Company that made the item
```

### 6.3. 主题推断
主题是一种比摘要更简洁直观地让我们了解文章的方式。一篇文章的摘要包含了其大部分主要内容，而主题只涉及文章内容属于哪些领域，讨论了哪些话题。通过创建自动推断文章主题的脚本，我们可以实现文章自动归类和新闻提醒功能。

例子：推断故事文本的主题
```
Determine five topics that are being discussed in the following text
```


## 7. 文本转换
将文本输入转换为不同的形式是大语言模型擅长的工作。例如，将一种语言的文本翻译为另一种语言，或对文本进行拼写或语法更正。文本转换甚至包括将文本转换为截然不同的形式，如 HTML 转 JSON，把一段描述转为正则表达式或 python 代码等等。

### 7.1. 翻译任务
例子：将一段话从英文翻译到西班牙文
```
Translate the following English text to Spanish: \ 
```Hi, I would like to order a blender```
```

例子：识别一段文本属于哪种语言
```
Tell me which language this is: 
```Combien coûte le lampadaire?```
```


## 8. 语法检查任务
在我们在进行邮件往来，论坛发帖，润色英文文章的时候，可以利用 ChatGPT 很方便地进行拼写和语法检查，以确保自己的内容不存在语法错误。

### 8.1. 语法检查任务
例子：拼写和语法检查

```
Proofread and correct the following text and rewrite the corrected version. 
If you don't find and errors, just say "No errors found". 
Don't use any punctuation around the text:
    ```{t}```
```


### 8.2. 语言风格转换
ChatGPT 可以将同一份文本转换为适合不同场合的语言风格，例如日常对话、公文风格、正式信件风格等。

例子：将一句话转换为较为正式的商业邮件风格
```
Translate the following from slang to a business letter: 
'Dude, This is Joe, check out this spec on this standing lamp.'
```

### 8.3. 数据/文本格式转换
我们可以利用 ChatGPT 方便地将数据或文本转换为不同的格式。JSON、XML、YAML 之间的相互转换，或文本、HTML、Markdown 之间的转换，均可以由 ChatGPT 来完成。

例子：JSON 转 HTML

```PYTHON
from IPython.display import HTML

data_json = { "resturant employees" :[ 
    {"name":"Shyam", "email":"shyamjaiswal@gmail.com"},
    {"name":"Bob", "email":"bob32@gmail.com"},
    {"name":"Jai", "email":"jai87@gmail.com"}
]}

prompt = f"""
Translate the following python dictionary from JSON to an HTML \
table with column headers and title: {data_json}
"""
response = get_completion(prompt)
display(HTML(response))
```


## 9. 扩展文本
扩展是指输入一小段文本（例如一系列说明或主题列表）并让大型语言模型生成一段较长的文本（例如电子邮件或关于某个主题的文章）的任务。
扩展除了可以帮我们写一些报告之外，还可以用于作为头脑风暴的伙伴帮助我们获取灵感。


### 9.1. 根据评价自动回复

```
You are a customer service AI assistant.
Your task is to send an email reply to a valued customer.
Given the customer email delimited by ```, \
Generate a reply to thank the customer for their review.
If the sentiment is positive or neutral, thank them for their review.
If the sentiment is negative, apologize and suggest that they can reach out to customer service. 
Make sure to use specific details from the review.
Write in a concise and professional tone.
Sign the email as `AI customer agent`.
Customer review: \`\`\`{review}\`\`\`
Review sentiment: negative
```

### 9.2. 模型温度参数的应用

温度（temperature）是 GPT 模型的一个重要参数，它意味着模型对不同输出可能性的探索程度或随机性的高度。较简而言之，设置低的温度值意味着模型针对同一输入的输出比较固定，而较高的温度则会使模型对同一个输入产生更加多样化的输出。

```
my favorite food is: 
  53% pizza
  30% sushi
  5%  tacos

Temperature = 0
  my favorite food is pizza
  my favorite food is pizza
  my favorite food is pizza

Temperature = 0.3
  my favorite food is pizza
  my favorite food is sushi
  my favorite food is pizza


Temperature = 0.7
  my favorite food is tacos
  my favorite food is sushi
  my favorite food is pizza

```

正如我们之前所说的，ChatGPT 是通过不断预测下一个最可能出现的单词来构建输出。在图中的例子中，对于前文“我最喜欢的食物”，模型认为最可能出现在下一个词位置的三个单词分别是披萨、寿司、炸玉米饼，概率分别为 53%、30% 和 5% 。如果我们把温度设为 0，模型将始终将选择概率最高的比萨作为下一个词输出，而在较高的温度值下，模型则有机会选择出一些不太可能出现的词作为下个单词，例如炸玉米饼。

在需要输出固定可预测性强的场合我们最好将温度设为 0，而在需要输出具有创造性和多样性的场景下则应该尽量设置一个比较的温度，如 0.7。

在我们之前的例子中，为了结果有更好的可重复性，模型温度均被默认设为 0，接下来我们将探索更高的温度对模型输出带来的影响。


将温度设为 0.7 生成更多样化的客服回复.



## 10. 创建聊天机器人
OpenAI API 非常酷的一点在于，我们能够用它轻易地创建自己的聊天机器人，让它按照我们设定的方式聊天。


### 10.1. 三种角色

我们与 ChatGPT 的所有对话均被分成三种角色。
- "system" 系统角色，即对话的底层设定，包括模型应该扮演怎样的角色、给用户何种类型的反馈等等，这类角色通常在对话开始之前由后台给出，并不暴露给用户。
- “assistant”助理角色，即对话过程中模型输出使用的角色。
- "user" 用户角色，用户向模型发送的信息使用的角色，


一段由"system"角色给出基本设定的对话
```python
messages =  [  
{'role':'system', 'content':'You are an assistant that speaks like Shakespeare.'},    
{'role':'user', 'content':'tell me a joke'},   
{'role':'assistant', 'content':'Why did the chicken cross the road'},   
{'role':'user', 'content':'I don\'t know'}  ]
response = get_completion_from_messages(messages, temperature=1)
print(response)
```
输出：
```
To reach the other side, good sir!
```


### 10.2. 维护 messages 列表
一个稍有些违反直觉的事实是，尽管模型显得能够记住我们之前说过的话，但事实上我们每一次对模型的输入都是一次全新的请求，模型并不会将之前的对话以某种方式“记忆”在权重里。我们之所以能够实现连续对话，是因为网站后台会自动将之前的对话内容保存下来，在每次请求时把这些的记录作为前文一并发送给模型，而每句对话的角色属性则是用于区分哪句话是用户说的、哪句话是模型自己说的、哪句话是系统设定的“标签”。

在 OpenAI API 中，我们需要自己编写代码实现对话前文的维护。 messages 列表就是专门用于这一点。（换句话说，像我们在之前的例子里 messages 列表只存放了当前的请求其实是不能连续对话的。）

例子：把对话内容分两次单独放进 messages 列表发送，模型“遗忘”了之前的对话
```python
messages =  [  
{'role':'system', 'content':'You are friendly chatbot.'},    
{'role':'user', 'content':'Hi, my name is Isa'}  ]
response = get_completion_from_messages(messages, temperature=1)
print(response)
messages =  [  
{'role':'system', 'content':'You are friendly chatbot.'},    
{'role':'user', 'content':'Yes,  can you remind me, What is my name?'}  ]
response = get_completion_from_messages(messages, temperature=1)
print(response)
```
输出：第一次回答：知道用户的名字。第二次回答：不知道用户的名字。
```
Hello Isa! It's nice to meet you. How may I assist you today?

As an AI chatbot, I don't have access to your personal information, so I don't know your name unless you've provided me with that information before. If you'd like, you can tell me your name again, and I'll make sure to remember it in our future conversations!
```

例子：把完整的对话记录放进 messages 里给出，实现了与模型的连续对话
```python
messages =  [  
{'role':'system', 'content':'You are friendly chatbot.'},
{'role':'user', 'content':'Hi, my name is Isa'},
{'role':'assistant', 'content': "Hi Isa! It's nice to meet you. \
Is there anything I can help you with today?"},
{'role':'user', 'content':'Yes, you can remind me, What is my name?'}  ]
response = get_completion_from_messages(messages, temperature=1)
print(response)
```
输出：模型 “记住了” 用户的名字
```
Your name is Isa.
```


## 11. 总结

这门课程介绍了使用 ChatGPT 两个关键的提示原则：编写清晰明确的指令，并在适当的时候给模型一些思考的时间。此外，还展示了迭代提示开发的过程，以及如何使用大型语言模型的一些能力，例如摘要、推理、转换和扩展。紧接着，教给我们如何构建自定义的聊天机器人实现各种任务。

在这门课程的最后，吴恩达老师尤其强调大型语言模型是一项非常强大的技术，身为使用者的我们应当负责任地使用这项技术，尽量发挥它的积极意义，避免用于为社会带来负面影响的用途。同时保持着开放的心态，把知识传播给更多的人。


## A. Reference

- [ChatGPT Prompt Engineering for Developers](https://learn.deeplearning.ai/chatgpt-prompt-eng/lesson/1/introduction)
- [《ChatGPT Prompt Engineering for Developers》课程笔记](https://zhuanlan.zhihu.com/p/626819858)