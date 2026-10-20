# Kubernetes Tools

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/kubernetes-tools)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://git.hty1024.com/HTY1024/shell_tools/src/branch/main/LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Kubernetes クラスタの自動インストール・管理・保守ツールです。**kubeadm + containerd** をベースに静的バイナリでインストールし、シングルノード、1 コントロールプレーン + 複数ワーカー、高可用性クラスタに対応します。オンライン・オフラインのどちらでもインストールできます。

[中文](README.md) | [English](README_EN.md)

> 設計とコード構成は [DESIGN.md](DESIGN.md)（中国語）を参照してください。
>
> ツールが出力するログやプロンプトは中国語です。本マニュアルでツールの出力を引用する箇所には日本語訳を併記しています。

## 📋 目次

- [機能](#-機能)
- [システム要件](#-システム要件)
- [クイックスタート](#-クイックスタート)
- [デプロイシナリオ](#-デプロイシナリオ)
- [コマンド](#-コマンド)
- [設定パラメータ](#️-設定パラメータ)
- [日常運用](#-日常運用)
- [よくある質問](#-よくある質問)
- [トラブルシューティング](#-トラブルシューティング)
- [ファイル構成](#-ファイル構成)
- [更新履歴](#-更新履歴)

## ✨ 機能

### 主な機能
- ✅ **ワンコマンドデプロイ**：コンポーネントのインストールからクラスタの初期化・参加までを 1 コマンドで実行
- ✅ **オンライン/オフラインインストール**：`download` でパッケージをまとめ、`save-images` でイメージをエクスポートするため、閉域環境でも利用可能
- ✅ **複数の構成**：シングルノード、1 コントロールプレーン + 複数ワーカー、ロードバランサー配下に複数コントロールプレーンを置く高可用性クラスタ
- ✅ **ネットワークプラグイン**：Flannel（デフォルト）と Calico を内蔵。`none` を選んで自前でインストールすることも可能
- ✅ **バージョンアップグレード**：kubeadm 公式の手順に従いマイナーバージョンを 1 つずつアップグレード。`upgrade apply` と `upgrade node` を自動で使い分け
- ✅ **完全アンインストール**：クラスタから離脱し、プログラム・データ・システム設定を削除。swap のマウント設定も元に戻す

### システム管理
- 🔧 swap を無効化し、`overlay` と `br_netfilter` モジュールをロードし、カーネルパラメータを設定
- 🔧 SELinux を permissive に設定（RHEL 系）
- 🔧 containerd の設定を自動生成（systemd cgroup、pause イメージ、データディレクトリ、レジストリミラー）
- 🔧 systemd サービス、環境変数、kubectl を自動設定
- 🔧 すべてのパッケージを SHA256 で検証

### ユーザー体験
- 🎨 docker-tools と同じスタイルのカラーログ出力
- 🎨 実行前にパラメータを表示して確認（自動化向けに `-y` で確認をスキップ可能）
- 🎨 インストール完了後、そのままコピーして使えるノード参加コマンドを表示
- 🎨 依存コマンドが不足している場合、ディストリビューションに合ったインストールコマンドを表示

## 💻 システム要件

### 対応 OS

| ディストリビューション | バージョン | 備考 |
|---|---|---|
| RHEL / CentOS Stream / Rocky / AlmaLinux | 8、9、10 | SELinux を自動で permissive に設定 |
| Fedora | 最近のリリース | zram の swap は手動で無効化が必要（[Q3](#q3-swap-がまだ有効だと表示される) を参照） |
| Ubuntu | 20.04、22.04、24.04 | |
| Debian | 11、12、13 | |
| openSUSE Leap / SLES | 15.x、16.x | |

systemd を使用するその他のディストリビューションでも通常は動作します。systemd を使用しないディストリビューション（Alpine など）には対応していません。

### ハードウェアと環境

| 項目 | 要件 |
|---|---|
| CPU アーキテクチャ | x86_64（amd64）、aarch64（arm64） |
| CPU / メモリ | コントロールプレーンは 2 コア・2GB 以上、ワーカーは 1 コア・1GB 以上 |
| 権限 | root（`help`、`version`、`download` を除く） |
| ネットワーク | ノード間が相互に通信可能であること。ホスト名が一意で RFC 1123 に準拠していること（小文字の英字、数字、`-`、`.`） |
| 依存コマンド | `tar` `iptables` `conntrack` `socat` `ip` `mount` `nsenter` `modprobe` `sysctl` `sha256sum`。オンラインインストールでは `curl` も必要 |

依存パッケージのインストール例：

```bash
# RHEL / CentOS / Rocky / Alma / Fedora
dnf install -y tar iptables conntrack-tools socat iproute util-linux kmod curl

# Debian / Ubuntu
apt-get install -y tar iptables conntrack socat iproute2 util-linux kmod curl

# openSUSE / SLES
zypper install -y tar iptables conntrack-tools socat iproute2 util-linux kmod curl
```

> 依存コマンドが不足している場合、スクリプトが不足しているコマンドと対応するインストールコマンドを表示します。

### デフォルトのコンポーネントバージョン

| コンポーネント | バージョン |
|---|---|
| Kubernetes（kubeadm / kubelet / kubectl） | 1.37.1（`-v` で指定可能） |
| containerd | 2.4.2 |
| runc | 1.5.2 |
| CNI plugins | 1.9.1 |
| crictl | 1.37.0 |
| Flannel | 0.28.10 |
| Calico | 3.33.0 |

## 🚀 クイックスタート

### 1. ツールの取得

```bash
# 方法 1：git でクローン
git clone https://git.hty1024.com/HTY1024/shell_tools.git
cd shell_tools/kubernetes-tools

# 方法 2：リリースパッケージをダウンロード
wget https://git.hty1024.com/HTY1024/shell_tools/raw/branch/main/releases/kubernetes-tools_v1.0.0.zip
unzip kubernetes-tools_v1.0.0.zip -d kubernetes-tools && cd kubernetes-tools
```

### 2. 実行権限の付与

```bash
chmod +x kubernetes-tools
```

### 3. シングルノードクラスタのインストール

```bash
# -u：コントロールプレーンへの Pod スケジューリングを許可（シングルノードクラスタで必要）
sudo ./kubernetes-tools -u install
```

処理の流れ：環境チェック → パラメータ表示と確認 → パッケージのダウンロードと検証 → システム設定 → containerd と Kubernetes コンポーネントのインストール → `kubeadm init` → kubectl の設定 → ネットワークプラグインのインストール → ノードが Ready になるまで待機 → ノード参加コマンドの表示。

### 4. インストールの確認

```bash
source ~/.bashrc
kubectl get nodes -o wide
kubectl get pods -A
```

## 🧭 デプロイシナリオ

### シナリオ 1：シングルノードクラスタ（開発/テスト）

```bash
sudo ./kubernetes-tools -u install
```

### シナリオ 2：1 コントロールプレーン + 複数ワーカー

**コントロールプレーンノード**（例：`192.168.1.10`）：

```bash
sudo ./kubernetes-tools install
```

インストールが完了すると、次のような参加コマンドが表示されます（後から `./kubernetes-tools token` でいつでも再生成できます）：

```text
Worker 节点（Token 有效期 24 小时）：
  kubernetes-tools -r worker -m 192.168.1.10:6443 -t abcdef.0123456789abcdef -s sha256:1234...cdef install
```

（1 行目は「ワーカーノード（トークンの有効期限は 24 時間）：」という意味です。）

**ワーカーノード**：ツールのディレクトリをワーカーにコピーし、上のコマンドを実行します：

```bash
sudo ./kubernetes-tools -r worker -m 192.168.1.10:6443 \
  -t abcdef.0123456789abcdef \
  -s sha256:1234...cdef \
  install
```

コントロールプレーンに戻り、`kubectl get nodes` でノードの状態を確認します。

### シナリオ 3：高可用性クラスタ（複数コントロールプレーン）

高可用性クラスタには、先に**ロードバランサーのエンドポイント**（HAProxy + Keepalived の VIP やクラウドのロードバランサーなど）を用意し、`VIP:6443` をすべてのコントロールプレーンノードの `6443` ポートに転送する必要があります。本ツールはロードバランサーをデプロイしません。

> 1 台目のコントロールプレーンを初期化する前に、ロードバランサーがそのノードへトラフィックを転送できる状態になっている必要があります。そうでないと `kubeadm init` が失敗します。

**1 台目のコントロールプレーンノード**：

```bash
sudo ./kubernetes-tools -e 192.168.1.100:6443 install
```

`-e` を指定すると kubeadm がコントロールプレーンの証明書をアップロードし、出力にコントロールプレーン用の参加コマンドが追加されます：

```text
控制平面节点（证书密钥有效期 2 小时）：
  kubernetes-tools -r control-plane -m 192.168.1.100:6443 -t ... -s sha256:... -c <証明書キー> install
```

（1 行目は「コントロールプレーンノード（証明書キーの有効期限は 2 時間）：」という意味です。）

**その他のコントロールプレーンノード**：

```bash
sudo ./kubernetes-tools -r control-plane -m 192.168.1.100:6443 \
  -t abcdef.0123456789abcdef -s sha256:1234...cdef -c 0a1b...9f \
  install
```

**ワーカーノード**：シナリオ 2 と同じです。`-m` にはロードバランサーのアドレスを指定します。

> etcd のリーダー選出を正常に行えるよう、コントロールプレーンノードは奇数台（3 台または 5 台）にしてください。すべてのコントロールプレーンノードでデータディレクトリ（`-d`）を揃える必要があります。

### シナリオ 4：オフラインインストール（閉域環境）

**ステップ 1：インターネットに接続できるマシンでパッケージをダウンロード**（root 不要、任意の Linux で可）

```bash
./kubernetes-tools download                  # ホストのアーキテクチャ + Flannel
./kubernetes-tools -n calico download        # Calico を使用
./kubernetes-tools -b arm64 download         # arm64 用パッケージをダウンロード
./kubernetes-tools -v 1.37.2 download        # Kubernetes のバージョンを指定
```

パッケージは `packages/` ディレクトリに保存されます。各パッケージの横にある `.sha256` ファイルは、オフラインインストール時の検証に使われます。

**ステップ 2：インターネットに接続できるマシンでイメージをエクスポート**（先にコンポーネントのインストールが必要。例：`-a install`）

```bash
sudo ./kubernetes-tools -a install           # コンポーネントのみインストールし、クラスタは初期化しない
sudo ./kubernetes-tools save-images          # packages/k8s-images-v<バージョン>-<ネットワークプラグイン>-linux-<アーキテクチャ>.tar にエクスポート
sudo ./kubernetes-tools -b arm64 save-images # arm64 用イメージをエクスポート
```

イメージアーカイブには、Kubernetes コンポーネントのイメージ（apiserver、controller-manager、scheduler、proxy、coredns、etcd、pause）とネットワークプラグインのイメージが含まれます。

**ステップ 3：対象サーバーにコピーしてオフラインインストール**

```bash
scp -r kubernetes-tools/ root@192.168.1.10:/root/
ssh root@192.168.1.10
cd /root/kubernetes-tools
./kubernetes-tools -o install                # コントロールプレーン
./kubernetes-tools -o -r worker -m 192.168.1.10:6443 -t ... -s ... install   # ワーカー
```

> `-v`、`-n`、`-g` は `download` と `save-images` を実行したときと同じ値にしてください。異なると対応するパッケージが見つかりません。
> 内部ネットワークにプライベートレジストリがある場合は、イメージアーカイブを使わず、`-g` でプライベートレジストリを指定し、事前にイメージを push しておく方法もあります。

### シナリオ 5：中国本土のネットワーク環境

```bash
sudo ./kubernetes-tools \
  -g registry.aliyuncs.com/google_containers \
  -w docker.io=https://docker.1ms.run,ghcr.io=https://ghcr.nju.edu.cn,quay.io=https://quay.nju.edu.cn \
  install
```

- `-g`：Kubernetes コンポーネントのイメージ（pause を含む）に使うレジストリ
- `-w`：containerd のレジストリミラー。`/etc/containerd/certs.d/<レジストリ>/hosts.toml` に書き込まれます。1 つのレジストリに複数のミラーを指定でき、順番に試されます
- `dl.k8s.io` や `github.com` からのダウンロードが遅い場合は、回線の良いマシンで `download` を実行してからオフラインインストールしてください

> ミラーの可用性は変わるため、現時点で利用できるアドレスを使ってください。ワーカーの `-g`、`-w` はコントロールプレーンと揃えてください。

### シナリオ 6：段階的インストール（先にコンポーネント、後でクラスタ）

```bash
sudo ./kubernetes-tools -a install                       # 全ノード：コンポーネントのみインストール
sudo ./kubernetes-tools init                             # コントロールプレーン：クラスタを初期化
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # ワーカー：クラスタに参加
```

## 📖 コマンド

```text
kubernetes-tools [パラメータ] <コマンド>
```

| コマンド | 説明 | 実行するノード |
|---|---|---|
| `help` | ヘルプを表示（コマンド省略時のデフォルト） | 任意 |
| `version` | ツールのバージョンを表示 | 任意 |
| `download` | オフライン用パッケージをパッケージディレクトリにダウンロード（root 不要） | インターネットに接続できる任意のマシン |
| `save-images` | オフライン用イメージアーカイブを取得してエクスポート | コンポーネントをインストール済みで、インターネットに接続できるノード |
| `install` | コンポーネントをインストールし、ロールに応じてクラスタを初期化または参加 | 全ノード |
| `init` | クラスタを初期化 | コンポーネントをインストール済みのコントロールプレーン |
| `join` | クラスタに参加（`-r worker` または `-r control-plane` が必要） | コンポーネントをインストール済みのノード |
| `token` | ノード参加コマンドを生成 | コントロールプレーン |
| `reset` | ノードをリセット：クラスタから離脱してクラスタデータを削除。インストール済みのコンポーネントは残す | 全ノード |
| `uninstall` | アンインストール：クラスタから離脱し、すべてのファイルを削除 | 全ノード |
| `update` | Kubernetes のバージョンをアップグレード | 全ノード |
| `start` / `stop` / `restart` | containerd と kubelet を起動・停止・再起動 | 全ノード |
| `enable` / `disable` | containerd と kubelet の自動起動を設定・解除 | 全ノード |
| `info` | コンポーネントのバージョン、サービスの状態、ノードと Pod の情報を表示 | 全ノード |

## ⚙️ 設定パラメータ

### コマンドラインパラメータ

| パラメータ | 説明 | デフォルト | 例 |
|---|---|---|---|
| `-v` | Kubernetes のバージョン | 1.37.1 | `-v 1.37.2` |
| `-i` | インストールディレクトリ（プログラムは `bin/`、設定は `conf/`） | /opt/kubernetes | `-i /data/kubernetes` |
| `-d` | データディレクトリ（containerd のデータは `containerd/`、etcd のデータは `etcd/`） | /opt/kubernetes/data | `-d /data/kubernetes/data` |
| `-k` | パッケージディレクトリ | スクリプトと同じ階層の `packages/` | `-k /mnt/usb/packages` |
| `-o` | オフラインインストール | オンライン | `-o` |
| `-b` | パッケージのアーキテクチャ（`download`、`save-images` のみ） | ホストのアーキテクチャ | `-b arm64` |
| `-r` | ノードのロール：`master`、`worker`、`control-plane` | master | `-r worker` |
| `-a` | コンポーネントのみインストールし、クラスタの初期化・参加は行わない | いいえ | `-a` |
| `-l` | 自ノードの通信アドレス（advertise address） | 自動検出 | `-l 192.168.1.10` |
| `-e` | コントロールプレーンのエンドポイント（高可用性） | なし | `-e 192.168.1.100:6443` |
| `-m` | 参加先クラスタの API Server アドレス（ポート省略時は 6443） | なし | `-m 192.168.1.10` |
| `-t` | クラスタ参加用のトークン | なし | `-t abcdef.0123456789abcdef` |
| `-s` | CA 証明書ハッシュ（`sha256:` プレフィックスは省略可） | なし | `-s sha256:1234...` |
| `-c` | コントロールプレーンとして参加する際の証明書キー | なし | `-c 0a1b...` |
| `-n` | ネットワークプラグイン：`flannel`、`calico`、`none` | flannel | `-n calico` |
| `-p` | Pod ネットワーク | 10.244.0.0/16 | `-p 172.16.0.0/16` |
| `-x` | Service ネットワーク | 10.96.0.0/12 | `-x 10.100.0.0/16` |
| `-g` | Kubernetes のイメージレジストリ | registry.k8s.io | `-g registry.aliyuncs.com/google_containers` |
| `-w` | レジストリミラー（`レジストリ=URL`、複数はカンマ区切り） | なし | `-w docker.io=https://docker.1ms.run` |
| `-u` | コントロールプレーンへの Pod スケジューリングを許可（シングルノードクラスタ） | いいえ | `-u` |
| `-y` | 確認プロンプトをスキップ | いいえ | `-y` |

> ロール：`master` は新しいクラスタを初期化します（1 台目のコントロールプレーン）。`worker` はワーカーノードとして参加します。`control-plane` は追加のコントロールプレーンとして高可用性クラスタに参加します。

### スクリプト内の設定

あまり使わない設定は、スクリプト冒頭の変数を直接編集して変更します：

```bash
vim kubernetes-tools

CONTAINERD_VERSION=2.4.2           # containerd のバージョン
RUNC_VERSION=1.5.2                 # runc のバージョン
CNI_PLUGINS_VERSION=1.9.1          # CNI プラグインのバージョン
CRICTL_VERSION=1.37.0              # crictl のバージョン
FLANNEL_VERSION=0.28.10            # Flannel のバージョン
CALICO_VERSION=3.33.0              # Calico のバージョン
KUBE_PROXY_MODE=iptables           # kube-proxy のモード：iptables、ipvs、nftables
NEED_DISABLE_SWAP=true             # swap を無効化するかどうか
KUBEADM_IGNORE_PREFLIGHT_ERRORS="" # 無視する kubeadm のプリフライトエラー（例：NumCPU,Mem）
K8S_PACKAGE_URL=https://dl.k8s.io/release   # 各コンポーネントのダウンロード URL（社内ミラーに変更可能）
```

> 新しいカーネルでは `nftables` モードを推奨します。`ipvs` モードは Kubernetes 1.35 で非推奨になりました。

### kubeadm 設定テンプレート

`kubeadm-config.yaml` は `kubeadm init` 用の設定テンプレートで、`{{...}}` はプレースホルダーです。テンプレートには kubeadm の他のフィールドも追加できます。たとえば API Server 証明書に SAN を追加する場合：

```yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
...
apiServer:
  certSANs:
    - k8s.example.com
    - 192.168.1.100
```

レンダリング後の設定は `<インストールディレクトリ>/conf/kubeadm-config.yaml` に、初期化ログは `<インストールディレクトリ>/conf/kubeadm-init.log` に保存されます（トークンを含むため root のみ読み取り可能）。

## 🛠 日常運用

### ノードの追加

```bash
# コントロールプレーン：新しい参加コマンドを生成（トークンの有効期限はデフォルトで 24 時間）
sudo ./kubernetes-tools token

# 新しいノード：表示されたコマンドを実行
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... install
```

### ノードの削除

```bash
# コントロールプレーン：Pod を退避してノードを削除
kubectl drain <ノード名> --ignore-daemonsets --delete-emptydir-data
kubectl delete node <ノード名>

# 削除したノード：クラスタから離脱（コンポーネントは残す）、または完全にアンインストール
sudo ./kubernetes-tools reset
sudo ./kubernetes-tools uninstall
```

### Kubernetes のアップグレード

kubeadm は**マイナーバージョンを 1 つずつ**しかアップグレードできず（例：1.36.x → 1.37.x）、ダウングレードには対応していません。アップグレードの順序は **1 台目のコントロールプレーン → その他のコントロールプレーン → ワーカー** で、1 ノードずつ行います。

```bash
# 1. （コントロールプレーンで実行）アップグレードするノードの Pod を退避
kubectl drain <ノード名> --ignore-daemonsets

# 2. （アップグレードするノードで実行）アップグレード
sudo ./kubernetes-tools -v 1.37.2 update            # オンライン
sudo ./kubernetes-tools -o -v 1.37.2 update         # オフライン（事前に download / save-images が必要）

# 3. （コントロールプレーンで実行）スケジューリングを再開
kubectl uncordon <ノード名>
```

スクリプトは次のルールでアップグレード方法を判定します：
- コントロールプレーンノードで、クラスタのバージョンがまだ目標バージョンでない場合は、最初にアップグレードするコントロールプレーンとみなし、`kubeadm upgrade plan` と `kubeadm upgrade apply` を実行
- その他のコントロールプレーンとワーカーは `kubeadm upgrade node` を実行
- アップグレード前に、旧バージョンの kubeadm、kubelet、kubectl を `<インストールディレクトリ>/backup/<日時>/` にバックアップ

> `update` がアップグレードするのは Kubernetes のコンポーネントだけです。containerd や runc をアップグレードする場合は手動で置き換えてください：ノードを `kubectl drain` し、`stop` を実行して新しいバージョンを `<インストールディレクトリ>/bin` に上書き展開し、`start` と `kubectl uncordon` を実行します。

### 証明書の管理

kubeadm が発行する証明書の有効期限は 1 年です。`update` を実行すると自動で更新されます。

```bash
kubeadm certs check-expiration   # 証明書の有効期限を確認
kubeadm certs renew all          # すべての証明書を手動で更新（その後コントロールプレーンのコンポーネントを再起動）
```

### サービスの管理

```bash
sudo ./kubernetes-tools start      # containerd、kubelet を起動
sudo ./kubernetes-tools stop       # kubelet、containerd を停止
sudo ./kubernetes-tools restart    # 再起動
sudo ./kubernetes-tools enable     # 自動起動を有効化
sudo ./kubernetes-tools disable    # 自動起動を無効化
sudo ./kubernetes-tools info       # 情報を表示
```

> `stop` しても実行中のコンテナは停止しません。containerd は `KillMode=process` を使用しており、これは Kubernetes の標準的な構成です。

### アンインストール

```bash
sudo ./kubernetes-tools uninstall
# カスタムディレクトリを使用した場合は、同じディレクトリを指定
sudo ./kubernetes-tools -i /data/kubernetes -d /data/kubernetes/data uninstall
```

アンインストールでは `kubeadm reset` を実行し、サービスを停止・削除したうえで、次を削除します：インストールディレクトリ、データディレクトリ、`/etc/kubernetes`、`/var/lib/kubelet`、`/etc/containerd`、`/etc/cni`、`/opt/cni/bin`、`~/.kube/config`、環境変数、カーネルパラメータのファイル。インストール時にコメントアウトした swap のマウント設定も元に戻します。

次のものは変更しません：インストール済みのシステム依存パッケージ、SELinux の設定、iptables のルール（クリーンアップ用のコマンドはアンインストール時に表示されます）、`packages/` ディレクトリ。

## ❓ よくある質問

### Q1: 依存コマンドが不足していると表示される

メッセージに表示されたコマンドでインストールしてください。例：

```bash
dnf install -y conntrack-tools socat
```

### Q2: 環境変数が反映されず、kubectl が見つからない

```bash
source ~/.bashrc
source /etc/profile
# または再ログイン
```

### Q3: swap がまだ有効だと表示される

Fedora などのディストリビューションは、デフォルトで zram による swap を作成します：

```bash
swapoff -a
dnf remove -y zram-generator-defaults   # または touch /etc/systemd/zram-generator.conf
```

### Q4: イメージの取得に失敗する（ImagePull / ErrImagePull）

- Kubernetes コンポーネントのイメージ：`-g registry.aliyuncs.com/google_containers` でアクセス可能なレジストリに切り替える
- ネットワークプラグインのイメージ（ghcr.io / quay.io / docker.io）：`-w` でミラーを設定するか、オフライン用イメージアーカイブを使用する
- 具体的なエラーの確認：`crictl pull <イメージ>`、`journalctl -u containerd -n 50`

### Q5: ノードが NotReady のまま

```bash
kubectl get pods -n kube-flannel -o wide       # Flannel
kubectl get pods -n kube-system -l k8s-app=calico-node   # Calico
kubectl describe node <ノード名>
```

よくある原因：ネットワークプラグインのイメージ取得に失敗している。Pod ネットワークがノードのネットワークと重複している（`-p` で変更）。ファイアウォールが Flannel の 8472/udp や Calico の 179/tcp を遮断している。

### Q6: トークンの有効期限が切れてクラスタに参加できない

トークンはデフォルトで 24 時間、証明書キーは 2 時間で失効します。コントロールプレーンで再生成してください：

```bash
sudo ./kubernetes-tools token
```

### Q7: 初期化や参加に失敗した場合の再試行方法

```bash
sudo ./kubernetes-tools reset     # クラスタの状態をクリア（インストール済みのコンポーネントは残す）
sudo ./kubernetes-tools init      # コントロールプレーン：再度初期化
sudo ./kubernetes-tools -r worker -m ... -t ... -s ... join   # ワーカー：再度参加
```

### Q8: 別の方法でインストールされた containerd が存在すると表示される

本ツールは独自の containerd を使用するため、`containerd.io` や `docker-ce` パッケージでインストールされた containerd と競合します。先にそれらのパッケージをアンインストールしてください。docker-tools でインストールした Docker は競合しません。その containerd は dockerd が内部で管理しており、別のソケットを使用するためです。ただし、同じマシンで Docker と Kubernetes を併用する場合、Docker は iptables の FORWARD のデフォルトポリシーを DROP に設定するため、ノード間の Pod 通信に注意してください。

### Q9: 2 コア・2GB 未満のマシンでプリフライトチェックが失敗する

テスト環境では、スクリプトの変数を次のように変更できます：

```bash
KUBEADM_IGNORE_PREFLIGHT_ERRORS=NumCPU,Mem
```

### Q10: ファイアウォールで開放が必要なポート

| ノード | ポート | 用途 |
|---|---|---|
| コントロールプレーン | 6443/tcp | API Server |
| コントロールプレーン | 2379-2380/tcp | etcd |
| コントロールプレーン | 10257/tcp、10259/tcp | controller-manager、scheduler |
| 全ノード | 10250/tcp | kubelet |
| ワーカー | 30000-32767/tcp | NodePort |
| 全ノード | 8472/udp | Flannel VXLAN |
| 全ノード | 179/tcp、4789/udp | Calico BGP / VXLAN |

```bash
# firewalld の例（コントロールプレーン）
firewall-cmd --permanent --add-port={6443,2379-2380,10250,10257,10259}/tcp --add-port=8472/udp
firewall-cmd --reload
```

## 🔧 トラブルシューティング

### ログの場所

```bash
journalctl -u kubelet -f            # kubelet のログ
journalctl -u containerd -f         # containerd のログ
cat /opt/kubernetes/conf/kubeadm-init.log   # 初期化ログ
crictl ps -a                        # このノードのコンテナ
crictl logs <コンテナID>            # コンテナのログ
```

スクリプト自体はログファイルを書き出さず、出力はそのままターミナルに表示されます。保存したい場合は `./kubernetes-tools install 2>&1 | tee install.log` を実行してください。

### よくあるエラー

#### エラー 1: `[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]`

`br_netfilter` モジュールがロードされていません：

```bash
modprobe br_netfilter
sysctl -p /etc/sysctl.d/kubernetes.conf
```

#### エラー 2: `kubelet` が再起動を繰り返す

初期化や参加の前は、kubelet が kubeadm による設定生成を待って再起動を繰り返すのは正常な動作です。初期化後も続く場合：

```bash
journalctl -u kubelet -n 100 --no-pager
```

よくある原因：swap が無効化されていない。cgroup ドライバーが一致していない（本ツールではどちらも systemd に統一しています）。

#### エラー 3: `The connection to the server localhost:8080 was refused`

現在のユーザーに kubeconfig が設定されていません：

```bash
mkdir -p ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config
```

#### エラー 4: `x509: certificate signed by unknown authority`

クラスタを再構築したのに `~/.kube/config` が古いままです。`/etc/kubernetes/admin.conf` を再度コピーしてください。

## 📁 ファイル構成

### ツールのディレクトリ

```text
kubernetes-tools/
├── kubernetes-tools        # メインスクリプト
├── kubeadm-config.yaml     # kubeadm 設定テンプレート
├── containerd.service      # containerd の systemd サービステンプレート
├── kubelet.service         # kubelet の systemd サービステンプレート
├── 10-kubeadm.conf         # kubelet の systemd ドロップインテンプレート（kubeadm の引数）
├── README.md               # ユーザーマニュアル（中国語）
├── README_EN.md            # ユーザーマニュアル（英語）
├── README_JA.md            # ユーザーマニュアル（日本語）
├── DESIGN.md               # 設計ドキュメント（中国語）
└── packages/               # パッケージディレクトリ（download またはオンラインインストール時に作成）
```

### インストール後のシステム構成（デフォルトのパス）

```text
/opt/kubernetes/
├── bin/          # kubeadm kubelet kubectl containerd containerd-shim-runc-v2 ctr runc crictl
├── conf/         # kubeadm-config.yaml、kubeadm-init.log、ネットワークプラグインのマニフェスト
├── backup/       # update 時にバックアップした旧バージョン
└── data/
    ├── containerd/   # containerd のデータ（イメージ、コンテナ）
    └── etcd/         # etcd のデータ（コントロールプレーン）
/opt/cni/bin/                         # CNI プラグイン
/etc/containerd/config.toml           # containerd の設定
/etc/containerd/certs.d/              # レジストリミラーの設定
/etc/crictl.yaml                      # crictl の設定
/etc/kubernetes/                      # kubeadm が生成した証明書と kubeconfig
/usr/lib/systemd/system/containerd.service
/usr/lib/systemd/system/kubelet.service
/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/sysctl.d/kubernetes.conf
/etc/modules-load.d/kubernetes.conf
```

## 🔒 セキュリティに関する推奨事項

1. **認証情報の保護**：`/etc/kubernetes/admin.conf` はクラスタ管理者権限を持つため、外部に渡さないでください。トークンと証明書キーは使用後に失効させて構いません
2. **API アクセスの制限**：ファイアウォールやセキュリティグループで 6443 ポートへの接続元を制限してください
3. **定期的なアップグレード**：Kubernetes のパッチリリースを速やかに適用し、証明書の有効期限にも注意してください
4. **最小権限**：日常的に使うユーザーには RBAC で権限を絞った kubeconfig を作成し、admin.conf を直接使わないでください
5. **etcd のバックアップ**：コントロールプレーンの etcd データを定期的にバックアップしてください（`etcdctl snapshot save`）

## 📝 更新履歴

### v1.0.0 (2026-10-20)
- 🎉 初回リリース
- kubeadm + containerd をベースにした静的バイナリによるインストール。x86_64、aarch64 に対応
- シングルノード、1 コントロールプレーン + 複数ワーカー、高可用性（複数コントロールプレーン）クラスタに対応
- オンライン/オフラインインストール：`download` でパッケージを取得、`save-images` でイメージアーカイブをエクスポート。すべてのパッケージを SHA256 で検証
- Flannel、Calico ネットワークプラグインを内蔵
- 代替イメージレジストリ（`-g`）とレジストリミラー（`-w`）に対応
- `init`、`join`、`token`、`reset`、`update`、`uninstall` などのクラスタライフサイクルコマンドを提供

## 👤 作者

**HTY1024**

- Git: [@HTY1024](https://git.hty1024.com/HTY1024)

## 🙏 謝辞

- [Kubernetes](https://kubernetes.io/)
- [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
- [containerd](https://containerd.io/)
- [Flannel](https://github.com/flannel-io/flannel)
- [Calico](https://www.tigera.io/project-calico/)

[トップに戻る](#kubernetes-tools)
