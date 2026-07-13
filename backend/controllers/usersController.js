const User = require("../models/User");
const AppError = require("../utils/AppError");

// PUT /api/users/profile
const updateProfile = async (req, res, next) => {
  const { name, username, bio, avatar, framePoster } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: { name, username, bio, avatar, framePoster } },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json(user);
};

// PUT /api/users/preferences
const updatePreferences = async (req, res, next) => {
  const { contentTypes, genres, languages } = req.body;

  const updates = { isOnboarded: true };
  if (contentTypes !== undefined) updates["preferences.contentTypes"] = contentTypes;
  if (genres !== undefined) updates["preferences.genres"] = genres;
  if (languages !== undefined) updates["preferences.languages"] = languages;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: updates },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json(user);
};

// PUT /api/users/fcm-token
const updateFcmToken = async (req, res, next) => {
  const { fcmToken } = req.body;
  if (!fcmToken) return next(new AppError(400, "USER_FCM_TOKEN_REQUIRED", "fcmToken is required"));

  await User.findByIdAndUpdate(req.user.userId, { fcmToken });
  res.json({ message: "FCM token updated" });
};

module.exports = { updateProfile, updatePreferences, updateFcmToken };
