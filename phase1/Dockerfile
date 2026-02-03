# マルチステージビルドの例
# ステージ1: ビルドステージ
FROM nginx:alpine AS builder

# 作業ディレクトリ設定
WORKDIR /app

# カスタムHTMLファイルをコピー
COPY index.html /app/

# ステージ2: 実行ステージ
FROM nginx:alpine

# メンテナ情報
LABEL maintainer="shima-ecom-platform"
LABEL description="Nginx web server for Phase 1 learning"

# ビルドステージからファイルをコピー
COPY --from=builder /app/index.html /usr/share/nginx/html/

# カスタムNginx設定をコピー
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# ポート公開
EXPOSE 80

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Nginxをフォアグラウンドで実行
CMD ["nginx", "-g", "daemon off;"]
