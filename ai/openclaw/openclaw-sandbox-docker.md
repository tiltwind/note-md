<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-18
markmeta_title: OpenClaw Docker Sandbox 配置
markmeta_categories: ai
markmeta_tags: ai,openclaw,agent,docker,sandbox
-->

# OpenClaw Docker Sandbox 配置

Docker Sandbox 是 OpenClaw 默认的沙箱实现，通过 Docker 容器隔离 Agent 的工具执行环境，防止 Agent 访问凭证、系统文件和外部网络。

## 1. 工作原理

当 Agent 需要执行工具（如 `exec`、`write`）时，Gateway 不在本地直接执行，而是启动一个临时 Docker 容器（沙箱容器），将工具在容器内执行后返回结果：

```
┌─────────────────────────────────────────────────┐
│                   宿主机                          │
│                                                   │
│  ┌──────────────────────┐  ┌──────────────────┐  │
│  │  Gateway 进程         │  │  沙箱容器         │  │
│  │  ┌────────────────┐  │  │  ┌────────────┐  │  │
│  │  │ Agent Runtime   │──┼──┼─→│ 工具执行    │  │  │
│  │  └────────────────┘  │  │  └────────────┘  │  │
│  │  ┌────────────────┐  │  │                   │  │
│  │  │ credentials/   │  │  │  只挂载 workspace │  │
│  │  │ (Agent 不可达)  │  │  │  无网络访问       │  │
│  │  └────────────────┘  │  │  只读根文件系统    │  │
│  └──────────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────┘
```

沙箱容器只挂载 `workspace/` 目录，不包含 `credentials/`、`openclaw.json` 等敏感文件。

## 2. 前置条件

Docker Sandbox 要求宿主机已安装 Docker：

```bash
# 检查 Docker 是否可用
docker --version
docker info

# 确保运行 OpenClaw 的用户在 docker 组中
sudo usermod -aG docker $USER
```

## 3. 沙箱镜像

### 3.1 使用默认镜像

OpenClaw 提供预构建的沙箱镜像 `openclaw-sandbox:bookworm-slim`，基于 Debian Bookworm 最小化版本：

```bash
# 拉取沙箱镜像
docker pull openclaw-sandbox:bookworm-slim
```

### 3.2 自定义镜像

如果 Agent 需要特定工具（如 Python、Node.js、编译器等），可以基于默认镜像构建自定义版本：

```dockerfile
FROM openclaw-sandbox:bookworm-slim

# 安装 Agent 工作所需的工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
```

```bash
docker build -t openclaw-sandbox:custom .
```

也可以通过配置中的 `setupCommand` 在容器启动时安装（每次启动都会执行，速度较慢）：

```json5
{
  "sandbox": {
    "docker": {
      "image": "openclaw-sandbox:bookworm-slim",
      "setupCommand": "apt-get update && apt-get install -y git curl jq"
    }
  }
}
```

> 自定义镜像适合需要频繁使用的工具，`setupCommand` 适合临时或轻量的依赖。

## 4. 配置详解

### 4.1 基础配置

在 `openclaw.json` 中配置沙箱：

```json5
{
  "sandbox": {
    "mode": "non-main",           // 沙箱模式
    "docker": {
      "image": "openclaw-sandbox:bookworm-slim"
    }
  }
}
```

### 4.2 沙箱模式

| 模式 | 说明 | 适用场景 |
|------|------|---------|
| `"off"` | 不使用沙箱，工具直接在宿主机/Gateway 容器内执行 | 仅限可信环境的本地开发 |
| `"non-main"` | 非主会话（Cron、Webhook、Heartbeat 触发）在沙箱中执行 | **默认推荐** |
| `"all"` | 所有会话均在沙箱中执行 | 高安全要求的生产环境 |

### 4.3 完整安全配置

```json5
{
  "sandbox": {
    "mode": "all",
    "docker": {
      "image": "openclaw-sandbox:bookworm-slim",
      "readOnlyRoot": true,       // 只读根文件系统，防止恶意软件持久化
      "network": "none",          // 无网络访问，防止数据外泄和内网探测
      "memory": "1g",             // 内存上限，防止资源耗尽
      "cpus": 1                   // CPU 上限
    }
  }
}
```

### 4.4 Workspace 访问权限

控制沙箱中 Agent 对 workspace 目录的读写权限：

```json5
{
  "sandbox": {
    "mode": "all",
    "workspaceAccess": "read-write",  // 默认值，允许 Agent 读写 workspace
    // "workspaceAccess": "read-only"  // 沙箱中 workspace 只读
  }
}
```

### 4.5 沙箱作用范围

`scope` 控制沙箱容器的生命周期粒度：

```json5
{
  "sandbox": {
    "mode": "all",
    "scope": "agent"    // 每个 Agent 实例一个沙箱容器
    // "scope": "session"  // 每个会话一个沙箱容器（更强隔离）
  }
}
```

## 5. 多 Agent 差异化配置

不同角色的 Agent 可设置不同的沙箱策略：

```json5
{
  "agents": {
    "defaults": {
      "sandbox": { "mode": "non-main" }   // 全局默认
    },
    "list": [
      {
        "id": "analyst",
        "sandbox": { "mode": "non-main" }  // 分析师：仅自动任务沙箱化
      },
      {
        "id": "developer",
        "tools": {
          "profile": "coding",
          "allow": ["exec", "write", "edit", "read"]
        }
        // 继承默认沙箱配置
      },
      {
        "id": "tester",
        "sandbox": {
          "mode": "all",                    // 测试：全部沙箱化
          "scope": "agent",
          "docker": {
            "setupCommand": "apt-get update && apt-get install -y git curl jq"
          }
        }
      }
    ]
  }
}
```

## 6. Gateway 在 Docker 中运行时的沙箱配置

当 Gateway 本身运行在 Docker 容器中时，需要挂载宿主机 Docker Socket，让 Gateway 通过宿主机 Docker 引擎创建沙箱容器（Sibling Container 模式）：

```yaml
# docker-compose.yml
services:
  openclaw-gateway:
    image: openclaw-gateway:latest
    volumes:
      - openclaw_data:/home/node/.openclaw
      - /var/run/docker.sock:/var/run/docker.sock
```

```json5
// openclaw.json — 配置与原生部署相同
{
  "sandbox": {
    "mode": "all",
    "docker": {
      "image": "openclaw-sandbox:bookworm-slim",
      "readOnlyRoot": true,
      "network": "none"
    }
  }
}
```

沙箱容器作为 Gateway 容器的"兄弟"运行在宿主机 Docker 引擎上，只挂载 workspace 目录，无法访问 credentials。

> 关于 Docker 部署下沙箱与凭证保护的详细安全分析，参见 [安全加固 - 4.4 Docker 部署下的沙箱与凭证保护](openclaw-security.md#44-docker-部署下的沙箱与凭证保护)。

## 7. 验证沙箱状态

```bash
# 检查沙箱镜像是否存在
docker images openclaw-sandbox

# 运行安全诊断
openclaw doctor

# 查看正在运行的沙箱容器
docker ps --filter "label=openclaw.sandbox=true"
```

## 8. 故障排除

### 沙箱容器启动失败

```bash
# 检查 Docker 服务状态
systemctl status docker

# 检查镜像是否存在
docker images | grep openclaw-sandbox

# 手动测试沙箱镜像
docker run --rm openclaw-sandbox:bookworm-slim echo "sandbox ok"
```

### setupCommand 执行超时

`setupCommand` 在每次容器启动时执行，如果依赖较多会显著影响响应速度。建议将常用工具预装到自定义镜像中，仅用 `setupCommand` 安装临时依赖。

### 沙箱中工具缺失

Agent 执行工具报错找不到命令时，需要在沙箱镜像中安装对应工具：

```json5
{
  "sandbox": {
    "docker": {
      // 方式一：启动时安装（慢）
      "setupCommand": "apt-get update && apt-get install -y <package>"
      // 方式二：使用预装了所需工具的自定义镜像（推荐）
      // "image": "openclaw-sandbox:custom"
    }
  }
}
```

## 参考

- [OpenClaw 安全加固](openclaw-security.md)
- [OpenClaw 配置](openclaw-config.md)
- [OpenClaw Docker 部署](openclaw-install-docker.md)
- [OpenClaw 多 Agent 实例配置](openclaw-multi-agent.md)
- [Docker 官方博客 - OpenClaw 安全沙箱](https://www.docker.com/blog/run-openclaw-securely-in-docker-sandboxes/)
