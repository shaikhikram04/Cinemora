const RankingList = require("../models/RankingList");

// GET /api/rankings
const getLists = async (req, res) => {
  const lists = await RankingList.find({ userId: req.user.userId })
    .sort({ updatedAt: -1 })
    .select("-__v");
  res.json(lists);
};

// POST /api/rankings
const createList = async (req, res) => {
  const { title, description, emoji, accentColor, isPublic } = req.body;
  if (!title) return res.status(400).json({ error: "title is required" });

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
const getList = async (req, res) => {
  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  }).select("-__v");

  if (!list) return res.status(404).json({ error: "List not found" });
  res.json(list);
};

// PUT /api/rankings/:id
const updateList = async (req, res) => {
  const { title, description, emoji, accentColor, isPublic } = req.body;

  const list = await RankingList.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.userId },
    { $set: { title, description, emoji, accentColor, isPublic } },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!list) return res.status(404).json({ error: "List not found" });
  res.json(list);
};

// DELETE /api/rankings/:id
const deleteList = async (req, res) => {
  const result = await RankingList.deleteOne({
    _id: req.params.id,
    userId: req.user.userId,
  });

  if (result.deletedCount === 0) return res.status(404).json({ error: "List not found" });
  res.json({ message: "List deleted" });
};

// POST /api/rankings/:id/entries
const addEntry = async (req, res) => {
  const { tmdbId, cinemaType, title, posterPath, year } = req.body;
  if (!tmdbId || !cinemaType || !title) {
    return res.status(400).json({ error: "tmdbId, cinemaType, and title are required" });
  }

  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return res.status(404).json({ error: "List not found" });

  const alreadyIn = list.entries.some((e) => e.tmdbId === tmdbId);
  if (alreadyIn) return res.status(409).json({ error: "Already in this list" });

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
const reorderEntries = async (req, res) => {
  const { entries } = req.body;
  if (!Array.isArray(entries)) return res.status(400).json({ error: "entries must be an array" });

  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return res.status(404).json({ error: "List not found" });

  list.entries = entries.map((e, i) => ({ ...e, rank: i + 1 }));
  await list.save();
  res.json(list);
};

// DELETE /api/rankings/:id/entries/:tmdbId
const removeEntry = async (req, res) => {
  const list = await RankingList.findOne({
    _id: req.params.id,
    userId: req.user.userId,
  });
  if (!list) return res.status(404).json({ error: "List not found" });

  const before = list.entries.length;
  list.entries = list.entries.filter((e) => e.tmdbId !== Number(req.params.tmdbId));

  if (list.entries.length === before) {
    return res.status(404).json({ error: "Entry not found in list" });
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
