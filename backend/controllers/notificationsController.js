const Notification = require("../models/Notification");
const AppError = require("../utils/AppError");
const { generateWithTimeBox } = require("../services/releaseNotifications");

// GET /api/notifications?page=1&limit=20
const getNotifications = async (req, res) => {
  // Compute-on-read: resolve newly released titles / premiered seasons into
  // notification rows before serving the inbox. Time-boxed so a slow upstream
  // can't stall the request — late results just show up on the next fetch.
  await generateWithTimeBox(req.user.userId);

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

// GET /api/notifications/unread-count
// Lightweight poll for the home-screen bell badge. Runs the same generation
// pass (tighter time box) so the badge can light up without opening the inbox.
const getUnreadCount = async (req, res) => {
  await generateWithTimeBox(req.user.userId, 1500);

  const unreadCount = await Notification.countDocuments({
    userId: req.user.userId,
    isRead: false,
  });
  res.json({ unreadCount });
};

// PUT /api/notifications/:id/read
const markRead = async (req, res, next) => {
  const result = await Notification.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.userId },
    { isRead: true },
    { new: true }
  ).select("-__v");

  if (!result) return next(new AppError(404, "NOTIFICATION_NOT_FOUND", "Notification not found"));
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

module.exports = { getNotifications, getUnreadCount, markRead, markAllRead };
