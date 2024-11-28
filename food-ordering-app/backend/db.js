const { Pool } = require('pg');

const pool = new Pool({
    user: 'admin',
    host: '10.0.102.142',
    database: 'foodering',
    password: 'admin123!',
    port: 5432,
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};
