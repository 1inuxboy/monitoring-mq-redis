# Monitoring MQ Redis

基于 Prometheus + Grafana 的 RocketMQ 和 Redis 监控系统。

## 项目结构

```
monitoring-mq-redis/
├── docker-compose.yml          # Docker Compose 配置文件
├── .env                        # 环境变量配置（不上传到仓库）
├── .env.example               # 环境变量示例文件
├── .gitignore                 # Git 忽略规则
├── README.md                  # 项目说明文档
├── config/                    # 配置文件目录
│   ├── prometheus/
│   │   └── prometheus.yml    # Prometheus 配置文件
│   └── grafana/
│       └── provisioning/
│           └── datasources/
│               └── prometheus.yml # Grafana 数据源配置
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

# Redis 配置
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# RocketMQ 配置
ROCKETMQ_NAMESRV_ADDR=your-rocketmq-namesrv:9876
ROCKETMQ_ACL_ENABLE=false
ROCKETMQ_ACL_ACCESS_KEY=
ROCKETMQ_ACL_SECRET_KEY=
```

### 2. 启动服务

启动所有服务（data 目录会自动创建）：

```bash
docker-compose up -d
```

查看服务状态：

```bash
docker-compose ps
```

查看服务日志：

```bash
docker-compose logs -f
```

### 3. 访问服务

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
  - 默认用户名：在 `.env` 中配置的 `GRAFANA_ADMIN_USER`
  - 默认密码：在 `.env` 中配置的 `GRAFANA_ADMIN_PASSWORD`

### 4. 停止服务

```bash
docker-compose down
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

### Prometheus

- 端口：9090
- 数据保留：15天
- 采集间隔：15秒
- 监控目标：
  - Prometheus 自身
  - Redis Exporter
  - RocketMQ Exporter

### Grafana

- 端口：3000
- 已自动配置 Prometheus 数据源
- 数据持久化存储

### Redis Exporter

- 端口：9121（内部）
- 监控指定的 Redis 实例

### RocketMQ Exporter

- 端口：5557（内部）
- 监控指定的 RocketMQ 集群

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
   - 所有服务在同一个 Docker 网络中
   - 确保能够访问配置的 Redis 和 RocketMQ 服务

## 常见问题

### 1. Grafana 无法连接 Prometheus

检查 Prometheus 服务是否正常运行：
```bash
docker-compose logs prometheus
```

### 2. Exporter 无法连接目标服务

- 检查 `.env` 中的配置是否正确
- 确保目标服务（Redis/RocketMQ）网络可达
- 查看 exporter 日志：
  ```bash
  docker-compose logs redis-exporter
  docker-compose logs rocketmq-exporter
  ```

### 3. 数据丢失

- 确保 `data/` 目录有正确的权限
- 定期备份 `data/` 目录

## 许可证

MIT

# monitoring-mq-redis
