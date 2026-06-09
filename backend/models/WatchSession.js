const mongoose = require("mongoose");

const participantSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    name: { type: String },
    avatar: { type: String },
    joinedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const watchSessionSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true, index: true },
    hostId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    participants: { type: [participantSchema], default: [] },
    tmdbId: { type: Number, required: true },
    cinemaType: {
      type: String,
      enum: ["movie", "tv", "anime"],
      required: true,
    },
    title: { type: String, required: true },
    posterPath: { type: String },
    status: {
      type: String,
      enum: ["waiting", "active", "ended"],
      default: "waiting",
    },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

// Auto-delete expired sessions via MongoDB TTL index
watchSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model("WatchSession", watchSessionSchema);
