const express = require('express');

const {
  getRecommendedStudents,
  getStudentById,
} = require('../controllers/student_controller');

const router = express.Router();

router.get('/students/recommended', getRecommendedStudents);
router.get('/students/:id', getStudentById);

module.exports = router;
