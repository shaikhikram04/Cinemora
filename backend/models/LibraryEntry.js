const mongoose = require("mongoose");

const seasonEntrySchema = new mongoose.Schema(
  {
    seasonNumber: { type: Number, required: true },
    seasonId: { type: Number }, // TMDB season ID or MAL ID — nullable for Jikan
    status: {
      type: String,
      enum: ["watchlist", "watched", "dropped"],
      required: true,
    },
    rating: { type: Number, min: 0, max: 5 },
  },
  { _id: false }
);

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

    // ── Release-notification tracking (written by services/releaseNotifications)
    //
    // Full release/premiere date, resolved server-side from TMDB/AniList when
    // the notification generator first checks this title.
    releaseDate: { type: Date },

    // Terminal marker: set once the "now available" decision has been made for
    // this entry — either a notification was created, or the title was already
    // released when the user added it (sealed silently, nothing to announce).
    // Null = release still pending, keep checking.
    releaseNotifiedAt: { type: Date, default: null },

    // Season marker, seeded silently on the generator's first pass (so seasons
    // that already existed when tracking began are never announced); a later
    // higher value is news → notify and advance. Null = not yet seeded.
    // TV: highest aired season number. Anime: count of premiered sequels in
    // the AniList SEQUEL chain (seasons there are separate media entries).
    seasonNotifiedCount: { type: Number, default: null },

    genres: { type: [String], default: [] },
    tmdbRating: { type: Number },
    runtimeMinutes: { type: Number },

    // ISO 639-1 (TMDB `original_language`; for anime, derived from AniList
    // `countryOfOrigin`). Feeds the derived "Language" tile on the profile.
    // Absent on entries created before this field existed — the tile treats
    // those as unknown rather than guessing.
    originalLanguage: { type: String },

    // Show-level status (set via show-level buttons)
    //
    // MIGRATION NOTE: "watching" was removed from this enum. Existing docs
    // still carrying it will fail validation on their next save — migrate with:
    //   db.libraryentries.updateMany({ status: "watching" }, { $set: { status: "watchlist" } })
    status: {
      type: String,
      enum: ["watchlist", "watched", "dropped"],
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

    // Per-season tracking (set via season-level buttons)
    seasons: { type: [seasonEntrySchema], default: [] },

    watchedAt: { type: [Date], default: [] },
  },
  { timestamps: true }
);

// Compound unique key: one entry per user per (tmdbId, cinemaType)
// This prevents TMDB movie ID 1396 from colliding with MAL anime ID 1396.
//
// MIGRATION NOTE: if upgrading from the old single-field index, run in MongoDB:
//   db.libraryentries.dropIndex("userId_1_tmdbId_1")
//   db.libraryentries.createIndex({ userId: 1, tmdbId: 1, cinemaType: 1 }, { unique: true })
libraryEntrySchema.index({ userId: 1, tmdbId: 1, cinemaType: 1 }, { unique: true });

module.exports = mongoose.model("LibraryEntry", libraryEntrySchema);
