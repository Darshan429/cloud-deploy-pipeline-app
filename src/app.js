const express = require('express');
const notesRouter = require('./routes/notes');
const { register, metricsMiddleware } = require('./middleware/metrics');

function createApp() {
  const app = express();
  app.use(express.json());
  app.use(metricsMiddleware);

  // Liveness/readiness probe target for Kubernetes.
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', uptime: process.uptime() });
  });

  // Scrape target for Prometheus.
  app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  });

  app.use('/api/notes', notesRouter);

  app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
  });

  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  });

  return app;
}

module.exports = createApp;
