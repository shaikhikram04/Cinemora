const axios = require("axios");
const NodeCache = require("node-cache");

const cache = new NodeCache();

const tmdb = axios.create({
  baseURL: "https://api.themoviedb.org/3",
  params: { api_key: process.env.TMDB_API_KEY },
  timeout: 10_000,
});

// TTLs in seconds
const TTL = {
  trending: 60 * 60,       // 1 hour
  details: 60 * 60 * 24,   // 24 hours
  genres: 60 * 60 * 24 * 7, // 7 days
};

const get = async (path, params = {}, ttl = TTL.details) => {
  const key = path + JSON.stringify(params);
  const cached = cache.get(key);
  if (cached) return cached;

  const { data } = await tmdb.get(path, { params });
  cache.set(key, data, ttl);
  return data;
};

// raw client for calls that should never be cached (e.g. search)
const fetch = async (path, params = {}) => {
  const { data } = await tmdb.get(path, { params });
  return data;
};

module.exports = { get, fetch, TTL };
