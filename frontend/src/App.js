import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [products, setProducts] = useState([]);
  const [health, setHealth]     = useState(null);
  const [loading, setLoading]   = useState(true);
  const [cart, setCart]         = useState([]);

  useEffect(() => {
    fetchProducts();
    fetchHealth();
  }, []);

  const fetchProducts = async () => {
    try {
      const res = await axios.get(`${API_URL}/products`);
      setProducts(res.data);
    } catch (e) {
      console.error('Error fetching products:', e);
    } finally {
      setLoading(false);
    }
  };

  const fetchHealth = async () => {
    try {
      const res = await axios.get(`${API_URL}/health`);
      setHealth(res.data);
    } catch (e) {
      setHealth({ status: 'unhealthy' });
    }
  };

  const addToCart = (product) => {
    setCart([...cart, product]);
    alert(`${product.name} cart mein add ho gaya!`);
  };

  return (
    <div className="App">
      <header className="header">
        <h1>🛒 ShopKaro - E-Commerce Store</h1>
        <div className="cart-badge">🛒 Cart: {cart.length}</div>
        {health && (
          <div className={`health-badge ${health.status === 'healthy' ? 'green' : 'red'}`}>
            ● {health.status}
          </div>
        )}
      </header>

      <main className="main">
        {loading ? (
          <div className="loading">Loading products...</div>
        ) : (
          <div className="products-grid">
            {products.length === 0 ? (
              <p className="no-products">Koi product nahi mila. Backend check karo.</p>
            ) : (
              products.map((p) => (
                <div key={p.id} className="product-card">
                  <div className="product-emoji">📦</div>
                  <h3>{p.name}</h3>
                  <p>{p.description}</p>
                  <div className="product-footer">
                    <span className="price">₹{p.price}</span>
                    <button onClick={() => addToCart(p)}>Add to Cart</button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
