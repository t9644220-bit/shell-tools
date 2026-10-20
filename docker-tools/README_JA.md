# Docker Tools

[![Version](https://img.shields.io/badge/version-2.4.0-blue.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/docker-tools)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Docker Engine、Docker Compose、Docker Swarm のワンクリックデプロイをサポートする、Docker の自動インストール、管理、メンテナンスツール。

[中文](README.md) | [English](README_EN.md)

## 📋 目次

- [機能](#機能)
- [システム要件](#システム要件)
- [クイックスタート](#クイックスタート)
- [インストール方法](#インストール方法)
- [使用方法](#使用方法)
- [設定](#設定)
- [よくある質問](#よくある質問)
- [トラブルシューティング](#トラブルシューティング)
- [貢献](#貢献)
- [ライセンス](#ライセンス)

## ✨ 機能

### コア機能
- ✅ **ワンクリックインストール** - Docker Engine と Docker Compose の自動インストール
- ✅ **オンライン/オフラインインストール** - オンラインダウンロードとオフラインパッケージデプロイの両方をサポート
- ✅ **バージョン管理** - 特定バージョンのインストールとアップデートをサポート
- ✅ **クラスターサポート** - Docker Swarm クラスター設定を内蔵
- ✅ **完全アンインストール** - Docker 関連のファイルと設定を完全にクリーンアップ
- ✅ **自動バックアップ** - 操作前に重要な設定ファイルを自動的にバックアップ

### システム管理
- 🔧 システムカーネルパラメータの自動設定
- 🔧 Docker ユーザーとグループの自動作成
- 🔧 環境変数の自動設定
- 🔧 systemd サービスの自動設定
- 🔧 起動時の自動起動をサポート

### ユーザーエクスペリエンス
- 🎨 見やすいカラーログ出力
- 🎨 詳細な操作プロンプトと進行状況表示
- 🎨 誤操作を防ぐインタラクティブ確認
- 🎨 包括的なエラー処理とプロンプト

## 💻 システム要件

### サポートされているオペレーティングシステム
- CentOS 7/8/9
- RHEL 7/8/9
- Ubuntu 18.04/20.04/22.04
- Debian 10/11/12
- openSUSE Leap 15.x/16.x
- systemd をサポートするその他の Linux ディストリビューション

### サポートされている CPU アーキテクチャ
- x86_64 (amd64)
- aarch64 (arm64)
- その他のアーキテクチャ (armv7l など) は非対応で、スクリプトはエラー終了します

### システム要件
- **OS**: Linux (カーネル 3.10+)
- **権限**: root または sudo
- **ディスク容量**: 最低 10GB の空き容量
- **メモリ**: 2GB 以上推奨
- **依存ツール**: 
  - `iptables` (必須)
  - `tar` (必須)
  - `curl` と `wget` (オンラインインストール時に必須)

## 🚀 クイックスタート

### 1. スクリプトのダウンロード

```bash
# 方法 1: git でクローン
git clone https://git.hty1024.com/HTY1024/shell_tools.git
cd shell_tools/docker-tools

# 方法 2: 直接ダウンロード
wget https://git.hty1024.com/HTY1024/shell_tools/raw/branch/main/releases/docker-tools_v2.4.0.zip
unzip docker-tools_v2.4.0.zip -d docker-tools && cd docker-tools
```

### 2. 実行権限の付与

```bash
chmod +x docker-tools
```

### 3. インストールの実行

```bash
# デフォルト設定でインストール
sudo ./docker-tools install

# またはバージョンを指定
sudo ./docker-tools -v 29.5.2 -c v5.1.4 install
```

### 4. インストールの確認

```bash
# Docker バージョンの確認
docker --version

# Docker Compose バージョンの確認
docker-compose --version

# Docker 情報の表示
docker info
```

## 📦 インストール方法

### 方法 1: オンラインインストール（推奨）

**利点**: 最新バージョンを自動ダウンロード、パッケージの準備不要

```bash
# デフォルトインストール (Docker 29.5.2 + Compose v5.1.4)
sudo ./docker-tools install

# バージョン指定
sudo ./docker-tools -v 29.5.2 -c v5.1.4 install

# カスタムインストールディレクトリ
sudo ./docker-tools -i /data/docker -d /data/docker/data install
```

### 方法 2: オフラインインストール

**利点**: ネットワークがないサーバーやネットワーク制限のあるサーバーに適している

#### ステップ 1: パッケージの準備

ネットワークアクセスのあるマシンでパッケージをダウンロード:

```bash
# Docker Engine のダウンロード
wget https://download.docker.com/linux/static/stable/x86_64/docker-29.5.2.tgz

# Docker Compose のダウンロード
wget https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-x86_64
```

#### ステップ 2: ターゲットサーバーへのアップロード

```bash
# パッケージとスクリプトを同じディレクトリにアップロード
scp docker-29.5.2.tgz docker-compose-linux-x86_64 docker-tools user@server:/path/to/dir/
```

#### ステップ 3: オフラインインストールの実行

```bash
sudo ./docker-tools -p docker-29.5.2.tgz -n docker-compose-linux-x86_64 install
```

### 方法 3: Docker Engine のみインストール

```bash
# Docker Engine のみインストール、Docker Compose はスキップ
sudo ./docker-tools -a install
```

### 方法 4: Docker Compose のみインストール

```bash
# Docker Compose のみインストール (docker ユーザー・インストールディレクトリ・環境変数を自動作成し、Docker Engine が稼働中なら再起動します)
sudo ./docker-tools -b install
```

## 📖 使用方法

### 基本コマンド

```bash
# ヘルプの表示
./docker-tools help

# バージョンの表示
./docker-tools version

# Docker のインストール
sudo ./docker-tools install

# Docker のアンインストール
sudo ./docker-tools uninstall

# Docker の更新
sudo ./docker-tools update

# Docker の起動
sudo ./docker-tools start

# Docker の停止
sudo ./docker-tools stop

# Docker の再起動
sudo ./docker-tools restart

# 自動起動の有効化
sudo ./docker-tools enable

# 自動起動の無効化
sudo ./docker-tools disable

# Docker 情報の表示
sudo ./docker-tools info
```

### 高度な使用方法

#### 1. カスタムインストールディレクトリ

```bash
# インストールディレクトリとデータディレクトリを指定
sudo ./docker-tools \
  -i /data/docker \
  -d /data/docker/data \
  install
```

#### 2. バージョンの指定

```bash
# Docker と Compose の特定バージョンをインストール
sudo ./docker-tools \
  -v 28.2.1 \
  -c v2.36.2 \
  install
```

#### 3. オフラインインストール

```bash
# ローカルパッケージを使用したオフラインインストール
sudo ./docker-tools \
  -p docker-29.5.2.tgz \
  -n docker-compose-linux-x86_64 \
  install
```

#### 4. Docker Swarm クラスターのデプロイ

**Manager ノード**:

```bash
# Docker をインストールして Swarm Manager を初期化
sudo ./docker-tools -s install

# インストール後、Worker Token を取得
docker swarm join-token worker
# 出力例:
# docker swarm join --token SWMTKN-1-xxx... 192.168.1.100:2377
```

**Worker ノード**:

```bash
# Manager の IP と Token でクラスターに参加
sudo ./docker-tools \
  -s \
  -r worker \
  -m 192.168.1.100 \
  -t SWMTKN-1-xxx... \
  install
```

#### 5. Docker バージョンの更新

```bash
# 指定バージョンへのオンライン更新
sudo ./docker-tools -v 29.5.2 update

# オフライン更新 (Docker Engine のみ。Compose も更新する場合は -n でパッケージを指定)
sudo ./docker-tools -a -p docker-29.5.2.tgz update
```

## ⚙️ 設定

### コマンドラインパラメータ

| パラメータ | 説明 | デフォルト | 例 |
|-----------|------|-----------|-----|
| `-v` | Docker Engine バージョン | 29.5.2 | `-v 28.2.1` |
| `-i` | Docker インストールディレクトリ | /opt/docker | `-i /data/docker` |
| `-d` | Docker データディレクトリ | /opt/docker/data | `-d /data/docker/data` |
| `-p` | Docker Engine パッケージ名 (オフライン) | - | `-p docker-29.5.2.tgz` |
| `-c` | Docker Compose バージョン | v5.1.4 | `-c v2.36.2` |
| `-n` | Docker Compose パッケージ名 (オフライン) | - | `-n docker-compose-linux-x86_64` |
| `-a` | Docker Engine のみインストール | false | `-a` |
| `-b` | Docker Compose のみインストール | false | `-b` |
| `-s` | Docker Swarm を有効化 | false | `-s` |
| `-r` | Swarm ロール (manager/worker) | manager | `-r worker` |
| `-m` | Swarm Manager IP | 127.0.0.1 | `-m 192.168.1.100` |
| `-t` | Swarm Token (worker に必須) | - | `-t SWMTKN-1-xxx...` |

### スクリプト設定

スクリプト内の設定変数を直接変更できます:

```bash
# スクリプトの編集
vim docker-tools

# これらの変数を変更
DOCKER_VERSION=29.5.2              # Docker バージョン
DOCKER_INSTALL_DIR=/opt/docker     # インストールディレクトリ (バイナリは bin/、CLI 設定は conf/)
DOCKER_DATA_DIR=/opt/docker/data   # データディレクトリ
NEED_ENABLE_DOCKER=true            # 起動時の自動起動
```

### Docker Daemon 設定

デフォルト設定ファイル `daemon.json`:

```json
{
  "exec-opts" : ["native.cgroupdriver=systemd"],
  "log-level": "warn",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },
  "registry-mirrors": [
    "https://dockerpull.org",
    "https://hub.geekery.cn",
    "https://docker.1ms.run"
  ],
  "bip": "10.21.21.1/24",
  "data-root": "{{DOCKER_DATA_DIR}}",
  "live-restore": {{DOCKER_LIVE_RESTORE}}
}
```

必要に応じてカスタマイズ:

```bash
# 設定ファイルの編集
vim daemon.json

# レジストリミラーの追加
"registry-mirrors": [
  "https://mirror.ccs.tencentyun.com",
  "https://docker.mirrors.ustc.edu.cn"
]

# プライベートレジストリの追加
"insecure-registries": [
  "192.168.1.100:5000"
]
```

## ❓ よくある質問

### Q1: 依存関係が不足しているためインストールに失敗する

**A**: まず必要な依存関係をインストールしてください:

```bash
# CentOS/RHEL
sudo yum install -y iptables tar curl

# Ubuntu/Debian
sudo apt-get install -y iptables tar curl

# openSUSE
sudo zypper install -y iptables tar curl
```

### Q2: 環境変数が有効にならない

**A**: インストール後に手動で実行してください:

```bash
source ~/.bashrc
source /etc/profile

# またはシステムに再ログイン
```

### Q3: Docker サービスの起動に失敗する

**A**: ログを確認して原因を調査:

```bash
# サービスステータスの確認
sudo systemctl status docker

# 詳細ログの表示
sudo journalctl -u docker -n 50

# 設定の確認
sudo docker info
```

### Q4: オフラインインストール時にパッケージが見つからない

**A**: パッケージがスクリプトと同じディレクトリにあることを確認:

```bash
# ファイルの確認
ls -lh docker-*.tgz docker-compose-*

# 正しいファイル名を確認
./docker-tools -p docker-29.5.2.tgz -n docker-compose-linux-x86_64 install
```

### Q5: アンインストール後に残留ファイルがある

**A**: 手動でクリーンアップ:

```bash
# データディレクトリの削除
sudo rm -rf /opt/docker
sudo rm -rf /var/lib/docker

# 設定ファイルの削除
sudo rm -rf /etc/docker

# 環境変数設定の削除
vim ~/.bashrc  # Docker Env 関連行を削除
vim /etc/profile
```

### Q6: Docker Swarm への参加に失敗する

**A**: ネットワークとファイアウォールを確認:

```bash
# ポート接続性の確認
telnet <manager-ip> 2377

# 必要なポートを開放 (Manager ノード)
sudo firewall-cmd --permanent --add-port=2377/tcp  # クラスター管理
sudo firewall-cmd --permanent --add-port=7946/tcp  # ノード通信
sudo firewall-cmd --permanent --add-port=7946/udp
sudo firewall-cmd --permanent --add-port=4789/udp  # オーバーレイネットワーク
sudo firewall-cmd --reload

# またはテスト用に一時的にファイアウォールを無効化
sudo systemctl stop firewalld
```

### Q7: 権限拒否エラー

**A**: root 権限を使用していることを確認:

```bash
# sudo を使用
sudo ./docker-tools install

# または root ユーザーに切り替え
su -
./docker-tools install
```

### Q8: 更新後にバージョンが正しくない

**A**: キャッシュをクリアして再インストール:

```bash
# 完全アンインストール
sudo ./docker-tools uninstall

# オンラインインストール時にカレントディレクトリへダウンロードされたパッケージを削除
rm -f docker-*.tgz* docker-compose-linux-*

# 再インストール
sudo ./docker-tools -v 29.5.2 install
```

## 🔧 トラブルシューティング

### ログの場所

```bash
# システムログ
sudo journalctl -u docker -f

# スクリプト自体はログファイルを出力せず、実行結果は端末に表示されます
```

### 一般的なエラーと解決策

#### エラー 1: "Cannot connect to the Docker daemon"

```bash
# サービスステータスの確認
sudo systemctl status docker

# サービスの起動
sudo systemctl start docker

# ソケットの確認
sudo systemctl status docker.socket
```

#### エラー 2: "permission denied while trying to connect"

```bash
# 現在のユーザーを docker グループに追加
sudo usermod -aG docker $USER

# 再ログインまたは実行
newgrp docker
```

#### エラー 3: "Error response from daemon: conflict"

```bash
# 競合するコンテナ/ネットワークのクリーンアップ
docker system prune -a

# または手動で削除
docker rm -f $(docker ps -aq)
docker network prune
```

#### エラー 4: "no space left on device"

```bash
# ディスク容量の確認
df -h

# Docker データのクリーンアップ
docker system prune -a --volumes

# データディレクトリの変更
sudo ./docker-tools -d /data/docker/data install
```

### パフォーマンス最適化

#### 1. ストレージドライバーの調整

```bash
# daemon.json の編集
sudo vim /etc/docker/daemon.json

# ストレージドライバーの変更
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}

# Docker の再起動
sudo systemctl restart docker
```

#### 2. ログローテーションの設定

```bash
# daemon.json の編集
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "5"
  }
}
```

#### 3. 同時実行制限の調整

```bash
# daemon.json の編集
{
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10
}
```

## 📁 ファイル構造

```
docker-tools/
├── docker-tools             # メインスクリプト
├── daemon.json              # Docker daemon 設定テンプレート
├── docker.service           # systemd サービスファイル
├── docker.socket            # systemd ソケットファイル
├── README.md                # 中国語ドキュメント
├── README_EN.md             # 英語ドキュメント
└── README_JA.md             # 日本語ドキュメント
```

## 🔒 セキュリティ推奨事項

1. **最小権限の原則**: 必要な場合のみ root 権限を使用
2. **定期的な更新**: Docker を最新の安定版に保つ
3. **ネットワーク分離**: ファイアウォールを使用して Docker API アクセスを制限
4. **イメージセキュリティ**: 信頼できるイメージソースのみを使用
5. **ログ監査**: ログ記録を有効にして定期的にレビュー
6. **リソース制限**: コンテナに CPU とメモリの制限を設定

```bash
# コンテナリソースの制限
docker run -d \
  --cpus="1.5" \
  --memory="512m" \
  --memory-swap="1g" \
  nginx
```

## 📝 変更履歴
### v2.4.0 (2026-10-20)
#### 🐛 バグ修正
- `update` で Docker Compose を更新する際、変数名の誤字 (`DOCKER_INSTALL_DIRn`) により `set -u` 下で必ず中断する問題を修正
- デフォルトをオンラインインストールに戻す (v2.0.0 以降誤ってオフラインになっていた)。ヘルプの記載と一致。`-p` / `-n` は引き続きオフラインに切り替え
- オフラインパッケージ名のデフォルトを `-v` のバージョンから導出 (`docker-<バージョン>.tgz`)。`-v` が無視されなくなった
- `-b` (Compose のみ) が新規マシンでも動作：docker ユーザー・インストールディレクトリ・環境変数を自動作成し、オフライン時に Engine パッケージを要求しない
- `uninstall` で `docker.service` が存在しない場合は停止/自動起動解除をスキップし、後続のクリーンアップが中断しないよう修正
#### 📖 ドキュメント
- README の Markdown エスケープを修正、スクリプト名を `docker-tools` に統一、`-i` のデフォルトを `/opt/docker` に訂正、`daemon.json` の例を実際のテンプレートに合わせた
- ヘルプの `-i` 説明とサンプルパスを訂正
### v2.3.0 (2026-05-21)
#### 🆕 バージョン更新
- デフォルト Docker Engine を **29.5.2**、デフォルト Docker Compose を **v5.1.4** に更新
#### ✨ 変更
- インストールディレクトリのデフォルトを `/opt/docker/bin` から `/opt/docker` に変更 (バイナリは `bin/`、CLI 設定は `conf/`)
- 環境変数 `DOCKER_CONFIG=<インストールディレクトリ>/conf` を追加し、Compose を CLI プラグインとしてもインストール (`docker compose` 対応)
### v2.2.0 (2026-05-14)
- リリースパッケージ内のスクリプトが CRLF 改行で Linux 上で実行できない問題を修正し、LF を強制する `.gitattributes` を追加
### v2.1.0 (2026-04-24)
#### 🆕 バージョン更新
- デフォルト Docker Engine を **29.4.1** に更新
- デフォルト Docker Compose を **v5.1.3** に更新
#### 🐛 バグ修正
- サブコマンド分岐の修正：`case "$@"` が複数引数で一致しない問題、`info` が `info_docker` を呼べていなかった問題
- `check_net` の TIMEOUT 位置パラメータ誤用および 2xx/3xx を失敗扱いにしていた不具合を修正
- `backup_file` がディレクトリに対して機能せず、アップグレード時にバックアップされていなかった問題を修正
- `remove_env` が sed で残す空行を、範囲削除に切り替え
- `docker.service` のコメントと `ExecStart=` が同一行に残っていた残骸を修正
- スペルミスを修正（Dokcer / Coimpose / Conpose）
#### ✨ 堅牢性向上
- `config_env` を冪等化：再インストール時に `~/.bashrc`・`/etc/profile` への重複追記を回避
- スクリプト内で `source ~/.bashrc` を実行しないように変更（`set -u` 時の外部 rc による中断を防止）
- `daemon.json` のテンプレート置換後に `{{...}}` の残留を検証
- データディレクトリは owner のみ変更し、`chmod -R 755` によるイメージレイヤ権限破壊を回避
- 非推奨の `chown docker.docker` を `docker:docker` に更新
- `useradd/groupadd` のハードコード UID/GID=1001 を削除し衝突を防止
- `CPU_ARCH` をランタイム検出に変更、`aarch64` をサポート
- `getopts` に不明オプション / 引数欠落の分岐を追加。`-r/-m/-t` は Swarm を暗黙に有効化しない
- Swarm worker 役割での Manager IP と Token の強制バリデーション
- `only_install_docker_compose` は Docker Engine 未稼働時に restart/info をスキップ
### v2.0.0
- ロギングの再構築、`set -euo pipefail` の導入、インタラクティブ確認
### v1.3.x / v1.2.x / v1.1.x
- Git 履歴を参照
## 👤 著者

**HTY1024**

- Git: [@HTY1024](https://git.hty1024.com/HTY1024)

## 🙏 謝辞

以下のプロジェクトとリソースに感謝します:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Swarm](https://docs.docker.com/engine/swarm/)

[トップに戻る](#docker-tools)
