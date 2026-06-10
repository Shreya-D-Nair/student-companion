const app = require('./app');

const port = process.env.PORT || 4242;

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://localhost:${port}`);
});
