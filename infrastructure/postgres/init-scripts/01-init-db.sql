CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE SCHEMA IF NOT EXISTS myapp;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_user') THEN
      CREATE USER app_user WITH PASSWORD 'AppPassword123';
   END IF;
END
$$;

GRANT USAGE ON SCHEMA myapp TO app_user;
GRANT CREATE ON SCHEMA myapp TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA myapp GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

CREATE TABLE IF NOT EXISTS myapp.users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS myapp.orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES myapp.users(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    total_amount DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO myapp.users (email, username) VALUES
    ('user1@example.com', 'user1'),
    ('user2@example.com', 'user2')
ON CONFLICT DO NOTHING;
