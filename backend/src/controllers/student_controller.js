const { query } = require('../config/database');

async function getRecommendedStudents(req, res) {
  try {
    const { anonymousDeviceId } = req.query;

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    const students = await query`
      SELECT
        students.id,
        students.name,
        students.course,
        students.academic_year,
        students.bio,
        students.avatar_url,
        COUNT(interests.id)::int AS common_interest_count,
        COALESCE(
          json_agg(interests.name ORDER BY interests.name)
          FILTER (WHERE interests.id IS NOT NULL),
          '[]'
        ) AS shared_interests
      FROM students
      JOIN student_interests
        ON student_interests.student_id = students.id
      JOIN anonymous_user_interests
        ON anonymous_user_interests.interest_id = student_interests.interest_id
       AND anonymous_user_interests.anonymous_device_id = ${anonymousDeviceId}
      JOIN interests
        ON interests.id = student_interests.interest_id
      GROUP BY students.id
      HAVING COUNT(interests.id) > 0
      ORDER BY common_interest_count DESC, students.name ASC
    `;

    return res.json({
      success: true,
      data: students,
    });
  } catch (error) {
    console.error('Recommended students error: unable to load students.');

    return res.status(500).json({
      success: false,
      message: 'Unable to load recommended students',
    });
  }
}

async function getStudentById(req, res) {
  try {
    const { id } = req.params;
    const { anonymousDeviceId } = req.query;

    const students = await query`
      SELECT
        students.id,
        students.name,
        students.course,
        students.academic_year,
        students.bio,
        students.avatar_url,
        COALESCE(
          json_agg(DISTINCT interests.name ORDER BY interests.name),
          '[]'
        ) AS interests,
        COALESCE(
          json_agg(DISTINCT common_interests.name ORDER BY common_interests.name)
          FILTER (WHERE common_interests.id IS NOT NULL),
          '[]'
        ) AS shared_interests
      FROM students
      LEFT JOIN student_interests
        ON student_interests.student_id = students.id
      LEFT JOIN interests
        ON interests.id = student_interests.interest_id
      LEFT JOIN anonymous_user_interests
        ON anonymous_user_interests.interest_id = student_interests.interest_id
       AND anonymous_user_interests.anonymous_device_id = ${anonymousDeviceId || ''}
      LEFT JOIN interests AS common_interests
        ON common_interests.id = anonymous_user_interests.interest_id
      WHERE students.id = ${id}
      GROUP BY students.id
    `;

    if (students.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Student not found',
      });
    }

    return res.json({
      success: true,
      data: students[0],
    });
  } catch (error) {
    console.error('Student details error: unable to load student.');

    return res.status(500).json({
      success: false,
      message: 'Unable to load student details',
    });
  }
}

module.exports = {
  getRecommendedStudents,
  getStudentById,
};
