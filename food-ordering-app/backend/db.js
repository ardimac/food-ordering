const { Pool } = require('pg');

const pool = new Pool({
    user: 'admin',
    host: 'localhost',
    database: 'foodering',
    password: 'admin123!',
    port: 5432,
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};
