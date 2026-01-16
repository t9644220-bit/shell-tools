\# Docker Tools



\[!\[Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/docker-tools)

\[!\[License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/LICENSE)

\[!\[Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)



Docker 自动化安装、管理和维护工具，支持 Docker Engine、Docker Compose 和 Docker Swarm 的一键部署。



\[English](README\_EN.md) | \[日本語](README\_JA.md)



\## 📋 目录



\- \[功能特性](#功能特性)

\- \[系统要求](#系统要求)

\- \[快速开始](#快速开始)

\- \[安装方式](#安装方式)

\- \[使用说明](#使用说明)

\- \[配置参数](#配置参数)

\- \[常见问题](#常见问题)

\- \[故障排除](#故障排除)

\- \[贡献指南](#贡献指南)

\- \[许可证](#许可证)



\## ✨ 功能特性



\### 核心功能

\- ✅ \*\*一键安装\*\* - 自动化安装 Docker Engine 和 Docker Compose

\- ✅ \*\*在线/离线安装\*\* - 支持在线下载和离线安装包部署

\- ✅ \*\*版本管理\*\* - 支持指定版本安装和版本更新

\- ✅ \*\*集群支持\*\* - 内置 Docker Swarm 集群配置

\- ✅ \*\*完整卸载\*\* - 彻底清理 Docker 相关文件和配置

\- ✅ \*\*自动备份\*\* - 操作前自动备份重要配置文件



\### 系统管理

\- 🔧 自动配置系统内核参数

\- 🔧 自动创建 Docker 用户和用户组

\- 🔧 自动配置环境变量

\- 🔧 自动配置 systemd 服务

\- 🔧 支持开机自启动设置



\### 用户体验

\- 🎨 彩色日志输出，清晰易读

\- 🎨 详细的操作提示和进度显示

\- 🎨 交互式确认，防止误操作

\- 🎨 完善的错误处理和提示



\## 💻 系统要求



\### 支持的操作系统

\- CentOS 7/8/9

\- RHEL 7/8/9

\- Ubuntu 18.04/20.04/22.04

\- Debian 10/11/12

\- openSUSE Leap 15.x/16.x

\- 其他支持 systemd 的 Linux 发行版



\### 支持的 CPU 架构

\- x86\_64 (amd64)

\- aarch64 (arm64) - 部分支持

\- armv7l - 部分支持



\### 系统要求

\- \*\*操作系统\*\*: Linux (内核 3.10+)

\- \*\*权限\*\*: root 或 sudo

\- \*\*磁盘空间\*\*: 至少 10GB 可用空间

\- \*\*内存\*\*: 建议 2GB 以上

\- \*\*依赖工具\*\*: 

&nbsp; - `iptables` (必需)

&nbsp; - `tar` (必需)

&nbsp; - `curl` 或 `wget` (在线安装时必需)



\## 🚀 快速开始



\### 1. 下载脚本



```bash

\# 方式一：使用 git 克隆

git https://git.hty1024.com/HTY1024/shell\_tools.git

cd shell\_tools/docker-tools



\# 方式二：直接下载

wget https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/releases/docker-tools\_v2.0.0.zip

unzip docker-tools\_v2.0.0.zip

```



\### 2. 赋予执行权限



```bash

chmod +x docker-tools.sh

```



\### 3. 执行安装



```bash

\# 使用默认配置安装

sudo ./docker-tools.sh install



\# 或者指定版本安装

sudo ./docker-tools.sh -v 29.1.4 -c v5.0.1 install

```



\### 4. 验证安装



```bash

\# 检查 Docker 版本

docker --version



\# 检查 Docker Compose 版本

docker-compose --version



\# 查看 Docker 信息

docker info

```



\## 📦 安装方式



\### 方式一：在线安装（推荐）



\*\*优点\*\*: 自动下载最新版本，无需准备安装包



```bash

\# 默认安装（Docker 29.1.4 + Compose v5.0.1）

sudo ./docker-tools.sh install



\# 指定版本安装

sudo ./docker-tools.sh -v 29.1.4 -c v5.0.1 install



\# 自定义安装目录

sudo ./docker-tools.sh -i /data/docker/bin -d /data/docker/data install

```



\### 方式二：离线安装



\*\*优点\*\*: 适用于无网络环境或网络受限的服务器



\#### 步骤 1: 准备安装包



在有网络的机器上下载安装包：



```bash

\# 下载 Docker Engine

wget https://download.docker.com/linux/static/stable/x86\_64/docker-29.1.4.tgz



\# 下载 Docker Compose

wget https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86\_64

```



\#### 步骤 2: 上传到目标服务器



```bash

\# 将安装包和脚本上传到同一目录

scp docker-29.1.4.tgz docker-compose-linux-x86\_64 docker-tools.sh user@server:/path/to/dir/

```



\#### 步骤 3: 执行离线安装



```bash

sudo ./docker-tools.sh -p docker-29.1.4.tgz -n docker-compose-linux-x86\_64 install

```



\### 方式三：仅安装 Docker Engine



```bash

\# 只安装 Docker Engine，不安装 Docker Compose

sudo ./docker-tools.sh -a install

```



\### 方式四：仅安装 Docker Compose



```bash

\# 只安装 Docker Compose（需要已安装 Docker Engine）

sudo ./docker-tools.sh -b install

```



\## 📖 使用说明



\### 基本命令



```bash

\# 查看帮助信息

./docker-tools.sh help



\# 查看版本信息

./docker-tools.sh version



\# 安装 Docker

sudo ./docker-tools.sh install



\# 卸载 Docker

sudo ./docker-tools.sh uninstall



\# 更新 Docker

sudo ./docker-tools.sh update



\# 启动 Docker

sudo ./docker-tools.sh start



\# 停止 Docker

sudo ./docker-tools.sh stop



\# 重启 Docker

sudo ./docker-tools.sh restart



\# 设置开机自启

sudo ./docker-tools.sh enable



\# 取消开机自启

sudo ./docker-tools.sh disable



\# 查看 Docker 信息

sudo ./docker-tools.sh info

```



\### 高级用法



\#### 1. 自定义安装目录



```bash

\# 指定安装目录和数据目录

sudo ./docker-tools.sh \\

&nbsp; -i /data/docker/bin \\

&nbsp; -d /data/docker/data \\

&nbsp; install

```



\#### 2. 指定版本安装



```bash

\# 安装特定版本的 Docker 和 Compose

sudo ./docker-tools.sh \\

&nbsp; -v 28.2.1 \\

&nbsp; -c v2.36.2 \\

&nbsp; install

```



\#### 3. 离线安装



```bash

\# 使用本地安装包进行离线安装

sudo ./docker-tools.sh \\

&nbsp; -p docker-29.1.4.tgz \\

&nbsp; -n docker-compose-linux-x86\_64 \\

&nbsp; install

```



\#### 4. Docker Swarm 集群部署



\*\*Manager 节点（主节点）\*\*:



```bash

\# 安装 Docker 并初始化 Swarm Manager

sudo ./docker-tools.sh -s install



\# 安装完成后，获取 Worker Token

docker swarm join-token worker

\# 输出示例：

\# docker swarm join --token SWMTKN-1-xxx... 192.168.1.100:2377

```



\*\*Worker 节点（工作节点）\*\*:



```bash

\# 使用 Manager 的 IP 和 Token 加入集群

sudo ./docker-tools.sh \\

&nbsp; -s \\

&nbsp; -r worker \\

&nbsp; -m 192.168.1.100 \\

&nbsp; -t SWMTKN-1-xxx... \\

&nbsp; install

```



\#### 5. 更新 Docker 版本



```bash

\# 在线更新到指定版本

sudo ./docker-tools.sh -v 29.1.4 update



\# 离线更新

sudo ./docker-tools.sh -p docker-29.1.4.tgz update

```



\## ⚙️ 配置参数



\### 命令行参数



| 参数 | 说明 | 默认值 | 示例 |

|------|------|--------|------|

| `-v` | Docker Engine 版本 | 29.1.4 | `-v 28.2.1` |

| `-i` | Docker 安装目录 | /opt/docker/bin | `-i /data/docker/bin` |

| `-d` | Docker 数据目录 | /opt/docker/data | `-d /data/docker/data` |

| `-p` | Docker Engine 安装包名称（离线） | - | `-p docker-29.1.4.tgz` |

| `-c` | Docker Compose 版本 | v5.0.1 | `-c v2.36.2` |

| `-n` | Docker Compose 安装包名称（离线） | - | `-n docker-compose-linux-x86\_64` |

| `-a` | 仅安装 Docker Engine | false | `-a` |

| `-b` | 仅安装 Docker Compose | false | `-b` |

| `-s` | 启用 Docker Swarm | false | `-s` |

| `-r` | Swarm 角色 (manager/worker) | manager | `-r worker` |

| `-m` | Swarm Manager IP | 127.0.0.1 | `-m 192.168.1.100` |

| `-t` | Swarm Token (worker 节点必需) | - | `-t SWMTKN-1-xxx...` |



\### 脚本内配置



可以直接修改脚本中的配置变量：



```bash

\# 编辑脚本

vim docker-tools.sh



\# 修改以下变量

DOCKER\_VERSION=29.1.4              # Docker 版本

DOCKER\_INSTALL\_DIR=/opt/docker/bin # 安装目录

DOCKER\_DATA\_DIR=/opt/docker/data   # 数据目录

NEED\_ENABLE\_DOCKER=true            # 是否开机自启

```



\### Docker Daemon 配置



默认配置文件 `daemon.json`:



```json

{

&nbsp; "data-root": "{{DOCKER\_DATA\_DIR}}",

&nbsp; "storage-driver": "overlay2",

&nbsp; "log-driver": "json-file",

&nbsp; "log-opts": {

&nbsp;   "max-size": "100m",

&nbsp;   "max-file": "3"

&nbsp; },

&nbsp; "live-restore": {{DOCKER\_LIVE\_RESTORE}},

&nbsp; "registry-mirrors": \[],

&nbsp; "insecure-registries": \[]

}

```



可以根据需要修改配置：



```bash

\# 编辑配置文件

vim daemon.json



\# 添加镜像加速器

"registry-mirrors": \[

&nbsp; "https://mirror.ccs.tencentyun.com",

&nbsp; "https://docker.mirrors.ustc.edu.cn"

]



\# 添加私有仓库

"insecure-registries": \[

&nbsp; "192.168.1.100:5000"

]

```



\## ❓ 常见问题



\### Q1: 安装失败，提示缺少依赖



\*\*A\*\*: 请先安装必要的依赖工具：



```bash

\# CentOS/RHEL

sudo yum install -y iptables tar curl



\# Ubuntu/Debian

sudo apt-get install -y iptables tar curl



\# openSUSE

sudo zypper install -y iptables tar curl

```



\### Q2: 环境变量不生效



\*\*A\*\*: 安装完成后需要手动执行：



```bash

source ~/.bashrc

source /etc/profile



\# 或者重新登录系统

```



\### Q3: Docker 服务启动失败



\*\*A\*\*: 检查日志查找原因：



```bash

\# 查看服务状态

sudo systemctl status docker



\# 查看详细日志

sudo journalctl -u docker -n 50



\# 检查配置文件

sudo docker info

```



\### Q4: 离线安装时找不到安装包



\*\*A\*\*: 确保安装包与脚本在同一目录：



```bash

\# 检查文件

ls -lh docker-\*.tgz docker-compose-\*



\# 确保文件名正确

./docker-tools.sh -p docker-29.1.4.tgz -n docker-compose-linux-x86\_64 install

```



\### Q5: 卸载后仍有残留文件



\*\*A\*\*: 手动清理残留：



```bash

\# 删除数据目录

sudo rm -rf /opt/docker

sudo rm -rf /var/lib/docker



\# 删除配置文件

sudo rm -rf /etc/docker



\# 删除环境变量配置

vim ~/.bashrc  # 删除 Docker Env 相关行

vim /etc/profile

```



\### Q6: Docker Swarm 加入失败



\*\*A\*\*: 检查网络和防火墙：



```bash

\# 检查端口连通性

telnet <manager-ip> 2377



\# 开放必要端口（Manager 节点）

sudo firewall-cmd --permanent --add-port=2377/tcp  # 集群管理

sudo firewall-cmd --permanent --add-port=7946/tcp  # 节点通信

sudo firewall-cmd --permanent --add-port=7946/udp

sudo firewall-cmd --permanent --add-port=4789/udp  # overlay 网络

sudo firewall-cmd --reload



\# 或者临时关闭防火墙测试

sudo systemctl stop firewalld

```



\### Q7: 权限不足错误



\*\*A\*\*: 确保使用 root 权限：



```bash

\# 使用 sudo

sudo ./docker-tools.sh install



\# 或切换到 root 用户

su -

./docker-tools.sh install

```



\### Q8: 更新后版本不正确



\*\*A\*\*: 清理缓存并重新安装：



```bash

\# 完全卸载

sudo ./docker-tools.sh uninstall



\# 清理缓存

sudo rm -rf /tmp/docker-\*



\# 重新安装

sudo ./docker-tools.sh -v 29.1.4 install

```



\## 🔧 故障排除



\### 日志位置



```bash

\# 系统日志

sudo journalctl -u docker -f



\# Docker 日志

sudo tail -f /var/log/docker.log



\# 脚本日志（如果配置了）

sudo tail -f /var/log/docker-tools.log

```



\### 常见错误及解决方案



\#### 错误 1: "Cannot connect to the Docker daemon"



```bash

\# 检查服务状态

sudo systemctl status docker



\# 启动服务

sudo systemctl start docker



\# 检查 socket

sudo systemctl status docker.socket

```



\#### 错误 2: "permission denied while trying to connect"



```bash

\# 将当前用户添加到 docker 组

sudo usermod -aG docker $USER



\# 重新登录或执行

newgrp docker

```



\#### 错误 3: "Error response from daemon: conflict"



```bash

\# 清理冲突的容器/网络

docker system prune -a



\# 或手动删除

docker rm -f $(docker ps -aq)

docker network prune

```



\#### 错误 4: "no space left on device"



```bash

\# 检查磁盘空间

df -h



\# 清理 Docker 数据

docker system prune -a --volumes



\# 修改数据目录

sudo ./docker-tools.sh -d /data/docker/data install

```



\### 性能优化



\#### 1. 调整存储驱动



```bash

\# 编辑 daemon.json

sudo vim /etc/docker/daemon.json



\# 修改存储驱动

{

&nbsp; "storage-driver": "overlay2",

&nbsp; "storage-opts": \[

&nbsp;   "overlay2.override\_kernel\_check=true"

&nbsp; ]

}



\# 重启 Docker

sudo systemctl restart docker

```



\#### 2. 配置日志轮转



```bash

\# 编辑 daemon.json

{

&nbsp; "log-driver": "json-file",

&nbsp; "log-opts": {

&nbsp;   "max-size": "50m",

&nbsp;   "max-file": "5"

&nbsp; }

}

```



\#### 3. 调整并发限制



```bash

\# 编辑 daemon.json

{

&nbsp; "max-concurrent-downloads": 10,

&nbsp; "max-concurrent-uploads": 10

}

```



\## 📁 文件结构



```

docker-tools/

├── docker-tools.sh          # 主脚本

├── daemon.json              # Docker daemon 配置模板

├── docker.service           # systemd 服务文件

├── docker.socket            # systemd socket 文件

├── README.md                # 中文文档

├── README\_EN.md             # 英文文档

└── README\_JA.md             # 日文文档

```



\## 🔒 安全建议



1\. \*\*最小权限原则\*\*: 仅在必要时使用 root 权限

2\. \*\*定期更新\*\*: 及时更新 Docker 到最新稳定版本

3\. \*\*网络隔离\*\*: 使用防火墙限制 Docker API 访问

4\. \*\*镜像安全\*\*: 只使用可信的镜像源

5\. \*\*日志审计\*\*: 启用日志记录并定期审查

6\. \*\*资源限制\*\*: 为容器设置 CPU 和内存限制



```bash

\# 限制容器资源

docker run -d \\

&nbsp; --cpus="1.5" \\

&nbsp; --memory="512m" \\

&nbsp; --memory-swap="1g" \\

&nbsp; nginx

```



\## 👤 作者



\*\*HTY1024\*\*



\- Git: \[@HTY1024](https://git.hty1024.com/HTY1024)



\## 🙏 致谢



感谢以下项目和资源：



\- \[Docker](https://www.docker.com/)

\- \[Docker Compose](https://docs.docker.com/compose/)

\- \[Docker Swarm](https://docs.docker.com/engine/swarm/)



\[返回顶部](#docker-tools)

