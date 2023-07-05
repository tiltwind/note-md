<!---
markmeta_author: titlwind
markmeta_date: 2023-06-30
markmeta_title: Note for Prompt Engineering Techniques (Ibrahim John)
markmeta_categories: ai
markmeta_tags: ai,prompt-engineering
-->

# Note for Prompt Engineering Techniques (Ibrahim John)

> The Art of Asking ChatGPT for High-Quality Answers
> A Complete Guide to Prompt Engineering Techniques 
> Copyright © 2023 Ibrahim John


## Chapter 1: Introduction to Prompt Engineering Techniques (介绍)

Prompt engineering is the process of creating prompts or asking or
instructions that guide the output of a language model like ChatGPT. 

ChatGPT is a state-of-the-art language model that is capable of generating human-like text. It is built on the transformer architecture, which allows it to handle large amounts of data and generate high- quality text.

A prompt formula is a specific format for the prompt, it is generally composed of 3 main elements:
- task: a clear and concise statement of what the prompt is asking the model to generate.
- instructions: the instructions that should be followed by the model when generating text.
- role: the role that the model should take on when generating text.


## Chapter 2: Instructions Prompt Technique (要求说明)

The instructions prompt technique is a way of guiding the output of ChatGPT by providing specific instructions for the model to follow.

- Prompt formula: "Generate [task] following these instructions: [instructions]"


Exampes:

Generating customer service responses:
- Task: Generate responses to customer inquiries
- Instructions: The responses should be professional and provide accurate information
- Prompt formula: "Generate responses to customer inquiries following these instructions: The responses should be professional and provide accurate information."


The instructions should be clear and specific.


## Chapter 3: Role Prompting (定位角色)

The role prompting technique is useful for generating text that is tailored to a specific context or audience.
You will need to provide a clear and specific role.

- Prompt formula: "Generate [task] as a [role]"

Generating customer service responses:
-  Task: Generate responses to customer inquiries
-  Role: Customer service representative
-  - Prompt formula: "Generate responses to customer inquiries as a customer service representative."


## Chapter 4: Standard Prompts (标准模式)

Standard prompts are a simple way to guide the output of
ChatGPT by providing a specific task for the model to complete.

- Prompt formula: "Generate a [task]"

Example: Generating a summary of a news article: 
- Task: Summarize this news article
- Prompt formula: "Generate a summary of this news article" 

Example: Generating a product review:
- Task: Write a review of a new smartphone
- Prompt formula: "Generate a review of this new smartphone"


## Chapter 5: Zero, One and Few Shot Prompting (提供案例)

With minimal or no examples. These techniques are useful when there is limited data available for a specific task or when the task is new and not well-defined.

- The zero-shot prompting technique is used when there are no examples available for the task.
- The one-shot prompting technique is used when there is only one example available for the task. 
- The few-shot prompting technique is used when there are a limited number of examples available for the task. 

Example: Generating a product description for a new product with no examples available:
- Task: Write a product description for a new smartwatch
- Prompt formula: "Generate a product description for this new smartwatch with zero examples"

Example: Generating a product comparison with one example available:
- Task: Compare a new smartphone to the latest iPhone
- Prompt formula: "Generate a product comparison of this new smartphone with one example (latest iPhone)"

Example: Generating a product review with few examples available:
- Task: Write a review of a new e-reader
- Prompt formula: "Generate a review of this new e-reader with few examples (3 other e-readers)"


## Chapter 6: "Let’s think about this” prompt (思考模式)

Used to encourage ChatGPT to generate text that is reflective and contemplative.
This technique is useful for tasks such as writing essays, poetry, or creative writing.

The - Prompt formula: "Let's think about this: [a topic or question]"

Examples:
- Prompt: "Let's think about the impact of climate change on agriculture"
- Prompt: "Let's discuss the current state of artificial intelligence"
- Prompt: "Let's talk about the benefits and drawbacks of remote work"


## Chapter 7: Self-Consistency Prompt (逻辑自恰)

Ensure that the output of ChatGPT is consistent with the input provided. 
This technique is useful for tasks such as fact-checking, data validation, or consistency checking in text generation.

The - Prompt formula: the input text followed by the instruction "Please ensure the following text is self-consistent"

Example: Text Summarization
- Task: Summarize a news article
- Instructions: The summary should be consistent with the information provided in the article
- Prompt formula: "Summarize the following news article in a way that is consistent with the information provided [insert news article]"

Example: Fact-checking:
- Task: Check for consistency in a given news article
- Input text: "The article states that the population of the city is 5 million, but later on, it says that the population is 7 million." 
- Prompt formula: "Please ensure the following text is self-consistent: The article states that the population of the city is 5 million, but later on, it says that the population is 7 million."
- Response:  "The information provided in the text is inconsistent. In one instance, it states that the population of the city is 5 million, while in another instance, it mentions that the population is 7 million. These two statements contradict each other and create a discrepancy in the information. To ensure self-consistency, the text should be revised to present a consistent population figure throughout the article."


Example: Data validation:
- Task: Check for consistency in a given data set
- Input text: "The data shows that the average temperature in July is 30 degrees, but the minimum temperature is recorded as 20 degrees."
- Prompt formula: "Please ensure the following text is self-consistent: The data shows that the average temperature in July is 30 degrees, but the minimum temperature is recorded as 20 degrees."
- Response: "The provided text is self-consistent. It states that the average temperature in July is 30 degrees, and it also mentions that the minimum temperature recorded during that time is 20 degrees. These two pieces of information do not contradict each other and can coexist. The average temperature represents the overall mean temperature for the month, while the minimum temperature refers to the lowest recorded temperature within that period."


## Chapter 8: Seed-word Prompt  (种子词汇)

This technique allows the model to generate text that is related to the seed word and expand on it. 

The - Prompt formula: followed by the instruction "Please generate text based on the following seed-word"

Example: Text Generation
- Task: Generate a poem
- Instructions: The poem should be related to the seed word "love" and should be written in the style of a sonnet.
- Role: Poet
- Prompt formula: "Generate a sonnet related to the seed word 'love' as a poet"


## Chapter 9: Knowledge Generation prompt (知识生成)

used to elicit new and original information.

The - Prompt formula:  "Please generate new and original information about X" where X is the topic of interest."

- "Generate new and accurate information about [specific topic] "
- "Answer the following question: [insert question]"
- "Integrate the following information with the existing knowledge about [specific topic]: [insert new information]"
- "Please generate new and original information about customer behavior from this dataset"


## Chapter 10: Knowledge Integration prompts (知识整合)

This technique uses a model's pre-existing knowledge to integrate new information or to connect different pieces of information.
This technique is useful for combining existing knowledge with new information to generate a more comprehensive understanding of a specific topic.


- Prompt formula: "Integrate the following information with the existing knowledge about [specific topic]: [insert new information]"
- Prompt formula: "Connect the following pieces of information in a way that is relevant and logical: [insert information 1] [insert information 2]"
- Prompt formula: "Update the existing knowledge about [specific topic] with the following information: [insert new information]"


## Chapter 11: Multiple Choice prompts (多选项)

This technique is useful for generating text that is limited to a specific set of options and can be used for question-answering, text completion and other tasks. 
The model can generate text that is limited to the predefined options.

- Prompt formula: "Answer the following question by selecting one of the following options: [insert question] [insert option 1] [insert option 2] [insert option 3]"
- Prompt formula: "Complete the following sentence by selecting one of the following options: [insert sentence] [insert option 1] [insert option 2] [insert option 3]"
- Prompt formula: "Classify the following text as positive, neutral or negative by selecting one of the following options: [insert text] [positive] [neutral] [negative]"


## Chapter 12: Interpretable Soft Prompts (可解释的软提示)

providing the model with a set of controlled inputs and some additional information about the desired output.

- Prompt formula: "Generate a story based on the following characters: [insert characters] and the theme: [insert theme]"
- Prompt formula: "Complete the following sentence in the style of [specific author]: [insert sentence]"
- Prompt formula: "Generate text in the style of [specific period]:[insert context]"


## Chapter 13: Controlled Generation prompts (生成控制)

providing the model with a specific set of inputs, such as a template, a specific vocabulary, or a set of
constraints, that can be used to guide the generation process.

- Prompt formula: "Generate a story based on the following template: [insert template]"
- Prompt formula: "Complete the following sentence using the following vocabulary: [insert vocabulary]: [insert sentence]"
- Prompt formula: "Generate text that follows the following grammatical rules: [insert rules]: [insert context]"


## Chapter 14: Question-answering prompts (问答)

providing the model with a question or task as input, along with any additional information that may be relevant to the
question or task.

- Prompt formula: "Answer the following factual question: [insert question]"
- Prompt formula: "Define the following word: [insert word]"
- Prompt formula: "Retrieve information about [specific topic] from the following source: [insert source]"


## Chapter 15: Summarization prompts (总结)

providing the model with a longer text as input and asking it to generate a summary of that text.


- Prompt formula: "Summarize the following news article in one short sentence: [insert article]"
- Prompt formula: "Summarize the following meeting transcript by listing the main decisions and actions taken: [insert transcript]"
- Prompt formula: "Summarize the following book in one short paragraph: [insert book title]"


## Chapter 16: Dialogue prompts (对话)

provided with information about the desired output, such as the type of conversation or dialogue and any specific requirements or constraints.


- Prompt formula: "Generate a conversation between the following characters [insert characters] in the following context [insert context]"
- Prompt formula: "Generate a dialogue between the following characters [insert characters] in the following story [insert story]"
- Prompt formula: "Generate a professional and accurate dialogue for a customer service chatbot, when the customer asks about [insert topic]"


## Chapter 17: Adversarial prompts (对抗)

Adversarial prompts is a technique that allows a model to generate text that is resistant(抵制) to certain types of attacks or biases(偏见). 
This technique can be used to train models that are more robust(强健的) and resistant to certain types of attacks or biases.

To use adversarial prompts with ChatGPT, the model should be
provided with a prompt that is designed to be difficult for the model to generate text that is consistent with the desired output. 
The prompt should also include information about the desired output, such as the type of text to be generated and any specific requirements or constraints.


- Prompt formula: "Generate text that is difficult to classify as [insert label]"
- Prompt formula: "Generate text that is difficult to classify as having the sentiment of [insert sentiment]"
- Prompt formula: "Generate text that is difficult to translate to [insert target language]"


## Chapter 18: Clustering prompts (归类)

group similar data points together based on certain characteristics or features.

providing the model with a set of data points and asking it to group them into clusters based on certain characteristics or features.

Useful for tasks such as data analysis, machine learning, and natural language processing.

- Prompt formula: "Group the following customer reviews into clusters based on sentiment: [insert reviews]"
- Prompt formula: "Group the following news articles into clusters based on topic: [insert articles]"
- Prompt formula: "Group the following scientific papers into clusters based on research area: [insert papers]"


## Chapter 19: Reinforcement learning prompts (强化学习)

allows a model to learn from its past actions and improve its performance over time.
provided with a set of inputs and rewards, and allowed to adjust its behavior based on the rewards it receives. 
useful for tasks such as decision making, game playing, and natural language generation.

- Prompt formula: "Use reinforcement learning to generate text that is consistent with the following style [insert style]"
- Prompt formula: "Use reinforcement learning to translate the following text [insert text] from [insert language] to [insert language]"
- Prompt formula: "Use reinforcement learning to generate an answer to the following question [insert question]"


## Chapter 20: Curriculum learning prompts (课程学习)

Allows a model to learn a complex task by first training on simpler tasks and gradually increasing the difficulty.
Provided with a sequence of tasks that gradually increase in difficulty. 
Useful for tasks such as natural language processing, image recognition, and machine learning.


- Prompt formula: "Use curriculum learning to generate text that is consistent with the following styles [insert styles] in the following order [insert order]"
- Prompt formula: "Use curriculum learning to translate text from the following languages [insert languages] in the following order [insert order]"
- Prompt formula: "Use curriculum learning to generate answers to the following questions [insert questions] in the following order [insert order]"


## Chapter 21: Sentiment analysis prompts (观点分析)

Determine the emotional tone or attitude of a piece of text, such as whether it is positive, negative, or neutral.
To provided with a piece of text and asked to classify it based on its sentiment.
Useful for tasks such as natural language processing, customer service, and market research.

- Prompt formula: "Perform sentiment analysis on the following customer reviews [insert reviews] and classify them as positive, negative, or neutral."
- Prompt formula: "Perform sentiment analysis on the following tweets [insert tweets] and classify them as positive, negative, or neutral."
- Prompt formula: "Perform sentiment analysis on the following product reviews [insert reviews] and classify them as positive, negative, or neutral."


## Chapter 22: Named entity recognition prompts (已命名事物识别)


identify and classify named entities in text, such as people, organizations, locations, and dates.
To provided with a piece of text and asked to identify and classify named entities within the text.

- Prompt formula: "Perform named entity recognition on the following news article [insert article] and identify and classify people, organizations, locations, and dates."
- Prompt formula: "Perform named entity recognition on the following legal document [insert document] and identify and classify people, organizations, locations, and dates."
- Prompt formula: "Perform named entity recognition on the following research paper [insert paper] and identify and classify people, organizations, locations, and dates."


## Chapter 23: Text classification prompts (文本分类)

categorize text into different classes or categories. This technique is useful for tasks such as natural language processing, text analytics, and sentiment analysis.
provided with a piece of text and asked to classify it based on predefined categories or labels. 

- Prompt formula: "Perform text classification on the following customer reviews [insert reviews] and classify them into different categories such as electronics, clothing and furniture based on their content."
- Prompt formula: "Perform text classification on the following news articles [insert articles] and classify them into different categories such as sports, politics, and entertainment based on their content."
- Prompt formula: "Perform text classification on the following emails [insert emails] and classify them into different categories such as spam, important, or urgent based on their content and sender."


## Chapter 24: Text generation prompts

used to fine-tune a pre-trained model or to train a new model for specific tasks.

- Prompt formula: "Generate a story of at least 1000 words, including characters [insert characters] and a plot [insert plot] based on the following prompt [insert prompt]."
- Prompt formula: "Translate the following text [insert text] into [insert target language] and make sure that it is accurate and idiomatic."
- Prompt formula: "Complete the following text [insert text] and make sure that it is coherent and consistent with the input text."



## A. Reference

- [Art of Asking ChatGPT for High-Quality Answ Engineering Techniques, The - Ibrahim John.pdf](https://bing.com/search?q=The%20Art%20of%20Asking%20ChatGPT%20for%20High-Quality%20Answers%20pdf)