const express = require('express');

const {
  createConfession,
  deleteConfession,
  getConfessions,
  reactToConfession,
  removeReaction,
  reportConfession,
} = require('../controllers/confession_controller');

const router = express.Router();

router.get('/confessions', getConfessions);
router.post('/confessions', createConfession);
router.delete('/confessions/:id', deleteConfession);
router.post('/confessions/:id/react', reactToConfession);
router.delete('/confessions/:id/react', removeReaction);
router.post('/confessions/:id/report', reportConfession);

module.exports = router;
