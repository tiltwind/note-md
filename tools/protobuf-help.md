<!---
markmeta_author: tiltwind
markmeta_date: 2020-01-23
markmeta_title: Protocol Buffer Help
markmeta_categories: 工具
markmeta_tags: protobuf,protoc
-->

# Protocol Buffer Help


## install

Mac:
```bash
curl -L -C - -O https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-osx-x86_64.zip
sudo tar -C /usr/local -xzf protoc-21.12-osx-x86_64.zip

# install protobuf rust codegen
cargo install protobuf-codegen
```

Linux:
```bash
curl -L -C - -O https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip
sudo tar -C /usr/local -xzf protoc-21.12-linux-x86_64.zip
```




## Troubleshooting


### rust cargo ssh error

```bash
cargo install protobuf-codegen
#     Updating crates.io index
# error: failed to fetch `https://github.com/rust-lang/crates.io-index`
# 
# Caused by:
#   failed to authenticate when downloading repository: git@github.com:rust-lang/crates.io-index
# 
#   * attempted ssh-agent authentication, but no usernames succeeded: `git`
# 
#   if the git CLI succeeds then `net.git-fetch-with-cli` may help here
#   https://doc.rust-lang.org/cargo/reference/config.html#netgit-fetch-with-cli
# 
# Caused by:
#   no authentication available


eval `ssh-agent -s`
# Agent pid 27236

ssh-add
# Identity added: /Users/sathia/.ssh/id_rsa
#   uzhaippu git:(master) ✗ cargo build
```