const LibraryEntry = require("../models/LibraryEntry");

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
      // For tv/anime: multiply per-episode runtime by total episodes watched
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

// POST /api/library
const addToLibrary = async (req, res) => {
  const {
    tmdbId, cinemaType, title, posterPath, releaseYear,
    genres, tmdbRating, runtimeMinutes, status,
  } = req.body;

  if (!tmdbId || !cinemaType || !title) {
    return res.status(400).json({ error: "tmdbId, cinemaType, and title are required" });
  }

  const existing = await LibraryEntry.findOne({ userId: req.user.userId, tmdbId });
  if (existing) return res.status(409).json({ error: "Already in library" });

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

// GET /api/library/:tmdbId
const getEntry = async (req, res) => {
  const entry = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId: Number(req.params.tmdbId),
  }).select("-__v");

  if (!entry) return res.status(404).json({ error: "Not in library" });
  res.json(entry);
};

// PUT /api/library/:tmdbId
const updateEntry = async (req, res) => {
  const entry = await LibraryEntry.findOne({
    userId: req.user.userId,
    tmdbId: Number(req.params.tmdbId),
  });

  if (!entry) return res.status(404).json({ error: "Not in library" });

  const { status, userRating, review, progress } = req.body;

  // Push a new watch date each time status flips to "watched"
  const wasWatched = entry.status === "watched";
  const nowWatched = status === "watched";
  if (nowWatched && !wasWatched) {
    entry.watchedAt.push(new Date());
  }

  if (status !== undefined) entry.status = status;
  if (userRating !== undefined) entry.userRating = userRating;
  if (review !== undefined) entry.review = review;
  if (progress !== undefined) entry.progress = { ...entry.progress, ...progress };

  await entry.save();
  res.json(entry);
};

// DELETE /api/library/:tmdbId
const deleteEntry = async (req, res) => {
  const result = await LibraryEntry.deleteOne({
    userId: req.user.userId,
    tmdbId: Number(req.params.tmdbId),
  });

  if (result.deletedCount === 0) return res.status(404).json({ error: "Not in library" });
  res.json({ message: "Removed from library" });
};

module.exports = { getLibrary, getStats, addToLibrary, getEntry, updateEntry, deleteEntry };
