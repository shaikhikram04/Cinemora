const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getNotifications, markRead, markAllRead,
} = require("../controllers/notificationsController");

router.use(auth);

router.get("/", getNotifications);
router.put("/read-all", markAllRead);     // must be before /:id/read
router.put("/:id/read", markRead);

module.exports = router;
