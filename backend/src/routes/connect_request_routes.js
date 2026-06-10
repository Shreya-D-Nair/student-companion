const express = require('express');

const {
  createConnectRequest,
} = require('../controllers/connect_request_controller');

const router = express.Router();

router.post('/connect-requests', createConnectRequest);

module.exports = router;
