const router = require("express").Router();
const auth = require("../middlewares/auth");
const { numericParam } = require("../middlewares/params");
const {
  getTrending,
  search,
  getMovie,
  getTv,
  getSeason,
  getMovieProviders,
  getTvProviders,
  getFeaturedCollections,
  searchCollections,
  getCollection,
  getGenres,
  discover,
} = require("../controllers/tmdbController");

router.use(auth);

// Both feed straight into the upstream TMDB path — see middlewares/params.js.
router.param("id", numericParam);
router.param("season", numericParam);

router.get("/trending", getTrending);
router.get("/search", search);
router.get("/genres", getGenres);
router.get("/discover", discover);
router.get("/movie/:id", getMovie);
router.get("/movie/:id/watch-providers", getMovieProviders);
router.get("/tv/:id", getTv);
router.get("/tv/:id/season/:season", getSeason);
router.get("/tv/:id/watch-providers", getTvProviders);
router.get("/collection/featured", getFeaturedCollections);
router.get("/collection/search", searchCollections);
router.get("/collection/:id", getCollection);

module.exports = router;
