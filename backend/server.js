const express = require('express');
const { Pool } = require('pg');
const { createClient } = require('redis');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// PostgreSQL Connection
const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'ecommerce',
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'password123',
});

// Redis Connection
let redisClient;
(async () => {
  redisClient = createClient({
    socket: {
      host: process.env.REDIS_HOST || 'redis',
      port: process.env.REDIS_PORT || 6379,
    }
  });
  redisClient.on('error', (err) => console.log('Redis Error:', err));
  await redisClient.connect();
  console.log('Redis connected');
})();

// Init DB Tables
async function initDB() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        description TEXT,
        stock INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      );
      INSERT INTO products (name, price, description, stock)
      SELECT 'Sample Product 1', 999.99, 'A great product', 100
      WHERE NOT EXISTS (SELECT 1 FROM products LIMIT 1);
      INSERT INTO products (name, price, description, stock)
      SELECT 'Sample Product 2', 499.99, 'Another great product', 50
      WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Sample Product 2');
    `);
    console.log('Database initialized');
  } catch (err) {
    console.error('DB init error:', err.message);
  }
}
initDB();

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'backend', timestamp: new Date() });
});

// Get all products (with Redis cache)
app.get('/api/products', async (req, res) => {
  try {
    const cached = await redisClient.get('products');
    if (cached) {
      return res.json({ source: 'cache', data: JSON.parse(cached) });
    }
    const result = await pool.query('SELECT * FROM products ORDER BY id');
    await redisClient.setEx('products', 60, JSON.stringify(result.rows));
    res.json({ source: 'database', data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single product
app.get('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM products WHERE id=$1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Product not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create product
app.post('/api/products', async (req, res) => {
  try {
    const { name, price, description, stock } = req.body;
    const result = await pool.query(
      'INSERT INTO products (name, price, description, stock) VALUES ($1,$2,$3,$4) RETURNING *',
      [name, price, description, stock]
    );
    await redisClient.del('products'); // invalidate cache
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  try {
    const dbResult = await pool.query('SELECT COUNT(*) FROM products');
    const productCount = dbResult.rows[0].count;
    const metrics = `
# HELP products_total Total number of products
# TYPE products_total gauge
products_total ${productCount}

# HELP backend_up Backend service status
# TYPE backend_up gauge
backend_up 1
`;
    res.set('Content-Type', 'text/plain');
    res.send(metrics);
  } catch (err) {
    res.status(500).send('Error generating metrics');
  }
});

const PORT = process.env.APP_PORT || 8080;
app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));
