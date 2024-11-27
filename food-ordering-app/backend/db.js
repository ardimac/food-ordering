const { Pool } = require('pg');

const pool = new Pool({
    user: 'admin',
    host: '172.17.1.1',
    database: 'foodering',
    password: 'admin123!',
    port: 5432,
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};
