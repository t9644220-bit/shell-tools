\# Docker Tools



\[!\[Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/docker-tools)

\[!\[License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/LICENSE)

\[!\[Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)



Automated installation, management, and maintenance tool for Docker, supporting one-click deployment of Docker Engine, Docker Compose, and Docker Swarm.



\[中文](README.md) | \[日本語](README\_JA.md)



\## 📋 Table of Contents



\- \[Features](#features)

\- \[System Requirements](#system-requirements)

\- \[Quick Start](#quick-start)

\- \[Installation Methods](#installation-methods)

\- \[Usage](#usage)

\- \[Configuration](#configuration)

\- \[FAQ](#faq)

\- \[Troubleshooting](#troubleshooting)

\- \[Contributing](#contributing)

\- \[License](#license)



\## ✨ Features



\### Core Features

\- ✅ \*\*One-Click Installation\*\* - Automated installation of Docker Engine and Docker Compose

\- ✅ \*\*Online/Offline Installation\*\* - Support both online download and offline package deployment

\- ✅ \*\*Version Management\*\* - Support specific version installation and updates

\- ✅ \*\*Cluster Support\*\* - Built-in Docker Swarm cluster configuration

\- ✅ \*\*Complete Uninstallation\*\* - Thoroughly clean up Docker-related files and configurations

\- ✅ \*\*Automatic Backup\*\* - Automatically backup important configuration files before operations



\### System Management

\- 🔧 Automatically configure system kernel parameters

\- 🔧 Automatically create Docker user and group

\- 🔧 Automatically configure environment variables

\- 🔧 Automatically configure systemd services

\- 🔧 Support auto-start on boot



\### User Experience

\- 🎨 Colored log output for clarity

\- 🎨 Detailed operation prompts and progress display

\- 🎨 Interactive confirmation to prevent misoperations

\- 🎨 Comprehensive error handling and prompts



\## 💻 System Requirements



\### Supported Operating Systems

\- CentOS 7/8/9

\- RHEL 7/8/9

\- Ubuntu 18.04/20.04/22.04

\- Debian 10/11/12

\- openSUSE Leap 15.x/16.x

\- Other Linux distributions with systemd support



\### Supported CPU Architectures

\- x86\_64 (amd64)

\- aarch64 (arm64) - Partial support

\- armv7l - Partial support



\### System Requirements

\- \*\*OS\*\*: Linux (Kernel 3.10+)

\- \*\*Privileges\*\*: root or sudo

\- \*\*Disk Space\*\*: At least 10GB available

\- \*\*Memory\*\*: 2GB+ recommended

\- \*\*Dependencies\*\*: 

&nbsp; - `iptables` (required)

&nbsp; - `tar` (required)

&nbsp; - `curl` or `wget` (required for online installation)



\## 🚀 Quick Start



\### 1. Download Script



```bash

\# Method 1: Clone with git

git https://git.hty1024.com/HTY1024/shell\_tools.git

cd shell\_tools/docker-tools



\# Method 2: Direct download

wget https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/releases/docker-tools\_v2.1.0.zip

unzip docker-tools\_v2.1.0.zip

```



\### 2. Grant Execute Permission



```bash

chmod +x docker-tools.sh

```



\### 3. Run Installation



```bash

\# Install with default configuration

sudo ./docker-tools.sh install



\# Or specify version

sudo ./docker-tools.sh -v 29.4.1 -c v5.1.3 install

```



\### 4. Verify Installation



```bash

\# Check Docker version

docker --version



\# Check Docker Compose version

docker-compose --version



\# View Docker info

docker info

```



\## 📦 Installation Methods



\### Method 1: Online Installation (Recommended)



\*\*Advantages\*\*: Automatically download latest version, no need to prepare packages



```bash

\# Default installation (Docker 29.4.1 + Compose v5.1.3)

sudo ./docker-tools.sh install



\# Specify version

sudo ./docker-tools.sh -v 29.4.1 -c v5.1.3 install



\# Custom installation directory

sudo ./docker-tools.sh -i /data/docker/bin -d /data/docker/data install

```



\### Method 2: Offline Installation



\*\*Advantages\*\*: Suitable for servers without network or with network restrictions



\#### Step 1: Prepare Packages



Download packages on a machine with network access:



```bash

\# Download Docker Engine

wget https://download.docker.com/linux/static/stable/x86\_64/docker-29.4.1.tgz



\# Download Docker Compose

wget https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-x86\_64

```



\#### Step 2: Upload to Target Server



```bash

\# Upload packages and script to the same directory

scp docker-29.4.1.tgz docker-compose-linux-x86\_64 docker-tools.sh user@server:/path/to/dir/

```



\#### Step 3: Execute Offline Installation



```bash

sudo ./docker-tools.sh -p docker-29.4.1.tgz -n docker-compose-linux-x86\_64 install

```



\### Method 3: Install Docker Engine Only



```bash

\# Install only Docker Engine, skip Docker Compose

sudo ./docker-tools.sh -a install

```



\### Method 4: Install Docker Compose Only



```bash

\# Install only Docker Compose (requires Docker Engine installed)

sudo ./docker-tools.sh -b install

```



\## 📖 Usage



\### Basic Commands



```bash

\# Show help

./docker-tools.sh help



\# Show version

./docker-tools.sh version



\# Install Docker

sudo ./docker-tools.sh install



\# Uninstall Docker

sudo ./docker-tools.sh uninstall



\# Update Docker

sudo ./docker-tools.sh update



\# Start Docker

sudo ./docker-tools.sh start



\# Stop Docker

sudo ./docker-tools.sh stop



\# Restart Docker

sudo ./docker-tools.sh restart



\# Enable auto-start

sudo ./docker-tools.sh enable



\# Disable auto-start

sudo ./docker-tools.sh disable



\# Show Docker info

sudo ./docker-tools.sh info

```



\### Advanced Usage



\#### 1. Custom Installation Directory



```bash

\# Specify installation and data directories

sudo ./docker-tools.sh \\

&nbsp; -i /data/docker/bin \\

&nbsp; -d /data/docker/data \\

&nbsp; install

```



\#### 2. Specify Version



```bash

\# Install specific versions of Docker and Compose

sudo ./docker-tools.sh \\

&nbsp; -v 28.2.1 \\

&nbsp; -c v2.36.2 \\

&nbsp; install

```



\#### 3. Offline Installation



```bash

\# Use local packages for offline installation

sudo ./docker-tools.sh \\

&nbsp; -p docker-29.4.1.tgz \\

&nbsp; -n docker-compose-linux-x86\_64 \\

&nbsp; install

```



\#### 4. Docker Swarm Cluster Deployment



\*\*Manager Node\*\*:



```bash

\# Install Docker and initialize Swarm Manager

sudo ./docker-tools.sh -s install



\# After installation, get Worker Token

docker swarm join-token worker

\# Output example:

\# docker swarm join --token SWMTKN-1-xxx... 192.168.1.100:2377

```



\*\*Worker Node\*\*:



```bash

\# Join cluster with Manager IP and Token

sudo ./docker-tools.sh \\

&nbsp; -s \\

&nbsp; -r worker \\

&nbsp; -m 192.168.1.100 \\

&nbsp; -t SWMTKN-1-xxx... \\

&nbsp; install

```



\#### 5. Update Docker Version



```bash

\# Online update to specified version

sudo ./docker-tools.sh -v 29.4.1 update



\# Offline update

sudo ./docker-tools.sh -p docker-29.4.1.tgz update

```



\## ⚙️ Configuration



\### Command Line Parameters



| Parameter | Description | Default | Example |

|-----------|-------------|---------|---------|

| `-v` | Docker Engine version | 29.4.1 | `-v 28.2.1` |

| `-i` | Docker installation directory | /opt/docker/bin | `-i /data/docker/bin` |

| `-d` | Docker data directory | /opt/docker/data | `-d /data/docker/data` |

| `-p` | Docker Engine package name (offline) | - | `-p docker-29.4.1.tgz` |

| `-c` | Docker Compose version | v5.1.3 | `-c v2.36.2` |

| `-n` | Docker Compose package name (offline) | - | `-n docker-compose-linux-x86\_64` |

| `-a` | Install Docker Engine only | false | `-a` |

| `-b` | Install Docker Compose only | false | `-b` |

| `-s` | Enable Docker Swarm | false | `-s` |

| `-r` | Swarm role (manager/worker) | manager | `-r worker` |

| `-m` | Swarm Manager IP | 127.0.0.1 | `-m 192.168.1.100` |

| `-t` | Swarm Token (required for worker) | - | `-t SWMTKN-1-xxx...` |



\### Script Configuration



You can modify configuration variables directly in the script:



```bash

\# Edit script

vim docker-tools.sh



\# Modify these variables

DOCKER\_VERSION=29.4.1              # Docker version

DOCKER\_INSTALL\_DIR=/opt/docker/bin # Installation directory

DOCKER\_DATA\_DIR=/opt/docker/data   # Data directory

NEED\_ENABLE\_DOCKER=true            # Auto-start on boot

```



\### Docker Daemon Configuration



Default configuration file `daemon.json`:



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



Customize as needed:



```bash

\# Edit configuration file

vim daemon.json



\# Add registry mirrors

"registry-mirrors": \[

&nbsp; "https://mirror.ccs.tencentyun.com",

&nbsp; "https://docker.mirrors.ustc.edu.cn"

]



\# Add private registries

"insecure-registries": \[

&nbsp; "192.168.1.100:5000"

]

```



\## ❓ FAQ



\### Q1: Installation fails with missing dependencies



\*\*A\*\*: Install required dependencies first:



```bash

\# CentOS/RHEL

sudo yum install -y iptables tar curl



\# Ubuntu/Debian

sudo apt-get install -y iptables tar curl



\# openSUSE

sudo zypper install -y iptables tar curl

```



\### Q2: Environment variables not taking effect



\*\*A\*\*: Manually execute after installation:



```bash

source ~/.bashrc

source /etc/profile



\# Or re-login to the system

```



\### Q3: Docker service fails to start



\*\*A\*\*: Check logs for the cause:



```bash

\# Check service status

sudo systemctl status docker



\# View detailed logs

sudo journalctl -u docker -n 50



\# Check configuration

sudo docker info

```



\### Q4: Cannot find installation package during offline installation



\*\*A\*\*: Ensure packages are in the same directory as the script:



```bash

\# Check files

ls -lh docker-\*.tgz docker-compose-\*



\# Ensure correct filenames

./docker-tools.sh -p docker-29.4.1.tgz -n docker-compose-linux-x86\_64 install

```



\### Q5: Residual files after uninstallation



\*\*A\*\*: Manually clean up:



```bash

\# Remove data directories

sudo rm -rf /opt/docker

sudo rm -rf /var/lib/docker



\# Remove configuration files

sudo rm -rf /etc/docker



\# Remove environment variable configuration

vim ~/.bashrc  # Delete Docker Env related lines

vim /etc/profile

```



\### Q6: Failed to join Docker Swarm



\*\*A\*\*: Check network and firewall:



```bash

\# Check port connectivity

telnet <manager-ip> 2377



\# Open required ports (Manager node)

sudo firewall-cmd --permanent --add-port=2377/tcp  # Cluster management

sudo firewall-cmd --permanent --add-port=7946/tcp  # Node communication

sudo firewall-cmd --permanent --add-port=7946/udp

sudo firewall-cmd --permanent --add-port=4789/udp  # Overlay network

sudo firewall-cmd --reload



\# Or temporarily disable firewall for testing

sudo systemctl stop firewalld

```



\### Q7: Permission denied error



\*\*A\*\*: Ensure using root privileges:



```bash

\# Use sudo

sudo ./docker-tools.sh install



\# Or switch to root user

su -

./docker-tools.sh install

```



\### Q8: Version incorrect after update



\*\*A\*\*: Clean cache and reinstall:



```bash

\# Complete uninstallation

sudo ./docker-tools.sh uninstall



\# Clean cache

sudo rm -rf /tmp/docker-\*



\# Reinstall

sudo ./docker-tools.sh -v 29.4.1 install

```



\## 🔧 Troubleshooting



\### Log Locations



```bash

\# System logs

sudo journalctl -u docker -f



\# Docker logs

sudo tail -f /var/log/docker.log



\# Script logs (if configured)

sudo tail -f /var/log/docker-tools.log

```



\### Common Errors and Solutions



\#### Error 1: "Cannot connect to the Docker daemon"



```bash

\# Check service status

sudo systemctl status docker



\# Start service

sudo systemctl start docker



\# Check socket

sudo systemctl status docker.socket

```



\#### Error 2: "permission denied while trying to connect"



```bash

\# Add current user to docker group

sudo usermod -aG docker $USER



\# Re-login or execute

newgrp docker

```



\#### Error 3: "Error response from daemon: conflict"



```bash

\# Clean conflicting containers/networks

docker system prune -a



\# Or manually delete

docker rm -f $(docker ps -aq)

docker network prune

```



\#### Error 4: "no space left on device"



```bash

\# Check disk space

df -h



\# Clean Docker data

docker system prune -a --volumes



\# Change data directory

sudo ./docker-tools.sh -d /data/docker/data install

```



\### Performance Optimization



\#### 1. Adjust Storage Driver



```bash

\# Edit daemon.json

sudo vim /etc/docker/daemon.json



\# Modify storage driver

{

&nbsp; "storage-driver": "overlay2",

&nbsp; "storage-opts": \[

&nbsp;   "overlay2.override\_kernel\_check=true"

&nbsp; ]

}



\# Restart Docker

sudo systemctl restart docker

```



\#### 2. Configure Log Rotation



```bash

\# Edit daemon.json

{

&nbsp; "log-driver": "json-file",

&nbsp; "log-opts": {

&nbsp;   "max-size": "50m",

&nbsp;   "max-file": "5"

&nbsp; }

}

```



\#### 3. Adjust Concurrency Limits



```bash

\# Edit daemon.json

{

&nbsp; "max-concurrent-downloads": 10,

&nbsp; "max-concurrent-uploads": 10

}

```



\## 📁 File Structure



```

docker-tools/

├── docker-tools.sh          # Main script

├── daemon.json              # Docker daemon configuration template

├── docker.service           # systemd service file

├── docker.socket            # systemd socket file

├── README.md                # Chinese documentation

├── README\_EN.md             # English documentation

└── README\_JA.md             # Japanese documentation

```



\## 🔒 Security Recommendations



1\. \*\*Principle of Least Privilege\*\*: Use root privileges only when necessary

2\. \*\*Regular Updates\*\*: Keep Docker updated to the latest stable version

3\. \*\*Network Isolation\*\*: Use firewall to restrict Docker API access

4\. \*\*Image Security\*\*: Only use trusted image sources

5\. \*\*Log Auditing\*\*: Enable logging and review regularly

6\. \*\*Resource Limits\*\*: Set CPU and memory limits for containers



```bash

\# Limit container resources

docker run -d \\

&nbsp; --cpus="1.5" \\

&nbsp; --memory="512m" \\

&nbsp; --memory-swap="1g" \\

&nbsp; nginx

```



\## 📝 Changelog

\### v2.1.0 (2026-04-24)

\#### 🆕 Version Updates

\- Default Docker Engine bumped to \*\*29.4.1\*\*

\- Default Docker Compose bumped to \*\*v5.1.3\*\*

\#### 🐛 Bug Fixes

\- Fix subcommand dispatch: `case "$@"` failed on multi-arg; `info` missed `info_docker`

\- Fix `check_net` TIMEOUT positional-param misuse, and 2xx/3xx incorrectly treated as failures

\- Fix `backup_file` not working on directories (upgrades previously skipped backup)

\- Fix `remove_env` leaving blank lines; switched to range deletion via sed

\- Fix leftover mixed line with comment and `ExecStart=` in `docker.service`

\- Fix typos (Dokcer / Coimpose / Conpose)

\#### ✨ Robustness

\- `config_env` is now idempotent — repeated installs no longer duplicate `~/.bashrc` / `/etc/profile`

\- No longer `source ~/.bashrc` inside the script (prevents `set -u` crashes from third-party rc files)

\- Validate `daemon.json` after template substitution to catch unfilled `{{...}}` placeholders

\- Data directory owner-only changes; dropped `chmod -R 755` which could break image layer permissions

\- Replace deprecated `chown docker.docker` with `docker:docker`

\- Remove hardcoded UID/GID=1001 in `useradd/groupadd` to avoid collisions

\- `CPU_ARCH` is now runtime-detected; `aarch64` supported

\- `getopts` now handles unknown/missing-arg options; `-r/-m/-t` no longer implicitly enable Swarm

\- Strong validation of Manager IP and Token for Swarm worker role

\- `only_install_docker_compose` skips restart/info when Docker Engine isn't running

\### v2.0.0

\- Logging refactor, `set -euo pipefail`, interactive confirmations

\### v1.3.x / v1.2.x / v1.1.x

\- See git history

\## 👤 Author



\*\*HTY1024\*\*



\- Git: \[@HTY1024](https://git.hty1024.com/HTY1024)



\## 🙏 Acknowledgments



Thanks to the following projects and resources:



\- \[Docker](https://www.docker.com/)

\- \[Docker Compose](https://docs.docker.com/compose/)

\- \[Docker Swarm](https://docs.docker.com/engine/swarm/)



\[Back to Top](#docker-tools)

