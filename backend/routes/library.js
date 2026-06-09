const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getLibrary,
  getStats,
  addToLibrary,
  getEntry,
  updateEntry,
  deleteEntry,
} = require("../controllers/libraryController");

// All library routes require auth
router.use(auth);

router.get("/", getLibrary);
router.get("/stats", getStats);   // must be before /:tmdbId
router.post("/", addToLibrary);
router.get("/:tmdbId", getEntry);
router.put("/:tmdbId", updateEntry);
router.delete("/:tmdbId", deleteEntry);

module.exports = router;
