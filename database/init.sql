-- E-Commerce Database Initialization
CREATE DATABASE ecommerce;
\c ecommerce;

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Sample Data
INSERT INTO products (name, price, description, stock) VALUES
('iPhone 15 Pro', 134999.00, 'Latest Apple smartphone with A17 Pro chip', 50),
('Samsung Galaxy S24', 89999.00, 'Android flagship with AI features', 75),
('Sony WH-1000XM5', 29999.00, 'Premium noise-cancelling headphones', 120),
('MacBook Air M3', 114999.00, 'Ultra-thin laptop with Apple Silicon', 30),
('Nike Air Max 270', 12999.00, 'Comfortable running shoes', 200),
('Levi 501 Jeans', 4999.00, 'Classic straight-fit jeans', 500);
