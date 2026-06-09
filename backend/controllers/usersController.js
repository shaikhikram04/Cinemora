const User = require("../models/User");

// PUT /api/users/profile
const updateProfile = async (req, res) => {
  const { name, avatar, framePoster } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: { name, avatar, framePoster } },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!user) return res.status(404).json({ error: "User not found" });
  res.json(user);
};

// PUT /api/users/preferences
const updatePreferences = async (req, res) => {
  const { contentTypes, genres, language } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    {
      $set: {
        "preferences.contentTypes": contentTypes,
        "preferences.genres": genres,
        "preferences.language": language,
        isOnboarded: true,
      },
    },
    { new: true, runValidators: true }
  ).select("-__v");

  if (!user) return res.status(404).json({ error: "User not found" });
  res.json(user);
};

// PUT /api/users/fcm-token
const updateFcmToken = async (req, res) => {
  const { fcmToken } = req.body;
  if (!fcmToken) return res.status(400).json({ error: "fcmToken is required" });

  await User.findByIdAndUpdate(req.user.userId, { fcmToken });
  res.json({ message: "FCM token updated" });
};

module.exports = { updateProfile, updatePreferences, updateFcmToken };
