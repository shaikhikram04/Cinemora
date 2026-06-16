const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getTop,
  getSeasonNow,
  getSeasonUpcoming,
  getAnime,
  getCharacters,
  getEpisodes,
  getRecommendations,
  getGenres,
  search,
} = require("../controllers/jikanController");

router.use(auth);

router.get("/top", getTop);
router.get("/seasons/now", getSeasonNow);
router.get("/seasons/upcoming", getSeasonUpcoming);
router.get("/genres", getGenres);
router.get("/search", search);
router.get("/anime/:id", getAnime);
router.get("/anime/:id/characters", getCharacters);
router.get("/anime/:id/episodes", getEpisodes);
router.get("/anime/:id/recommendations", getRecommendations);

module.exports = router;
