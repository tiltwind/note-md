<!---
markmeta_author: wongoo
markmeta_date: 2019-01-16
markmeta_title: Go Installation
markmeta_categories: 编程语言
markmeta_tags: golang,installation
-->

# go installation

Mac:
```bash
curl -C - -O https://dl.google.com/go/go1.19.3.darwin-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.3.darwin-amd64.tar.gz
```

Linux:
```bash
curl -C - -O https://dl.google.com/go/go1.19.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
sudo tar -C /tmp/go/local -xzf go1.19.3.linux-amd64.tar.gz
```

config env:
```bash
> sudo vi /etc/profile
export BASEDIR=/Users/gelnyang
export GOPATH=$BASEDIR/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN
export GO111MODULE=on

# add direct to support private reporsitories, eg gitlab.
export GOPROXY=https://goproxy.cn,direct
# export GOPROXY=https://goproxy.io

export GOPRIVATE=gitlab.homeking365.com


```

upgrade: 
```bash
sudo rm -rf /usr/local/go
# then install the latest
```

Install from source:
```bash
curl -C - -O https://dl.google.com/go/go1.19.3.src.tar.gz
tar -C /usr/local -xzf go1.19.3.src.tar.gz
cd /usr/local/go/src
time sudo ./make.bash
```


## go tools

```bash
# golang tools
# cd $GOPATH/src/github.com/golang/tools && git pull -v && go install ./...
go install golang.org/x/tools/cmd/...@latest


# golangci-lint
# cd $GOPATH/src/github.com/golangci/golangci-lint && git pull -v && go install ./...
# curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
go install github.com/golangci/golangci-lint/...@latest

go install mvdan.cc/gofumpt@latest
```

