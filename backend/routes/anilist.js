const router = require("express").Router();
const auth = require("../middlewares/auth");
const { getAnimeDetail } = require("../controllers/anilistController");

router.use(auth);

router.get("/anime/:malId", getAnimeDetail);

module.exports = router;
