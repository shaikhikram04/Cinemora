const jikan = require("../config/jikan");
const AppError = require("../utils/AppError");

// GET /api/jikan/top?filter=airing&type=tv&page=1&limit=25
const getTop = async (req, res, next) => {
  const { filter = "airing", type = "tv", page = 1, limit = 25 } = req.query;
  const validFilters = ["airing", "upcoming", "bypopularity", "favorite"];
  const validTypes = ["tv", "movie", "ova", "special", "ona", "music", "cm", "pv", "tv_special"];

  if (!validFilters.includes(filter)) return next(new AppError(400, "JIKAN_INVALID_FILTER", "Invalid filter"));
  if (!validTypes.includes(type)) return next(new AppError(400, "JIKAN_INVALID_TYPE", "Invalid type"));

  const data = await jikan.get("/top/anime", { filter, type, page, limit }, jikan.TTL.topAiring);

  const now = new Date();
  data.data = data.data.filter((item) => {
    const dateStr = item.aired?.from;
    if (!dateStr) return false;
    return new Date(dateStr) <= now;
  });

  res.json(data);
};

// GET /api/jikan/seasons/now?page=1
const getSeasonNow = async (req, res) => {
  const { page = 1 } = req.query;
  const data = await jikan.get("/seasons/now", { page }, jikan.TTL.seasons);
  res.json(data);
};

// GET /api/jikan/seasons/upcoming?page=1
const getSeasonUpcoming = async (req, res) => {
  const { page = 1 } = req.query;
  const data = await jikan.get("/seasons/upcoming", { page }, jikan.TTL.seasons);
  res.json(data);
};

// GET /api/jikan/anime/:id
const getAnime = async (req, res) => {
  const data = await jikan.get(`/anime/${req.params.id}/full`);
  res.json(data);
};

// GET /api/jikan/anime/:id/characters
const getCharacters = async (req, res) => {
  const data = await jikan.get(`/anime/${req.params.id}/characters`);
  res.json(data);
};

// GET /api/jikan/anime/:id/episodes?page=1
const getEpisodes = async (req, res) => {
  const { page = 1 } = req.query;
  // Episodes change as series airs — shorter TTL (1 hour)
  const data = await jikan.get(
    `/anime/${req.params.id}/episodes`,
    { page },
    jikan.TTL.topAiring,
  );
  res.json(data);
};

// GET /api/jikan/anime/:id/recommendations
const getRecommendations = async (req, res) => {
  const data = await jikan.get(`/anime/${req.params.id}/recommendations`);
  res.json(data);
};

// GET /api/jikan/anime/:id/relations
const getRelations = async (req, res) => {
  const data = await jikan.get(`/anime/${req.params.id}/relations`);
  res.json(data);
};

// GET /api/jikan/genres
const getGenres = async (req, res) => {
  const data = await jikan.get("/genres/anime", {}, jikan.TTL.genres);
  res.json(data);
};

// GET /api/jikan/search?q=&type=&status=&genres=&order_by=&sort=&page=&limit=
const search = async (req, res, next) => {
  const { q, type, status, genres, order_by, sort, page = 1, limit = 25 } = req.query;
  if (!q) return next(new AppError(400, "JIKAN_QUERY_REQUIRED", "q is required"));

  const params = { q, page, limit, sfw: true };
  if (type) params.type = type;
  if (status) params.status = status;
  if (genres) params.genres = genres;
  if (order_by) params.order_by = order_by;
  if (sort) params.sort = sort;

  const data = await jikan.fetch("/anime", params);
  res.json(data);
};

module.exports = {
  getTop,
  getSeasonNow,
  getSeasonUpcoming,
  getAnime,
  getCharacters,
  getEpisodes,
  getRecommendations,
  getRelations,
  getGenres,
  search,
};
