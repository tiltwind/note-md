<!---
markmeta_author: titlwind
markmeta_date: 2023-07-06
markmeta_title: AI提示词 —— 代码生成（解析数据）
markmeta_categories: ai
markmeta_tags: ai,prompt-engineering
-->
# AI提示词 —— 代码生成（解析数据）


> 团队360评估打分出来了，要去计算平均分，让 AI 来帮助我吧！


## 代码生成(询问AI)

现在有一个评价数据表格, 文件名称是 evaluation.csv，其中包含7列，分别是  "被评人"、"评价人"、"专业技术"、"业务理解"、"学习分享"、"沟通协作"、"影响力"；

其中"专业技术"、"业务理解"、"学习分享"、"沟通协作"、"影响力"这5列为指标列，值的格式是数值。

指标"总体评价"不在数据表格中，而是通过计算得出，计算方式为"专业技术"、"业务理解"、"学习分享"、"沟通协作"、"影响力"这5个指标的平均分。

数据表中每个"被评人"会有多笔被评记录, 每个"评价人"也有多笔评价记录。

你的任务是生成golang分析代码，请遵循以下要求:
1. 代码变量命名需要使用英文，注释用中文。
2. 按照被评人纬度计算所有指标的平均分, 按照 csv 格式输出到 evaluation_avg.csv 文件中
3. 输出表头包括"被评人"、"专业技术平均分"、"业务理解平均分"、"学习分享平均分"、"沟通协作平均分"、"影响力平均分"、"总体评价平均分"。
4. 每个指标的平均分是被评人所有被评记录的对应指标的平均分。


## 代码生成(AI回答)


好的,我用Golang来实现这个数据分析任务:

```go
package main

import (
  "encoding/csv"
  "os"
  "strconv"
)

// 评价数据结构
type Evaluation struct {
  Evaluator  string // 评价人
  Evaluatee  string // 被评人
  TechScore      float64 // 专业技术得分
  BizScore       float64 // 业务理解得分 
  ShareScore     float64 // 学习分享得分
  CommScore      float64 // 沟通协作得分
  InfluenceScore float64 // 影响力得分
}

func main() {
  // 读取CSV文件
  file, err := os.Open("evaluation.csv")
  if err != nil {
    panic(err)
  }
  defer file.Close()

  // CSV解析器
  csvReader := csv.NewReader(file)
  records, err := csvReader.ReadAll()
  if err != nil {
    panic(err)
  }

  // 数据解析
  var evaluations []Evaluation
  for _, record := range records[1:] {
    techScore, _ := strconv.ParseFloat(record[2], 64) 
    bizScore, _ := strconv.ParseFloat(record[3], 64)
    shareScore, _ := strconv.ParseFloat(record[4], 64)  
    commScore, _ := strconv.ParseFloat(record[5], 64)
    influenceScore, _ := strconv.ParseFloat(record[6], 64)
    
    eval := Evaluation{
      Evaluator: record[1],
      Evaluatee: record[0],
      TechScore: techScore,
      BizScore: bizScore,
      ShareScore: shareScore,
      CommScore: commScore,
      InfluenceScore: influenceScore,
    }
    
    evaluations = append(evaluations, eval)
  }

  // 按被评人分组
  evalMap := make(map[string][]Evaluation)
  for _, eval := range evaluations {
    evalMap[eval.Evaluatee] = append(evalMap[eval.Evaluatee], eval)
  }

  // 计算平均分
  outputRecords := make([][]string, 0)
  outputRecords = append(outputRecords, []string{"被评人", "专业技术平均分", "业务理解平均分", "学习分享平均分", "沟通协作平均分", "影响力平均分", "总体评价平均分"})
  
  for name, evals := range evalMap {
    var techTotal, bizTotal, shareTotal, commTotal, influenceTotal float64
    for _, eval := range evals {
      techTotal += eval.TechScore
      bizTotal += eval.BizScore
      shareTotal += eval.ShareScore
      commTotal += eval.CommScore
      influenceTotal += eval.InfluenceScore
    }
    
    techAvg := techTotal / float64(len(evals))
    bizAvg := bizTotal / float64(len(evals))
    shareAvg := shareTotal / float64(len(evals))  
    commAvg := commTotal / float64(len(evals))
    influenceAvg := influenceTotal / float64(len(evals))
    overallAvg := (techAvg + bizAvg + shareAvg + commAvg + influenceAvg) / 5.0
    
    outputRecords = append(outputRecords, []string{name, 
      strconv.FormatFloat(techAvg, 'f', 2, 64),
      strconv.FormatFloat(bizAvg, 'f', 2, 64),
      strconv.FormatFloat(shareAvg, 'f', 2, 64),
      strconv.FormatFloat(commAvg, 'f', 2, 64),
      strconv.FormatFloat(influenceAvg, 'f', 2, 64),
      strconv.FormatFloat(overallAvg, 'f', 2, 64)})
  }
  
  // 输出结果到CSV文件
  outputFile, err := os.Create("evaluation_avg.csv")
  if err != nil {
    panic(err)
  }
  defer outputFile.Close()
  
  csvWriter := csv.NewWriter(outputFile)
  csvWriter.WriteAll(outputRecords)
  
  if err := csvWriter.Error(); err != nil {
    panic(err)
  }
}
```

这个代码读取 evaluation.csv 文件,解析数据到 Evaluation 结构体,然后按被评人分组,计算每个人的各项指标平均分,最后写入 evaluation_avg.csv 输出文件。输出格式符合要求,注释使用中文说明,变量名称英文。请检查实现是否符合要求。


