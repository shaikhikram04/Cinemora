const RankingList = require("../models/RankingList");
const AppError = require("../utils/AppError");

// GET /api/rankings
const getLists = async (req, res) => {
  const lists = await RankingList.find({ userId: req.user.userId })
    .sort({ updatedAt: -1 })
    .select("-__v");
  res.json(lists);
};

// POST /api/rankings
const createList = async (req, res, next) => {
  const { title, description, emoji, accentColor, isPublic } = req.body;
  if (!title) return next(new AppError(400, "RANKING_TITLE_REQUIRED", "title is required"));

  const list = await RankingList.create({
    userId: req.user.userId,
    title,
    description,
    emoji,
    accentColor,
    isPublic: isPublic || false,
    entries: [],
  });

  res.status(201).json(list);
};

// GET /api/rankings/:id
const getList = async (req, res, next) => {
  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  }).select("-__v");

  if (!list) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));
  res.json(list);
};

// PUT /api/rankings/:id
const updateList = async (req, res, next) => {
  const { title, description, emoji, accentColor, isPublic } = req.body;

  const list = await RankingList.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.userId },
    { $set: { title, description, emoji, accentColor, isPublic } },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!list) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));
  res.json(list);
};

// DELETE /api/rankings/:id
const deleteList = async (req, res, next) => {
  const result = await RankingList.deleteOne({
    _id: req.params.id,
    userId: req.user.userId,
  });

  if (result.deletedCount === 0) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));
  res.json({ message: "List deleted" });
};

// POST /api/rankings/:id/entries
const addEntry = async (req, res, next) => {
  const { tmdbId, cinemaType, title, posterPath, year } = req.body;
  if (!tmdbId || !cinemaType || !title) {
    return next(new AppError(400, "RANKING_MISSING_FIELDS", "tmdbId, cinemaType, and title are required"));
  }

  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));

  const alreadyIn = list.entries.some((e) => e.tmdbId === tmdbId);
  if (alreadyIn) return next(new AppError(409, "RANKING_ALREADY_IN_LIST", "Already in this list"));

  list.entries.push({
    rank: list.entries.length + 1,
    tmdbId,
    cinemaType,
    title,
    posterPath,
    year,
  });

  await list.save();
  res.status(201).json(list);
};

// PUT /api/rankings/:id/entries  — full reorder
// Body: [{ tmdbId, cinemaType, title, posterPath, year }, ...]  ordered by new rank
const reorderEntries = async (req, res, next) => {
  const { entries } = req.body;
  if (!Array.isArray(entries)) return next(new AppError(400, "RANKING_ENTRIES_INVALID", "entries must be an array"));

  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));

  list.entries = entries.map((e, i) => ({ ...e, rank: i + 1 }));
  await list.save();
  res.json(list);
};

// DELETE /api/rankings/:id/entries/:tmdbId
const removeEntry = async (req, res, next) => {
  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return next(new AppError(404, "RANKING_LIST_NOT_FOUND", "List not found"));

  const before = list.entries.length;
  list.entries = list.entries.filter((e) => e.tmdbId !== Number(req.params.tmdbId));

  if (list.entries.length === before) {
    return next(new AppError(404, "RANKING_ENTRY_NOT_FOUND", "Entry not found in list"));
  }

  // Re-number ranks after removal
  list.entries = list.entries.map((e, i) => ({ ...e, rank: i + 1 }));
  await list.save();
  res.json(list);
};

module.exports = {
  getLists, createList, getList, updateList, deleteList,
  addEntry, reorderEntries, removeEntry,
};
