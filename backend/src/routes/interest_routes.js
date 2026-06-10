const express = require('express');

const {
  getInterests,
  saveUserInterests,
} = require('../controllers/interest_controller');

const router = express.Router();

router.get('/interests', getInterests);
router.post('/user-interests', saveUserInterests);

module.exports = router;
