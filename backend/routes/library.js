const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getLibrary,
  getStats,
  addToLibrary,
  upsertEntry,
  getEntry,
  updateEntry,
  deleteEntry,
  upsertSeason,
  deleteSeason,
} = require("../controllers/libraryController");

// All library routes require auth
router.use(auth);

router.get("/", getLibrary);
router.get("/stats", getStats); // must be before /:tmdbId
router.post("/", addToLibrary);
router.post("/upsert", upsertEntry); // must be before /:tmdbId
router.get("/:tmdbId", getEntry);
router.put("/:tmdbId", updateEntry);
router.delete("/:tmdbId", deleteEntry);

// Season-level routes — must be after /:tmdbId to avoid conflicts
router.put("/:tmdbId/seasons/:seasonNumber", upsertSeason);
router.delete("/:tmdbId/seasons/:seasonNumber", deleteSeason);

module.exports = router;
