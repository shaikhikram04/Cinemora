const LibraryEntry = require("../models/LibraryEntry");
const { resolveOriginalLanguage } = require("../utils/originalLanguage");
const AppError = require("../utils/AppError");

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Resolves the compound key filter from request params + ?type= query param. */
const compoundFilter = (req) => ({
  userId: req.user.userId,
  tmdbId: Number(req.params.tmdbId),
  cinemaType: req.query.type,
});

// ── Collection ────────────────────────────────────────────────────────────────

const VALID_CINEMA_TYPES = new Set(["movie", "tv", "anime"]);
const VALID_STATUSES = new Set(["watchlist", "watching", "watched", "dropped"]);

// GET /api/library?status=&cinemaType=&sort=
const getLibrary = async (req, res, next) => {
  const { status, cinemaType, sort = "updatedAt" } = req.query;

  if (cinemaType && !VALID_CINEMA_TYPES.has(cinemaType)) {
    return next(
      new AppError(
        400,
        "LIBRARY_INVALID_TYPE",
        `cinemaType must be one of: ${[...VALID_CINEMA_TYPES].join(", ")}`,
      ),
    );
  }
  if (status && !VALID_STATUSES.has(status)) {
    return next(
      new AppError(
        400,
        "LIBRARY_INVALID_STATUS",
        `status must be one of: ${[...VALID_STATUSES].join(", ")}`,
      ),
    );
  }

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
    "status cinemaType genres watchedAt",
  );

  const byStatus = { watchlist: 0, watching: 0, watched: 0, dropped: 0 };
  const byCinemaType = { movie: 0, tv: 0, anime: 0 };
  const genreFreq = {};
  let rewatchCount = 0;

  for (const entry of entries) {
    byStatus[entry.status] = (byStatus[entry.status] || 0) + 1;
    byCinemaType[entry.cinemaType] = (byCinemaType[entry.cinemaType] || 0) + 1;

    for (const g of entry.genres) {
      genreFreq[g] = (genreFreq[g] || 0) + 1;
    }

    const watchCount = entry.watchedAt.length;
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
    rewatchCount,
    topGenres,
  });
};

// ── Single entry CRUD ─────────────────────────────────────────────────────────

// POST /api/library
const addToLibrary = async (req, res, next) => {
  const {
    tmdbId,
    cinemaType,
    title,
    posterPath,
    releaseYear,
    genres,
    tmdbRating,
    runtimeMinutes,
    originalLanguage,
    status,
  } = req.body;

  if (!tmdbId || !cinemaType || !title) {
    return next(
      new AppError(
        400,
        "LIBRARY_MISSING_FIELDS",
        "tmdbId, cinemaType, and title are required",
      ),
    );
  }

  const existing = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId,
    cinemaType,
  });
  if (existing)
    return next(
      new AppError(409, "LIBRARY_ALREADY_EXISTS", "Already in library"),
    );

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
    originalLanguage: await resolveOriginalLanguage(
      originalLanguage,
      cinemaType,
      tmdbId,
    ),
    status: status || "watchlist",
  });

  res.status(201).json(entry);
};

// POST /api/library/upsert
// Atomically creates or updates a library entry.
// Handles watchedAt stamping the same way PUT /:tmdbId does.
const upsertEntry = async (req, res, next) => {
  const {
    tmdbId,
    cinemaType,
    title,
    posterPath,
    releaseYear,
    genres,
    tmdbRating,
    runtimeMinutes,
    originalLanguage,
    status,
    userRating,
    progress,
  } = req.body;

  if (!tmdbId || !cinemaType || !title) {
    return next(
      new AppError(
        400,
        "LIBRARY_MISSING_FIELDS",
        "tmdbId, cinemaType, and title are required",
      ),
    );
  }

  const userId = req.user.userId;
  const numericTmdbId = Number(tmdbId);
  const resolvedStatus = status || "watchlist";
  const resolvedLanguage = await resolveOriginalLanguage(
    originalLanguage,
    cinemaType,
    numericTmdbId,
  );

  let entry = await LibraryEntry.findOne({
    userId,
    tmdbId: numericTmdbId,
    cinemaType,
  });

  if (!entry) {
    entry = await LibraryEntry.create({
      userId,
      tmdbId: numericTmdbId,
      cinemaType,
      title,
      posterPath,
      releaseYear,
      genres: genres || [],
      tmdbRating,
      runtimeMinutes,
      originalLanguage: resolvedLanguage,
      status: resolvedStatus,
      // Stamp watchedAt immediately when creating directly as watched.
      watchedAt: resolvedStatus === "watched" ? [new Date()] : [],
      seasons: [],
      ...(userRating !== undefined && { userRating }),
      ...(progress !== undefined && { progress }),
    });
  } else {
    // Mirror updateEntry's watchedAt logic: push a stamp on first transition to watched.
    const wasWatched = entry.status === "watched";
    const nowWatched = resolvedStatus === "watched";
    if (nowWatched && !wasWatched) entry.watchedAt.push(new Date());

    entry.status = resolvedStatus;
    if (userRating !== undefined) entry.userRating = userRating;
    if (progress !== undefined)
      entry.progress = { ...entry.progress?.toObject(), ...progress };
    if (runtimeMinutes !== undefined) entry.runtimeMinutes = runtimeMinutes;
    // Backfill only. Entries predating originalLanguage fill in the first time
    // the user touches them; we never overwrite a language already on record.
    if (!entry.originalLanguage && resolvedLanguage)
      entry.originalLanguage = resolvedLanguage;

    await entry.save();
  }

  res.json(entry);
};

// GET /api/library/:tmdbId?type=cinemaType
const getEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(
      new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"),
    );
  }

  const entry = await LibraryEntry.findOne(compoundFilter(req)).select("-__v");
  if (!entry)
    return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));
  res.json(entry);
};

// PUT /api/library/:tmdbId?type=cinemaType
const updateEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(
      new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"),
    );
  }

  const entry = await LibraryEntry.findOne(compoundFilter(req));
  if (!entry)
    return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));

  const { status, userRating, review, progress, runtimeMinutes } = req.body;

  const wasWatched = entry.status === "watched";
  const nowWatched = status === "watched";
  if (nowWatched && !wasWatched) entry.watchedAt.push(new Date());

  if (status !== undefined) entry.status = status;
  if (userRating !== undefined) entry.userRating = userRating;
  if (review !== undefined) entry.review = review;
  if (progress !== undefined)
    entry.progress = { ...entry.progress?.toObject(), ...progress };
  if (runtimeMinutes !== undefined) entry.runtimeMinutes = runtimeMinutes;

  await entry.save();
  res.json(entry);
};

// DELETE /api/library/:tmdbId?type=cinemaType
const deleteEntry = async (req, res, next) => {
  if (!req.query.type) {
    return next(
      new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"),
    );
  }

  const result = await LibraryEntry.deleteOne(compoundFilter(req));
  if (result.deletedCount === 0)
    return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));
  res.json({ message: "Removed from library" });
};

// ── Season-level CRUD ─────────────────────────────────────────────────────────

// PUT /api/library/:tmdbId/seasons/:seasonNumber?type=cinemaType
const upsertSeason = async (req, res, next) => {
  const cinemaType = req.query.type;
  if (!cinemaType) {
    return next(
      new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"),
    );
  }

  const tmdbId = Number(req.params.tmdbId);
  const seasonNumber = Number(req.params.seasonNumber);
  const {
    seasonId,
    status,
    rating,
    title,
    posterPath,
    releaseYear,
    genres,
    tmdbRating,
    originalLanguage,
  } = req.body;

  if (!status) {
    return next(
      new AppError(400, "LIBRARY_MISSING_FIELDS", "status is required"),
    );
  }

  // Find or create the parent show document
  let entry = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId,
    cinemaType,
  });

  if (!entry) {
    if (!title) {
      return next(
        new AppError(
          400,
          "LIBRARY_MISSING_FIELDS",
          "title is required when creating a new entry",
        ),
      );
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
      originalLanguage: await resolveOriginalLanguage(
        originalLanguage,
        cinemaType,
        tmdbId,
      ),
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
    return next(
      new AppError(400, "LIBRARY_MISSING_TYPE", "type query param is required"),
    );
  }

  const tmdbId = Number(req.params.tmdbId);
  const seasonNumber = Number(req.params.seasonNumber);

  const entry = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId,
    cinemaType,
  });
  if (!entry)
    return next(new AppError(404, "LIBRARY_ENTRY_NOT_FOUND", "Not in library"));

  entry.seasons = entry.seasons.filter((s) => s.seasonNumber !== seasonNumber);
  entry.markModified("seasons");
  await entry.save();
  res.json(entry);
};

module.exports = {
  getLibrary,
  getStats,
  addToLibrary,
  upsertEntry,
  getEntry,
  updateEntry,
  deleteEntry,
  upsertSeason,
  deleteSeason,
};
