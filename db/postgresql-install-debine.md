<!---
markmeta_author: titlwind
markmeta_date: 2025-11-07
markmeta_title: 安装 PostgreSQL 17 on Debian 12
markmeta_categories: db
markmeta_tags: db,postgresql,debian
-->

doc: https://www.postgresql.org/download/linux/debian/ ; https://wiki.postgresql.org/wiki/Apt


# 在 Debian 12 (Bookworm) 安装 PostgreSQL 17

本文基于 PostgreSQL 官方 Debian 指南与 PGDG Wiki，推荐使用官方 PGDG 仓库获取 PostgreSQL 17。

参考：
- 官方 Debian 下载页（添加 PGDG 仓库）：https://www.postgresql.org/download/linux/debian/
- PGDG Wiki（快速脚本与手动配置）：https://wiki.postgresql.org/wiki/Apt

## 方法一：使用官方快速脚本（推荐）

```bash
set -euo pipefail

# 1) 安装脚本所需工具
sudo apt update
sudo apt install -y postgresql-common ca-certificates

# 2) 运行 PGDG 仓库启用脚本（会为当前发行版生成 bookworm-pgdg 源并导入签名）
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

# 3) 安装 PostgreSQL 17 与客户端
sudo apt update
sudo apt install -y postgresql-17 postgresql-client-17

# 4) 启用并启动服务
sudo systemctl enable --now postgresql

# 5) 查看状态
systemctl status postgresql --no-pager
```

## 方法二：手动添加 PGDG 仓库并安装 17

```bash
set -euo pipefail

# 1) 安装基础工具
sudo apt update
sudo apt install -y curl ca-certificates lsb-release

# 2) 导入仓库签名到固定路径（PGDG 推荐的 signed-by 方式）
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc

# 3) 添加 PGDG 源（使用当前发行版代号）
echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/pgdg.list

# 4) 安装 PostgreSQL 17 与客户端
sudo apt update
sudo apt install -y postgresql-17 postgresql-client-17

# 5) 启用并启动服务
sudo systemctl enable --now postgresql

# 6) 验证版本
sudo -u postgres psql -c "SELECT version();"
```

## 初始化与本地验证

```bash
# 修改 postgres 超级用户密码（非交互方式）
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'StrongP@ssw0rd!';"

# 使用 psql 验证连接
psql -U postgres -h localhost -c '\\l'
psql -U postgres -h localhost -c '\\du'
```

## 远程访问配置（可选）

Debian 的配置文件在 `/etc/postgresql/17/main/` 目录下。

```bash
# 1) 监听所有地址（或替换为具体网卡 IP）
sudo sed -ri "s/^#?listen_addresses\s*=.*/listen_addresses = '*' /" /etc/postgresql/17/main/postgresql.conf

# 2) 允许外部 md5 认证（示例为全网段，实际请收敛到业务网段）
grep -qE "^host\s+all\s+all\s+0.0.0.0/0\s+md5" /etc/postgresql/17/main/pg_hba.conf || \
  echo "host    all             all             0.0.0.0/0               md5" | \
  sudo tee -a /etc/postgresql/17/main/pg_hba.conf

# 3) 重启服务使配置生效
sudo systemctl restart postgresql
```

## 防火墙（可选，使用 UFW）

```bash
sudo apt install -y ufw
sudo ufw allow 5432/tcp
sudo ufw reload
```

## 安装 PostGIS（可选）

PGDG 提供针对 PostgreSQL 17 的 PostGIS 包，安装后在数据库内启用扩展。

```bash
# 安装 PostGIS 包（包含 17 对应的二进制与 SQL 脚本）
sudo apt update
sudo apt install -y postgis postgresql-17-postgis-3 postgresql-17-postgis-3-scripts

# 在目标数据库启用扩展
sudo -u postgres psql -d appdb -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

# 创建数据库和用户

```sql
-- 1. 建库
CREATE DATABASE appdb;

-- 2. 建账号（同时建角色）
CREATE USER manageuser WITH PASSWORD 'StrongP@ssw0rd!';
CREATE USER appuser WITH PASSWORD 'StrongP@ssw0rd!';

-- 3. 赋库级所有权限
GRANT ALL PRIVILEGES ON DATABASE appdb TO manageuser;

\c appdb
GRANT CONNECT ON DATABASE appdb TO appuser;
GRANT USAGE ON SCHEMA public TO appuser;
GRANT CREATE ON SCHEMA public TO appuser;  -- 允许变更schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO appuser;  -- 未来新建表也继承
```

## 一键安装与初始化脚本（示例）

```bash
#!/usr/bin/env bash
set -euo pipefail

# 适用于 Debian 12 (Bookworm)：添加 PGDG 仓库并安装 PostgreSQL 17

sudo apt update
sudo apt install -y curl ca-certificates lsb-release
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc
echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-17 postgresql-client-17
sudo systemctl enable --now postgresql

# 设置 postgres 密码（替换为自己的安全密码）
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'StrongP@ssw0rd!';"

# 开启远程访问（如需）
sudo sed -ri "s/^#?listen_addresses\s*=.*/listen_addresses = '*' /" /etc/postgresql/17/main/postgresql.conf
grep -qE "^host\s+all\s+all\s+0.0.0.0/0\s+md5" /etc/postgresql/17/main/pg_hba.conf || \
  echo "host    all             all             0.0.0.0/0               md5" | \
  sudo tee -a /etc/postgresql/17/main/pg_hba.conf
sudo systemctl restart postgresql

# 基础验证
sudo -u postgres psql -c "SELECT version();"
psql -U postgres -h localhost -c '\\l'
psql -U postgres -h localhost -c '\\du'
```

## 备注与建议

- 为安全起见，生产环境请将 `pg_hba.conf` 的网段限制到特定业务网段，不建议使用 `0.0.0.0/0`。
- Debian 默认使用 `postgresql-common` 管理集群，安装 `postgresql-17` 时会自动创建并启动 `17/main` 集群。
- 官方快速脚本可减少手工错误；手动方式适于自定义签名与源配置。
- 如需固定在某一大版本（例如始终 17），请安装带版本号的包（如 `postgresql-17` 与 `postgresql-client-17`），避免 `postgresql` 元包随最新版本漂移。
