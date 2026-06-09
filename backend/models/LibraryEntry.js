const mongoose = require("mongoose");

const libraryEntrySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    tmdbId: { type: Number, required: true },
    cinemaType: {
      type: String,
      enum: ["movie", "tv", "anime"],
      required: true,
    },
    title: { type: String, required: true },
    posterPath: { type: String },
    releaseYear: { type: String },
    genres: { type: [String], default: [] },
    tmdbRating: { type: Number },
    runtimeMinutes: { type: Number }, // per episode for tv/anime, total for movies

    status: {
      type: String,
      enum: ["watchlist", "watching", "watched", "dropped"],
      default: "watchlist",
    },
    userRating: { type: Number, min: 0, max: 5 },
    review: { type: String },

    progress: {
      currentSeason: { type: Number },
      currentEpisode: { type: Number },
      totalSeasons: { type: Number },
      totalEpisodes: { type: Number },
    },

    // Array to track every watch date, including rewatches
    watchedAt: { type: [Date], default: [] },
  },
  { timestamps: true }
);

// Enforce one entry per user per title
libraryEntrySchema.index({ userId: 1, tmdbId: 1 }, { unique: true });

module.exports = mongoose.model("LibraryEntry", libraryEntrySchema);
