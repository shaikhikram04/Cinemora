const LibraryEntry = require("../models/LibraryEntry");
const AppError = require("../utils/AppError");

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Resolves the compound key filter from request params + ?type= query param. */
const compoundFilter = (req) => ({
  userId: req.user.userId,
  tmdbId: Number(req.params.tmdbId),
  cinemaType: req.query.type,
});

// ── Collection ────────────────────────────────────────────────────────────────

// GET /api/library?status=&cinemaType=&sort=
const getLibrary = async (req, res) => {
  const { status, cinemaType, sort = "updatedAt" } = req.query;

  const filter = { userId: req.user.userId };
  if (status) filter.status = status;
  if (cinemaType) filter.cinemaType = cinemaType;

  const sortMap = {
    updatedAt: { updatedAt: -1 },
    addedAt: { createdAt: -1 },
    title: { title: 1 },
    rating: { userRating: -1 },
  };

  const entries = await LibraryEntry.find(filter)
    .sort(sortMap[sort] || { updatedAt: -1 })
    .select("-__v");

  res.json(entries);
};

// GET /api/library/stats
const getStats = async (req, res) => {
  const userId = req.user.userId;

  const entries = await LibraryEntry.find({ userId }).select(
    "status cinemaType genres runtimeMinutes watchedAt progress"
  );

  const byStatus = { watchlist: 0, watching: 0, watched: 0, dropped: 0 };
  const byCinemaType = { movie: 0, tv: 0, anime: 0 };
  const genreFreq = {};
  let totalWatchMinutes = 0;
  let rewatchCount = 0;

  for (const entry of entries) {
    byStatus[entry.status] = (byStatus[entry.status] || 0) + 1;
    byCinemaType[entry.cinemaType] = (byCinemaType[entry.cinemaType] || 0) + 1;

    for (const g of entry.genres) {
      genreFreq[g] = (genreFreq[g] || 0) + 1;
    }

    const watchCount = entry.watchedAt.length;
    if (watchCount > 0 && entry.runtimeMinutes) {
      const totalEps = entry.progress?.totalEpisodes || 1;
      const episodeMultiplier = entry.cinemaType === "movie" ? 1 : totalEps;
      totalWatchMinutes += entry.runtimeMinutes * episodeMultiplier * watchCount;
    }

    if (watchCount > 1) rewatchCount += watchCount - 1;
  }

  const topGenres = Object.entries(genreFreq)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([genre, count]) => ({ genre, count }));

  res.json({
    totalEntries: entries.length,
    byStatus,
    byCinemaType,
    totalWatchMinutes,
    rewatchCount,
    topGenres,
  });
};

// ── Single entry CRUD ─────────────────────────────────────────────────────────

// POST /api/library
const addToLibrary = async (req, res, next) => {
  const {
    tmdbId, cinemaType, title, posterPath, releaseYear,
    genres, tmdbRating, runtimeMinutes, status,
  } = req.body;

  if (!tmdbId || !cinemaType || !title) {
    return next(new AppError(400, "LIBRARY_MISSING_FIELDS", "tmdbId, cinemaType, and title are required"));
  }

  const existing = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId,
    cinemaType,
  });
  if (existing) return next(new AppError(409, "LIBRARY_ALREADY_EXISTS", "Already in library"));

  const entry = await LibraryEntry.create({
    userId: req.user.userId,
    tmdbId,
    cinemaType,
    title,
    posterPath,
    releaseYear,
    genres: genres || [],
    tmdbRating,
    runtimeMinutes,
    status: status || "watchlist",
  });

  res.status(201).json(entry);
};

// GET /api/library/:tmdbId?type=cinemaType
const getEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"));
  }

  const entry = await LibraryEntry.findOne(compoundFilter(req)).select("-__v");
  if (!entry) return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));
  res.json(entry);
};

// PUT /api/library/:tmdbId?type=cinemaType
const updateEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"));
  }

  const entry = await LibraryEntry.findOne(compoundFilter(req));
  if (!entry) return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));

  const { status, userRating, review, progress, runtimeMinutes } = req.body;

  const wasWatched = entry.status === "watched";
  const nowWatched = status === "watched";
  if (nowWatched && !wasWatched) entry.watchedAt.push(new Date());

  if (status !== undefined) entry.status = status;
  if (userRating !== undefined) entry.userRating = userRating;
  if (review !== undefined) entry.review = review;
  if (progress !== undefined) entry.progress = { ...entry.progress?.toObject(), ...progress };
  if (runtimeMinutes !== undefined) entry.runtimeMinutes = runtimeMinutes;

  await entry.save();
  res.json(entry);
};

// DELETE /api/library/:tmdbId?type=cinemaType
const deleteEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"));
  }

  const result = await LibraryEntry.deleteOne(compoundFilter(req));
  if (result.deletedCount === 0) return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));
  res.json({ message: "Removed from library" });
};

// ── Season-level CRUD ─────────────────────────────────────────────────────────

// PUT /api/library/:tmdbId/seasons/:seasonNumber?type=cinemaType
const upsertSeason = async (req, res, next) => {
  const cinemaType = req.query.type;
  if (!cinemaType) {
    return next(new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"));
  }

  const tmdbId = Number(req.params.tmdbId);
  const seasonNumber = Number(req.params.seasonNumber);
  const { seasonId, status, rating, title, posterPath, releaseYear, genres, tmdbRating } = req.body;

  if (!status) {
    return next(new AppError(400, "LIBRARY_MISSING_FIELDS", "status is required"));
  }

  // Find or create the parent show document
  let entry = await LibraryEntry.findOne({ userId: req.user.userId, tmdbId, cinemaType });

  if (!entry) {
    if (!title) {
      return next(new AppError(400, "LIBRARY_MISSING_FIELDS", "title is required when creating a new entry"));
    }
    entry = new LibraryEntry({
      userId: req.user.userId,
      tmdbId,
      cinemaType,
      title,
      posterPath,
      releaseYear,
      genres: genres || [],
      tmdbRating,
      status: "watchlist", // show-level defaults to watchlist until explicitly set
      seasons: [],
    });
  }

  // Upsert the season within the embedded array
  const idx = entry.seasons.findIndex((s) => s.seasonNumber === seasonNumber);
  if (idx >= 0) {
    if (status !== undefined) entry.seasons[idx].status = status;
    if (rating !== undefined) entry.seasons[idx].rating = rating;
    if (seasonId !== undefined) entry.seasons[idx].seasonId = seasonId;
  } else {
    entry.seasons.push({ seasonNumber, seasonId, status, rating });
  }

  entry.markModified("seasons");
  await entry.save();
  res.json(entry);
};

// DELETE /api/library/:tmdbId/seasons/:seasonNumber?type=cinemaType
const deleteSeason = async (req, res, next) => {
  const cinemaType = req.query.type;
  if (!cinemaType) {
    return next(new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"));
  }

  const tmdbId = Number(req.params.tmdbId);
  const seasonNumber = Number(req.params.seasonNumber);

  const entry = await LibraryEntry.findOne({ userId: req.user.userId, tmdbId, cinemaType });
  if (!entry) return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));

  entry.seasons = entry.seasons.filter((s) => s.seasonNumber !== seasonNumber);
  entry.markModified("seasons");
  await entry.save();
  res.json(entry);
};

module.exports = {
  getLibrary,
  getStats,
  addToLibrary,
  getEntry,
  updateEntry,
  deleteEntry,
  upsertSeason,
  deleteSeason,
};
