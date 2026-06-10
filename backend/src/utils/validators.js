const { z } = require('zod');

const anonymousDeviceIdSchema = z.string().uuid();

module.exports = {
  anonymousDeviceIdSchema,
};
