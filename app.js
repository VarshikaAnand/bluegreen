// app.js
const express = require("express");
const app = express();

const version = process.env.APP_VERSION || "blue";

app.get("/", (req, res) => {
  res.send(`Hello from ${version} environment!`);
});

app.get("/health", (req, res) => {
  res.json({ status: "UP", environment: version });
});

app.listen(3000, () => console.log(`Running on ${version} env...`));
