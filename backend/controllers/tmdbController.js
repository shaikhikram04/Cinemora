const tmdb = require("../config/tmdb");

// GET /api/tmdb/trending?type=all&time=day
const getTrending = async (req, res) => {
  const { type = "all", time = "day" } = req.query;
  const validTypes = ["all", "movie", "tv", "person"];
  const validTimes = ["day", "week"];

  if (!validTypes.includes(type))
    return res.status(400).json({ error: "Invalid type" });
  if (!validTimes.includes(time))
    return res.status(400).json({ error: "Invalid time window" });

  const data = await tmdb.get(
    `/trending/${type}/${time}`,
    {},
    tmdb.TTL.trending,
  );

  const now = new Date();
  data.results = data.results.filter((item) => {
    const dateStr = item.release_date || item.first_air_date;
    if (!dateStr) return false;
    return new Date(dateStr) <= now;
  });

  res.json(data);
};

// GET /api/tmdb/search?q=&type=
const search = async (req, res) => {
  const { q, type = "multi" } = req.query;
  if (!q) return res.status(400).json({ error: "q is required" });

  const validTypes = ["multi", "movie", "tv"];
  if (!validTypes.includes(type))
    return res.status(400).json({ error: "Invalid type" });

  // Not cached — search results change constantly and are query-specific
  const data = await tmdb.fetch(`/search/${type}`, {
    query: q,
    include_adult: false,
  });
  res.json(data);
};

// GET /api/tmdb/movie/:id
const getMovie = async (req, res) => {
  const data = await tmdb.get(`/movie/${req.params.id}`, {
    append_to_response: "credits,videos,similar",
  });
  res.json(data);
};

// GET /api/tmdb/tv/:id
const getTv = async (req, res) => {
  const data = await tmdb.get(`/tv/${req.params.id}`, {
    append_to_response: "credits,videos,similar",
  });
  res.json(data);
};

// GET /api/tmdb/tv/:id/season/:season
const getSeason = async (req, res) => {
  const { id, season } = req.params;
  const data = await tmdb.get(`/tv/${id}/season/${season}`);
  res.json(data);
};

// GET /api/tmdb/movie/:id/watch-providers
const getMovieProviders = async (req, res) => {
  const data = await tmdb.get(`/movie/${req.params.id}/watch/providers`);
  res.json(data);
};

// GET /api/tmdb/tv/:id/watch-providers
const getTvProviders = async (req, res) => {
  const data = await tmdb.get(`/tv/${req.params.id}/watch/providers`);
  res.json(data);
};

// GET /api/tmdb/genres?type=movie|tv
const getGenres = async (req, res) => {
  const { type = "movie" } = req.query;
  if (!["movie", "tv"].includes(type))
    return res.status(400).json({ error: "type must be movie or tv" });

  const data = await tmdb.get(`/genre/${type}/list`, {}, tmdb.TTL.genres);
  res.json(data);
};

module.exports = {
  getTrending,
  search,
  getMovie,
  getTv,
  getSeason,
  getMovieProviders,
  getTvProviders,
  getGenres,
};
