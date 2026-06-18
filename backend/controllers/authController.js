const jwt = require("jsonwebtoken");
const admin = require("../config/firebase");
const User = require("../models/User");
const AppError = require("../utils/AppError");

const signAccess = (userId) =>
  jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "15m",
  });

const signRefresh = (userId) =>
  jwt.sign({ userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || "30d",
  });

// POST /api/auth/firebase
// Body: { idToken }
const firebaseLogin = async (req, res, next) => {
  const { idToken } = req.body;
  if (!idToken) return next(new AppError(400, "AUTH_ID_TOKEN_REQUIRED", "idToken required"));

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch {
    return next(new AppError(401, "AUTH_INVALID_FIREBASE_TOKEN", "Invalid Firebase token"));
  }

  const { uid, email, name, picture, firebase } = decoded;
  const provider = firebase.sign_in_provider.replace(".com", "").replace("apple", "apple");
  const authProvider = provider.includes("apple") ? "apple" : "google";

  let user = await User.findOne({ firebaseUid: uid });

  if (!user) {
    // Also check by email in case they previously used another provider
    user = await User.findOne({ email });
    if (user) {
      // Link the new provider to the existing account
      if (!user.authProviders.includes(authProvider)) {
        user.authProviders.push(authProvider);
      }
      if (!user.firebaseUid) user.firebaseUid = uid;
      await user.save();
    } else {
      // Brand new user
      user = await User.create({
        firebaseUid: uid,
        email,
        name: name || email.split("@")[0],
        avatar: picture || null,
        authProviders: [authProvider],
      });
    }
  }

  const accessToken = signAccess(user._id);
  const refreshToken = signRefresh(user._id);

  res.json({
    accessToken,
    refreshToken,
    user: {
      id: user._id,
      name: user.name,
      username: user.username,
      bio: user.bio,
      email: user.email,
      avatar: user.avatar,
      framePoster: user.framePoster,
      isOnboarded: user.isOnboarded,
      preferences: user.preferences,
    },
  });
};

// POST /api/auth/refresh
// Body: { refreshToken }
const refresh = (req, res, next) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return next(new AppError(400, "AUTH_REFRESH_TOKEN_REQUIRED", "refreshToken required"));

  let payload;
  try {
    payload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  } catch {
    return next(new AppError(401, "AUTH_INVALID_REFRESH_TOKEN", "Invalid or expired refresh token"));
  }

  const accessToken = signAccess(payload.userId);
  res.json({ accessToken });
};

// GET /api/auth/me
const me = async (req, res, next) => {
  const user = await User.findById(req.user.userId).select("-__v");
  if (!user) return next(new AppError(404, "AUTH_USER_NOT_FOUND", "User not found"));
  res.json(user);
};

// DELETE /api/auth/account
const deleteAccount = async (req, res, next) => {
  const userId = req.user.userId;

  const user = await User.findById(userId);
  if (!user) return next(new AppError(404, "AUTH_USER_NOT_FOUND", "User not found"));

  // Remove from Firebase
  await admin.auth().deleteUser(user.firebaseUid);

  // Cascade delete all user data
  await Promise.all([
    User.deleteOne({ _id: userId }),
    require("../models/LibraryEntry").deleteMany({ userId }),
    require("../models/RankingList").deleteMany({ userId }),
    require("../models/WatchSession").deleteMany({ hostId: userId }),
    require("../models/Notification").deleteMany({ userId }),
  ]);

  res.json({ message: "Account deleted" });
};

module.exports = { firebaseLogin, refresh, me, deleteAccount };
