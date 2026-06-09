const WatchSession = require("../models/WatchSession");
const User = require("../models/User");

const SESSION_TTL_MS = 12 * 60 * 60 * 1000; // 12 hours

const generateCode = () => {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no O/0, I/1 to avoid confusion
  return Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
};

const uniqueCode = async () => {
  let code;
  let attempts = 0;
  do {
    code = generateCode();
    attempts++;
    if (attempts > 10) throw new Error("Could not generate unique session code");
  } while (await WatchSession.exists({ code }));
  return code;
};

// POST /api/watch-together/sessions
const createSession = async (req, res) => {
  const { tmdbId, cinemaType, title, posterPath } = req.body;
  if (!tmdbId || !cinemaType || !title) {
    return res.status(400).json({ error: "tmdbId, cinemaType, and title are required" });
  }

  const host = await User.findById(req.user.userId).select("name avatar");

  const session = await WatchSession.create({
    code: await uniqueCode(),
    hostId: req.user.userId,
    participants: [{ userId: req.user.userId, name: host.name, avatar: host.avatar }],
    tmdbId,
    cinemaType,
    title,
    posterPath,
    expiresAt: new Date(Date.now() + SESSION_TTL_MS),
  });

  res.status(201).json(session);
};

// GET /api/watch-together/sessions/:code
const getSession = async (req, res) => {
  const session = await WatchSession.findOne({ code: req.params.code }).select("-__v");
  if (!session) return res.status(404).json({ error: "Session not found" });
  res.json(session);
};

// POST /api/watch-together/sessions/:code/join
const joinSession = async (req, res) => {
  const session = await WatchSession.findOne({ code: req.params.code });
  if (!session) return res.status(404).json({ error: "Session not found" });
  if (session.status === "ended") return res.status(410).json({ error: "Session has ended" });

  const alreadyIn = session.participants.some(
    (p) => p.userId.toString() === req.user.userId
  );

  if (!alreadyIn) {
    const user = await User.findById(req.user.userId).select("name avatar");
    session.participants.push({ userId: req.user.userId, name: user.name, avatar: user.avatar });
    session.status = "active";
    await session.save();
  }

  res.json(session);
};

// DELETE /api/watch-together/sessions/:code
const endSession = async (req, res) => {
  const session = await WatchSession.findOne({ code: req.params.code });
  if (!session) return res.status(404).json({ error: "Session not found" });

  if (session.hostId.toString() !== req.user.userId) {
    return res.status(403).json({ error: "Only the host can end the session" });
  }

  session.status = "ended";
  await session.save();
  res.json({ message: "Session ended" });
};

module.exports = { createSession, getSession, joinSession, endSession };
