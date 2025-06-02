const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// For monitoring if app is ready to receive requests
let isReady = false;

// Set the app to be ready after 2 seconds
setTimeout(() => {
  isReady = true;
  console.log('Application is ready to receive traffic');
}, 2000);

// Liveness probe endpoint
app.get('/liveness', (req, res) => {
  console.log('Liveness probe request received');
  res.status(200).json({ status: 'alive' });
});

// Readiness probe endpoint
app.get('/readiness', (req, res) => {
  console.log('Readiness probe request received');
  
  if (isReady) {
    res.status(200).json({ status: 'ready' });
  } else {
    // Return 503 if the app is not ready yet
    res.status(503).json({ status: 'not ready' });
  }
});

// Health check endpoint
app.get('/healthz', (req, res) => {
  console.log('Health check request received');
  res.status(200).json({ status: 'healthy' });
});

// Default route
app.get('/', (req, res) => {
  res.status(200).json({ status: 'Ok', version: 'v1' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('Initializing application...');
  console.log('Application will be ready in 2 seconds');
});
