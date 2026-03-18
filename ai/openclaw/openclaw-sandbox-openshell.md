<!--
markmeta_author: tiltwind
markmeta_date: 2026-03-18
markmeta_title: OpenClaw OpenShell Sandbox 配置
markmeta_categories: ai
markmeta_tags: ai,openclaw,agent,openshell,sandbox
-->

# OpenClaw OpenShell Sandbox 配置

OpenShell 是 OpenClaw 提供的一种轻量级沙箱方案，基于 Linux 命名空间（Namespaces）和 seccomp 实现进程级隔离，无需 Docker 即可限制 Agent 的工具执行环境。适用于无法安装 Docker 或资源受限的场景。

## 1. 工作原理

OpenShell 利用 Linux 内核原生的隔离机制，为每次工具执行创建受限的进程环境：

```
┌─────────────────────────────────────────────┐
│                   宿主机                      │
│                                               │
│  ┌──────────────────┐                         │
│  │  Gateway 进程     │                         │
│  │  ┌──────────┐    │                         │
│  │  │ Agent    │    │    ┌─────────────────┐  │
│  │  │ Runtime  │────┼───→│ OpenShell 沙箱   │  │
│  │  └──────────┘    │    │ ┌─────────────┐ │  │
│  │                   │    │ │ 工具执行     │ │  │
│  │  credentials/     │    │ │ (受限进程)   │ │  │
│  │  (沙箱外，不可达)  │    │ └─────────────┘ │  │
│  └──────────────────┘    │ - Mount NS 隔离  │  │
│                           │ - PID NS 隔离    │  │
│                           │ - seccomp 过滤   │  │
│                           │ - 只挂载workspace│  │
│                           └─────────────────┘  │
└─────────────────────────────────────────────┘
```

与 Docker Sandbox 的关键区别：

| 特性 | Docker Sandbox | OpenShell Sandbox |
|------|---------------|-------------------|
| 依赖 | 需要 Docker 引擎 | 仅需 Linux 内核 (≥ 5.13) |
| 隔离级别 | 容器级（完整 rootfs） | 进程级（命名空间 + seccomp） |
| 启动开销 | 较高（创建容器） | 极低（fork + unshare） |
| 资源占用 | 每个沙箱一个容器 | 无额外容器开销 |
| 镜像管理 | 需维护沙箱镜像 | 无需镜像 |
| 文件系统隔离 | 独立 rootfs | bind mount + 只读挂载 |
| 网络隔离 | Docker network `none` | Network Namespace 隔离 |
| 平台要求 | Linux / macOS / Windows | **仅 Linux** |

## 2. 前置条件

### 2.1 内核版本

OpenShell 依赖 Linux 命名空间和 seccomp，要求内核版本 ≥ 5.13：

```bash
# 检查内核版本
uname -r

# 检查命名空间支持
ls /proc/self/ns/

# 检查 seccomp 支持
grep CONFIG_SECCOMP /boot/config-$(uname -r)
# CONFIG_SECCOMP=y
# CONFIG_SECCOMP_FILTER=y
```

### 2.2 用户命名空间

需要启用非特权用户命名空间（大多数现代发行版默认启用）：

```bash
# 检查是否启用
sysctl kernel.unprivileged_userns_clone
# kernel.unprivileged_userns_clone = 1

# 如未启用
sudo sysctl -w kernel.unprivileged_userns_clone=1
# 持久化
echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/99-userns.conf
```

## 3. 配置详解

### 3.1 基础配置

在 `openclaw.json` 中将沙箱类型设为 `openshell`：

```json5
{
  "sandbox": {
    "mode": "non-main",
    "type": "openshell"            // 使用 OpenShell 沙箱（默认为 "docker"）
  }
}
```

### 3.2 完整配置

```json5
{
  "sandbox": {
    "mode": "all",
    "type": "openshell",
    "openshell": {
      "readOnlyRoot": true,        // 根目录只读
      "network": "none",           // 网络隔离（创建独立 Network NS）
      "memory": "1g",              // 内存限制（通过 cgroup）
      "cpus": 1,                   // CPU 限制（通过 cgroup）
      "allowPaths": [              // 额外允许访问的只读路径
        "/usr/bin",
        "/usr/lib"
      ],
      "denyPaths": [               // 明确禁止访问的路径
        "/home",
        "/root",
        "/etc/shadow"
      ],
      "seccomp": "default"         // seccomp 策略（default / strict / custom）
    }
  }
}
```

### 3.3 沙箱模式

与 Docker Sandbox 相同，支持三种模式：

| 模式 | 说明 |
|------|------|
| `"off"` | 不使用沙箱 |
| `"non-main"` | 仅自动任务（Cron、Webhook、Heartbeat）沙箱化 |
| `"all"` | 所有会话沙箱化 |

### 3.4 seccomp 策略

seccomp 过滤限制沙箱进程可使用的系统调用：

| 策略 | 说明 |
|------|------|
| `"default"` | 允许常见系统调用，阻止高危调用（如 `mount`、`reboot`、`ptrace`） |
| `"strict"` | 仅允许最小必要系统调用（`read`、`write`、`exit` 等），适合纯计算任务 |
| `"custom"` | 自定义 seccomp profile，路径通过 `seccompProfile` 指定 |

使用自定义 seccomp profile：

```json5
{
  "sandbox": {
    "type": "openshell",
    "openshell": {
      "seccomp": "custom",
      "seccompProfile": "~/.openclaw/seccomp-profile.json"
    }
  }
}
```

### 3.5 路径访问控制

OpenShell 通过 bind mount 精确控制沙箱内的文件系统可见性：

```json5
{
  "sandbox": {
    "type": "openshell",
    "openshell": {
      "allowPaths": [
        "/usr/bin",                // Agent 需要的系统工具
        "/usr/lib",                // 共享库
        "/usr/share/ca-certificates"  // TLS 证书（如需网络访问）
      ],
      "denyPaths": [
        "/home",                   // 其他用户目录
        "/root",                   // root 目录
        "/etc/shadow",             // 密码文件
        "/etc/ssh"                 // SSH 配置
      ]
    }
  }
}
```

默认情况下：
- `~/.openclaw/workspace/` —— 挂载到沙箱内，受 `workspaceAccess` 控制读写权限
- `~/.openclaw/credentials/` —— **不挂载**，沙箱内不可见
- `/tmp` —— 沙箱内独立的 tmpfs

## 4. 多 Agent 差异化配置

```json5
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "type": "openshell"
      }
    },
    "list": [
      {
        "id": "analyst",
        "sandbox": {
          "mode": "non-main",
          "type": "openshell",
          "openshell": {
            "seccomp": "default",
            "network": "none"
          }
        }
      },
      {
        "id": "developer",
        "sandbox": {
          "mode": "all",
          "type": "openshell",
          "openshell": {
            "seccomp": "default",
            "allowPaths": ["/usr/bin", "/usr/lib"],
            "network": "none"
          }
        },
        "tools": {
          "profile": "coding",
          "allow": ["exec", "write", "edit", "read"]
        }
      },
      {
        "id": "tester",
        "sandbox": {
          "mode": "all",
          "type": "openshell",
          "openshell": {
            "seccomp": "strict",   // 测试环境使用严格策略
            "network": "none",
            "memory": "512m"
          }
        }
      }
    ]
  }
}
```

## 5. 与 Docker Sandbox 的选择建议

| 场景 | 推荐方案 |
|------|---------|
| 生产服务器，已有 Docker | Docker Sandbox — 隔离更彻底 |
| 轻量 VPS / 边缘设备，无 Docker | OpenShell — 无需额外依赖 |
| macOS / Windows 开发机 | Docker Sandbox — OpenShell 仅支持 Linux |
| 高频工具调用，对延迟敏感 | OpenShell — 启动开销更低 |
| 需要完整独立文件系统环境 | Docker Sandbox — 独立 rootfs |
| 与 ZeroClaw 搭配 | OpenShell 或 Landlock — 轻量级方案更匹配 |

两种沙箱可以在同一 Gateway 中混合使用，为不同 Agent 指定不同的沙箱类型：

```json5
{
  "agents": {
    "list": [
      {
        "id": "developer",
        "sandbox": { "type": "docker", "mode": "all" }     // 需要完整环境
      },
      {
        "id": "monitor",
        "sandbox": { "type": "openshell", "mode": "all" }  // 轻量监控任务
      }
    ]
  }
}
```

## 6. 验证与诊断

```bash
# 运行安全诊断，检查 OpenShell 依赖
openclaw doctor

# 检查内核命名空间支持
ls /proc/self/ns/
# 应包含：cgroup ipc mnt net pid user uts

# 检查 seccomp 支持
grep SECCOMP /proc/self/status
# Seccomp:         0
# Seccomp_filters: 0

# 手动测试 unshare 是否可用（非特权）
unshare --user --pid --fork --mount-proc echo "namespace ok"
```

## 7. 故障排除

### unshare 失败：Operation not permitted

用户命名空间未启用：

```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1
```

部分发行版（如 Debian）可能需要额外配置 AppArmor：

```bash
# 检查 AppArmor 是否限制了 unshare
sudo aa-status
# 如有限制，调整对应 profile
```

### 沙箱内命令找不到

OpenShell 默认仅挂载 workspace，系统工具需要通过 `allowPaths` 显式暴露：

```json5
{
  "openshell": {
    "allowPaths": ["/usr/bin", "/usr/lib", "/bin", "/lib"]
  }
}
```

### 内存限制不生效

cgroup v2 需要正确配置，检查 cgroup 挂载：

```bash
# 检查 cgroup 版本
stat -fc %T /sys/fs/cgroup/
# cgroup2fs 表示 v2

# 检查当前用户的 cgroup 控制器
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/cgroup.controllers
```

## 参考

- [OpenClaw 安全加固](openclaw-security.md)
- [OpenClaw Docker Sandbox 配置](openclaw-sandbox-docker.md)
- [OpenClaw 配置](openclaw-config.md)
- [Linux Namespaces - man7.org](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [seccomp - Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/userspace-api/seccomp_filter.html)
