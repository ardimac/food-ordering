const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: '*', // Allow all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'X-Requested-With', 'Accept']
}));

// Alternative more verbose CORS configuration
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }

  next();
});

app.use(bodyParser.json());

app.get('/menu', async (req, res) => {
  try {
    console.log('Menu request received');
    const result = await db.query('SELECT * FROM menu_items');

    console.log('Menu items found:', result.rows);

    if (result.rows.length === 0) {
      console.warn('No menu items found in database');
      return res.status(404).json({ message: 'No menu items found' });
    }

    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching menu items:', err);
    res.status(500).json({
      error: 'Server error',
      details: err.message
    });
  }
});

// New Order Route with Detailed Logging
app.post('/order', async (req, res) => {
  console.log('Order request received');
  console.log('Request body:', req.body);

  const { items } = req.body;

  if (!items || !Array.isArray(items)) {
    console.error('Invalid order request');
    return res.status(400).json({ error: 'Invalid order request' });
  }

  try {
    // Start transaction
    await db.query('BEGIN');

    // Calculate total price
    const totalPrice = items.reduce((total, item) =>
      total + (Number(item.price) * item.quantity), 0);

    // Insert order
    const orderResult = await db.query(
      'INSERT INTO orders (total_price) VALUES ($1) RETURNING id',
      [totalPrice]
    );
    const orderId = orderResult.rows[0].id;

    // Insert order items
    for (let item of items) {
      await db.query(
        'INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES ($1, $2, $3)',
        [orderId, item.id, item.quantity]
      );
    }

    // Commit transaction
    await db.query('COMMIT');

    console.log('Order processed successfully');
    res.status(201).json({
      message: 'Order placed successfully',
      orderId
    });
  } catch (err) {
    // Rollback transaction on error
    await db.query('ROLLBACK');
    console.error('Error processing order:', err);
    res.status(500).json({
      error: 'Failed to process order',
      details: err.message
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

