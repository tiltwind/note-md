<!---
markmeta_author: titlwind
markmeta_date: 2022-12-28
markmeta_title: CVE
markmeta_categories: 安全
markmeta_tags: cve,nvd,cpe
-->

# 漏洞数据库

名词解释
- CVE : Common Vulnerabilities and Exposures, 通用漏洞披露
- NVD : NATIONAL VULNERABILITY DATABASE 美国国家漏洞数据库


## 漏洞查询API

接口文档参考: https://nvd.nist.gov/developers/vulnerabilities

接口有做限流，滚动30s内不超过5次请求，应用应该要主动控制限流，并且存储已查询结果，尽量从本地查询。

范例:
```bash
# 查询 log4j 相关漏洞
curl --location --request GET 'https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=log4j'

# 查询 windows 10 特定版本漏洞
curl --location --request GET 'https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=cpe:2.3:o:microsoft:windows_10:1607'
```

## CPE 名称定义

CPE (Common Platform Enumeration) 通用平台枚举, 一种结构化命名方案，用来描述标记应用、操作系统、硬件设备。

> CPE 并不定义在具体操作系统上的唯一实例，比如 `XYZ Visualizer Enterprise Suite 4.2.3 且序列号为Q472B987P113`. 
> CPE 标记的是虚拟产品分类，例如 `XYZ Visualizer Enterprise Suite 4.2.3`， 或者 `XYZ Visualizer Enterprise Suite` (所有版本), 或者 `XYZ Visualizer` (所有类型).


以 CPE 2.3版为例, 参考定义: https://nvlpubs.nist.gov/nistpubs/Legacy/IR/nistir7695.pdf

格式: `cpe:2.3:<part>:<vendor>:<product>:<version>:<update>:<edition>:<sw_edition>:<target_sw>:<target_hw>:<language>:<other>`

- **part**: `a`表示应用, `o`表示操作系统, `h`表示硬件设备
- **vendor**: 标识创建产品的机构或个人
- **product**: 产品名
- **version**: 产品版本
- **update**: 产品更新标识
- **edition**: 产品版次(后续考虑废弃)
- **sw_edition**: 定制版次(指定市场或个人)
- **target_sw**: 软件操作系统环境
- **target_hw**: 操作系统指令集(如x86)
- **language**: 语言
- **other**: 自定义内容

范例:

Microsoft Internet Explorer 8.0.6001 Beta (no edition):
`wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8\.0\.6001",update="beta",edition=NA]`

Microsoft Internet Explorer 8.* SP? (no edition, any language):
`wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8\.*",update="sp?",edition=NA,language=ANY]`

Identifier for HP Insight Diagnostics 7.4.0.1570 Online Edition for Windows 2003 x64:
`wfn:[part="a",vendor="hp",product="insight_diagnostics",version="7\.4\.0\.1570",sw_edition="online",target_sw="windows_2003",target_hw="x64"]`

Identifier for HP OpenView Network Manager 7.51 (no update) for Linux:
`wfn:[part="a",vendor="hp",product="openview_network_manager",version="7\.51",update=NA,target_sw="linux"]`

Foo\Bar Systems Big$Money 2010 Special Edition for iPod Touch:
`wfn:[part="a",vendor="foo\\bar",product="big\$money_2010",sw_edition="special",target_sw="ipod_touch"]`


CPE URI 格式:
```
cpe-name = "cpe:/" component-list
component-list = part ":" vendor ":" product ":" version ":" update ": "edition ":" lang
component-list /= part ":" vendor ":" product ":" version ":" update ":" edition
component-list /= part ":" vendor ":" product ":" version ":" update
component-list /= part ":" vendor ":" product ":" version
component-list /= part ":" vendor ":" product
component-list /= part ":" vendor
component-list /= part
component-list /= empty
part = "h" / "o" / "a" / empty
vendor = string
product = string
version = string
update = string
edition = string
lang = LANGTAG / empty
string = *( unreserved / pct-encoded )
empty = ""
unreserved = ALPHA / DIGIT / "-" / "." / "_" / "˜"
pct-encoded = "%" HEXDIG HEXDIG
ALPHA = %x41-5a / %x61-7a ; A-Z or a-z
DIGIT = %x30-39 ; 0-9
HEXDIG = DIGIT / "a" / "b" / "c" / "d" / "e" / "f"
LANGTAG = cf. [RFC5646]
```

- CPE 名称匹配规范: https://nvlpubs.nist.gov/nistpubs/Legacy/IR/nistir7696.pdf
- CPE Java 解析库: https://github.com/stevespringett/CPE-Parser


## 扫描漏洞工具 DependencyCheck

[DependencyCheck](https://jeremylong.github.io/DependencyCheck/general/internals.html) 会下载漏洞数据库，并存储在本地索引中, 通过CPE匹配，如果匹配则加入到报告中。
DependencyCheck 扫描的目标是 jar 包, 指定目录下需包含jar包。

### 命令行使用方式


```bash
curl -L -O -C - https://github.com/jeremylong/DependencyCheck/releases/download/v7.4.3/dependency-check-7.4.3-release.zip

unzip dependency-check-7.4.3-release.zip

cd dependency-check/bin

# 扫描项目
./dependency-check.sh -s <myproject_path>

# 会在当前目录生成报告文件
open dependency-check-report.html

# 查看高级帮助
./dependency-check.sh --advancedHelp
./dependency-check.sh --disableRetireJS --prettyPrint -f JSON -o ~/temp -s <myproject_path>
```

命令行下载的漏洞数据会存放在 `dependency-check/data` 目录下


### maven 插件使用方式

maven插件的方式可以通过maven识别项目依赖的包，并直接扫描本地仓库中的jar包。
maven插件下载的漏洞数据库位置是 `~/.m2/repository/org/owasp/dependency-check-data/`.

```xml
<build>
    <plugins>
        <plugin>
          <groupId>org.owasp</groupId>
          <artifactId>dependency-check-maven</artifactId>
          <version>7.4.3</version>
        </plugin>
    </plugins>
</build>
```


执行命令:
```bash
# 聚合检查maven项目(包括子项目), 输出json格式, 输出到制定目录下, 输出文件名为 dependency-check-report.json
mvn dependency-check:aggregate -DretireJsAnalyzerEnabled=false -Dformat=JSON -DprettyPrint=true -Dodc.outputDirectory=/Users/gelnyang/temp
```

输出的JSON数据格式:
```JSON
{
  "dependencies": [
    {
      "isVirtual": false,
      "fileName": "aliyun-sdk-opensearch-3.1.3.jar (shaded: com.google.guava:guava:19.0)",
      "filePath": "/Users/gelnyang/.m2/repository/com/aliyun/opensearch/aliyun-sdk-opensearch/3.1.3/aliyun-sdk-opensearch-3.1.3.jar/META-INF/maven/com.google.guava/guava/pom.xml",
      "description": "\n    Guava is a suite of core and expanded libraries that include\n    utility classes, google's collections, io classes, and much\n    much more.\n\n    Guava has only one code dependency - javax.annotation,\n    per the JSR-305 spec.\n  ",
      "packages": [
        {
          "id": "pkg:maven/com.google.guava/guava@19.0",
          "confidence": "HIGH",
          "url": "https://ossindex.sonatype.org/component/pkg:maven/com.google.guava/guava@19.0?utm_source=dependency-check&utm_medium=integration&utm_content=7.4.3"
        }
      ],
      "vulnerabilities": [
        {
          "source": "NVD",
          "name": "CVE-2018-10237",
          "severity": "MEDIUM",
          "cwes": [
            "CWE-770"
          ],
          "description": "Unbounded memory allocation in Google Guava 11.0 through 24.x before 24.1.1 allows remote attackers to conduct denial of service attacks against servers that depend on this library and deserialize attacker-provided data, because the AtomicDoubleArray class (when serialized with Java serialization) and the CompoundOrdering class (when serialized with GWT serialization) perform eager allocation without appropriate checks on what a client has sent and whether the data size is reasonable."
        }
      ]
    }
  ]
}
```

- 可在jenkins中增加检查步骤, 将输出的json上报到系统，让漏洞系统进行解析；
- 系统从 `packages/id` 解析出 maven 包的版本信息, 从 `vulnerabilities/name` 解析出漏洞编号, 便可以对maven包进行漏洞标记；


## 查看maven库是不是存在漏洞

访问特定库的版本，比如 log4j:1.2.17 版本 https://mvnrepository.com/artifact/log4j/log4j/1.2.17 , 页面上会该版本是不是存在漏洞(Vulnerabilities).


## Reference

1. NVD 美国国家漏洞数据库, https://nvd.nist.gov/
2. CPE 定义, https://csrc.nist.gov/projects/security-content-automation-protocol/specifications/cpe

