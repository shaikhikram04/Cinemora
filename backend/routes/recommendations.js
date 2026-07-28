const router = require("express").Router();
const auth = require("../middlewares/auth");
const { numericParam, enumParam } = require("../middlewares/params");
const {
  getHome,
  getSimilar,
  postMoodMessage,
} = require("../controllers/recommendationsController");

router.use(auth);

// Both are interpolated into the recommender's /internal/* path, on a client
// that carries X-Internal-Secret — see middlewares/params.js.
router.param("cinemaType", enumParam(["movie", "tv", "anime"]));
router.param("tmdbId", numericParam);

router.get("/home", getHome);
router.get("/similar/:cinemaType/:tmdbId", getSimilar);
router.post("/mood/message", postMoodMessage);

module.exports = router;
