const tmdb = require("../config/tmdb");
const AppError = require("../utils/AppError");

// GET /api/tmdb/trending?type=all&time=day
const getTrending = async (req, res, next) => {
  const { type = "all", time = "day" } = req.query;
  const validTypes = ["all", "movie", "tv", "person"];
  const validTimes = ["day", "week"];

  if (!validTypes.includes(type))
    return next(new AppError(400, "TMDB_INVALID_TYPE", "Invalid type"));
  if (!validTimes.includes(time))
    return next(new AppError(400, "TMDB_INVALID_TIME_WINDOW", "Invalid time window"));

  try {
    const data = await tmdb.get(
      `/trending/${type}/${time}`,
      {},
      tmdb.TTL.trending,
    );

    const now = new Date();
    const filtered = data.results.filter((item) => {
      const dateStr = item.release_date || item.first_air_date;
      if (!dateStr) return false;
      return new Date(dateStr) <= now;
    });

    res.json({ ...data, results: filtered });
  } catch (err) {
    console.error("[TMDB] getTrending failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/search?q=&type=
const search = async (req, res, next) => {
  const { q, type = "multi" } = req.query;
  if (!q) return next(new AppError(400, "TMDB_QUERY_REQUIRED", "q is required"));

  const validTypes = ["multi", "movie", "tv"];
  if (!validTypes.includes(type))
    return next(new AppError(400, "TMDB_INVALID_TYPE", "Invalid type"));

  try {
    const data = await tmdb.fetch(`/search/${type}`, {
      query: q,
      include_adult: false,
    });
    res.json(data);
  } catch (err) {
    console.error("[TMDB] search failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/movie/:id
const getMovie = async (req, res, next) => {
  try {
    const data = await tmdb.get(`/movie/${req.params.id}`, {
      append_to_response: "credits,videos,similar",
    });
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getMovie failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/tv/:id
const getTv = async (req, res, next) => {
  try {
    const data = await tmdb.get(`/tv/${req.params.id}`, {
      append_to_response: "credits,videos,similar",
    });
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getTv failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/tv/:id/season/:season
const getSeason = async (req, res, next) => {
  try {
    const { id, season } = req.params;
    const data = await tmdb.get(`/tv/${id}/season/${season}`);
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getSeason failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/movie/:id/watch-providers
const getMovieProviders = async (req, res, next) => {
  try {
    const data = await tmdb.get(`/movie/${req.params.id}/watch/providers`);
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getMovieProviders failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/tv/:id/watch-providers
const getTvProviders = async (req, res, next) => {
  try {
    const data = await tmdb.get(`/tv/${req.params.id}/watch/providers`);
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getTvProviders failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/genres?type=movie|tv
const getGenres = async (req, res, next) => {
  const { type = "movie" } = req.query;
  if (!["movie", "tv"].includes(type))
    return next(new AppError(400, "TMDB_INVALID_GENRE_TYPE", "type must be movie or tv"));

  try {
    const data = await tmdb.get(`/genre/${type}/list`, {}, tmdb.TTL.genres);
    res.json(data);
  } catch (err) {
    console.error("[TMDB] getGenres failed:", err.message);
    next(err);
  }
};

// GET /api/tmdb/discover?type=movie|tv&genre_id=28&page=1
const discover = async (req, res, next) => {
  const { type = "movie", genre_id, page = "1" } = req.query;
  if (!["movie", "tv"].includes(type))
    return next(new AppError(400, "TMDB_INVALID_TYPE", "type must be movie or tv"));

  try {
    const params = {
      sort_by: "popularity.desc",
      page: parseInt(page, 10) || 1,
      include_adult: false,
    };
    if (genre_id) params.with_genres = genre_id;

    const data = await tmdb.get(`/discover/${type}`, params, tmdb.TTL.trending);

    const now = new Date();
    const filtered = data.results.filter((item) => {
      const dateStr = item.release_date || item.first_air_date;
      if (!dateStr) return false;
      return new Date(dateStr) <= now;
    });

    res.json({ ...data, results: filtered });
  } catch (err) {
    console.error("[TMDB] discover failed:", err.message);
    next(err);
  }
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
  discover,
};
