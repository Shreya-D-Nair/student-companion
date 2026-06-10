const { query } = require('../config/database');

async function getHealth(req, res) {
  try {
    const result = await query`SELECT NOW() AS database_time;`;

    return res.json({
      success: true,
      message: 'Backend is connected to Neon PostgreSQL',
      databaseTime: result[0].database_time,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Health check database error: connection unavailable.');

    return res.status(503).json({
      success: false,
      message: 'Unable to connect to the database',
    });
  }
}

module.exports = { getHealth };
