const { query } = require('../config/database');

async function getInterests(req, res) {
  try {
    const interests = await query`
      SELECT
        id,
        name,
        icon_name
      FROM interests
      ORDER BY name ASC
    `;

    return res.status(200).json({
      success: true,
      data: interests,
    });
  } catch (error) {
    console.error('Fetch interests error: unable to load interests.');

    return res.status(500).json({
      success: false,
      message: 'Unable to load interests',
    });
  }
}

async function saveUserInterests(req, res) {
  try {
    const { anonymousDeviceId, interestIds } = req.body;

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    if (!Array.isArray(interestIds)) {
      return res.status(400).json({
        success: false,
        message: 'Interest IDs must be an array',
      });
    }

    await query`
      DELETE FROM anonymous_user_interests
      WHERE anonymous_device_id = ${anonymousDeviceId}
    `;

    for (const interestId of interestIds) {
      await query`
        INSERT INTO anonymous_user_interests (
          anonymous_device_id,
          interest_id
        )
        VALUES (
          ${anonymousDeviceId},
          ${interestId}
        )
        ON CONFLICT DO NOTHING
      `;
    }

    return res.json({
      success: true,
      message: 'Interests saved successfully',
    });
  } catch (error) {
    console.error('Save interests error: unable to save interests.');

    return res.status(500).json({
      success: false,
      message: 'Unable to save interests',
    });
  }
}

module.exports = { getInterests, saveUserInterests };
