const mongoose = require("mongoose");

const entrySchema = new mongoose.Schema(
  {
    rank: { type: Number, required: true },
    tmdbId: { type: Number, required: true },
    cinemaType: {
      type: String,
      enum: ["movie", "tv", "anime"],
      required: true,
    },
    title: { type: String, required: true },
    posterPath: { type: String },
    year: { type: String },
  },
  { _id: false }
);

const rankingListSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    title: { type: String, required: true },
    description: { type: String },
    emoji: { type: String },
    accentColor: { type: String },
    isPublic: { type: Boolean, default: false },
    entries: { type: [entrySchema], default: [] },
  },
  { timestamps: true }
);

module.exports = mongoose.model("RankingList", rankingListSchema);
