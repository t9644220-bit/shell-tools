# Kubernetes Tools

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/kubernetes-tools)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Automated installation, management, and maintenance tool for Kubernetes clusters. It is built on **kubeadm + containerd**, installs everything from static binaries, supports single-node, one-control-plane-many-workers and highly available clusters, and works both online and offline.

[中文](README.md) | [日本語](README_JA.md)

> For the design and code structure, see [DESIGN.md](DESIGN.md) (Chinese).
>
> Log messages and prompts printed by the tool are in Chinese. Where this manual quotes tool output, an English translation is given alongside.

## 📋 Table of Contents

- [Features](#-features)
- [System Requirements](#-system-requirements)
- [Quick Start](#-quick-start)
- [Deployment Scenarios](#-deployment-scenarios)
- [Commands](#-commands)
- [Configuration](#️-configuration)
- [Operations](#-operations)
- [FAQ](#-faq)
- [Troubleshooting](#-troubleshooting)
- [File Structure](#-file-structure)
- [Changelog](#-changelog)

## ✨ Features

### Core Features
- ✅ **One-command deployment**: installs the components and initializes or joins the cluster in a single command
- ✅ **Online/offline installation**: `download` bundles the packages and `save-images` exports the images, so air-gapped environments work too
- ✅ **Multiple topologies**: single node, one control plane with many workers, and highly available clusters with multiple control planes behind a load balancer
- ✅ **Network plugins**: Flannel (default) and Calico built in, or `none` to install your own
- ✅ **Version upgrades**: follows the official kubeadm process one minor version at a time, and chooses between `upgrade apply` and `upgrade node` automatically
- ✅ **Complete uninstall**: leaves the cluster, removes binaries, data and system configuration, and restores swap entries

### System Management
- 🔧 Disables swap, loads the `overlay` and `br_netfilter` modules, and sets kernel parameters
- 🔧 Sets SELinux to permissive (RHEL family)
- 🔧 Generates the containerd configuration (systemd cgroup, pause image, data directory, registry mirrors)
- 🔧 Configures systemd services, environment variables and kubectl
- 🔧 Verifies every package with SHA256

### User Experience
- 🎨 Colored log output, consistent with docker-tools
- 🎨 Shows the parameters and asks for confirmation before running (`-y` skips confirmation for automation)
- 🎨 Prints ready-to-copy node join commands after installation
- 🎨 Prints the matching install command for your distribution when dependencies are missing

## 💻 System Requirements

### Supported Operating Systems

| Distribution | Versions | Notes |
|---|---|---|
| RHEL / CentOS Stream / Rocky / AlmaLinux | 8, 9, 10 | SELinux is set to permissive automatically |
| Fedora | Recent releases | zram swap must be disabled manually (see [Q3](#q3-swap-is-reported-as-still-enabled)) |
| Ubuntu | 20.04, 22.04, 24.04 | |
| Debian | 11, 12, 13 | |
| openSUSE Leap / SLES | 15.x, 16.x | |

Other distributions that use systemd usually work too. Distributions without systemd (such as Alpine) are not supported.

### Hardware and Environment

| Item | Requirement |
|---|---|
| CPU architecture | x86_64 (amd64), aarch64 (arm64) |
| CPU / memory | At least 2 cores and 2GB for control planes; at least 1 core and 1GB for workers |
| Privileges | root (except `help`, `version` and `download`) |
| Network | Nodes can reach each other; hostnames are unique and follow RFC 1123 (lowercase letters, digits, `-`, `.`) |
| Required commands | `tar` `iptables` `conntrack` `socat` `ip` `mount` `nsenter` `modprobe` `sysctl` `sha256sum`, plus `curl` for online installation |

Installing the dependencies:

```bash
# RHEL / CentOS / Rocky / Alma / Fedora
dnf install -y tar iptables conntrack-tools socat iproute util-linux kmod curl

# Debian / Ubuntu
apt-get install -y tar iptables conntrack socat iproute2 util-linux kmod curl

# openSUSE / SLES
zypper install -y tar iptables conntrack-tools socat iproute2 util-linux kmod curl
```

> When dependencies are missing, the script lists the missing commands together with the install command for your distribution.

### Default Component Versions

| Component | Version |
|---|---|
| Kubernetes (kubeadm / kubelet / kubectl) | 1.37.1 (set with `-v`) |
| containerd | 2.4.2 |
| runc | 1.5.2 |
| CNI plugins | 1.9.1 |
| crictl | 1.37.0 |
| Flannel | 0.28.10 |
| Calico | 3.33.0 |

## 🚀 Quick Start

### 1. Get the Tool

```bash
# Option 1: clone with git
git clone https://git.hty1024.com/HTY1024/shell_tools.git
cd shell_tools/kubernetes-tools

# Option 2: download the release package
wget https://git.hty1024.com/HTY1024/shell_tools/raw/branch/main/releases/kubernetes-tools_v1.0.0.zip
unzip kubernetes-tools_v1.0.0.zip -d kubernetes-tools && cd kubernetes-tools
```

### 2. Make It Executable

```bash
chmod +x kubernetes-tools
```

### 3. Install a Single-Node Cluster

```bash
# -u: allow Pods to be scheduled on the control plane (required for a single-node cluster)
sudo ./kubernetes-tools -u install
```

What happens: environment checks → show parameters and confirm → download and verify packages → configure the system → install containerd and the Kubernetes components → `kubeadm init` → configure kubectl → install the network plugin → wait for the node to become Ready → print the node join commands.

### 4. Verify the Installation

```bash
source ~/.bashrc
kubectl get nodes -o wide
kubectl get pods -A
```

## 🧭 Deployment Scenarios

### Scenario 1: Single-Node Cluster (Development/Testing)

```bash
sudo ./kubernetes-tools -u install
```

### Scenario 2: One Control Plane, Multiple Workers

**Control plane node** (for example `192.168.1.10`):

```bash
sudo ./kubernetes-tools install
```

When the installation finishes, it prints a join command like the one below (you can regenerate it at any time with `./kubernetes-tools token`):

```text
Worker 节点（Token 有效期 24 小时）：
  kubernetes-tools -r worker -m 192.168.1.10:6443 -t abcdef.0123456789abcdef -s sha256:1234...cdef install
```

(The first line reads "Worker node (token valid for 24 hours):".)

**Worker nodes**: copy the tool directory to each worker and run the command above:

```bash
sudo ./kubernetes-tools -r worker -m 192.168.1.10:6443 \
  -t abcdef.0123456789abcdef \
  -s sha256:1234...cdef \
  install
```

Back on the control plane, run `kubectl get nodes` to check the nodes.

### Scenario 3: Highly Available Cluster (Multiple Control Planes)

A highly available cluster needs a **load-balanced entry point** first (for example a HAProxy + Keepalived VIP, or a cloud load balancer) that forwards `VIP:6443` to port `6443` on every control plane node. This tool does not deploy the load balancer.

> The load balancer must already forward traffic to the first control plane before you initialize it, otherwise `kubeadm init` fails.

**First control plane node**:

```bash
sudo ./kubernetes-tools -e 192.168.1.100:6443 install
```

`-e` makes kubeadm upload the control plane certificates, and the output includes an extra join command for control planes:

```text
控制平面节点（证书密钥有效期 2 小时）：
  kubernetes-tools -r control-plane -m 192.168.1.100:6443 -t ... -s sha256:... -c <certificate-key> install
```

(The first line reads "Control plane node (certificate key valid for 2 hours):".)

**Other control plane nodes**:

```bash
sudo ./kubernetes-tools -r control-plane -m 192.168.1.100:6443 \
  -t abcdef.0123456789abcdef -s sha256:1234...cdef -c 0a1b...9f \
  install
```

**Worker nodes**: same as Scenario 2, with `-m` set to the load balancer address.

> Use an odd number of control plane nodes (3 or 5) so etcd can elect a leader. All control plane nodes must use the same data directory (`-d`).

### Scenario 4: Offline Installation (Air-Gapped Network)

**Step 1: download the packages on a machine with internet access** (no root needed, any Linux works)

```bash
./kubernetes-tools download                  # host architecture + Flannel
./kubernetes-tools -n calico download        # use Calico
./kubernetes-tools -b arm64 download         # download arm64 packages
./kubernetes-tools -v 1.37.2 download        # specific Kubernetes version
```

Packages are saved to the `packages/` directory. Each package has a `.sha256` file next to it, which is used for verification during offline installation.

**Step 2: export the images on a machine with internet access** (the components must be installed first, for example with `-a install`)

```bash
sudo ./kubernetes-tools -a install           # install components only, do not initialize a cluster
sudo ./kubernetes-tools save-images          # exports to packages/k8s-images-v<version>-<network-plugin>-linux-<arch>.tar
sudo ./kubernetes-tools -b arm64 save-images # export arm64 images
```

The image archive contains the Kubernetes component images (apiserver, controller-manager, scheduler, proxy, coredns, etcd, pause) and the network plugin images.

**Step 3: copy everything to the target server and install offline**

```bash
scp -r kubernetes-tools/ root@192.168.1.10:/root/
ssh root@192.168.1.10
cd /root/kubernetes-tools
./kubernetes-tools -o install                # control plane
./kubernetes-tools -o -r worker -m 192.168.1.10:6443 -t ... -s ... install   # worker
```

> `-v`, `-n` and `-g` must match the values used for `download` and `save-images`, otherwise the matching packages cannot be found.
> If the internal network has a private registry, you can skip the image archive: point `-g` at the private registry and push the images there beforehand.

### Scenario 5: Networks in Mainland China

```bash
sudo ./kubernetes-tools \
  -g registry.aliyuncs.com/google_containers \
  -w docker.io=https://docker.1ms.run,ghcr.io=https://ghcr.nju.edu.cn,quay.io=https://quay.nju.edu.cn \
  install
```

- `-g`: registry used for the Kubernetes component images (including pause)
- `-w`: containerd registry mirrors, written to `/etc/containerd/certs.d/<registry>/hosts.toml`. A registry can have several mirrors, which are tried in order
- If downloads from `dl.k8s.io` and `github.com` are slow, run `download` on a machine with a better connection and install offline

> Mirror availability changes over time, so use addresses that currently work. Workers should use the same `-g` and `-w` as the control plane.

### Scenario 6: Step-by-Step Installation (Components First, Cluster Later)

```bash
sudo ./kubernetes-tools -a install                       # all nodes: install components only
sudo ./kubernetes-tools init                             # control plane: initialize the cluster
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # workers: join the cluster
```

## 📖 Commands

```text
kubernetes-tools [options] <command>
```

| Command | Description | Run on |
|---|---|---|
| `help` | Show help (default when no command is given) | Anywhere |
| `version` | Show the tool version | Anywhere |
| `download` | Download offline packages to the package directory (no root needed) | Any machine with internet access |
| `save-images` | Pull and export the offline image archive | A node with components installed and internet access |
| `install` | Install components, then initialize or join the cluster according to the role | All nodes |
| `init` | Initialize the cluster | Control plane with components installed |
| `join` | Join the cluster (requires `-r worker` or `-r control-plane`) | Nodes with components installed |
| `token` | Generate node join commands | Control plane |
| `reset` | Reset the node: leave the cluster and clean cluster data, keeping the installed components | All nodes |
| `uninstall` | Uninstall: leave the cluster and remove all files | All nodes |
| `update` | Upgrade the Kubernetes version | All nodes |
| `start` / `stop` / `restart` | Start, stop or restart containerd and kubelet | All nodes |
| `enable` / `disable` | Enable or disable starting containerd and kubelet at boot | All nodes |
| `info` | Show component versions, service status, nodes and Pods | All nodes |

## ⚙️ Configuration

### Command-Line Options

| Option | Description | Default | Example |
|---|---|---|---|
| `-v` | Kubernetes version | 1.37.1 | `-v 1.37.2` |
| `-i` | Install directory (binaries in `bin/`, configuration in `conf/`) | /opt/kubernetes | `-i /data/kubernetes` |
| `-d` | Data directory (containerd data in `containerd/`, etcd data in `etcd/`) | /opt/kubernetes/data | `-d /data/kubernetes/data` |
| `-k` | Package directory | `packages/` next to the script | `-k /mnt/usb/packages` |
| `-o` | Offline installation | Online | `-o` |
| `-b` | Package architecture (only for `download` and `save-images`) | Host architecture | `-b arm64` |
| `-r` | Node role: `master`, `worker`, `control-plane` | master | `-r worker` |
| `-a` | Install components only; do not initialize or join a cluster | No | `-a` |
| `-l` | Local advertise address | Auto-detected | `-l 192.168.1.10` |
| `-e` | Control plane endpoint (high availability) | None | `-e 192.168.1.100:6443` |
| `-m` | API Server address of the cluster to join (port defaults to 6443) | None | `-m 192.168.1.10` |
| `-t` | Token for joining the cluster | None | `-t abcdef.0123456789abcdef` |
| `-s` | CA certificate hash (the `sha256:` prefix is optional) | None | `-s sha256:1234...` |
| `-c` | Certificate key for joining as a control plane | None | `-c 0a1b...` |
| `-n` | Network plugin: `flannel`, `calico`, `none` | flannel | `-n calico` |
| `-p` | Pod CIDR | 10.244.0.0/16 | `-p 172.16.0.0/16` |
| `-x` | Service CIDR | 10.96.0.0/12 | `-x 10.100.0.0/16` |
| `-g` | Kubernetes image registry | registry.k8s.io | `-g registry.aliyuncs.com/google_containers` |
| `-w` | Registry mirrors (`registry=URL`, comma-separated) | None | `-w docker.io=https://docker.1ms.run` |
| `-u` | Allow Pods on the control plane (single-node cluster) | No | `-u` |
| `-y` | Skip confirmation prompts | No | `-y` |

> Roles: `master` initializes a new cluster (the first control plane); `worker` joins as a worker node; `control-plane` joins a highly available cluster as an additional control plane.

### In-Script Settings

Less common settings can be changed in the variables at the top of the script:

```bash
vim kubernetes-tools

CONTAINERD_VERSION=2.4.2           # containerd version
RUNC_VERSION=1.5.2                 # runc version
CNI_PLUGINS_VERSION=1.9.1          # CNI plugins version
CRICTL_VERSION=1.37.0              # crictl version
FLANNEL_VERSION=0.28.10            # Flannel version
CALICO_VERSION=3.33.0              # Calico version
KUBE_PROXY_MODE=iptables           # kube-proxy mode: iptables, ipvs, nftables
NEED_DISABLE_SWAP=true             # whether to disable swap
KUBEADM_IGNORE_PREFLIGHT_ERRORS="" # kubeadm preflight errors to ignore, e.g. NumCPU,Mem
K8S_PACKAGE_URL=https://dl.k8s.io/release   # download URLs (can point to an internal mirror)
```

> On recent kernels, `nftables` mode is recommended. `ipvs` mode has been deprecated since Kubernetes 1.35.

### kubeadm Configuration Template

`kubeadm-config.yaml` is the configuration template for `kubeadm init`; `{{...}}` are placeholders. You can add other kubeadm fields to the template, for example extra SANs for the API Server certificate:

```yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
...
apiServer:
  certSANs:
    - k8s.example.com
    - 192.168.1.100
```

The rendered configuration is saved to `<install-dir>/conf/kubeadm-config.yaml`, and the init log to `<install-dir>/conf/kubeadm-init.log` (it contains the token and is readable by root only).

## 🛠 Operations

### Adding Nodes

```bash
# Control plane: generate a new join command (tokens expire after 24 hours by default)
sudo ./kubernetes-tools token

# New node: run the printed command
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... install
```

### Removing Nodes

```bash
# Control plane: evict the Pods and delete the node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl delete node <node-name>

# Removed node: leave the cluster (keep components) or uninstall completely
sudo ./kubernetes-tools reset
sudo ./kubernetes-tools uninstall
```

### Upgrading Kubernetes

kubeadm only supports upgrading **one minor version at a time** (for example 1.36.x → 1.37.x) and does not support downgrades. Upgrade order: **first control plane → other control planes → workers**, one node at a time.

```bash
# 1. (on a control plane) evict the Pods on the node being upgraded
kubectl drain <node-name> --ignore-daemonsets

# 2. (on the node being upgraded) upgrade
sudo ./kubernetes-tools -v 1.37.2 update            # online
sudo ./kubernetes-tools -o -v 1.37.2 update         # offline (run download / save-images beforehand)

# 3. (on a control plane) re-enable scheduling
kubectl uncordon <node-name>
```

The script picks the upgrade method as follows:
- On a control plane node, if the cluster version is not yet the target version, this is the first control plane to be upgraded, so it runs `kubeadm upgrade plan` and `kubeadm upgrade apply`
- Other control planes and workers run `kubeadm upgrade node`
- Before upgrading, the old kubeadm, kubelet and kubectl are backed up to `<install-dir>/backup/<timestamp>/`

> `update` only upgrades the Kubernetes components. To upgrade containerd or runc, replace them manually: `kubectl drain` the node, run `stop`, extract the new version over `<install-dir>/bin`, then run `start` and `kubectl uncordon`.

### Certificate Management

Certificates issued by kubeadm are valid for 1 year. They are renewed automatically when you run `update`.

```bash
kubeadm certs check-expiration   # check certificate expiration
kubeadm certs renew all          # renew all certificates manually; restart the control plane components afterwards
```

### Service Management

```bash
sudo ./kubernetes-tools start      # start containerd and kubelet
sudo ./kubernetes-tools stop       # stop kubelet and containerd
sudo ./kubernetes-tools restart    # restart
sudo ./kubernetes-tools enable     # start at boot
sudo ./kubernetes-tools disable    # do not start at boot
sudo ./kubernetes-tools info       # show information
```

> `stop` does not stop running containers. containerd uses `KillMode=process`, which is standard practice for Kubernetes.

### Uninstalling

```bash
sudo ./kubernetes-tools uninstall
# if custom directories were used, specify them too
sudo ./kubernetes-tools -i /data/kubernetes -d /data/kubernetes/data uninstall
```

Uninstalling runs `kubeadm reset`, stops and removes the services, and deletes: the install directory, the data directory, `/etc/kubernetes`, `/var/lib/kubelet`, `/etc/containerd`, `/etc/cni`, `/opt/cni/bin`, `~/.kube/config`, the environment variables and the kernel parameter files. Swap entries commented out during installation are restored.

The following are left untouched: installed system dependencies, SELinux settings, iptables rules (the cleanup commands are printed during uninstall) and the `packages/` directory.

## ❓ FAQ

### Q1: Missing dependency commands are reported

Install them with the command shown in the message, for example:

```bash
dnf install -y conntrack-tools socat
```

### Q2: Environment variables do not take effect and kubectl is not found

```bash
source ~/.bashrc
source /etc/profile
# or log in again
```

### Q3: Swap is reported as still enabled

Fedora and some other distributions create swap with zram by default:

```bash
swapoff -a
dnf remove -y zram-generator-defaults   # or: touch /etc/systemd/zram-generator.conf
```

### Q4: Image pulls fail (ImagePull / ErrImagePull)

- Kubernetes component images: switch to a reachable registry with `-g registry.aliyuncs.com/google_containers`
- Network plugin images (ghcr.io / quay.io / docker.io): configure mirrors with `-w`, or use the offline image archive
- To see the exact error: `crictl pull <image>`, `journalctl -u containerd -n 50`

### Q5: Nodes stay NotReady

```bash
kubectl get pods -n kube-flannel -o wide       # Flannel
kubectl get pods -n kube-system -l k8s-app=calico-node   # Calico
kubectl describe node <node-name>
```

Common causes: the network plugin images failed to pull; the Pod CIDR overlaps the node network (change it with `-p`); a firewall blocks Flannel's 8472/udp or Calico's 179/tcp.

### Q6: The token has expired and nodes cannot join

Tokens expire after 24 hours by default and certificate keys after 2 hours. Regenerate them on a control plane:

```bash
sudo ./kubernetes-tools token
```

### Q7: How to retry after a failed init or join

```bash
sudo ./kubernetes-tools reset     # clean cluster state (keep installed components)
sudo ./kubernetes-tools init      # control plane: initialize again
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # worker: join again
```

### Q8: An existing containerd installed by other means is reported

This tool ships its own containerd, which conflicts with containerd installed from the `containerd.io` or `docker-ce` packages. Uninstall those packages first. Docker installed with docker-tools does not conflict: its containerd is managed internally by dockerd and uses a different socket. However, when Docker and Kubernetes run on the same machine, Docker sets the iptables FORWARD default policy to DROP, so check Pod traffic between nodes.

### Q9: Preflight fails on machines with less than 2 cores / 2GB

For test environments, set the script variable:

```bash
KUBEADM_IGNORE_PREFLIGHT_ERRORS=NumCPU,Mem
```

### Q10: Which ports need to be opened in the firewall

| Node | Port | Purpose |
|---|---|---|
| Control plane | 6443/tcp | API Server |
| Control plane | 2379-2380/tcp | etcd |
| Control plane | 10257/tcp, 10259/tcp | controller-manager, scheduler |
| All nodes | 10250/tcp | kubelet |
| Workers | 30000-32767/tcp | NodePort |
| All nodes | 8472/udp | Flannel VXLAN |
| All nodes | 179/tcp, 4789/udp | Calico BGP / VXLAN |

```bash
# firewalld example (control plane)
firewall-cmd --permanent --add-port={6443,2379-2380,10250,10257,10259}/tcp --add-port=8472/udp
firewall-cmd --reload
```

## 🔧 Troubleshooting

### Log Locations

```bash
journalctl -u kubelet -f            # kubelet logs
journalctl -u containerd -f         # containerd logs
cat /opt/kubernetes/conf/kubeadm-init.log   # init log
crictl ps -a                        # containers on this node
crictl logs <container-id>          # container logs
```

The script itself does not write a log file; its output goes straight to the terminal. To keep it, run `./kubernetes-tools install 2>&1 | tee install.log`.

### Common Errors

#### Error 1: `[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]`

The `br_netfilter` module is not loaded:

```bash
modprobe br_netfilter
sysctl -p /etc/sysctl.d/kubernetes.conf
```

#### Error 2: `kubelet` keeps restarting

Before init or join, it is normal for kubelet to keep restarting while it waits for kubeadm to generate its configuration. If it still happens afterwards:

```bash
journalctl -u kubelet -n 100 --no-pager
```

Common causes: swap is still enabled; mismatched cgroup drivers (this tool sets both to systemd).

#### Error 3: `The connection to the server localhost:8080 was refused`

The current user has no kubeconfig:

```bash
mkdir -p ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config
```

#### Error 4: `x509: certificate signed by unknown authority`

The cluster was rebuilt but `~/.kube/config` is still the old one. Copy `/etc/kubernetes/admin.conf` again.

## 📁 File Structure

### Tool Directory

```text
kubernetes-tools/
├── kubernetes-tools        # main script
├── kubeadm-config.yaml     # kubeadm configuration template
├── containerd.service      # containerd systemd service template
├── kubelet.service         # kubelet systemd service template
├── 10-kubeadm.conf         # kubelet systemd drop-in template (kubeadm arguments)
├── README.md               # user manual (Chinese)
├── README_EN.md            # user manual (English)
├── README_JA.md            # user manual (Japanese)
├── DESIGN.md               # design document (Chinese)
└── packages/               # package directory (created by download or online installation)
```

### System Layout After Installation (Default Paths)

```text
/opt/kubernetes/
├── bin/          # kubeadm kubelet kubectl containerd containerd-shim-runc-v2 ctr runc crictl
├── conf/         # kubeadm-config.yaml, kubeadm-init.log, network plugin manifest
├── backup/       # old versions backed up by update
└── data/
    ├── containerd/   # containerd data (images, containers)
    └── etcd/         # etcd data (control plane)
/opt/cni/bin/                         # CNI plugins
/etc/containerd/config.toml           # containerd configuration
/etc/containerd/certs.d/              # registry mirror configuration
/etc/crictl.yaml                      # crictl configuration
/etc/kubernetes/                      # certificates and kubeconfigs generated by kubeadm
/usr/lib/systemd/system/containerd.service
/usr/lib/systemd/system/kubelet.service
/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/sysctl.d/kubernetes.conf
/etc/modules-load.d/kubernetes.conf
```

## 🔒 Security Recommendations

1. **Protect credentials**: `/etc/kubernetes/admin.conf` has cluster-admin rights, so never share it; tokens and certificate keys can be left to expire once used
2. **Restrict API access**: limit the sources allowed to reach port 6443 with a firewall or security group
3. **Upgrade regularly**: apply Kubernetes patch releases promptly and watch certificate expiration
4. **Least privilege**: give everyday users kubeconfigs with restricted RBAC instead of admin.conf
5. **Back up etcd**: back up the etcd data on the control plane regularly (`etcdctl snapshot save`)

## 📝 Changelog

### v1.0.0 (2026-10-20)
- 🎉 First release
- Static binary installation based on kubeadm + containerd, supporting x86_64 and aarch64
- Single-node, one-control-plane-many-workers and highly available (multiple control plane) clusters
- Online/offline installation: `download` fetches packages, `save-images` exports the image archive, and all packages are verified with SHA256
- Built-in Flannel and Calico network plugins
- Alternative image registry (`-g`) and registry mirrors (`-w`)
- Cluster lifecycle commands including `init`, `join`, `token`, `reset`, `update` and `uninstall`

## 👤 Author

**HTY1024**

- Git: [@HTY1024](https://git.hty1024.com/HTY1024)

## 🙏 Acknowledgments

- [Kubernetes](https://kubernetes.io/)
- [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
- [containerd](https://containerd.io/)
- [Flannel](https://github.com/flannel-io/flannel)
- [Calico](https://www.tigera.io/project-calico/)

[Back to top](#kubernetes-tools)
