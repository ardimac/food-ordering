const { Pool } = require('pg');

const pool = new Pool({
    user: 'admin',
    host: '18.136.209.179',
    database: 'foodering',
    password: 'admin123!',
    port: 5432,
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};
