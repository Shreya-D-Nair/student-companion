const { query } = require('../config/database');

async function getConfessions(req, res) {
  try {
    const { anonymousDeviceId } = req.query;
    const confessions = anonymousDeviceId
      ? await query`
        SELECT
          id,
          anonymous_device_id,
          content,
          reaction_count,
          created_at,
          EXISTS (
            SELECT 1
            FROM confession_reactions
            WHERE confession_reactions.confession_id = confessions.id
              AND confession_reactions.anonymous_device_id = ${anonymousDeviceId}
          ) AS has_reacted
        FROM confessions
        ORDER BY created_at DESC
      `
      : await query`
        SELECT
          id,
          anonymous_device_id,
          content,
          reaction_count,
          created_at,
          false AS has_reacted
        FROM confessions
        ORDER BY created_at DESC
      `;

    return res.status(200).json({
      success: true,
      data: confessions,
    });
  } catch (error) {
    console.error('Fetch confessions error: unable to load confessions.');

    return res.status(500).json({
      success: false,
      message: 'Unable to load confessions',
    });
  }
}

async function createConfession(req, res) {
  try {
    const { anonymousDeviceId, content } = req.body;
    const trimmedContent = content?.trim();

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    if (!trimmedContent) {
      return res.status(400).json({
        success: false,
        message: 'Confession cannot be empty',
      });
    }

    if (trimmedContent.length > 300) {
      return res.status(400).json({
        success: false,
        message: 'Confession must not exceed 300 characters',
      });
    }

    const result = await query`
      INSERT INTO confessions (
        anonymous_device_id,
        content
      )
      VALUES (
        ${anonymousDeviceId},
        ${trimmedContent}
      )
      RETURNING
        id,
        anonymous_device_id,
        content,
        reaction_count,
        created_at,
        false AS has_reacted
    `;

    return res.status(201).json({
      success: true,
      message: 'Confession created successfully',
      data: result[0],
    });
  } catch (error) {
    console.error('Create confession error: unable to create confession.');

    return res.status(500).json({
      success: false,
      message: 'Unable to create confession',
    });
  }
}

async function deleteConfession(req, res) {
  try {
    const { id } = req.params;
    const { anonymousDeviceId } = req.body;

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    const result = await query`
      DELETE FROM confessions
      WHERE id = ${id}
        AND anonymous_device_id = ${anonymousDeviceId}
      RETURNING id
    `;

    if (result.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'You can delete only confessions created from this device',
      });
    }

    return res.json({
      success: true,
      message: 'Confession deleted successfully',
    });
  } catch (error) {
    console.error('Delete confession error: unable to delete confession.');

    return res.status(500).json({
      success: false,
      message: 'Unable to delete confession',
    });
  }
}

async function reactToConfession(req, res) {
  try {
    const { id } = req.params;
    const { anonymousDeviceId } = req.body;

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    const reaction = await query`
      INSERT INTO confession_reactions (
        confession_id,
        anonymous_device_id
      )
      VALUES (
        ${id},
        ${anonymousDeviceId}
      )
      ON CONFLICT (confession_id, anonymous_device_id) DO NOTHING
      RETURNING id
    `;

    if (reaction.length > 0) {
      await query`
        UPDATE confessions
        SET reaction_count = reaction_count + 1
        WHERE id = ${id}
      `;
    }

    const confession = await query`
      SELECT
        id,
        anonymous_device_id,
        content,
        reaction_count,
        created_at,
        true AS has_reacted
      FROM confessions
      WHERE id = ${id}
    `;

    if (confession.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Confession not found',
      });
    }

    return res.json({
      success: true,
      message: reaction.length > 0 ? 'Reaction added' : 'Already reacted',
      data: confession[0],
    });
  } catch (error) {
    console.error('React confession error: unable to update reaction.');

    return res.status(500).json({
      success: false,
      message: 'Unable to react to confession',
    });
  }
}

async function removeReaction(req, res) {
  try {
    const { id } = req.params;
    const { anonymousDeviceId } = req.body;

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    const removed = await query`
      DELETE FROM confession_reactions
      WHERE confession_id = ${id}
        AND anonymous_device_id = ${anonymousDeviceId}
      RETURNING id
    `;

    if (removed.length > 0) {
      await query`
        UPDATE confessions
        SET reaction_count = GREATEST(reaction_count - 1, 0)
        WHERE id = ${id}
      `;
    }

    const confession = await query`
      SELECT
        id,
        anonymous_device_id,
        content,
        reaction_count,
        created_at,
        false AS has_reacted
      FROM confessions
      WHERE id = ${id}
    `;

    if (confession.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Confession not found',
      });
    }

    return res.json({
      success: true,
      message: removed.length > 0 ? 'Reaction removed' : 'No reaction found',
      data: confession[0],
    });
  } catch (error) {
    console.error('Remove reaction error: unable to update reaction.');

    return res.status(500).json({
      success: false,
      message: 'Unable to remove reaction',
    });
  }
}

async function reportConfession(req, res) {
  try {
    const { id } = req.params;
    const { anonymousDeviceId, reason } = req.body;
    const trimmedReason = reason?.trim() || 'Reported by user';

    if (!anonymousDeviceId) {
      return res.status(400).json({
        success: false,
        message: 'Anonymous device ID is required',
      });
    }

    await query`
      INSERT INTO confession_reports (
        confession_id,
        anonymous_device_id,
        reason
      )
      VALUES (
        ${id},
        ${anonymousDeviceId},
        ${trimmedReason.slice(0, 200)}
      )
      ON CONFLICT (confession_id, anonymous_device_id) DO NOTHING
    `;

    return res.status(201).json({
      success: true,
      message: 'Confession reported successfully',
    });
  } catch (error) {
    console.error('Report confession error: unable to report confession.');

    return res.status(500).json({
      success: false,
      message: 'Unable to report confession',
    });
  }
}

module.exports = {
  createConfession,
  deleteConfession,
  getConfessions,
  reactToConfession,
  removeReaction,
  reportConfession,
};
