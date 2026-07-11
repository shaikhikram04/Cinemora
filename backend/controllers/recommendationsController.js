const recommender = require("../config/recommender");
const AppError = require("../utils/AppError");

const VALID_TYPES = new Set(["all", "movie", "tv", "anime"]);

// GET /api/recommendations/home?type=all|movie|tv|anime
const getHome = async (req, res, next) => {
  const { type = "all" } = req.query;
  if (!VALID_TYPES.has(type)) {
    return next(
      new AppError(400, "RECS_INVALID_TYPE", `type must be one of: ${[...VALID_TYPES].join(", ")}`),
    );
  }

  try {
    const { data } = await recommender.get("/internal/recommendations/home", {
      params: { type },
      headers: { "X-User-Id": req.user.userId },
    });
    res.json(data);
  } catch (err) {
    console.error("[Recommender] getHome failed:", err.message);
    next(err);
  }
};

// GET /api/recommendations/similar/:cinemaType/:tmdbId
const getSimilar = async (req, res, next) => {
  const { cinemaType, tmdbId } = req.params;
  try {
    const { data } = await recommender.get(
      `/internal/recommendations/similar/${cinemaType}/${tmdbId}`,
      { headers: { "X-User-Id": req.user.userId } },
    );
    res.json(data);
  } catch (err) {
    console.error("[Recommender] getSimilar failed:", err.message);
    next(err);
  }
};

// POST /api/recommendations/mood/message
const postMoodMessage = async (req, res, next) => {
  const { sessionId, message } = req.body || {};
  try {
    const { data } = await recommender.post(
      "/internal/mood/message",
      { sessionId, message },
      { headers: { "X-User-Id": req.user.userId } },
    );
    res.json(data);
  } catch (err) {
    // Surface the recommender's own status + message (e.g. 429 rate limit, 503 not configured).
    if (err.response) {
      const detail = err.response.data?.detail || "Mood chat error";
      return res.status(err.response.status).json({
        error: { code: "MOOD_CHAT_ERROR", message: detail },
      });
    }
    console.error("[Recommender] postMoodMessage failed:", err.message);
    next(err);
  }
};

module.exports = { getHome, getSimilar, postMoodMessage };
