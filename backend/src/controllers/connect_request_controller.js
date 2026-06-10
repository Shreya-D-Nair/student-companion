const { query } = require('../config/database');

async function createConnectRequest(req, res) {
  try {
    const { anonymousDeviceId, studentId } = req.body;

    if (!anonymousDeviceId || !studentId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID and student ID are required',
      });
    }

    const result = await query`
      INSERT INTO connect_requests (
        anonymous_device_id,
        student_id
      )
      VALUES (
        ${anonymousDeviceId},
        ${studentId}
      )
      ON CONFLICT (anonymous_device_id, student_id) DO NOTHING
      RETURNING id, anonymous_device_id, student_id, status, created_at
    `;

    return res.status(result.length > 0 ? 201 : 200).json({
      success: true,
      message:
        result.length > 0
          ? 'Connect request sent successfully.'
          : 'Connect request already exists.',
      data: result[0] || null,
    });
  } catch (error) {
    console.error('Connect request error: unable to create request.');

    return res.status(500).json({
      success: false,
      message: 'Unable to send connect request',
    });
  }
}

module.exports = { createConnectRequest };
