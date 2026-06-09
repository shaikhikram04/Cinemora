const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  createSession, getSession, joinSession, endSession,
} = require("../controllers/watchTogetherController");

router.use(auth);

router.post("/sessions", createSession);
router.get("/sessions/:code", getSession);
router.post("/sessions/:code/join", joinSession);
router.delete("/sessions/:code", endSession);

module.exports = router;
