const { neon } = require('@neondatabase/serverless');

function cleanConnectionString(value) {
  return value?.trim().replace(/^['"]|['"]$/g, '');
}

const connectionString = cleanConnectionString(process.env.DATABASE_URL);

let sql;

function getSqlClient() {
  if (!connectionString) {
    throw new Error('DATABASE_URL is not configured.');
  }

  if (!sql) {
    sql = neon(connectionString);
  }

  return sql;
}

function query(strings, ...values) {
  return getSqlClient()(strings, ...values);
}

async function checkDatabaseConnection() {
  const result = await query`SELECT 1 AS ok;`;
  return result[0]?.ok === 1;
}

async function closeDatabasePool() {
  sql = undefined;
}

module.exports = {
  query,
  getSqlClient,
  checkDatabaseConnection,
  closeDatabasePool,
};
