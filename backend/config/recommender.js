const axios = require("axios");

// Fail at boot rather than on the first recommendation request. The
// recommender refuses to start without this too, and the two must match —
// catching it here means a misconfigured deploy is obvious immediately
// instead of surfacing as every user's home feed quietly 401ing.
const PLACEHOLDERS = new Set([
  "dev-secret-change-me",
  "change-me-shared-with-node-backend",
  "change-me-shared-with-recommender",
]);

const secret = (process.env.INTERNAL_SERVICE_SECRET || "").trim();
if (!secret || PLACEHOLDERS.has(secret) || secret.length < 16) {
  throw new Error(
    "INTERNAL_SERVICE_SECRET must be set to a real, unpublished value of at " +
      "least 16 characters (generate one with `openssl rand -hex 32`), and " +
      "must match INTERNAL_SERVICE_SECRET in recommender/.env",
  );
}

const recommender = axios.create({
  baseURL: process.env.RECOMMENDER_URL || "http://localhost:8000",
  timeout: 15_000,
  headers: { "X-Internal-Secret": process.env.INTERNAL_SERVICE_SECRET },
});

module.exports = recommender;
