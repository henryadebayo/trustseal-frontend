const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

async function runMigrations() {
    const migrationsDir = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(migrationsDir)
        .filter(file => file.endsWith('.sql'))
        .sort();

    console.log('Running migrations...');

    for (const file of files) {
        console.log(`Executing migration: ${file}`);
        const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');

        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            await client.query(sql);
            await client.query('COMMIT');
            console.log(`✓ Migration ${file} completed`);
        } catch (error) {
            await client.query('ROLLBACK');
            console.error(`✗ Migration ${file} failed:`, error.message);
            throw error;
        } finally {
            client.release();
        }
    }

    console.log('All migrations completed successfully!');
    process.exit(0);
}

runMigrations().catch(error => {
    console.error('Migration failed:', error);
    process.exit(1);
});
