# Monitoring MQ Redis

基于 Prometheus + Grafana 的 RocketMQ 和 Redis 监控系统。

## 项目结构

```
monitoring-mq-redis/
├── docker-compose.yml          # Prometheus & Grafana 主服务配置
├── docker-compose-exporter.yml # Exporter 服务配置（独立管理）
├── .env                        # 环境变量配置（不上传到仓库）
├── .env.example               # 环境变量示例文件
├── .gitignore                 # Git 忽略规则
├── README.md                  # 项目说明文档
├── config/                    # 配置文件目录
│   ├── prometheus/
│   │   └── prometheus.yml    # Prometheus 配置文件
│   └── grafana/              # Grafana 配置（按需添加）
└── data/                      # 数据持久化目录（执行时自动创建）
    ├── prometheus/            # Prometheus 数据
    └── grafana/               # Grafana 数据
```

## 快速开始

### 1. 配置环境变量

复制示例环境变量文件并修改为实际配置：

```bash
cp .env.example .env
```

然后编辑 `.env` 文件，填入实际的配置信息：

```env
# Grafana 配置
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your-secure-password

# Redis 配置（支持多实例）
REDIS_HOST_1=your-redis-host-1:6379
REDIS_PASSWORD_1=your-redis-password-1
REDIS_HOST_2=your-redis-host-2:6380
REDIS_PASSWORD_2=your-redis-password-2

# RocketMQ 配置
ROCKETMQ_NAMESRV_ADDR=your-rocketmq-namesrv:9876
ROCKETMQ_ACL_ENABLE=false
ROCKETMQ_ACL_ACCESS_KEY=
ROCKETMQ_ACL_SECRET_KEY=

# 时区配置
TZ=Asia/Shanghai
```


### 2. 启动服务

本项目采用**分离式架构**，将监控服务（Prometheus + Grafana）和数据采集器（Exporters）分开管理，便于灵活部署。

#### 启动监控服务（Prometheus + Grafana）

```bash
docker-compose up -d
```

#### 启动 Exporter 服务（按需启动）

使用 Docker Compose Profiles 功能，可以灵活选择启动哪些 Exporter：

**方式 1：启动所有 Redis Exporters**
```bash
docker-compose -f docker-compose-exporter.yml --profile all-redis-exporter up -d
```

**方式 2：只启动第一个 Redis Exporter (6379)**
```bash
docker-compose -f docker-compose-exporter.yml --profile redis-exporter-1 up -d
```

**方式 3：只启动第二个 Redis Exporter (6380)**
```bash
docker-compose -f docker-compose-exporter.yml --profile redis-exporter-2 up -d
```

**方式 4：启动 RocketMQ Exporter**
```bash
docker-compose -f docker-compose-exporter.yml --profile rocketmq-exporter up -d
```

**方式 5：组合启动（例如：redis-1 + rocketmq）**
```bash
docker-compose -f docker-compose-exporter.yml --profile redis-exporter-1 --profile rocketmq-exporter up -d
```

**方式 6：启动所有 Exporters**
```bash
docker-compose -f docker-compose-exporter.yml --profile all up -d
```

#### 查看服务状态

```bash
# 查看监控服务状态
docker-compose ps

# 查看 Exporter 服务状态
docker-compose -f docker-compose-exporter.yml ps
```

#### 查看服务日志

```bash
# 查看监控服务日志
docker-compose logs -f

# 查看 Exporter 日志
docker-compose -f docker-compose-exporter.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose-exporter.yml logs -f redis-exporter-6379
```

### 3. 访问服务

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
  - 默认用户名：在 `.env` 中配置的 `GRAFANA_ADMIN_USER`
  - 默认密码：在 `.env` 中配置的 `GRAFANA_ADMIN_PASSWORD`

### 4. 停止服务

```bash
# 停止监控服务
docker-compose down

# 停止 Exporter 服务
docker-compose -f docker-compose-exporter.yml down

# 一次性停止所有服务
docker-compose down && docker-compose -f docker-compose-exporter.yml down
```

## 配置文件说明

所有配置文件统一存放在 `config/` 目录下：

### Prometheus 配置

文件位置：`config/prometheus/prometheus.yml`

- 定义了监控目标和采集规则
- 可以根据需要添加更多的监控目标
- 默认监控：Prometheus 自身、Redis Exporter、RocketMQ Exporter

### Grafana 配置

文件位置：`config/grafana/provisioning/datasources/prometheus.yml`

- 自动配置 Prometheus 作为数据源
- 可以在此目录下添加更多的 provisioning 配置

## 服务说明

### 监控服务（docker-compose.yml）

#### Prometheus
- **端口**：9090
- **数据保留**：3天
- **采集间隔**：15秒
- **网络模式**：host
- **监控目标**：
  - Prometheus 自身
  - Redis Exporter (9121, 9122)
  - RocketMQ Exporter (5557)

#### Grafana
- **端口**：3000
- **网络模式**：host
- **已自动配置 Prometheus 数据源**
- **数据持久化存储**
- **默认账号**：通过 `.env` 配置

### Exporter 服务（docker-compose-exporter.yml）

#### Redis Exporter 1
- **容器名称**：redis-exporter-6379
- **端口**：9121
- **监控目标**：由 `REDIS_HOST_1` 指定的 Redis 实例
- **Profile**：`redis-exporter-1` 或 `all-redis-exporter`

#### Redis Exporter 2
- **容器名称**：redis-exporter-6380
- **端口**：9122
- **监控目标**：由 `REDIS_HOST_2` 指定的 Redis 实例
- **Profile**：`redis-exporter-2` 或 `all-redis-exporter`

#### RocketMQ Exporter
- **容器名称**：rocketmq-exporter
- **端口**：5557
- **监控目标**：由 `ROCKETMQ_NAMESRV_ADDR` 指定的 RocketMQ 集群
- **Profile**：`rocketmq-exporter`

## 架构设计

### 为什么分离 Exporter？

1. **灵活部署**：可以根据实际需求选择启动哪些 Exporter
2. **独立管理**：Exporter 的启停不影响监控服务
3. **资源优化**：不需要的 Exporter 可以不启动，节省资源
4. **便于扩展**：需要监控更多 Redis 实例时，只需在 exporter 文件中添加即可

### 使用 Profiles 的优势

- **按需启动**：通过 `--profile` 参数精确控制启动哪些服务
- **环境隔离**：开发环境和生产环境可以启动不同的 Exporter 组合
- **配置统一**：所有 Exporter 配置在同一文件中，便于管理

## 注意事项

1. **安全性**：
   - 请勿将 `.env` 文件提交到版本控制系统
   - 生产环境请使用强密码
   - 建议配置防火墙规则限制访问

2. **数据持久化**：
   - `data/` 目录包含 Prometheus 和 Grafana 的数据
   - 该目录已在 `.gitignore` 中忽略，不会提交到仓库
   - 该目录会在首次启动服务时自动创建
   - 定期备份数据目录

3. **网络配置**：
   - Prometheus 和 Grafana 使用 host 网络模式
   - Exporter 服务独立网络，通过端口映射访问
   - 确保能够访问配置的 Redis 和 RocketMQ 服务

4. **Profile 使用**：
   - 必须使用 `--profile` 参数才能启动 Exporter 服务
   - 可以组合多个 profile 同时启动多个 Exporter
   - 不指定 profile 直接运行会提示没有服务启动

## 常见问题

### 1. Grafana 无法连接 Prometheus

检查 Prometheus 服务是否正常运行：
```bash
docker-compose logs prometheus
```

确认 Prometheus 和 Grafana 都使用 host 网络模式，可以通过 localhost 互相访问。

### 2. Exporter 无法连接目标服务

- 检查 `.env` 中的 `REDIS_HOST_1`、`REDIS_HOST_2`、`ROCKETMQ_NAMESRV_ADDR` 配置是否正确
- 确保目标服务（Redis/RocketMQ）网络可达
- 查看 exporter 日志：
  ```bash
  docker-compose -f docker-compose-exporter.yml logs redis-exporter-6379
  docker-compose -f docker-compose-exporter.yml logs redis-exporter-6380
  docker-compose -f docker-compose-exporter.yml logs rocketmq-exporter
  ```

### 3. 启动 Exporter 时提示没有服务

这是因为没有指定 profile。必须使用 `--profile` 参数：
```bash
# 错误方式
docker-compose -f docker-compose-exporter.yml up -d

# 正确方式
docker-compose -f docker-compose-exporter.yml --profile redis-exporter-1 up -d
```

### 4. 如何查看已启动的 Exporter？

```bash
docker-compose -f docker-compose-exporter.yml ps
```

或者使用 Docker 命令：
```bash
docker ps | grep exporter
```

### 5. Prometheus 抓取不到 Exporter 数据

- 确认 Exporter 服务已经启动：`docker ps | grep exporter`
- 检查端口是否正确映射：
  - Redis Exporter 1: 9121
  - Redis Exporter 2: 9122
  - RocketMQ Exporter: 5557
- 访问 Prometheus Targets 页面检查状态：http://localhost:9090/targets
- 如果使用 host 网络模式，确保可以通过 `localhost:端口` 访问

### 6. 数据丢失

- 确保 `data/` 目录有正确的权限
- 定期备份 `data/` 目录

### 7. 如何添加更多 Redis 实例监控？

在 `docker-compose-exporter.yml` 中添加新的服务：
```yaml
redis-exporter-3:
  image: oliver006/redis_exporter:latest
  container_name: redis-exporter-6381
  restart: unless-stopped
  environment:
    - TZ=${TZ:-Asia/Shanghai}
  command:
    - --redis.addr=redis://${REDIS_HOST_3:-localhost:6381}
    - --redis.password=${REDIS_PASSWORD_3:-}
    - --export-client-port=9123
  volumes:
    - /etc/timezone:/etc/timezone:ro
    - /etc/localtime:/etc/localtime:ro
  ports:
    - "9123:9123"
  profiles:
    - all-redis-exporter
    - redis-exporter-3
```

然后在 `.env` 中添加对应配置，并更新 `config/prometheus/prometheus.yml`。

## 快速命令参考

### 一键启动常用组合

```bash
# 启动监控服务 + 所有 Redis Exporters
docker-compose up -d && \
docker-compose -f docker-compose-exporter.yml --profile all-redis-exporter up -d

# 启动监控服务 + 第一个 Redis + RocketMQ
docker-compose up -d && \
docker-compose -f docker-compose-exporter.yml \
  --profile redis-exporter-1 \
  --profile rocketmq-exporter up -d

# 启动全部服务
docker-compose up -d && \
docker-compose -f docker-compose-exporter.yml \
  --profile all-redis-exporter \
  --profile rocketmq-exporter up -d
```

### 重启服务

```bash
# 重启监控服务
docker-compose restart

# 重启特定 Exporter
docker restart redis-exporter-6379
docker restart redis-exporter-6380
docker restart rocketmq-exporter
```

### 更新配置后重载

```bash
# Prometheus 热重载配置（无需重启）
curl -X POST http://localhost:9090/-/reload

# 或重启 Prometheus
docker-compose restart prometheus
```

### 清理和重置

```bash
# 停止并删除所有容器
docker-compose down
docker-compose -f docker-compose-exporter.yml down

# 清理数据（谨慎操作！）
rm -rf data/prometheus/*
rm -rf data/grafana/*
```

## 监控指标说明

### Redis Exporter 指标
- `redis_up`：Redis 是否在线
- `redis_connected_clients`：连接的客户端数量
- `redis_memory_used_bytes`：内存使用量
- `redis_commands_processed_total`：处理的命令总数
- 更多指标请访问：http://localhost:9121/metrics 或 http://localhost:9122/metrics

### RocketMQ Exporter 指标
- `rocketmq_broker_tps`：Broker TPS
- `rocketmq_producer_message_size`：生产者消息大小
- `rocketmq_consumer_tps`：消费者 TPS
- 更多指标请访问：http://localhost:5557/metrics

## 许可证

MIT
