# PostgreSQLのデータをバックアップ・リストア手順

## バックアップ（データベースのダンプ）

```bash
cd /home/agio0021/projects/shima-ecom-platform/docker-compose-jenkins/phase1

# 全データベースをダンプ

docker-compose exec postgres pg_dump -U phase1_user -d phase1_db > backup_$(date +%Y%m%d_%H%M%S).sql

# または、より詳細なカスタム形式（リストア時に便利）

docker-compose exec postgres pg_dump -U phase1_user -d phase1_db --format=custom > backup.dump
```

## リストア（バックアップから復元）

## １．SQLファイルから復元

```bash
# SQLファイルから復元
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "DROP TABLE IF EXISTS users, products CASCADE;"
docker-compose exec -T postgres psql -U phase1_user -d phase1_db < backup_20260127_175443.sql

# 確認
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM products;"
```

## ２．カスタム形式から復元

```bash
# ホストのファイルをコンテナ内にコピー
docker cp buckup_20260127.dump phase1-postgres:/tmp/buckup_20260127.dump

# コンテナ内から実行
docker-compose exec postgres pg_restore -U phase1_user -d phase1_db /tmp/buckup_20260127.dump

# 確認
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "SELECT COUNT(*) FROM users;"
```

## 実務的な手順例

```bash
# 1. 現在のコンテナ状態を確認
docker-compose ps

# 2. データベース内容をダンプ
docker-compose exec postgres pg_dump -U phase1_user -d phase1_db > backup.sql

# 3. バックアップファイルをホストに保存（確認）
ls -lh backup.sql

# 4. テスト：コンテナを停止・削除
docker-compose down -v

# 5. コンテナを再起動
docker-compose up -d

# 6. データベースをリストア
docker-compose exec -T postgres psql -U phase1_user -d phase1_db < backup.sql

# 7. データが復元されたか確認
docker-compose exec postgres psql -U phase1_user -d phase1_db -c "SELECT * FROM users;"
```
