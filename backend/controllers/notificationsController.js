const Notification = require("../models/Notification");

// GET /api/notifications?page=1&limit=20
const getNotifications = async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.min(50, parseInt(req.query.limit) || 20);
  const skip = (page - 1) * limit;

  const [notifications, total] = await Promise.all([
    Notification.find({ userId: req.user.userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select("-__v"),
    Notification.countDocuments({ userId: req.user.userId }),
  ]);

  const unreadCount = await Notification.countDocuments({
    userId: req.user.userId,
    isRead: false,
  });

  res.json({
    notifications,
    unreadCount,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) },
  });
};

// PUT /api/notifications/:id/read
const markRead = async (req, res) => {
  const result = await Notification.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.userId },
    { isRead: true },
    { new: true }
  ).select("-__v");

  if (!result) return res.status(404).json({ error: "Notification not found" });
  res.json(result);
};

// PUT /api/notifications/read-all
const markAllRead = async (req, res) => {
  await Notification.updateMany(
    { userId: req.user.userId, isRead: false },
    { isRead: true }
  );
  res.json({ message: "All notifications marked as read" });
};

module.exports = { getNotifications, markRead, markAllRead };
