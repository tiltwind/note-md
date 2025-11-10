
# duckdb

- innic: 免费sql客户端,支持访问 duckdb, https://www.innicdata.com/
- duckdb, 单文件高性能数据库，兼容postgresql， https://duckdb.org/docs/installation/

```bash
curl https://install.duckdb.org | sh

export PATH='/root/.duckdb/cli/latest':$PATH

duckdb
.open xx.duckdb
```

common sql:
```sql
show tables;
SELECT * FROM duckdb_indexes();

ALTER TABLE wx_user RENAME TO yn_wx_user;

CREATE TABLE yn_user(id INTEGER PRIMARY KEY, "name" VARCHAR DEFAULT(NULL), pass VARCHAR DEFAULT(NULL), nickname VARCHAR DEFAULT(NULL),
created_by VARCHAR DEFAULT('system') NOT NULL, created_at TIMESTAMP DEFAULT(CURRENT_TIMESTAMP) NOT NULL,
updated_by VARCHAR DEFAULT('system') NOT NULL, updated_at TIMESTAMP DEFAULT(CURRENT_TIMESTAMP) NOT NULL, UNIQUE("name"));

CREATE SEQUENCE yn_user_id_seq;
ALTER TABLE yn_user ALTER id SET DEFAULT nextval('yn_user_id_seq');



```

https://github.com/duckdb/duckdb-go-bindings
golang compile:
```bash

go build -ldflags "-s -w"  -o build/target/yonisvr cmd/server.go

cd /opt/lib
git clone https://github.com/duckdb/duckdb-go-bindings.git

# staic link
ln -s libduckdb_static.a /opt/lib/duckdb-go-bindings/linux-amd64/libduckdb.a

CGO_ENABLED=1 CPPFLAGS="-DDUCKDB_STATIC_BUILD" CGO_LDFLAGS="-lduckdb -lstdc++ -lm -ldl -L/opt/duckdb-go-bindings/linux-amd64" go build -tags=duckdb_use_static_lib  -ldflags "-s -w"  -o build/target/yonisvr cmd/server.go

#
CGO_ENABLED=1 CGO_LDFLAGS="-lduckdb -L/opt/lib/duckdb-go-bindings/linux-amd64" LD_LIBRARY_PATH=/opt/lib/duckdb-go-bindings/linux-amd64 go build -tags=duckdb_use_lib -ldflags "-s -w"  -o build/target/yonisvr cmd/server.go
```
