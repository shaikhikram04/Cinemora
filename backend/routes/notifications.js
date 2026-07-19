const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getNotifications, getUnreadCount, markRead, markAllRead,
} = require("../controllers/notificationsController");

router.use(auth);

router.get("/", getNotifications);
router.get("/unread-count", getUnreadCount);
router.put("/read-all", markAllRead);     // must be before /:id/read
router.put("/:id/read", markRead);

module.exports = router;
