\# Docker Tools



\[!\[Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/docker-tools)

\[!\[License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/LICENSE)

\[!\[Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)



Docker Engine、Docker Compose、Docker Swarm のワンクリックデプロイをサポートする、Docker の自動インストール、管理、メンテナンスツール。



\[中文](README.md) | \[English](README\_EN.md)



\## 📋 目次



\- \[機能](#機能)

\- \[システム要件](#システム要件)

\- \[クイックスタート](#クイックスタート)

\- \[インストール方法](#インストール方法)

\- \[使用方法](#使用方法)

\- \[設定](#設定)

\- \[よくある質問](#よくある質問)

\- \[トラブルシューティング](#トラブルシューティング)

\- \[貢献](#貢献)

\- \[ライセンス](#ライセンス)



\## ✨ 機能



\### コア機能

\- ✅ \*\*ワンクリックインストール\*\* - Docker Engine と Docker Compose の自動インストール

\- ✅ \*\*オンライン/オフラインインストール\*\* - オンラインダウンロードとオフラインパッケージデプロイの両方をサポート

\- ✅ \*\*バージョン管理\*\* - 特定バージョンのインストールとアップデートをサポート

\- ✅ \*\*クラスターサポート\*\* - Docker Swarm クラスター設定を内蔵

\- ✅ \*\*完全アンインストール\*\* - Docker 関連のファイルと設定を完全にクリーンアップ

\- ✅ \*\*自動バックアップ\*\* - 操作前に重要な設定ファイルを自動的にバックアップ



\### システム管理

\- 🔧 システムカーネルパラメータの自動設定

\- 🔧 Docker ユーザーとグループの自動作成

\- 🔧 環境変数の自動設定

\- 🔧 systemd サービスの自動設定

\- 🔧 起動時の自動起動をサポート



\### ユーザーエクスペリエンス

\- 🎨 見やすいカラーログ出力

\- 🎨 詳細な操作プロンプトと進行状況表示

\- 🎨 誤操作を防ぐインタラクティブ確認

\- 🎨 包括的なエラー処理とプロンプト



\## 💻 システム要件



\### サポートされているオペレーティングシステム

\- CentOS 7/8/9

\- RHEL 7/8/9

\- Ubuntu 18.04/20.04/22.04

\- Debian 10/11/12

\- openSUSE Leap 15.x/16.x

\- systemd をサポートするその他の Linux ディストリビューション



\### サポートされている CPU アーキテクチャ

\- x86\_64 (amd64)

\- aarch64 (arm64) - 部分的サポート

\- armv7l - 部分的サポート



\### システム要件

\- \*\*OS\*\*: Linux (カーネル 3.10+)

\- \*\*権限\*\*: root または sudo

\- \*\*ディスク容量\*\*: 最低 10GB の空き容量

\- \*\*メモリ\*\*: 2GB 以上推奨

\- \*\*依存ツール\*\*: 

&nbsp; - `iptables` (必須)

&nbsp; - `tar` (必須)

&nbsp; - `curl` または `wget` (オンラインインストール時に必須)



\## 🚀 クイックスタート



\### 1. スクリプトのダウンロード



```bash

\# 方法 1: git でクローン

git https://git.hty1024.com/HTY1024/shell\_tools.git

cd shell\_tools/docker-tools



\# 方法 2: 直接ダウンロード

wget https://git.hty1024.com/HTY1024/shell\_tools/src/branch/main/releases/docker-tools\_v2.0.0.zip

unzip docker-tools\_v2.0.0.zip

```



\### 2. 実行権限の付与



```bash

chmod +x docker-tools.sh

```



\### 3. インストールの実行



```bash

\# デフォルト設定でインストール

sudo ./docker-tools.sh install



\# またはバージョンを指定

sudo ./docker-tools.sh -v 29.1.4 -c v5.0.1 install

```



\### 4. インストールの確認



```bash

\# Docker バージョンの確認

docker --version



\# Docker Compose バージョンの確認

docker-compose --version



\# Docker 情報の表示

docker info

```



\## 📦 インストール方法



\### 方法 1: オンラインインストール（推奨）



\*\*利点\*\*: 最新バージョンを自動ダウンロード、パッケージの準備不要



```bash

\# デフォルトインストール (Docker 29.1.4 + Compose v5.0.1)

sudo ./docker-tools.sh install



\# バージョン指定

sudo ./docker-tools.sh -v 29.1.4 -c v5.0.1 install



\# カスタムインストールディレクトリ

sudo ./docker-tools.sh -i /data/docker/bin -d /data/docker/data install

```



\### 方法 2: オフラインインストール



\*\*利点\*\*: ネットワークがないサーバーやネットワーク制限のあるサーバーに適している



\#### ステップ 1: パッケージの準備



ネットワークアクセスのあるマシンでパッケージをダウンロード:



```bash

\# Docker Engine のダウンロード

wget https://download.docker.com/linux/static/stable/x86\_64/docker-29.1.4.tgz



\# Docker Compose のダウンロード

wget https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86\_64

```



\#### ステップ 2: ターゲットサーバーへのアップロード



```bash

\# パッケージとスクリプトを同じディレクトリにアップロード

scp docker-29.1.4.tgz docker-compose-linux-x86\_64 docker-tools.sh user@server:/path/to/dir/

```



\#### ステップ 3: オフラインインストールの実行



```bash

sudo ./docker-tools.sh -p docker-29.1.4.tgz -n docker-compose-linux-x86\_64 install

```



\### 方法 3: Docker Engine のみインストール



```bash

\# Docker Engine のみインストール、Docker Compose はスキップ

sudo ./docker-tools.sh -a install

```



\### 方法 4: Docker Compose のみインストール



```bash

\# Docker Compose のみインストール (Docker Engine がインストール済みである必要があります)

sudo ./docker-tools.sh -b install

```



\## 📖 使用方法



\### 基本コマンド



```bash

\# ヘルプの表示

./docker-tools.sh help



\# バージョンの表示

./docker-tools.sh version



\# Docker のインストール

sudo ./docker-tools.sh install



\# Docker のアンインストール

sudo ./docker-tools.sh uninstall



\# Docker の更新

sudo ./docker-tools.sh update



\# Docker の起動

sudo ./docker-tools.sh start



\# Docker の停止

sudo ./docker-tools.sh stop



\# Docker の再起動

sudo ./docker-tools.sh restart



\# 自動起動の有効化

sudo ./docker-tools.sh enable



\# 自動起動の無効化

sudo ./docker-tools.sh disable



\# Docker 情報の表示

sudo ./docker-tools.sh info

```



\### 高度な使用方法



\#### 1. カスタムインストールディレクトリ



```bash

\# インストールディレクトリとデータディレクトリを指定

sudo ./docker-tools.sh \\

&nbsp; -i /data/docker/bin \\

&nbsp; -d /data/docker/data \\

&nbsp; install

```



\#### 2. バージョンの指定



```bash

\# Docker と Compose の特定バージョンをインストール

sudo ./docker-tools.sh \\

&nbsp; -v 28.2.1 \\

&nbsp; -c v2.36.2 \\

&nbsp; install

```



\#### 3. オフラインインストール



```bash

\# ローカルパッケージを使用したオフラインインストール

sudo ./docker-tools.sh \\

&nbsp; -p docker-29.1.4.tgz \\

&nbsp; -n docker-compose-linux-x86\_64 \\

&nbsp; install

```



\#### 4. Docker Swarm クラスターのデプロイ



\*\*Manager ノード\*\*:



```bash

\# Docker をインストールして Swarm Manager を初期化

sudo ./docker-tools.sh -s install



\# インストール後、Worker Token を取得

docker swarm join-token worker

\# 出力例:

\# docker swarm join --token SWMTKN-1-xxx... 192.168.1.100:2377

```



\*\*Worker ノード\*\*:



```bash

\# Manager の IP と Token でクラスターに参加

sudo ./docker-tools.sh \\

&nbsp; -s \\

&nbsp; -r worker \\

&nbsp; -m 192.168.1.100 \\

&nbsp; -t SWMTKN-1-xxx... \\

&nbsp; install

```



\#### 5. Docker バージョンの更新



```bash

\# 指定バージョンへのオンライン更新

sudo ./docker-tools.sh -v 29.1.4 update



\# オフライン更新

sudo ./docker-tools.sh -p docker-29.1.4.tgz update

```



\## ⚙️ 設定



\### コマンドラインパラメータ



| パラメータ | 説明 | デフォルト | 例 |

|-----------|------|-----------|-----|

| `-v` | Docker Engine バージョン | 29.1.4 | `-v 28.2.1` |

| `-i` | Docker インストールディレクトリ | /opt/docker/bin | `-i /data/docker/bin` |

| `-d` | Docker データディレクトリ | /opt/docker/data | `-d /data/docker/data` |

| `-p` | Docker Engine パッケージ名 (オフライン) | - | `-p docker-29.1.4.tgz` |

| `-c` | Docker Compose バージョン | v5.0.1 | `-c v2.36.2` |

| `-n` | Docker Compose パッケージ名 (オフライン) | - | `-n docker-compose-linux-x86\_64` |

| `-a` | Docker Engine のみインストール | false | `-a` |

| `-b` | Docker Compose のみインストール | false | `-b` |

| `-s` | Docker Swarm を有効化 | false | `-s` |

| `-r` | Swarm ロール (manager/worker) | manager | `-r worker` |

| `-m` | Swarm Manager IP | 127.0.0.1 | `-m 192.168.1.100` |

| `-t` | Swarm Token (worker に必須) | - | `-t SWMTKN-1-xxx...` |



\### スクリプト設定



スクリプト内の設定変数を直接変更できます:



```bash

\# スクリプトの編集

vim docker-tools.sh



\# これらの変数を変更

DOCKER\_VERSION=29.1.4              # Docker バージョン

DOCKER\_INSTALL\_DIR=/opt/docker/bin # インストールディレクトリ

DOCKER\_DATA\_DIR=/opt/docker/data   # データディレクトリ

NEED\_ENABLE\_DOCKER=true            # 起動時の自動起動

```



\### Docker Daemon 設定



デフォルト設定ファイル `daemon.json`:



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



必要に応じてカスタマイズ:



```bash

\# 設定ファイルの編集

vim daemon.json



\# レジストリミラーの追加

"registry-mirrors": \[

&nbsp; "https://mirror.ccs.tencentyun.com",

&nbsp; "https://docker.mirrors.ustc.edu.cn"

]



\# プライベートレジストリの追加

"insecure-registries": \[

&nbsp; "192.168.1.100:5000"

]

```



\## ❓ よくある質問



\### Q1: 依存関係が不足しているためインストールに失敗する



\*\*A\*\*: まず必要な依存関係をインストールしてください:



```bash

\# CentOS/RHEL

sudo yum install -y iptables tar curl



\# Ubuntu/Debian

sudo apt-get install -y iptables tar curl



\# openSUSE

sudo zypper install -y iptables tar curl

```



\### Q2: 環境変数が有効にならない



\*\*A\*\*: インストール後に手動で実行してください:



```bash

source ~/.bashrc

source /etc/profile



\# またはシステムに再ログイン

```



\### Q3: Docker サービスの起動に失敗する



\*\*A\*\*: ログを確認して原因を調査:



```bash

\# サービスステータスの確認

sudo systemctl status docker



\# 詳細ログの表示

sudo journalctl -u docker -n 50



\# 設定の確認

sudo docker info

```



\### Q4: オフラインインストール時にパッケージが見つからない



\*\*A\*\*: パッケージがスクリプトと同じディレクトリにあることを確認:



```bash

\# ファイルの確認

ls -lh docker-\*.tgz docker-compose-\*



\# 正しいファイル名を確認

./docker-tools.sh -p docker-29.1.4.tgz -n docker-compose-linux-x86\_64 install

```



\### Q5: アンインストール後に残留ファイルがある



\*\*A\*\*: 手動でクリーンアップ:



```bash

\# データディレクトリの削除

sudo rm -rf /opt/docker

sudo rm -rf /var/lib/docker



\# 設定ファイルの削除

sudo rm -rf /etc/docker



\# 環境変数設定の削除

vim ~/.bashrc  # Docker Env 関連行を削除

vim /etc/profile

```



\### Q6: Docker Swarm への参加に失敗する



\*\*A\*\*: ネットワークとファイアウォールを確認:



```bash

\# ポート接続性の確認

telnet <manager-ip> 2377



\# 必要なポートを開放 (Manager ノード)

sudo firewall-cmd --permanent --add-port=2377/tcp  # クラスター管理

sudo firewall-cmd --permanent --add-port=7946/tcp  # ノード通信

sudo firewall-cmd --permanent --add-port=7946/udp

sudo firewall-cmd --permanent --add-port=4789/udp  # オーバーレイネットワーク

sudo firewall-cmd --reload



\# またはテスト用に一時的にファイアウォールを無効化

sudo systemctl stop firewalld

```



\### Q7: 権限拒否エラー



\*\*A\*\*: root 権限を使用していることを確認:



```bash

\# sudo を使用

sudo ./docker-tools.sh install



\# または root ユーザーに切り替え

su -

./docker-tools.sh install

```



\### Q8: 更新後にバージョンが正しくない



\*\*A\*\*: キャッシュをクリアして再インストール:



```bash

\# 完全アンインストール

sudo ./docker-tools.sh uninstall



\# キャッシュのクリア

sudo rm -rf /tmp/docker-\*



\# 再インストール

sudo ./docker-tools.sh -v 29.1.4 install

```



\## 🔧 トラブルシューティング



\### ログの場所



```bash

\# システムログ

sudo journalctl -u docker -f



\# Docker ログ

sudo tail -f /var/log/docker.log



\# スクリプトログ (設定されている場合)

sudo tail -f /var/log/docker-tools.log

```



\### 一般的なエラーと解決策



\#### エラー 1: "Cannot connect to the Docker daemon"



```bash

\# サービスステータスの確認

sudo systemctl status docker



\# サービスの起動

sudo systemctl start docker



\# ソケットの確認

sudo systemctl status docker.socket

```



\#### エラー 2: "permission denied while trying to connect"



```bash

\# 現在のユーザーを docker グループに追加

sudo usermod -aG docker $USER



\# 再ログインまたは実行

newgrp docker

```



\#### エラー 3: "Error response from daemon: conflict"



```bash

\# 競合するコンテナ/ネットワークのクリーンアップ

docker system prune -a



\# または手動で削除

docker rm -f $(docker ps -aq)

docker network prune

```



\#### エラー 4: "no space left on device"



```bash

\# ディスク容量の確認

df -h



\# Docker データのクリーンアップ

docker system prune -a --volumes



\# データディレクトリの変更

sudo ./docker-tools.sh -d /data/docker/data install

```



\### パフォーマンス最適化



\#### 1. ストレージドライバーの調整



```bash

\# daemon.json の編集

sudo vim /etc/docker/daemon.json



\# ストレージドライバーの変更

{

&nbsp; "storage-driver": "overlay2",

&nbsp; "storage-opts": \[

&nbsp;   "overlay2.override\_kernel\_check=true"

&nbsp; ]

}



\# Docker の再起動

sudo systemctl restart docker

```



\#### 2. ログローテーションの設定



```bash

\# daemon.json の編集

{

&nbsp; "log-driver": "json-file",

&nbsp; "log-opts": {

&nbsp;   "max-size": "50m",

&nbsp;   "max-file": "5"

&nbsp; }

}

```



\#### 3. 同時実行制限の調整



```bash

\# daemon.json の編集

{

&nbsp; "max-concurrent-downloads": 10,

&nbsp; "max-concurrent-uploads": 10

}

```



\## 📁 ファイル構造



```

docker-tools/

├── docker-tools.sh          # メインスクリプト

├── daemon.json              # Docker daemon 設定テンプレート

├── docker.service           # systemd サービスファイル

├── docker.socket            # systemd ソケットファイル

├── README.md                # 中国語ドキュメント

├── README\_EN.md             # 英語ドキュメント

└── README\_JA.md             # 日本語ドキュメント

```



\## 🔒 セキュリティ推奨事項



1\. \*\*最小権限の原則\*\*: 必要な場合のみ root 権限を使用

2\. \*\*定期的な更新\*\*: Docker を最新の安定版に保つ

3\. \*\*ネットワーク分離\*\*: ファイアウォールを使用して Docker API アクセスを制限

4\. \*\*イメージセキュリティ\*\*: 信頼できるイメージソースのみを使用

5\. \*\*ログ監査\*\*: ログ記録を有効にして定期的にレビュー

6\. \*\*リソース制限\*\*: コンテナに CPU とメモリの制限を設定



```bash

\# コンテナリソースの制限

docker run -d \\

&nbsp; --cpus="1.5" \\

&nbsp; --memory="512m" \\

&nbsp; --memory-swap="1g" \\

&nbsp; nginx

```



\## 👤 著者



\*\*HTY1024\*\*



\- Git: \[@HTY1024](https://git.hty1024.com/HTY1024)



\## 🙏 謝辞



以下のプロジェクトとリソースに感謝します:



\- \[Docker](https://www.docker.com/)

\- \[Docker Compose](https://docs.docker.com/compose/)

\- \[Docker Swarm](https://docs.docker.com/engine/swarm/)



\[トップに戻る](#docker-tools)

