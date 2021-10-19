<!---
markmeta_author: wongoo
markmeta_date: 2021-10-15
markmeta_title: go proxy
markmeta_categories: go
markmeta_tags: golang,proxy
-->

# Go proxy

## 1. 什么是 go proxy

golang 官方提供了模块管理功能 `go mod`, 
项目下通过 `go.mod` 定义模块依赖， 
通过 `go.sum` 定义依赖模块的 checksum 校验码.

模块下载通过支持 [goproxy 协议](https://golang.org/ref/mod#goproxy-protocol) 的服务进行下载, 
默认地址是 `https://proxy.golang.org`。

checksum 数据库默认地址是 `https://sum.golang.org`, 
代理服务也可以代理 checksum 的代理请求，只需实现 [checksum代理协议](https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md#checksum-database)

但网络原因，可能访问不了默认代理服务或访问很慢，可以通过请求中间代理服务，
中间代理服务只要支持 `goproxy协议` 和 `checksum代理协议` 即可.

比如 `https://goproxy.io` , `https://goproxy.cn`.


## 2. 访问私有仓库

golang 要构建需要下载相关依赖库的源码，因为公司内部项目都是放在私有 gitlab 仓库中，要能够下载编译可以设置以下两个参数即可。

```bash
# 多个代理逗号间隔,go会依次尝试从各个代理下载依赖库,如果下载不了则使用下一个代理
# direct 代表直接连接
export GOPROXY=https://goproxy.cn,https://proxy.golang.org,direct

# 配置 gitlab 私有仓库， 以及 github上组织内的私有仓库
# GOPRIVATE 指定的仓库将不进行sum校验
export GOPRIVATE=gitlab.mycompany.com,*.mysubcompany.com,github.com/mycompany
```

还可以用 `GONOPROXY` 和 `GONOSUMDB` 更灵活的配置，这两个配置会覆盖 `GOPRIVATE` 的配置.

注意: 如果本地是通过ssh连接私有仓库,还需配置 `~/.gitconfig`：
```
[url "ssh://git@gitlab.mycompany.com/"]
    insteadOf = https://gitlab.mycompany.com/
```


## 3. 安装私有 goproxy

如果出于性能、安全、稳定性考虑, 公司还可以创建私有goproxy。

> 注意: goproxy 无安全认证，如果公司内部项目有权限访问限制，则不要将私有项目通过goproxy进行代理。
> 只有开源公开的项目才通过goproxy代理,其他项目则直接访问代码库的方式。

下面选择 开源goproxy实现 [athens](https://github.com/gomods/athens) 进行安装。


### 3.1. 下载 athens

从 [这里](https://github.com/gomods/athens/releases) 下周athens最新版本, 解压后得到 athens 可执行文件.

### 3.2. 创建 athens 配置文件

创建一个配置文件  config.toml: 
```conf
Port = ":3000"
GoBinary = "go"
GoEnv = "development"
GoProxy = ""

# gitlab.mycompany.com/open 只代理 open 组下的开源项目
GoBinaryEnvVars = ["GOPROXY=goproxy.cn,direct","GOPRIVATE=gitlab.mycompany.com/open"]

GoGetWorkers = 50
ProtocolWorkers = 30
LogLevel = "debug"
CloudRuntime = "none"

NoSumPatterns = ["gitlab.mycompany.com/*"]
DownloadMode = "sync"

Timeout = 300

StorageType = "disk"
[Storage]
    [Storage.Disk]
        RootPath = "/home/app/athens/storage"
```

其中 `RootPath = "/home/app/athens/storage"` 为配置缓存文件的目录。
完整配置属性参考[这里](https://docs.gomods.io/configuration/).
也可以基于 [范例](https://github.com/gomods/athens/blob/main/config.dev.toml) 进行修改.

### 3.3. 配置代码库访问权限

创建 .netrc 文件用于配置访问 gitlab 仓库的账号密码

```
machine gitlab.mycompany.com login root password ROOTPASS
```

### 3.4. 启动代理

```bash
./athens -config_file ./config.toml
```

假设访问地址为 http://192.168.15.212:3000.


### 3.5. 构建使用

jenkins或本地开发设置 `export GOPROXY=http://192.168.15.212:3000,direct` 即可。


## A. 参考
- goproxy protocol, https://golang.org/ref/mod#goproxy-protocol
- golang checksum database protocol, https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md#checksum-database
- GOPRIVATE 环境变量, https://goproxy.io/zh/docs/GOPRIVATE-env.html
- GOSUMDB 环境变量, https://goproxy.io/zh/docs/GOSUMDB-env.html


## B. 编辑历史
1. 2021-10-15, wangoo, 初版
