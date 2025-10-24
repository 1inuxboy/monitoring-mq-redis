#!/bin/bash
###
# @Author              : Lihang
# @Date                : 2025-10-24 10:29:57
# @Description         : 初始化数据目录
# @Email               : lihang818@foxmail.com
 # @LastEditTime        : 2025-10-24 10:58:06
### 
mkdir -p data/grafana data/prometheus

chown -R 472:472 data/grafana
chown -R 65534:65534 data/prometheus
chmod -R 755 data/grafana    # rwxr-xr-x - 目录和可执行文件
chmod -R 755 data/prometheus # rwxr-xr-x - 目录和可执行文件
