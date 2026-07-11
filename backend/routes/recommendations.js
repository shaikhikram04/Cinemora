const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getHome,
  getSimilar,
  postMoodMessage,
} = require("../controllers/recommendationsController");

router.use(auth);

router.get("/home", getHome);
router.get("/similar/:cinemaType/:tmdbId", getSimilar);
router.post("/mood/message", postMoodMessage);

module.exports = router;
