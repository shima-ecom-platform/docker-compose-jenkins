# Phase 1: Docker の基礎 + 単純Webアプリ

## 概要

Docker・Docker Compose・Dockerfileの基礎を習得し、Nginx + PostgreSQL のマルチコンテナアプリケーションを構築します。

## 学習目標

- Dockerfileの作成とイメージビルド
- マルチステージビルドによる最適化
- Docker Composeによる複数コンテナの管理
- コンテナ間ネットワーク通信
- ボリュームマウントによるデータ永続化
- 環境変数管理とコンテナ設定

## ディレクトリ構造

```text
phase1/
├── Dockerfile              # Nginxイメージビルド定義
├── docker-compose.yml      # マルチコンテナ定義
├── index.html              # Webページ
├── init-db.sql             # PostgreSQL初期化スクリプト
├── nginx/
│   └── nginx.conf          # Nginx設定ファイル
├── data/                   # PostgreSQLデータ(自動生成)
├── logs/                   # Nginxログ(自動生成)
└── README.md
```

## 事前準備

### 必要なツール

- Docker Desktop for Windows (WSL2 backend有効化)
- WSL2 (Ubuntu 20.04以降)
- テキストエディタ (VS Code推奨)

### Docker確認

```bash
docker --version
docker-compose --version
```

## 実装手順

### ステップ1: ディレクトリ準備

```bash
cd /home/agio0021/projects/shima-ecom-platform/docker-compose-jenkins/phase1

# データ保存用ディレクトリ作成
mkdir -p data/postgres logs/nginx
chmod 777 data/postgres logs/nginx
```

### ステップ2: コンテナ起動

```bash
# イメージビルド＆コンテナ起動
docker-compose up -d

# ログ確認(リアルタイム)
docker-compose logs -f

# Ctrl+C でログ表示終了
```

### ステップ3: 動作確認

#### Nginx確認

```bash
# ブラウザでアクセス
http://localhost:8080

# または curl で確認
curl http://localhost:8080

# ヘルスチェック
curl http://localhost:8080/health
curl http://localhost:8080/api/health
```

#### PostgreSQL確認

##### 方法1: インタラクティブに接続(推奨)

```bash
# PostgreSQLプロンプトに入る(WSL2では使用不可)
# TTY（擬似端末）の制限: Windowsのターミナルエミュレーションでは、完全なPTY（擬似端末）が正しく機能しない
# docker-compose exec -it postgres psql -U phase1_user -d phase1_db

# SQL実行 (psqlプロンプト内)
# phase1_db=> SELECT * FROM users;
# phase1_db=> SELECT * FROM products;
# phase1_db=> \dt   # テーブル一覧
# phase1_db=> \q    # 終了
```

⚠️ **重要**: `phase1_db=>` プロンプトで SQL を実行してください。シェルプロンプト (`$`) で実行するとエラーになります。

##### 方法2: ワンライナーで実行(プロンプト不要)

```bash
# ユーザー確認
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "SELECT * FROM users;"

# 商品確認
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "SELECT * FROM products;"
```

##### 方法3: 複数コマンド実行

```bash
#   これも実行すると下記のエラーが発生して使えない
# the input device is not a TTY
# docker-compose exec postgres psql -U phase1_user -d phase1_db << 'EOF_SQL'
# SELECT * FROM users;
# SELECT * FROM products;
# \dt
# EOF_SQL
```

### ステップ4: コンテナ状態確認

```bash
# コンテナ一覧
docker-compose ps

# ネットワーク確認
docker network ls
docker network inspect phase1_app-network

# ボリューム確認
docker volume ls
```

### ステップ5: ログ確認

```bash
# Nginxアクセスログ
tail -f logs/nginx/access.log

# Nginxエラーログ
tail -f logs/nginx/error.log

# PostgreSQLログ
docker-compose logs postgres
```

### ステップ6: コンテナ停止・削除

```bash
# コンテナ停止
docker-compose stop

# コンテナ削除(データは保持)
docker-compose down

# コンテナ+ボリューム削除(データも削除)
docker-compose down -v

# イメージも削除
docker-compose down --rmi all -v
```

## トラブルシューティング

### ポート8080が使用中

```bash
# ポート使用状況確認
netstat -ano | grep :8080
# または
ss -tlnp | grep :8080

# ポート使用状況確認 (Windows PowerShell)
# netstat -ano | findstr :8080

# docker-compose.ymlのポート変更例
# ports: "8080:80" → "8081:80"
```

### PostgreSQL接続エラー

```bash
# コンテナログ確認
docker-compose logs postgres

# データディレクトリ権限確認
ls -la data/postgres/

# 権限修正
chmod 777 data/postgres
```

### イメージビルド失敗

```bash
# キャッシュクリア後再ビルド
docker-compose build --no-cache

# Docker全体クリーンアップ
docker system prune -af
```

## 学習確認

### 基礎課題

- [ ] Dockerfileを理解し、独自イメージをビルドできる
- [ ] docker-compose.ymlを理解し、マルチコンテナを起動できる
- [ ] Nginxでカスタムページを表示できる
- [ ] PostgreSQLに接続しデータを確認できる

### 応用課題

- [ ] 環境変数を.envファイルで管理
- [ ] Nginxのリバースプロキシ設定を追加
- [ ] PostgreSQLのデータをバックアップ・リストア
- [ ] Docker Composeのスケールアウト機能を試す

## 次のステップ

Phase 2では、バックエンドAPIを追加し、フルスタックアプリケーションを構築します。
