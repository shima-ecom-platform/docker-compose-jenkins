# Docker Composeのスケールアウト機能を試す

## 概要

Docker Composeの `--scale` オプションを使用することで、複数のコンテナを同時に起動できます。この機能を利用して、Webサーバーをスケールアウトし、ロードバランシングを確認します。

## 前提条件

- Docker・Docker Composeがインストール済み
- Phase 1プロジェクトが構成済み
- 現在のコンテナが停止している状態

## 重要な制約事項

⚠️ **container_name が設定されているサービスはスケールできません**

Docker Composeでスケールアウトするには、各コンテナが一意の名前を持つ必要があります。そのため、`container_name` を指定したサービスは `--scale` オプションを使用できません。

```yaml
# ❌ スケールできない例

services:
  app:
    container_name: phase1-app  # これがあるとスケールできない
    image: nginx:alpine

# ✅ スケールできる例
services:
  web:
    # container_name を指定しない
    image: nginx:alpine
```

## ステップ1: 既存のコンテナを停止・削除

```bash
cd /home/agio0021/projects/shima-ecom-platform/docker-compose-jenkins/phase1

# 実行中のコンテナをすべて停止・削除
docker-compose down

# 確認: コンテナがないことを確認
docker ps -a | grep phase1
```

## ステップ2: スケールアウト専用の設定ファイルを準備

元の `docker-compose.yml` は学習用に保持し、スケールアウト用の専用設定ファイルを使用します。

### docker-compose-scale-test.yml の内容

このファイルは既に作成済みです。内容を確認します：

```bash
cat docker-compose-scale-test.yml
```

**主な構成:**

- `web`: スケール可能なWebサーバー（container_name なし）
- `loadbalancer`: ロードバランサー（Nginx）
- `postgres`: データベース

### nginx-lb.conf の内容

ロードバランサーの設定ファイルも作成済みです：

```bash
cat nginx-lb.conf
```

## ステップ3: スケールアウトでコンテナ起動

`-f` オプションで設定ファイルを指定し、`--scale` オプションでコンテナ数を指定します。

```bash
# web サービスを3つ起動
docker-compose -f docker-compose-scale-test.yml up -d --scale web=3
```

**実行結果例:**

```text
Creating network "phase1_app-network" with driver "bridge"
Creating phase1-postgres ... done
Creating phase1_web_1    ... done
Creating phase1_web_2    ... done
Creating phase1_web_3    ... done
Creating phase1-loadbalancer ... done
```

⚠️ **よくあるエラー1: container_name によるエラー**

元の `docker-compose.yml` を使用すると以下のエラーが発生します：

```text
WARNING: The "app" service is using the custom container name "phase1-app". 
Docker requires each container to have a unique name. 
Remove the custom name to scale the service.
```

**解決策:** `docker-compose-scale-test.yml` を使用してください。

⚠️ **よくあるエラー2: ポート競合エラー**

```text
ERROR: for phase1-nginx  Cannot start service nginx: failed to set up container networking: 
driver failed programming external connectivity on endpoint phase1-nginx: 
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**解決策:**

```bash
# 他のコンテナが起動していないか確認
docker ps | grep 8080

# すべてのPhase 1関連コンテナを停止
docker-compose down
docker-compose -f docker-compose-scale-test.yml down
```

## ステップ4: スケールアウト後のコンテナ状態確認

```bash
# コンテナ一覧表示
docker-compose -f docker-compose-scale-test.yml ps
```

**実行結果例:**

```text
       Name                      Command              State              Ports            
------------------------------------------------------------------------------------------
phase1-loadbalancer   /docker-entrypoint.sh ngin      Up      0.0.0.0:8080->80/tcp
phase1-postgres       docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
phase1_web_1          /docker-entrypoint.sh ngin      Up      80/tcp
phase1_web_2          /docker-entrypoint.sh ngin      Up      80/tcp
phase1_web_3          /docker-entrypoint.sh ngin      Up      80/tcp
```

**ポイント:**

- `web` サービスは `phase1_web_1`、`phase1_web_2`、`phase1_web_3` のように番号付きで作成される
- `loadbalancer` と `postgres` は `container_name` が設定されているため1つのみ

## ステップ5: ネットワーク構成を確認

スケールアウトされたコンテナが同じネットワークで通信できることを確認します。

```bash
# ネットワーク一覧
docker network ls

# Phase 1のネットワークを詳細表示
docker network inspect phase1_app-network
```

**実行結果例:**

```json
[
  {
    "Name": "phase1_app-network",
    "Containers": {
      "...": {
        "Name": "phase1_web_1",
        "IPv4Address": "172.19.0.2/16"
      },
      "...": {
        "Name": "phase1_web_2",
        "IPv4Address": "172.19.0.3/16"
      },
      "...": {
        "Name": "phase1_web_3",
        "IPv4Address": "172.19.0.4/16"
      }
    }
  }
]
```

## ステップ6: Webサーバー動作確認

```bash
# ブラウザでアクセス
# http://localhost:8080

# または curl で確認
curl http://localhost:8080

# ヘルスチェック
curl http://localhost:8080/health
```

## ステップ7: ロードバランシング動作確認

複数のコンテナに対してリクエストが分散されていることを確認します。

### 方法1: レスポンスヘッダーで確認

```bash
# X-Served-By ヘッダーでどのコンテナが応答したか確認
for i in {1..10}; do
    echo "=== Request $i ==="
    curl -s -I http://localhost:8080 | grep "X-Served-By"
done
```

**実行結果例:**

```text
=== Request 1 ===
X-Served-By: 172.19.0.4:80
=== Request 2 ===
X-Served-By: 172.19.0.4:80
```

### 方法2: Docker logで各コンテナのログを確認

```bash
# web_1のログ確認
docker-compose -f docker-compose-scale-test.yml logs web | grep web_1

# すべてのwebサービスのログをリアルタイム表示
docker-compose -f docker-compose-scale-test.yml logs -f web
```

**使用方法:**

- ブラウザで `http://localhost:8080` にアクセスしながらログを確認
- どのコンテナがリクエストを処理しているか確認できます
- Ctrl+C でログ表示を終了

## ステップ8: スケールアウト・スケールイン（動的スケーリング）

実行中のコンテナ数を動的に変更できます。

### スケールアップ（増加）

```bash
# コンテナ数を5に増やす
docker-compose -f docker-compose-scale-test.yml up -d --scale web=5

# コンテナ状態確認
docker-compose -f docker-compose-scale-test.yml ps | grep web
```

**実行結果例:**

```text
Creating phase1_web_4 ... done
Creating phase1_web_5 ... done
phase1_web_1          /docker-entrypoint.sh ngin ...   Up      80/tcp
phase1_web_2          /docker-entrypoint.sh ngin ...   Up      80/tcp
phase1_web_3          /docker-entrypoint.sh ngin ...   Up      80/tcp
phase1_web_4          /docker-entrypoint.sh ngin ...   Up      80/tcp
phase1_web_5          /docker-entrypoint.sh ngin ...   Up      80/tcp
```

### スケールダウン（減少）

```bash
# コンテナ数を2に減らす
docker-compose -f docker-compose-scale-test.yml up -d --scale web=2

# コンテナ状態確認
docker-compose -f docker-compose-scale-test.yml ps | grep web
```

**実行結果例:**

```text
Stopping and removing phase1_web_3 ... done
Stopping and removing phase1_web_4 ... done
Stopping and removing phase1_web_5 ... done
phase1_web_1          /docker-entrypoint.sh ngin ...   Up      80/tcp
phase1_web_2          /docker-entrypoint.sh ngin ...   Up      80/tcp
```

## ステップ9: リソース使用状況の確認

スケールアウト時のリソース消費状況を確認します。

```bash
# コンテナごとのリソース使用状況（リアルタイム）
docker stats

# 特定の web コンテナのみ表示
docker stats phase1_web_1 phase1_web_2 phase1_web_3
```

**表示項目:**

- CONTAINER ID: コンテナID
- NAME: コンテナ名
- CPU %: CPU使用率
- MEM USAGE: メモリ使用量
- NET I/O: ネットワークI/O
- BLOCK I/O: ブロックI/O

**Ctrl+C で終了します。**

## ステップ10: パフォーマンス測定（オプション）

複数コンテナでのロードバランシングのパフォーマンスを測定します。

```bash
# apachebenchtool（ab）を使用した負荷試験
# 100リクエスト、並行10接続で測定
ab -n 100 -c 10 http://localhost:8080/

# より詳細な統計情報を確認
ab -n 1000 -c 50 http://localhost:8080/
```

**ab が未インストールの場合:**

```bash
# Ubuntu/WSL2
sudo apt-get update
sudo apt-get install apache2-utils
```

## ステップ11: スケールアウト後のコンテナ停止・削除

```bash
# コンテナ停止
docker-compose -f docker-compose-scale-test.yml stop

# コンテナ削除（データ保持）
docker-compose -f docker-compose-scale-test.yml down

# コンテナ+ボリューム削除（データも削除）
docker-compose -f docker-compose-scale-test.yml down -v
```

## トラブルシューティング

### エラー1: container_name が指定されたサービスのスケール失敗

**エラーメッセージ:**

```text
WARNING: The "app" service is using the custom container name "phase1-app". 
Docker requires each container to have a unique name. 
Remove the custom name to scale the service.

ERROR: for phase1-app  Cannot create container for service app: 
Conflict. The container name "/phase1-app" is already in use
```

**原因:** `docker-compose.yml` で `container_name` を指定したサービスはスケールできません。

**解決策:**

```bash
# docker-compose-scale-test.yml を使用する
docker-compose -f docker-compose-scale-test.yml up -d --scale web=3
```

### エラー2: ポート競合エラー

**エラーメッセージ:**

```text
ERROR: for phase1-nginx Cannot start service nginx: 
failed to set up container networking: 
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**原因:** ポート8080が既に使用されています。

**解決策:**

```bash
# 使用中のコンテナを確認
docker ps | grep 8080

# すべてのPhase 1関連コンテナを停止
docker-compose down
docker-compose -f docker-compose-scale-test.yml down

# 再度起動
docker-compose -f docker-compose-scale-test.yml up -d --scale web=3
```

### エラー3: 孤立コンテナ（Orphan containers）の警告

**警告メッセージ:**

```text
WARNING: Found orphan containers (phase1_web_1, phase1-loadbalancer) 
for this project. If you removed or renamed this service in your compose file, 
you can run this command with the --remove-orphans flag to clean it up.
```

**原因:** 別の設定ファイルで起動したコンテナが残っています。

**解決策:**

```bash
# 孤立コンテナを削除して起動
docker-compose -f docker-compose-scale-test.yml up -d --scale web=3 --remove-orphans

# または、すべてのコンテナを明示的に削除
docker-compose down
docker-compose -f docker-compose-scale-test.yml down
```

### エラー4: コンテナ起動失敗（Exit 1）

**症状:** `docker-compose ps` で `Exit 1` と表示される

**確認方法:**

```bash
# エラーログを確認
docker-compose -f docker-compose-scale-test.yml logs web

# 特定のコンテナのログ確認
docker logs phase1_web_1
```

**一般的な原因:**

- 設定ファイルのパスが間違っている
- ボリュームマウントが失敗している
- ポートが競合している

## 学習確認

### 基礎課題

- [ ] `--scale` オプションで複数のコンテナを起動できた
- [ ] `container_name` の制約を理解した
- [ ] スケーリング後のコンテナ状態を確認できた
- [ ] ネットワーク内でコンテナ間通信が機能している

### 応用課題

- [ ] 動的スケーリング（増加・減少）ができた
- [ ] リソース使用状況を確認できた
- [ ] ロードバランサーを経由したアクセスを確認できた
- [ ] 負荷試験を実行してパフォーマンスを測定できた

## まとめ

Docker Composeのスケールアウト機能を使用する際の重要なポイント：

1. **container_name を指定しない**: スケールするサービスには `container_name` を設定しない
2. **専用の設定ファイルを使用**: `docker-compose-scale-test.yml` のようなスケール専用設定を用意
3. **ポート公開は避ける**: スケールするサービスは `expose` のみ使用し、`ports` で公開しない
4. **ロードバランサーを配置**: 複数コンテナへのアクセスにはロードバランサーを使用

## コマンドリファレンス

```bash
# スケールアウト（3つ）
docker-compose -f docker-compose-scale-test.yml up -d --scale web=3

# スケールアップ（5つ）
docker-compose -f docker-compose-scale-test.yml up -d --scale web=5

# スケールダウン（2つ）
docker-compose -f docker-compose-scale-test.yml up -d --scale web=2

# 状態確認
docker-compose -f docker-compose-scale-test.yml ps

# ログ確認
docker-compose -f docker-compose-scale-test.yml logs -f web

# リソース確認
docker stats

# 停止・削除
docker-compose -f docker-compose-scale-test.yml down
```

## 参考資料

- [Docker Compose公式ドキュメント - Scale](https://docs.docker.com/compose/reference/up/#service-scale)
- [Docker Compose ネットワーク](https://docs.docker.com/compose/networking/)
- [Nginx リバースプロキシ設定](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)

## 次のステップ

1. **本番環境での自動スケーリング**: Kubernetes（K8s）を使用した自動スケーリングの検討
2. **高度なロードバランシング**: 重み付け、ヘルスチェック、セッション固定などの実装
3. **監視・ロギング**: Prometheus、Grafana、ELKスタックの導入
4. **CI/CDパイプライン**: Jenkins、GitLab CI、GitHub Actionsでの自動デプロイとスケーリング

## 付録: ファイル一覧

このスケールアウト学習で使用するファイル：

- `docker-compose-scale-test.yml` - スケールアウト専用設定
- `nginx-lb.conf` - ロードバランサー設定
- `index.html` - Webページ
- `init-db.sql` - PostgreSQL初期化スクリプト
- `how_to_scale_out.md` - このドキュメント

元の学習用ファイル（スケールには使用しない）：

- `docker-compose.yml` - 元の設定（container_name あり）
- `Dockerfile` - Nginxイメージビルド定義
