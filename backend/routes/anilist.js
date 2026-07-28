const router = require("express").Router();
const auth = require("../middlewares/auth");
const { numericParam } = require("../middlewares/params");
const { searchAnime, getAnimeDetail } = require("../controllers/anilistController");

router.use(auth);

// AniList takes this as a GraphQL Int variable rather than a path segment, so
// it can't be traversed — but a non-numeric id is still a 400, not an upstream
// GraphQL error surfaced to the client.
router.param("malId", numericParam);

router.get("/search", searchAnime);
router.get("/anime/:malId", getAnimeDetail);

module.exports = router;
