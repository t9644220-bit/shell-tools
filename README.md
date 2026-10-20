# Shell 工具集

## 支持的 Linux 发行版

| 工具 | RHEL 系（CentOS / RHEL / Rocky / Alma / Fedora） | SUSE 系（openSUSE / SLES） | Debian 系（Debian / Ubuntu） | 说明 |
|---|---|---|---|---|
| ghd | ✅ | ✅ | ✅ | 仅依赖 `wget` |
| pip | ✅ | ✅ | ✅ | 仅依赖 `curl` |
| dii | ✅ | ✅ | ✅ | 依赖 `skopeo`、`jq` |
| bf | ✅ | ✅ | ✅ | 依赖 `tar`、`openssl` |
| cvs | ✅ | ✅ | ✅ | 自动识别 `yum`、`dnf`、`zypper`、`apt`；RHEL 需可用 EPEL 源 |
| sp | ⚠️ | ✅ | ⚠️ | 依赖 systemd；`/etc/sysconfig/proxy` 仅 SUSE 系提供，其他发行版自动跳过该步骤 |
| docker-tools | ✅ | ✅ | ✅ | 依赖 systemd，仅支持 x86_64、aarch64，详见 [docker-tools/README.md](docker-tools/README.md) |

> ✅：完整支持；⚠️：部分功能不可用（见说明）。不使用 systemd 的发行版（如 Alpine）不支持 `sp`、`docker-tools`。

<br/>

## ghd

    GitHub 文件加速下载工具，支持 `github.com` 和 `raw.githubusercontent.com` 域名。

**所需依赖：**

- 无需依赖，导入后直接使用即可

**参数说明：**

- `$1` ：需要下载的GitHub文件的URL

**使用方式：**

```bash
ghd 需要下载的GitHub文件的URL
```

**示例**：

```bash
ghd https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64
```

<br/>

## dii

    获取 Docker Hub 镜像信息工具

**所需依赖：**

- skopeo（ 通过包管理器直接安装即可，如： `zypper install -y skopeo`、`yum install -y skopeo` 或 `apt-get install -y skopeo` ）
- jq（ 通过包管理器直接安装即可，如： `zypper install -y jq`、`yum install -y jq` 或 `apt-get install -y jq` ）

**参数说明：**

- `$1` ：Docker镜像名称
- `$2` ：是否仅查询镜像Tag

**使用方式：**

- 查询全部信息

```bash
dii Docker镜像名称
```

**示例**：

```bash
dii mysql
```

- 仅查询 Tgs

```bash
dii Docker镜像名称 t
```

**示例**：

```bash
dii mysql t
```

<br/>

## cvs

    使用 ClamAV 扫描病毒工具。

**所需依赖：**

- 无需依赖，导入后直接使用即可

**参数说明：**

- `$1` ： 需要扫描的目录，不配置时默认全盘扫描
- `$2` ： 病毒文件的处理方式，不配置时默认为 `2`
  - `0` ： 不处理；
  - `1` ： 复制到指定目录；
  - `2` ： 移动至指定目录；
  - `3` ： 直接删除（不推荐）
- `$3` ： 工作目录，用于输出日志、存放病毒文件，不配置时默认为 `/opt/clamav` 目录
- `$4` ： 包管理器，支持 `yum`、`dnf`、`zypper`、`apt`，不配置时默认根据操作系统自动选择

**使用方式：**

```bash
cvs 需要扫描的目录 处理方式 工作目录 包管理器
```

**示例**：

- 全盘扫描，使用默认配置
``` bash
cvs
```

- 扫描 HOME 目录，使用默认配置
``` bash
cvs /home
```

- 全盘扫描，不处理病毒文件
``` bash
cvs / 0
```

- 扫描 HOME 目录，不处理病毒文件
``` bash
cvs /home 0
```

- 全盘扫描，将日志文件保存至 `/tmp/clamav` 目录，同时将扫描出的病毒文件也移动至此目录
``` bash
cvs / 2 /tmp/clamav
```

- 扫描 HOME 目录，将日志文件保存至 `/tmp/clamav` 目录，同时将扫描出的病毒文件也移动至此目录
``` bash
cvs /home 2 /tmp/clamav 
```

<br/>

## bf

    备份文件工具。

**所需依赖：**

- openssl（ 通过包管理器直接安装即可，如：`zypper install -y openssl`、`yum install -y openssl` 或 `apt-get install -y openssl` ）
- 如保存备份文件到 Amazon S3 ，则需安装：AWS CLI（ 安装方式请参考官方文档：https://aws.amazon.com/cn/cli ）
- 如保存备份文件到腾讯云 COS，则需安装：coscli（ 安装方式请参考官方文档：https://cloud.tencent.com/document/product/436/63144 ）
- 如保存备份文件到华为云 OBS，则需安装：obsutil（ 安装方式请参考官方文档：https://support.huaweicloud.com/utiltg-obs/obs_11_0003.html ）

**配置说明：**

请参考 `bf` 文件内部说明进行配置

**参数说明：**

- `$1` ： 备份文件名称
- `$2` ： 备份文件路径
- `$3` ： 备份文件加密秘钥路径

**使用方式：**

```bash
bf 备份文件名称 备份文件路径 备份文件加密秘钥路径
```

**示例**：

- 备份 `/opt/gitea` 目录
``` bash
bf gitea /opt/gitea
```

- 备份 `/opt/gitea` 目录，同时使用 `/root/gitea.key` 作为秘钥加密备份文件
``` bash
bf gitea /opt/gitea /root/gitea.key
```

<br/>

## sp

    设置系统代理工具。

**所需依赖：**

- systemd
- 设置用户代理（ `/etc/sysconfig/proxy` ）仅在 openSUSE/SLES 上生效，其他发行版会自动跳过该步骤
- 可重复执行：再次执行会覆盖之前设置的代理配置，不会重复追加；修改前的文件当天首次执行时备份为 `*.bak.日期`

**参数说明：**

- `$1` ： 代理URL

**使用方式：**

```bash
sp 代理URL
```

**示例**： 

- 设置代理为 `192.168.1.100:30000`  
``` bash
sp 192.168.1.100:30000
```

<br/>

## docker-tools

    Docker 工具：以静态二进制包安装、更新、卸载 Docker Engine / Docker Compose，并支持 Docker Swarm。

详细文档见 [docker-tools/README.md](docker-tools/README.md)，发布包见 [releases](releases) 目录。

**所需文件：**

- `docker-tools`、`daemon.json`、`docker.service`、`docker.socket` 需放在同一目录（发布包已包含）
- 离线安装时，安装包也需放在该目录

**使用方式**:  

```
docker-tools 参数 选项
```

**参数说明**：

  - `-v`： Docker 版本（可选，默认安装 29.5.2 版本）
  - `-i`： Docker 安装目录（可选，默认为 /opt/docker，程序位于其下 bin 目录）
  - `-d`： Docker 数据目录（可选，默认为 /opt/docker/data）
  - `-p`： Docker 安装包名称（可选，仅离线安装时使用，默认为在线安装）
  - `-c`： Docker Compose 版本（可选，默认安装 v5.1.4 版本）
  - `-n`： Docker Compose 安装包名称（可选，仅离线安装时使用，默认为在线安装）
  - `-a`： 仅安装 Docker Engine（可选，默认安装 Docker Engine 和 Docker Compose ）
  - `-b`： 仅安装 Docker Compose（可选，默认安装 Docker Engine 和 Docker Compose ）
  - `-s`： 启用 Docker Swarm（可选，默认不启用 ）
  - `-r`： Docker Swarm 角色（可选，默认 manager，可选 manager、worker ）
  - `-m`： Docker Swarm Manager IP（可选，默认 127.0.0.1 ）
  - `-t`： Docker Swarm Token（当角色为 worker 时必选 ）

**选项说明**：

  - `help`： 查看帮助信息（不带选项时默认）
  - `version`： 查看工具版本
  - `install`： 安装 Docker
  - `uninstall`： 卸载 Docker
  - `start`： 启动 Docker
  - `stop`： 停止 Docker
  - `restart`： 重启 Docker
  - `enable`： 设置 Docker 开机自启动
  - `disable`： 取消 Docker 开机自启动
  - `update`： 更新 Docker 版本
  - `swarm`： 设置 Docker Swarm
  - `info`： 查看 Docker 信息

**示例**：

  - 安装 Docker （使用默认配置，在线安装） ： `docker-tools install`
  - 安装 Docker （指定版本在线安装） ： `docker-tools -v 28.2.1 -c v2.36.2 install`
  - 安装 Docker （离线安装） ： `docker-tools -p docker-28.2.1.tgz -n docker-compose-linux-x86_64 install`
  - 安装 Docker （使用自定义目录） ： `docker-tools -i /data/docker -d /data/docker/data install`
  - 安装 Docker （同时作为 manager 节点启用 Swarm） ： `docker-tools -s install`
  - 安装 Docker （同时作为 worker 节点启用 Swarm） ： `docker-tools -s -r worker -m 192.168.0.100 -t SWMTKN-1-xxx install`
  - 安装 Docker （仅安装 Docker Engine） ： `docker-tools -a install`
  - 安装 Docker （仅安装 Docker Compose） ： `docker-tools -b install`
  - 卸载 Docker （使用默认配置） ： `docker-tools uninstall`
  - 卸载 Docker （使用自定义目录） ： `docker-tools -i /data/docker -d /data/docker/data uninstall`
  - 更新 Docker （在线更新到指定版本） ： `docker-tools -v 29.5.2 -c v5.1.4 update`
  - 重启 Docker ： `docker-tools restart`
  - 设置 Docker 开机自启动 ： `docker-tools enable`
  - 取消 Docker 开机自启动 ： `docker-tools disable`
  - 设置 Docker Swarm（manager） ： `docker-tools swarm`
  - 设置 Docker Swarm（worker） ： `docker-tools -r worker -m 192.168.0.100 -t SWMTKN-1-xxx swarm`
  - 查看 Docker 信息 ： `docker-tools info`
