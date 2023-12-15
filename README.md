# Shell 工具集

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

    示例：

```bash
ghd https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64
```

<br/>

## dii

    获取 Docker Hub 镜像信息工具

**所需依赖：**

- skopeo（通过包管理器直接安装即可，如： `zypper install -y skopeo` 或 `yum install -y skopeo`）
- jq（通过包管理器直接安装即可，如： `zypper install -y jq` 或 `yum install -y jq`）

**参数说明：**

- `$1` ：Docker镜像名称
- `$2` ：是否仅查询镜像Tag

**使用方式：**

- 查询全部信息

```bash
dii Docker镜像名称
```

    示例：

```bash
dii mysql
```

- 仅查询 Tgs

```bash
dii Docker镜像名称 t
```

    示例：

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
- `$4` ： 包管理器，支持 `yum`、`zypper`，不配置时默认根据操作系统自动选择

**使用方式：**

```bash
cvs 需要扫描的目录 处理方式 工作目录 包管理器
```

示例：

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

- openssl
- 如保存备份文件到腾讯云 COS，则需安装：coscli
- 如保存备份文件到华为云 OBS，则需安装：obsutil

**参数说明：**

- `$1` ： 备份文件名称
- `$2` ： 备份文件路径
- `$3` ： 备份文件加密秘钥路径

**使用方式：**

```bash
bf 备份文件名称 备份文件路径 备份文件加密秘钥路径
```

示例：

- 备份 `/opt/gitea` 目录
``` bash
bf gitea /opt/gitea
```

- 备份 `/opt/gitea` 目录，同时使用 `/root/gitea.key` 作为秘钥加密备份文件
``` bash
bf gitea /opt/gitea /root/gitea.key
```
