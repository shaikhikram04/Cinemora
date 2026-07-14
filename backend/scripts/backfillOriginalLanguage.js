/**
 * Backfills `originalLanguage` on library entries created before the field
 * existed, or added through a quick-add surface that didn't send it.
 *
 * Entries are grouped by (cinemaType, tmdbId) so a title twenty users have in
 * their libraries costs one TMDB lookup, not twenty — and TMDB's 24h cache
 * makes repeat runs nearly free. Anime resolves to Japanese without a lookup,
 * since its `tmdbId` is really a MAL id.
 *
 * Safe to re-run: it only ever fills entries where the field is missing, and
 * never overwrites a language already on record.
 *
 *   node scripts/backfillOriginalLanguage.js          # apply
 *   node scripts/backfillOriginalLanguage.js --dry    # report only
 */
require("dotenv").config();
const mongoose = require("mongoose");

const connectDB = require("../config/database");
const LibraryEntry = require("../models/LibraryEntry");
const { resolveOriginalLanguage } = require("../utils/originalLanguage");

const DRY_RUN = process.argv.includes("--dry");

const run = async () => {
  await connectDB();

  const missing = await LibraryEntry.find({
    $or: [
      { originalLanguage: { $exists: false } },
      { originalLanguage: null },
      { originalLanguage: "" },
    ],
  }).select("_id tmdbId cinemaType title");

  if (missing.length === 0) {
    console.log("Nothing to backfill — every entry already has a language.");
    return;
  }

  const titles = new Map(); // "cinemaType:tmdbId" -> { cinemaType, tmdbId, title }
  for (const entry of missing) {
    const key = `${entry.cinemaType}:${entry.tmdbId}`;
    if (!titles.has(key)) {
      titles.set(key, {
        cinemaType: entry.cinemaType,
        tmdbId: entry.tmdbId,
        title: entry.title,
      });
    }
  }

  console.log(
    `${missing.length} entr${missing.length === 1 ? "y" : "ies"} missing a ` +
      `language across ${titles.size} distinct title(s).\n`,
  );

  const resolved = new Map(); // key -> iso code
  for (const [key, { cinemaType, tmdbId, title }] of titles) {
    const language = await resolveOriginalLanguage(
      undefined,
      cinemaType,
      tmdbId,
    );
    if (language) {
      resolved.set(key, language);
      console.log(`  ${language}  ${title} (${cinemaType}/${tmdbId})`);
    } else {
      console.log(`  ??  ${title} (${cinemaType}/${tmdbId}) — unresolved, skipped`);
    }
  }

  if (DRY_RUN) {
    console.log(`\nDry run — nothing written. ${resolved.size} title(s) would be filled.`);
    return;
  }

  const ops = missing
    .filter((entry) => resolved.has(`${entry.cinemaType}:${entry.tmdbId}`))
    .map((entry) => ({
      updateOne: {
        filter: { _id: entry._id },
        update: {
          $set: {
            originalLanguage: resolved.get(
              `${entry.cinemaType}:${entry.tmdbId}`,
            ),
          },
        },
      },
    }));

  if (ops.length === 0) {
    console.log("\nNothing could be resolved — no writes made.");
    return;
  }

  const result = await LibraryEntry.bulkWrite(ops);
  console.log(`\nBackfilled ${result.modifiedCount} entr(y/ies).`);

  const stillMissing = missing.length - ops.length;
  if (stillMissing > 0) {
    console.log(
      `${stillMissing} entr(y/ies) left unresolved — TMDB had no language for them.`,
    );
  }
};

run()
  .catch((err) => {
    console.error("Backfill failed:", err);
    process.exitCode = 1;
  })
  .finally(() => mongoose.connection.close());
