const express = require('express');

const { getHealth } = require('../controllers/health_controller');

const router = express.Router();

router.get('/health', getHealth);

module.exports = router;
