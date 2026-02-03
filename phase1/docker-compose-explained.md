# docker-compose.yml のやさしい日本語解説

## このファイルでできること

- Nginx コンテナと PostgreSQL コンテナを 1 回のコマンドでまとめて起動・停止できます。
- アプリ用ネットワークと、ログ・データを保存するボリュームを用意します。

## サービス（services）

### 1. Nginx（nginx）

- 役割: Web サーバー。
- ビルド: カレントディレクトリの Dockerfile からイメージを作成。
- ポート: ホスト 8080 → コンテナ 80（ブラウザで <http://localhost:8080>）。
- 環境変数: NGINX_HOST=localhost, NGINX_PORT=80。
- ボリューム: nginx-logs を /var/log/nginx にマウントし、コンテナ削除後もログを保持。
- 依存関係: postgres が先に起動するまで待機（depends_on）。
- ヘルスチェック: 30 秒ごとに wget <http://localhost/health> で応答確認。
- 再起動ルール: unless-stopped（止めない限り再起動）。

### 2. PostgreSQL（postgres）

- 役割: データベースサーバー。
- イメージ: postgres:15-alpine。
- ポート: ホスト 5432 → コンテナ 5432。
- 環境変数: POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD で DB 名・ユーザー・パスワードを指定。
- ボリューム:
  - postgres-data を /var/lib/postgresql/data にマウントしデータを永続化。
  - ./init-db.sql を /docker-entrypoint-initdb.d/init.sql に配置し初回起動で初期化 SQL を実行。
- ヘルスチェック: 10 秒ごとに pg_isready で接続確認。
- 再起動ルール: unless-stopped。

## ネットワーク（networks）

- app-network（bridge）を作成し、コンテナ同士をつなぐ専用ネットワークを用意。
- サブネット: 172.20.0.0/16 を指定し、コンテナのアドレス帯を固定。

## ボリューム（volumes）

- postgres-data: ホストの ./data/postgres を DB データディレクトリにバインドマウント。
- nginx-logs: ホストの ./logs/nginx を Nginx のログディレクトリにバインドマウント。

> メモ: バインドマウントなので、ホスト側の data/postgres と logs/nginx に実ファイルが残り、コンテナを消してもデータやログは残ります。

## 使い方（初心者向け）

1. phase1 ディレクトリに移動する。
2. 初期化 SQL を使う場合は init-db.sql の内容を確認する。
3. 起動する:
   - バックグラウンド起動: docker-compose up -d
   - ログを見る: docker-compose logs -f
4. 止める: docker-compose down
5. データ・ログごと消す（慎重に）: docker-compose down -v でボリュームも削除。

## どんなときに便利？

- ローカルで Nginx と PostgreSQL の組み合わせをすぐ試したいとき。
- データやログを残したままコンテナを作り直したいとき。
- ヘルスチェック付きで起動状態を自動確認したいとき。
