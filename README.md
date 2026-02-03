# Docker Compose Jenkins

WSL2 上でのJenkins環境構築スクリプトとDocker Compose設定

## 概要

Docker ComposeでJenkinsとDocker-in-Docker（DinD）を構築し、CI/CD基盤を提供します。GitHub Webhookと連携し、マイクロサービスの自動ビルド・テスト・デプロイを実現します。

## 主な内容

- **Phase 1**: Docker基礎（Nginx + PostgreSQL）
- **Phase 3**: Jenkins構築とCI/CDパイプライン基礎
- Docker Compose による Jenkins + DinD 環境
- Jenkins初期設定スクリプト
- GitHub連携設定

## ディレクトリ構造（予定）

```text
docker-compose-jenkins/
├── phase1/                  # Phase 1: Docker基礎
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx/
│   │   └── nginx.conf
│   └── README.md
├── phase3/                  # Phase 3: Jenkins構築
│   ├── docker-compose.yml   # Jenkins + DinD
│   ├── Dockerfile.jenkins   # カスタムJenkins image
│   ├── jenkins-plugins.txt  # 必要なプラグイン一覧
│   ├── setup.sh             # 初期設定スクリプト
│   ├── Jenkinsfile.example  # サンプルPipeline
│   └── README.md
└── README.md
```

## Phase 1: Docker 基礎 + 単純Webアプリ

### Phase 1 の目標

- Docker・Docker Compose・Dockerfileの基礎習得
- マルチコンテナオーケストレーション理解
- コンテナ間通信の実践

### Phase 1 の実装内容

1. **Dockerfile作成** （Nginxベースイメージ）
2. **docker-compose.yml** でNginx + PostgreSQL構築
3. **ボリュームマウント**（永続化）
4. **ネットワーク定義**、**環境変数管理**
5. **マルチステージビルド**（最適化）

### 演習1: コンテナ間通信エラー対応

**シナリオ**: Nginx が PostgreSQL に接続できない

**ヒント段階**:

1. `docker-compose logs postgres` でPostgres起動確認
2. `docker network inspect` でネットワーク確認
3. docker-compose.yml のサービス名・ポート番号、Nginx設定ファイルの接続先確認

**期待結果**: Nginx経由でDB接続成功

### Phase 1 の使い方

```bash
cd phase1

# コンテナ起動
docker-compose up -d

# ログ確認
docker-compose logs -f

# 接続テスト
curl http://localhost:8080

# コンテナ停止
docker-compose down
```

## Phase 3: Jenkins 構築 + CI/CDパイプライン基礎

### Phase 3 の目標

- Jenkins インストール・設定
- Declarative Pipeline 基礎
- Kubernetes Plugin統合
- GitHub統合

### Phase 3 の実装内容

1. Docker Compose で **Jenkins on WSL2** 構築
2. Jenkins 初期設定（Admin ユーザー、Plugins）
3. **Kubernetes Plugin** インストール・設定
4. **Declarative Pipeline** の基本
5. **GitHub Plugin** インストール・PAT設定
6. **GitHub Webhook** 設定

### 演習3: CI/CD パイプライン実装

**シナリオ**: 単純な Node.js アプリを自動ビルド・テスト・イメージプッシュ

**ヒント段階**:

1. Pipeline の各ステージ（Checkout, Build, Test, Push）を定義
2. GitHub Webhook トリガー設定、PAT認証確認
3. Docker Hub または GitHub Container Registry のクレデンシャル設定

**期待結果**: Git push で自動ビルド・テスト・イメージプッシュ実行確認

### Phase 3 の使い方

```bash
cd phase3

# Jenkins起動
./setup.sh

# Jenkins URL
# http://localhost:8080

# 初期管理者パスワード取得
docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## 必要な環境

- WSL2 (Ubuntu 20.04 以降推奨)
- Docker Desktop for Windows (WSL2 backend)
- Git
- 最低8GB RAM（推奨16GB）

## トラブルシューティング

### Jenkins起動エラー

```bash
# ポート競合確認
netstat -ano | findstr :8080

# ログ確認
docker-compose logs jenkins
```

### Docker-in-Docker エラー

```bash
# Docker ソケット権限確認
ls -la /var/run/docker.sock

# DinD コンテナ再起動
docker-compose restart dind
```

## 参考資料

- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [kind Documentation](https://kind.sigs.k8s.io/)

## ライセンス

Apache License 2.0
