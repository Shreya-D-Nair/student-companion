require('dotenv').config();

const fs = require('fs/promises');
const path = require('path');
const { Client } = require('pg');

async function runSqlFile() {
  const relativeFilePath = process.argv[2];

  if (!relativeFilePath) {
    console.error('Please provide a SQL file path.');
    process.exit(1);
  }

  const connectionString = process.env.DATABASE_URL_DIRECT?.trim().replace(
    /^['"]|['"]$/g,
    '',
  );
  if (!connectionString) {
    console.error('DATABASE_URL_DIRECT is not configured.');
    process.exit(1);
  }

  const filePath = path.resolve(process.cwd(), relativeFilePath);
  const sql = await fs.readFile(filePath, 'utf8');

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false },
    connectionTimeoutMillis: 5000,
  });

  try {
    await client.connect();
    await client.query(sql);
    console.log(`Successfully ran ${relativeFilePath}`);
  } catch (error) {
    console.error(`Could not run ${relativeFilePath}. Check your database URL and SQL file.`);
    process.exitCode = 1;
  } finally {
    await client.end().catch(() => {});
  }
}

runSqlFile().catch((error) => {
  console.error('Database setup failed. Check your database URL and SQL file.');
  process.exit(1);
});
