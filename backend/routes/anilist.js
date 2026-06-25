const router = require("express").Router();
const auth = require("../middlewares/auth");
const { searchAnime, getAnimeDetail } = require("../controllers/anilistController");

router.use(auth);

router.get("/search", searchAnime);
router.get("/anime/:malId", getAnimeDetail);

module.exports = router;
