function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  const statusCode = error.statusCode || 500;
  const message =
    statusCode === 500
      ? 'Something went wrong. Please try again later.'
      : error.message;

  return res.status(statusCode).json({ error: message });
}

module.exports = { errorHandler };
