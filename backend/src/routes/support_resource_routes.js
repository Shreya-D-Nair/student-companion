const express = require('express');

const {
  getSupportResources,
} = require('../controllers/support_resource_controller');

const router = express.Router();

router.get('/support-resources', getSupportResources);

module.exports = router;
