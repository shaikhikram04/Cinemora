const axios = require("axios");
const { cacheGet, cacheSet } = require("./redis");

// Jikan v4 — no API key required; rate limit: 3 req/s, 60 req/min
const jikan = axios.create({
  baseURL: "https://api.jikan.moe/v4",
  timeout: 10000,
});

const TTL = {
  topAiring: 60 * 60, // 1 hour
  seasons: 60 * 60 * 6, // 6 hours
  details: 60 * 60 * 24, // 24 hours
  genres: 60 * 60 * 24 * 7, // 7 days
};

const get = async (path, params = {}, ttl = TTL.details) => {
  const key = `jikan:${path}${JSON.stringify(params)}`;
  const cached = await cacheGet(key);
  if (cached) return cached;

  const { data } = await jikan.get(path, { params });
  await cacheSet(key, data, ttl);
  return data;
};

// Uncached — for search results that vary per query
const fetch = async (path, params = {}) => {
  const { data } = await jikan.get(path, { params });
  return data;
};

module.exports = { get, fetch, TTL };
