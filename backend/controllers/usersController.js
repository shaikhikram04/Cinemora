const User = require("../models/User");
const AppError = require("../utils/AppError");
const { uploadBuffer } = require("../config/cloudinary");

// PUT /api/users/profile
const updateProfile = async (req, res, next) => {
  const { name, username, bio, avatar, framePoster } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: { name, username, bio, avatar, framePoster } },
    { new: true, runValidators: true },
  ).select("-__v");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json(user);
};

// PUT /api/users/preferences
const updatePreferences = async (req, res, next) => {
  const { contentTypes, genres, languages } = req.body;

  const updates = { isOnboarded: true };
  if (contentTypes !== undefined)
    updates["preferences.contentTypes"] = contentTypes;
  if (genres !== undefined) updates["preferences.genres"] = genres;
  if (languages !== undefined) updates["preferences.languages"] = languages;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: updates },
    { new: true, runValidators: true },
  ).select("-__v");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json(user);
};

// PUT /api/users/fcm-token
const updateFcmToken = async (req, res, next) => {
  const { fcmToken } = req.body;
  if (!fcmToken)
    return next(
      new AppError(400, "USER_FCM_TOKEN_REQUIRED", "fcmToken is required"),
    );

  await User.findByIdAndUpdate(req.user.userId, { fcmToken });
  res.json({ message: "FCM token updated" });
};

// PUT /api/users/notification-prefs
const updateNotificationPrefs = async (req, res, next) => {
  const { pushNewRelease, pushNewSeason } = req.body;

  const updates = {};
  if (typeof pushNewRelease === "boolean")
    updates["notificationPrefs.pushNewRelease"] = pushNewRelease;
  if (typeof pushNewSeason === "boolean")
    updates["notificationPrefs.pushNewSeason"] = pushNewSeason;

  if (Object.keys(updates).length === 0) {
    return next(
      new AppError(400, "USER_PREFS_EMPTY", "No valid preference fields"),
    );
  }

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: updates },
    { new: true },
  ).select("notificationPrefs");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json({ notificationPrefs: user.notificationPrefs });
};

// Avatars are square and face-aware; covers are a wide banner. Both are capped
// server-side so a 5 MB phone photo isn't what we serve back to every client.
const IMAGE_KINDS = {
  avatar: {
    field: "avatar",
    folder: "cinemora/avatars",
    transformation: [
      { width: 512, height: 512, crop: "fill", gravity: "face" },
      { quality: "auto", fetch_format: "auto" },
    ],
  },
  cover: {
    field: "framePoster",
    folder: "cinemora/covers",
    transformation: [
      { width: 1600, height: 600, crop: "fill", gravity: "auto" },
      { quality: "auto", fetch_format: "auto" },
    ],
  },
};

// POST /api/users/avatar  |  POST /api/users/cover  (multipart, field "image")
const uploadImage = (kind) => async (req, res, next) => {
  const { field, folder, transformation } = IMAGE_KINDS[kind];

  let result;
  try {
    result = await uploadBuffer(req.file.buffer, {
      folder,
      public_id: req.user.userId,
      transformation,
    });
  } catch (err) {
    return next(
      new AppError(
        502,
        "IMAGE_UPLOAD_FAILED",
        "Could not upload the image. Please try again.",
      ),
    );
  }

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: { [field]: result.secure_url } },
    { new: true, runValidators: true },
  ).select("-__v");

  if (!user) return next(new AppError(404, "USER_NOT_FOUND", "User not found"));
  res.json(user);
};

const uploadAvatar = uploadImage("avatar");
const uploadCover = uploadImage("cover");

module.exports = {
  updateProfile,
  updatePreferences,
  updateFcmToken,
  updateNotificationPrefs,
  uploadAvatar,
  uploadCover,
};
