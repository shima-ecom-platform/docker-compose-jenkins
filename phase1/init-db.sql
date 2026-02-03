-- Phase 1 サンプルデータベース初期化スクリプト

-- テーブル作成
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サンプルデータ挿入
INSERT INTO users (username, email) VALUES
    ('test_user1', 'user1@example.com'),
    ('test_user2', 'user2@example.com'),
    ('admin', 'admin@example.com')
ON CONFLICT (username) DO NOTHING;

INSERT INTO products (name, description, price, stock) VALUES
    ('サンプル商品A', 'これはテスト用の商品です', 1000.00, 10),
    ('サンプル商品B', 'Docker学習用サンプル', 2000.00, 5),
    ('サンプル商品C', 'PostgreSQL連携テスト', 1500.00, 20)
ON CONFLICT DO NOTHING;

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);

-- テーブル情報表示
\dt
\d users
\d products

-- データ確認
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as product_count FROM products;
