const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firebaseUid: { type: String, required: true, unique: true, index: true },
    name: { type: String, required: true },
    username: { type: String },
    bio: { type: String },
    email: { type: String, required: true, unique: true },
    avatar: { type: String },
    framePoster: { type: String },
    authProviders: {
      type: [String],
      enum: ["google", "apple"],
      default: [],
    },
    isOnboarded: { type: Boolean, default: false },
    preferences: {
      contentTypes: {
        type: [String],
        enum: ["movies", "series", "anime", "documentaries"],
        default: [],
      },
      genres: { type: [String], default: [] },
      languages: { type: [String], default: [] },
      // `era` was removed: favorite era is now derived from the user's library
      // rather than hand-picked. Existing docs may still carry the dead field.
    },
    fcmToken: { type: String },

    // Push-channel opt-outs, one per notification type. In-app inbox rows are
    // always created regardless — these only gate the FCM send.
    notificationPrefs: {
      pushNewRelease: { type: Boolean, default: true },
      pushNewSeason: { type: Boolean, default: true },
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("User", userSchema);
