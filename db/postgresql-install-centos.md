<!---
markmeta_author: titlwind
markmeta_date: 2025-11-07
markmeta_title: 安装 PostgreSQL 17 on CentOS 8
markmeta_categories: db
markmeta_tags: db,postgresql,centos
-->

doc: https://www.postgresql.org/download/linux/redhat/


# 通过
```bash

# CentOS 8
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql

sudo dnf install -y postgresql17-server postgresql17-contrib

sudo /usr/pgsql-17/bin/postgresql-17-setup initdb

sudo systemctl enable postgresql-17
sudo systemctl start postgresql-17

sudo -u postgres psql
\password postgres
# 输入并确认新密码
\q

sudo vi /var/lib/pgsql/17/data/postgresql.conf

# listen_addresses = '*'

sudo vi /var/lib/pgsql/17/data/pg_hba.conf
# host    all             all             0.0.0.0/0               md5

sudo systemctl restart postgresql-17

# 如果启用了防火墙（firewalld）
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload

# 验证安装
psql -U postgres -h localhost
# \l                    -- 看有哪些库
# \du                   -- 看有哪些角色/账号
# \z                    -- 在当前库看权限


# PostGIS packages are often in the EPEL repo. Install and enable it
sudo yum install -y epel-release

sudo yum search postgis
sudo yum install -y postgis35_17

# 注意：CentOS 8 的模块化机制会默认启用旧版 PostgreSQL 模块，若不手动禁用，会导致无法安装或使用官方新版 PostgreSQL。
# 建议先禁用系统自带 PostgreSQL 模块：
sudo dnf -y module disable postgresql

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
