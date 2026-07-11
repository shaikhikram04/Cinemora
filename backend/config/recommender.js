const axios = require("axios");

const recommender = axios.create({
  baseURL: process.env.RECOMMENDER_URL || "http://localhost:8000",
  timeout: 15_000,
  headers: { "X-Internal-Secret": process.env.INTERNAL_SERVICE_SECRET },
});

module.exports = recommender;
