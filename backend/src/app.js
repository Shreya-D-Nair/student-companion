require('dotenv').config();

const cors = require('cors');
const express = require('express');
const helmet = require('helmet');

const { errorHandler } = require('./middleware/error_handler');
const { generalLimiter } = require('./middleware/rate_limiter');
const confessionRoutes = require('./routes/confession_routes');
const connectRequestRoutes = require('./routes/connect_request_routes');
const healthRoutes = require('./routes/health_routes');
const interestRoutes = require('./routes/interest_routes');
const studentRoutes = require('./routes/student_routes');
const supportResourceRoutes = require('./routes/support_resource_routes');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '20kb' }));
app.use(generalLimiter);

app.get('/', (req, res) => {
  res.json({
    name: 'Student Companion API',
    status: 'ready',
    phase: 'submission-ready',
  });
});

app.use('/api', healthRoutes);
app.use('/api', confessionRoutes);
app.use('/api', interestRoutes);
app.use('/api', studentRoutes);
app.use('/api', connectRequestRoutes);
app.use('/api', supportResourceRoutes);

app.use(errorHandler);

module.exports = app;
