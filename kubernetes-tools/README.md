# Kubernetes Tools

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/kubernetes-tools)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Kubernetes 集群自动化安装、管理和维护工具。基于 **kubeadm + containerd**，用静态二进制包安装，支持单节点、一主多从和高可用集群，也支持在线和离线安装。

[English](README_EN.md) | [日本語](README_JA.md)

> 设计方案与代码结构见 [DESIGN.md](DESIGN.md)。

## 📋 目录

- [功能特性](#-功能特性)
- [系统要求](#-系统要求)
- [快速开始](#-快速开始)
- [部署场景](#-部署场景)
- [命令说明](#-命令说明)
- [配置参数](#️-配置参数)
- [日常运维](#-日常运维)
- [常见问题](#-常见问题)
- [故障排除](#-故障排除)
- [文件结构](#-文件结构)
- [更新日志](#-更新日志)

## ✨ 功能特性

### 核心功能
- ✅ **一键部署**：一条命令完成组件安装和集群初始化或加入
- ✅ **在线/离线安装**：`download` 打包安装包，`save-images` 导出镜像，内网环境同样可用
- ✅ **多种拓扑**：单节点、一主多从，以及带负载均衡入口的多控制平面高可用集群
- ✅ **网络插件**：内置 Flannel（默认）和 Calico，也可以选 `none` 自行安装
- ✅ **版本升级**：按 kubeadm 官方流程逐个次版本升级，自动判断用 `upgrade apply` 还是 `upgrade node`
- ✅ **完整卸载**：退出集群并清理程序、数据、系统配置，恢复 swap 挂载

### 系统管理
- 🔧 自动关闭 swap，加载 `overlay` 和 `br_netfilter` 模块，配置内核参数
- 🔧 自动把 SELinux 设为 permissive（RHEL 系）
- 🔧 自动生成 containerd 配置（systemd cgroup、pause 镜像、数据目录、镜像加速）
- 🔧 自动配置 systemd 服务、环境变量和 kubectl
- 🔧 所有安装包都做 SHA256 校验

### 用户体验
- 🎨 彩色日志输出，与 docker-tools 风格一致
- 🎨 执行前展示参数并要求确认（`-y` 跳过确认，便于自动化）
- 🎨 安装完成后打印可直接复制的节点加入命令
- 🎨 依赖缺失时给出对应发行版的安装命令

## 💻 系统要求

### 支持的操作系统

| 发行版 | 版本 | 说明 |
|---|---|---|
| RHEL / CentOS Stream / Rocky / AlmaLinux | 8、9、10 | 自动把 SELinux 设为 permissive |
| Fedora | 较新版本 | 需手动关闭 zram swap（见 [Q3](#q3-提示-swap-仍处于启用状态)） |
| Ubuntu | 20.04、22.04、24.04 | |
| Debian | 11、12、13 | |
| openSUSE Leap / SLES | 15.x、16.x | |

其他使用 systemd 的发行版通常也能用。不支持不使用 systemd 的发行版（如 Alpine）。

### 硬件与环境

| 项目 | 要求 |
|---|---|
| CPU 架构 | x86_64（amd64）、aarch64（arm64） |
| CPU / 内存 | 控制平面至少 2 核 2GB，工作节点至少 1 核 1GB |
| 权限 | root（`help`、`version`、`download` 除外） |
| 网络 | 节点之间网络互通；主机名唯一，且符合 RFC 1123（小写字母、数字、`-`、`.`） |
| 依赖命令 | `tar` `iptables` `conntrack` `socat` `ip` `mount` `nsenter` `modprobe` `sysctl` `sha256sum`，在线安装还需要 `curl` |

依赖安装示例：

```bash
# RHEL / CentOS / Rocky / Alma / Fedora
dnf install -y tar iptables conntrack-tools socat iproute util-linux kmod curl

# Debian / Ubuntu
apt-get install -y tar iptables conntrack socat iproute2 util-linux kmod curl

# openSUSE / SLES
zypper install -y tar iptables conntrack-tools socat iproute2 util-linux kmod curl
```

> 缺少依赖时，脚本会直接列出缺少的命令和对应的安装命令。

### 默认组件版本

| 组件 | 版本 |
|---|---|
| Kubernetes（kubeadm / kubelet / kubectl） | 1.37.1（可用 `-v` 指定） |
| containerd | 2.4.2 |
| runc | 1.5.2 |
| CNI plugins | 1.9.1 |
| crictl | 1.37.0 |
| Flannel | 0.28.10 |
| Calico | 3.33.0 |

## 🚀 快速开始

### 1. 获取工具

```bash
# 方式一：使用 git 克隆
git clone https://git.hty1024.com/HTY1024/shell_tools.git
cd shell_tools/kubernetes-tools

# 方式二：下载发布包
wget https://git.hty1024.com/HTY1024/shell_tools/raw/branch/main/releases/kubernetes-tools_v1.0.0.zip
unzip kubernetes-tools_v1.0.0.zip -d kubernetes-tools && cd kubernetes-tools
```

### 2. 赋予执行权限

```bash
chmod +x kubernetes-tools
```

### 3. 安装单节点集群

```bash
# -u：允许在控制平面节点调度 Pod（单节点集群需要）
sudo ./kubernetes-tools -u install
```

安装过程：环境校验 → 展示参数并确认 → 下载并校验安装包 → 配置系统 → 安装 containerd 和 Kubernetes 组件 → `kubeadm init` → 配置 kubectl → 安装网络插件 → 等待节点就绪 → 打印节点加入命令。

### 4. 验证安装

```bash
source ~/.bashrc
kubectl get nodes -o wide
kubectl get pods -A
```

## 🧭 部署场景

### 场景一：单节点集群（开发/测试）

```bash
sudo ./kubernetes-tools -u install
```

### 场景二：一主多从

**控制平面节点**（例如 `192.168.1.10`）：

```bash
sudo ./kubernetes-tools install
```

安装完成后会输出类似下面的加入命令（之后也可以随时执行 `./kubernetes-tools token` 重新生成）：

```text
Worker 节点（Token 有效期 24 小时）：
  kubernetes-tools -r worker -m 192.168.1.10:6443 -t abcdef.0123456789abcdef -s sha256:1234...cdef install
```

**工作节点**：把工具目录拷贝到工作节点，执行上面的命令：

```bash
sudo ./kubernetes-tools -r worker -m 192.168.1.10:6443 \
  -t abcdef.0123456789abcdef \
  -s sha256:1234...cdef \
  install
```

回到控制平面节点，执行 `kubectl get nodes` 查看节点状态。

### 场景三：高可用集群（多控制平面）

高可用集群需要先准备一个**负载均衡入口**（如 HAProxy + Keepalived 的 VIP，或云厂商负载均衡），把 `VIP:6443` 转发到所有控制平面节点的 `6443` 端口。本工具不负责部署负载均衡。

> 初始化第一个控制平面之前，负载均衡就需要能把流量转发到该节点，否则 `kubeadm init` 会失败。

**第一个控制平面节点**：

```bash
sudo ./kubernetes-tools -e 192.168.1.100:6443 install
```

`-e` 会让 kubeadm 上传控制平面证书，输出中会多出控制平面的加入命令：

```text
控制平面节点（证书密钥有效期 2 小时）：
  kubernetes-tools -r control-plane -m 192.168.1.100:6443 -t ... -s sha256:... -c <证书密钥> install
```

**其他控制平面节点**：

```bash
sudo ./kubernetes-tools -r control-plane -m 192.168.1.100:6443 \
  -t abcdef.0123456789abcdef -s sha256:1234...cdef -c 0a1b...9f \
  install
```

**工作节点**：与场景二相同，`-m` 填写负载均衡地址。

> 建议控制平面节点数为奇数（3 或 5），保证 etcd 选举正常。所有控制平面节点的数据目录（`-d`）需保持一致。

### 场景四：离线安装（内网环境）

**步骤 1：在联网机器上下载安装包**（无需 root，任意 Linux 均可）

```bash
./kubernetes-tools download                  # 本机架构 + Flannel
./kubernetes-tools -n calico download        # 使用 Calico
./kubernetes-tools -b arm64 download         # 下载 arm64 安装包
./kubernetes-tools -v 1.37.2 download        # 指定 Kubernetes 版本
```

安装包保存在 `packages/` 目录。每个包旁边有一个 `.sha256` 文件，离线安装时用来校验。

**步骤 2：在联网机器上导出镜像包**（需要先装好组件，如 `-a install`）

```bash
sudo ./kubernetes-tools -a install           # 仅安装组件，不初始化集群
sudo ./kubernetes-tools save-images          # 导出到 packages/k8s-images-v<版本>-<网络插件>-linux-<架构>.tar
sudo ./kubernetes-tools -b arm64 save-images # 导出 arm64 镜像
```

镜像包包含 Kubernetes 组件镜像（apiserver、controller-manager、scheduler、proxy、coredns、etcd、pause）和网络插件镜像。

**步骤 3：拷贝到目标服务器并离线安装**

```bash
scp -r kubernetes-tools/ root@192.168.1.10:/root/
ssh root@192.168.1.10
cd /root/kubernetes-tools
./kubernetes-tools -o install                # 控制平面
./kubernetes-tools -o -r worker -m 192.168.1.10:6443 -t ... -s ... install   # 工作节点
```

> `-v`、`-n`、`-g` 需与执行 `download` 和 `save-images` 时一致，否则会找不到对应的安装包。
> 如果内网有私有镜像仓库，也可以不导出镜像包，改用 `-g` 指向私有仓库，并提前把镜像推送进去。

### 场景五：国内网络环境

```bash
sudo ./kubernetes-tools \
  -g registry.aliyuncs.com/google_containers \
  -w docker.io=https://docker.1ms.run,ghcr.io=https://ghcr.nju.edu.cn,quay.io=https://quay.nju.edu.cn \
  install
```

- `-g`：Kubernetes 组件镜像（含 pause）使用的仓库
- `-w`：containerd 镜像加速，写入 `/etc/containerd/certs.d/<仓库>/hosts.toml`。同一仓库可以配置多个加速地址，按顺序尝试
- `dl.k8s.io` 和 `github.com` 下载慢时，可以在网络较好的机器上执行 `download`，再走离线安装

> 镜像加速地址的可用性会变化，请使用当前可用的地址。工作节点的 `-g`、`-w` 应与控制平面一致。

### 场景六：分步安装（先装组件，后建集群）

```bash
sudo ./kubernetes-tools -a install                       # 所有节点：仅安装组件
sudo ./kubernetes-tools init                             # 控制平面：初始化集群
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # 工作节点：加入集群
```

## 📖 命令说明

```text
kubernetes-tools 参数 选项
```

| 选项 | 说明 | 适用节点 |
|---|---|---|
| `help` | 查看帮助信息（不带选项时默认） | 任意 |
| `version` | 查看工具版本 | 任意 |
| `download` | 下载离线安装包到安装包目录（无需 root） | 任意联网机器 |
| `save-images` | 拉取并导出离线镜像包 | 已安装组件的联网节点 |
| `install` | 安装组件，并按角色初始化或加入集群 | 所有节点 |
| `init` | 初始化集群 | 已安装组件的控制平面 |
| `join` | 加入集群（需 `-r worker` 或 `-r control-plane`） | 已安装组件的节点 |
| `token` | 生成节点加入命令 | 控制平面 |
| `reset` | 重置节点：退出集群并清理集群数据，保留已安装组件 | 所有节点 |
| `uninstall` | 卸载：退出集群并删除所有文件 | 所有节点 |
| `update` | 升级 Kubernetes 版本 | 所有节点 |
| `start` / `stop` / `restart` | 启动、停止、重启 containerd 和 kubelet | 所有节点 |
| `enable` / `disable` | 设置或取消 containerd、kubelet 开机自启动 | 所有节点 |
| `info` | 查看组件版本、服务状态、节点和 Pod 信息 | 所有节点 |

## ⚙️ 配置参数

### 命令行参数

| 参数 | 说明 | 默认值 | 示例 |
|---|---|---|---|
| `-v` | Kubernetes 版本 | 1.37.1 | `-v 1.37.2` |
| `-i` | 安装目录（程序在 `bin/`，配置在 `conf/`） | /opt/kubernetes | `-i /data/kubernetes` |
| `-d` | 数据目录（containerd 数据在 `containerd/`，etcd 数据在 `etcd/`） | /opt/kubernetes/data | `-d /data/kubernetes/data` |
| `-k` | 安装包目录 | 脚本同级 `packages/` | `-k /mnt/usb/packages` |
| `-o` | 离线安装 | 在线 | `-o` |
| `-b` | 安装包架构（仅 `download`、`save-images` 使用） | 本机架构 | `-b arm64` |
| `-r` | 节点角色：`master`、`worker`、`control-plane` | master | `-r worker` |
| `-a` | 仅安装组件，不初始化或加入集群 | 否 | `-a` |
| `-l` | 本机通信地址（advertise address） | 自动探测 | `-l 192.168.1.10` |
| `-e` | 控制平面统一入口（高可用） | 无 | `-e 192.168.1.100:6443` |
| `-m` | 要加入的集群 API Server 地址（未写端口时默认 6443） | 无 | `-m 192.168.1.10` |
| `-t` | 加入集群的 Token | 无 | `-t abcdef.0123456789abcdef` |
| `-s` | CA 证书哈希（可省略 `sha256:` 前缀） | 无 | `-s sha256:1234...` |
| `-c` | 加入控制平面的证书密钥 | 无 | `-c 0a1b...` |
| `-n` | 网络插件：`flannel`、`calico`、`none` | flannel | `-n calico` |
| `-p` | Pod 网段 | 10.244.0.0/16 | `-p 172.16.0.0/16` |
| `-x` | Service 网段 | 10.96.0.0/12 | `-x 10.100.0.0/16` |
| `-g` | Kubernetes 镜像仓库 | registry.k8s.io | `-g registry.aliyuncs.com/google_containers` |
| `-w` | 镜像加速（`仓库=地址`，多个用逗号分隔） | 无 | `-w docker.io=https://docker.1ms.run` |
| `-u` | 允许控制平面调度 Pod（单节点集群） | 否 | `-u` |
| `-y` | 跳过交互确认 | 否 | `-y` |

> 角色说明：`master` 初始化新集群（第一个控制平面）；`worker` 作为工作节点加入；`control-plane` 作为额外的控制平面节点加入高可用集群。

### 脚本内配置

不常用的配置可以直接改脚本开头的变量：

```bash
vim kubernetes-tools

CONTAINERD_VERSION=2.4.2           # containerd 版本
RUNC_VERSION=1.5.2                 # runc 版本
CNI_PLUGINS_VERSION=1.9.1          # CNI 插件版本
CRICTL_VERSION=1.37.0              # crictl 版本
FLANNEL_VERSION=0.28.10            # Flannel 版本
CALICO_VERSION=3.33.0              # Calico 版本
KUBE_PROXY_MODE=iptables           # kube-proxy 模式：iptables、ipvs、nftables
NEED_DISABLE_SWAP=true             # 是否关闭 swap
KUBEADM_IGNORE_PREFLIGHT_ERRORS="" # 忽略的 kubeadm 预检错误，如 NumCPU,Mem
K8S_PACKAGE_URL=https://dl.k8s.io/release   # 各组件下载地址（可改为内网镜像站）
```

> 新内核建议用 `nftables` 模式。`ipvs` 模式自 Kubernetes 1.35 起已弃用。

### kubeadm 配置模板

`kubeadm-config.yaml` 是 `kubeadm init` 的配置模板，`{{...}}` 为占位符。可以在模板中加入其他 kubeadm 字段，例如给 API Server 证书加上额外的 SAN：

```yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
...
apiServer:
  certSANs:
    - k8s.example.com
    - 192.168.1.100
```

渲染后的配置保存在 `<安装目录>/conf/kubeadm-config.yaml`，初始化日志保存在 `<安装目录>/conf/kubeadm-init.log`（含 Token，仅 root 可读）。

## 🛠 日常运维

### 添加节点

```bash
# 控制平面：生成新的加入命令（Token 默认有效期 24 小时）
sudo ./kubernetes-tools token

# 新节点：执行输出的命令
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... install
```

### 删除节点

```bash
# 控制平面：驱逐 Pod 并删除节点
kubectl drain <节点名> --ignore-daemonsets --delete-emptydir-data
kubectl delete node <节点名>

# 被删除的节点：退出集群（保留组件）或完全卸载
sudo ./kubernetes-tools reset
sudo ./kubernetes-tools uninstall
```

### 升级 Kubernetes

kubeadm 只支持**逐个次版本**升级（例如 1.36.x → 1.37.x），不支持降级。升级顺序：**第一个控制平面 → 其他控制平面 → 工作节点**，一次升级一个节点。

```bash
# 1. （控制平面执行）驱逐要升级节点上的 Pod
kubectl drain <节点名> --ignore-daemonsets

# 2. （被升级节点执行）升级
sudo ./kubernetes-tools -v 1.37.2 update            # 在线
sudo ./kubernetes-tools -o -v 1.37.2 update         # 离线（需提前 download / save-images）

# 3. （控制平面执行）恢复调度
kubectl uncordon <节点名>
```

脚本按以下规则判断升级方式：
- 控制平面节点上，如果集群版本还不是目标版本，说明这是第一个升级的控制平面，执行 `kubeadm upgrade plan` 和 `kubeadm upgrade apply`
- 其他控制平面节点和工作节点执行 `kubeadm upgrade node`
- 升级前，旧的 kubeadm、kubelet、kubectl 会备份到 `<安装目录>/backup/<时间>/`

> `update` 只升级 Kubernetes 组件。containerd、runc 需要升级时请手动替换：先 `kubectl drain` 节点，再执行 `stop`，把新版本解压覆盖到 `<安装目录>/bin`，然后执行 `start` 和 `kubectl uncordon`。

### 证书管理

kubeadm 签发的证书有效期为 1 年。执行 `update` 时会自动续期。

```bash
kubeadm certs check-expiration   # 查看证书有效期
kubeadm certs renew all          # 手动续期全部证书，之后需重启控制平面组件
```

### 服务管理

```bash
sudo ./kubernetes-tools start      # 启动 containerd、kubelet
sudo ./kubernetes-tools stop       # 停止 kubelet、containerd
sudo ./kubernetes-tools restart    # 重启
sudo ./kubernetes-tools enable     # 开机自启
sudo ./kubernetes-tools disable    # 取消开机自启
sudo ./kubernetes-tools info       # 查看信息
```

> `stop` 不会停止已运行的容器。containerd 使用 `KillMode=process`，这是 Kubernetes 的标准做法。

### 卸载

```bash
sudo ./kubernetes-tools uninstall
# 使用了自定义目录时需同时指定
sudo ./kubernetes-tools -i /data/kubernetes -d /data/kubernetes/data uninstall
```

卸载会执行 `kubeadm reset`，停止并删除服务，并删除以下内容：安装目录、数据目录、`/etc/kubernetes`、`/var/lib/kubelet`、`/etc/containerd`、`/etc/cni`、`/opt/cni/bin`、`~/.kube/config`、环境变量、内核参数文件。安装时注释掉的 swap 挂载也会恢复。

以下内容不会处理：已安装的系统依赖、SELinux 设置、iptables 规则（清理命令见卸载时的提示）、`packages/` 安装包目录。

## ❓ 常见问题

### Q1: 提示缺少依赖命令

按提示中的命令安装即可，例如：

```bash
dnf install -y conntrack-tools socat
```

### Q2: 环境变量不生效，找不到 kubectl

```bash
source ~/.bashrc
source /etc/profile
# 或者重新登录
```

### Q3: 提示 swap 仍处于启用状态

Fedora 等发行版默认用 zram 创建 swap：

```bash
swapoff -a
dnf remove -y zram-generator-defaults   # 或者 touch /etc/systemd/zram-generator.conf
```

### Q4: 拉取镜像失败（ImagePull / ErrImagePull）

- Kubernetes 组件镜像：用 `-g registry.aliyuncs.com/google_containers` 换成可访问的仓库
- 网络插件镜像（ghcr.io / quay.io / docker.io）：用 `-w` 配置镜像加速，或者用离线镜像包
- 查看具体错误：`crictl pull <镜像>`、`journalctl -u containerd -n 50`

### Q5: 节点一直处于 NotReady

```bash
kubectl get pods -n kube-flannel -o wide       # Flannel
kubectl get pods -n kube-system -l k8s-app=calico-node   # Calico
kubectl describe node <节点名>
```

常见原因：网络插件镜像拉取失败；Pod 网段与节点网段重叠（用 `-p` 修改）；防火墙拦截了 Flannel 的 8472/udp 或 Calico 的 179/tcp。

### Q6: Token 过期，无法加入集群

Token 默认 24 小时过期，证书密钥 2 小时过期。在控制平面上重新生成：

```bash
sudo ./kubernetes-tools token
```

### Q7: 初始化或加入失败，如何重试

```bash
sudo ./kubernetes-tools reset     # 清理集群状态（保留已安装组件）
sudo ./kubernetes-tools init      # 控制平面重新初始化
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # 工作节点重新加入
```

### Q8: 提示已存在其他方式安装的 containerd

本工具使用自带的 containerd，与通过 `containerd.io`、`docker-ce` 软件包安装的 containerd 冲突，请先卸载这些软件包。用 docker-tools 安装的 Docker 不冲突：它的 containerd 由 dockerd 内部管理，使用的 socket 也不同。不过同一台机器同时运行 Docker 和 Kubernetes 时，Docker 会把 iptables 的 FORWARD 默认策略设为 DROP，请留意跨节点的 Pod 通信。

### Q9: 机器配置低于 2 核 2GB，预检失败

测试环境可以修改脚本变量：

```bash
KUBEADM_IGNORE_PREFLIGHT_ERRORS=NumCPU,Mem
```

### Q10: 防火墙需要放行哪些端口

| 节点 | 端口 | 用途 |
|---|---|---|
| 控制平面 | 6443/tcp | API Server |
| 控制平面 | 2379-2380/tcp | etcd |
| 控制平面 | 10257/tcp、10259/tcp | controller-manager、scheduler |
| 所有节点 | 10250/tcp | kubelet |
| 工作节点 | 30000-32767/tcp | NodePort |
| 所有节点 | 8472/udp | Flannel VXLAN |
| 所有节点 | 179/tcp、4789/udp | Calico BGP / VXLAN |

```bash
# firewalld 示例（控制平面）
firewall-cmd --permanent --add-port={6443,2379-2380,10250,10257,10259}/tcp --add-port=8472/udp
firewall-cmd --reload
```

## 🔧 故障排除

### 日志位置

```bash
journalctl -u kubelet -f            # kubelet 日志
journalctl -u containerd -f         # containerd 日志
cat /opt/kubernetes/conf/kubeadm-init.log   # 初始化日志
crictl ps -a                        # 本机容器
crictl logs <容器ID>                # 容器日志
```

脚本本身不写日志文件，运行输出直接打印到终端。需要保存时可以执行 `./kubernetes-tools install 2>&1 | tee install.log`。

### 常见错误

#### 错误 1: `[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]`

`br_netfilter` 模块未加载：

```bash
modprobe br_netfilter
sysctl -p /etc/sysctl.d/kubernetes.conf
```

#### 错误 2: `kubelet` 反复重启

初始化或加入之前 kubelet 反复重启是正常的，它在等待 kubeadm 生成配置。初始化之后仍然如此时：

```bash
journalctl -u kubelet -n 100 --no-pager
```

常见原因：swap 没有关闭；cgroup 驱动不一致（本工具已统一设为 systemd）。

#### 错误 3: `The connection to the server localhost:8080 was refused`

当前用户没有配置 kubeconfig：

```bash
mkdir -p ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config
```

#### 错误 4: `x509: certificate signed by unknown authority`

集群重建后，`~/.kube/config` 还是旧的。重新复制 `/etc/kubernetes/admin.conf`。

## 📁 文件结构

### 工具目录

```text
kubernetes-tools/
├── kubernetes-tools        # 主脚本
├── kubeadm-config.yaml     # kubeadm 配置模板
├── containerd.service      # containerd systemd 服务模板
├── kubelet.service         # kubelet systemd 服务模板
├── 10-kubeadm.conf         # kubelet systemd drop-in 模板（kubeadm 参数）
├── README.md               # 用户手册（中文）
├── README_EN.md            # 用户手册（英文）
├── README_JA.md            # 用户手册（日文）
├── DESIGN.md               # 设计方案
└── packages/               # 安装包目录（download 或在线安装时生成）
```

### 安装后的系统布局（默认路径）

```text
/opt/kubernetes/
├── bin/          # kubeadm kubelet kubectl containerd containerd-shim-runc-v2 ctr runc crictl
├── conf/         # kubeadm-config.yaml、kubeadm-init.log、网络插件清单
├── backup/       # update 时的旧版本备份
└── data/
    ├── containerd/   # containerd 数据（镜像、容器）
    └── etcd/         # etcd 数据（控制平面）
/opt/cni/bin/                         # CNI 插件
/etc/containerd/config.toml           # containerd 配置
/etc/containerd/certs.d/              # 镜像加速配置
/etc/crictl.yaml                      # crictl 配置
/etc/kubernetes/                      # kubeadm 生成的证书和 kubeconfig
/usr/lib/systemd/system/containerd.service
/usr/lib/systemd/system/kubelet.service
/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/sysctl.d/kubernetes.conf
/etc/modules-load.d/kubernetes.conf
```

## 🔒 安全建议

1. **保护凭据**：`/etc/kubernetes/admin.conf` 拥有集群管理员权限，不要外传；Token 和证书密钥用完即可失效
2. **限制 API 访问**：用防火墙或安全组限制 6443 端口的来源
3. **定期升级**：及时升级 Kubernetes 补丁版本，并关注证书有效期
4. **最小权限**：给日常用户创建 RBAC 受限的 kubeconfig，不要直接使用 admin.conf
5. **备份 etcd**：定期备份控制平面的 etcd 数据（`etcdctl snapshot save`）

## 📝 更新日志

### v1.0.0 (2026-10-20)
- 🎉 首个版本
- 基于 kubeadm + containerd 的静态二进制安装，支持 x86_64、aarch64
- 支持单节点、一主多从、高可用（多控制平面）集群
- 支持在线/离线安装：`download` 下载安装包，`save-images` 导出镜像包，安装包均做 SHA256 校验
- 内置 Flannel、Calico 网络插件
- 支持国内镜像仓库（`-g`）和镜像加速（`-w`）
- 支持 `init`、`join`、`token`、`reset`、`update`、`uninstall` 等集群生命周期命令

## 👤 作者

**HTY1024**

- Git: [@HTY1024](https://git.hty1024.com/HTY1024)

## 🙏 致谢

- [Kubernetes](https://kubernetes.io/)
- [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
- [containerd](https://containerd.io/)
- [Flannel](https://github.com/flannel-io/flannel)
- [Calico](https://www.tigera.io/project-calico/)

[返回顶部](#kubernetes-tools)
