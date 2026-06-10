const { query } = require('../config/database');

async function getSupportResources(req, res) {
  try {
    const resources = await query`
      SELECT
        id,
        category,
        description,
        tips,
        created_at
      FROM support_resources
      ORDER BY category ASC
    `;

    return res.status(200).json({
      success: true,
      data: resources,
    });
  } catch (error) {
    console.error('Fetch support resources error: unable to load resources.');

    return res.status(500).json({
      success: false,
      message: 'Unable to load support resources',
    });
  }
}

module.exports = { getSupportResources };
