const express = require("express");
const os = require("os");
const app = express();
const port = process.env.PORT || 3000;
const env = process.env.ENV_NAME || "unknown";

const startTime = Date.now();

app.get("/", (req, res) => {
  const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);
  const minutes = Math.floor(uptimeSeconds / 60);
  const seconds = uptimeSeconds % 60;

  res.send(`
    <html>
      <head>
        <title>Blue-Green Dashboard</title>
        <style>
          body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: ${env === "blue" ? "#cce5ff" : "#d4edda"};
            color: #333;
            text-align: center;
            margin-top: 80px;
          }
          h1 { font-size: 2.5rem; }
          .env {
            font-weight: bold;
            font-size: 1.5rem;
            color: ${env === "blue" ? "#004085" : "#155724"};
          }
          .stats {
            margin-top: 30px;
            font-size: 1.1rem;
          }
          .container {
            border: 3px solid ${env === "blue" ? "#004085" : "#155724"};
            display: inline-block;
            padding: 20px 40px;
            border-radius: 15px;
            background: white;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1> Blue-Green Deployment Demo</h1>
          <p class="env">Active Environment: ${env.toUpperCase()}</p>
          <div class="stats">
            <p>Hostname: ${os.hostname()}</p>
            <p>Running on port: ${port}</p>
            <p>Uptime: ${minutes}m ${seconds}s</p>
          </div>
        </div>
      </body>
    </html>
  `);
});
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP",
    environment: process.env.ENV_NAME || "unknown",
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`App running in ${env} mode on port ${port}`);
});
