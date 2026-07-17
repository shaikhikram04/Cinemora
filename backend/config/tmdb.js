const axios = require("axios");
const { cacheGet, cacheSet } = require("./redis");

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
  const key = `tmdb:${path}${JSON.stringify(params)}`;
  const cached = await cacheGet(key);
  if (cached) return cached;

  const { data } = await tmdb.get(path, { params });
  await cacheSet(key, data, ttl);
  return data;
};

// raw client for calls that should never be cached (e.g. search)
const fetch = async (path, params = {}) => {
  const { data } = await tmdb.get(path, { params });
  return data;
};

module.exports = { get, fetch, TTL };
