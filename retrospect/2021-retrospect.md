<!---
markmeta_author: wongoo
markmeta_date: 2021-12-28
markmeta_title: 2021年终总结
markmeta_categories: retrospect
markmeta_tags: 总结
-->

# 2021年终总结

## 1. 技术

这一年在技术上有很多规划和想法，团队大致都落实到项目中，较好的支持业务发展需求，同时提高了开发效率。

### 1.1. 核心模型抽象及流程梳理

每开发一个新的业务或系统，首要要做的是梳理核心模型和核心业务流程，这也是我必然要抓的事情。
核心模型或核心流程对了，系统基本方向就是对的，不会出什么大的问题。
核心模型抽象的越精炼，开发难度越简单。
核心模型和流程又要考虑扩展性，不能只满足mvp版本需求，还要考虑未来需求的方向。
要设计一个既精炼又有扩展性的模型和流程，需要反复的思考和验证。
产品一开始提供的需求是有限的，需要根据既有的需求抽象出模型和流程，再和产品确认。
一开始可能比较困难，当无法清晰的描述一件事情时，肯定是有潜在的模型未识别抽象出来。
一旦和产品确认，再基于模型和流程去创建实例化需求。
实例化需求在实际使用过程中效果极好，基本上可以很快识别出模型和流程的问题。
这时候需要根据识别的问题再反过来调整模型和流程，调整好后再修改实例化需求去验证模型和流程。
如此反复，经过1-2个迭代，基本上最终能确定一个比较健壮的模型和流程。

有了模型和流程，就可以输出通用术语,这是很重要的。
有一些词汇存在在很多业务和系统中，但意义完全不一样。
不明确通用术语，团队沟通效率就会低很多，常常还会出现误解。

有了模型和流程，系统架构、模块架构基本有就可以快速确定。如果反过来往往并不容易。


### 1.2. 治理思想

当一件事情不可控或比较繁琐的时候就需要治理了。

当遇到发不同消息需要配置不同的模板调用不同的接口，消息无法统一管理，消息发送无法控制策略，消息无法防止客户信息泄露，消息无法控制频率等问题时，就需要对消息发送进行治理。
解决办法是将消息模板定义标准化，统一消息发送接口，统一消息发送流程和策略，统一消息第三方发送渠道接口，统一消息账号模型。

当遇到接口定义规范不一，接口跨环境定义不一，接口前后无法兼容，接口调用无安全认证等问题时，就需要对API接口进行治理。
解决办法是统一API接口定义系统，API生命周期管理，接口项目授权认知机制，应用接口网关。

当遇到面客接口跨团队，开发链路长，开发周期长的问题时，就需要对开发模式进行治理。
解决办法是API网关直接打通中台，中台提供接口功能，账号中心统一认证。

当遇到事件发送方式不一，事件格式不一，无法追踪事件依赖关系等问题时，就需要对事件进行治理。
解决办法是统一事件定义方式，统一事件发送消费SDK，事件埋点分析。

当遇到数据量大但基本并不使用的数据，影响系统性能时，就需要对数据归档进行治理。
解决办法是冷数据平台，标准化冷数据归档和查询方式。


### 1.3. 全面思考

公司技术层面的一些问题是显而易见的，这促使我去思考相应的解决办法，在devops、架构、安全、测试方面也提出了一些建议。
主导整理了公司整体技术架构内容和路线图，目前在devops、可观测性方面已经有在落实改善了。
来年希望在serverless、mesh、压测、混沌工程等方面做一些投入。


## 2. 管理

管理上基本上是基本按照敏捷迭代的模式进行团队管理，推行OKR目标管理，让团队同学都积极参与到目标制定和执行中。
增加团队成员的参与感，让他们看到所做项目的价值，是最好的团队激励方式。

今年在公司未推行敏捷和OKR之前，团队就一直使用这种模式。
当推行的时候也作为实验标杆团队，梳理出了一套全技术中心适用的标准。


## 3. 业务

2021年在业务模式上也有很多思考，整理了一些改进的想法，有和产品和其他团队同学聊，但因为现状很难改变，基本就很难落实。
但业务模式又非常重要，曾想是不是可以新成立一个事业部或新公司来做这个事情，但要和老版讲还得进一步细化思考，整理可行性方案，整理ppt。


## 4. 生活

这一年最大的变化是对待钱和事不那么着急了。
可能是明白了一个道理，过去的事情不管有多糟糕，都是无法改变的，只能基于当前的状况，做出最好的选择，并努力去改变。

教育小孩有时还是会发脾气，但已改善了很多。 
也可能是明白了小孩发展规律，不同阶段的小孩要求也应该不一样，多一些陪伴和引导最重要。


## A. History

- 2022-01-07, 完稿
- 2021-12-28, 列了一个提纲

  