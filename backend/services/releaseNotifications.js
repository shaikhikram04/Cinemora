const LibraryEntry = require("../models/LibraryEntry");
const Notification = require("../models/Notification");
const tmdb = require("../config/tmdb");
const {
  getAnimeByMalId,
  getRelationsById,
  isSeasonNode,
} = require("../config/anilist");
const { sendPushForNotification } = require("./push");

// Compute-on-read notification generation (same pattern as the recommender's
// weekly pick): a pass runs when a user checks their inbox or badge, so only
// active users cost anything and no cron/scheduler is needed.
//
// Upstream lookups go through the existing Redis-cached TMDB/AniList clients
// (24h detail TTL), so each tracked title costs at most ~1 real API call per
// day — shared across every user tracking it.
//
// Per-entry markers (releaseNotifiedAt / seasonNotifiedCount) are advanced with
// atomic claims, so two concurrent passes can never create the same
// notification twice.

// ── Release seal (movies + anime premieres) ───────────────────────────────────

/**
 * Terminally resolves an entry's release: stamps releaseNotifiedAt and, when
 * the release actually happened after the user watchlisted the title, creates
 * and returns the "now available" notification. Titles that were already out
 * when added are sealed silently — announcing an old movie as "just released"
 * reads as a bug, not a feature.
 */
const sealRelease = async (entry, releaseDate, shouldNotify) => {
  const claimed = await LibraryEntry.findOneAndUpdate(
    { _id: entry._id, releaseNotifiedAt: null },
    {
      releaseNotifiedAt: new Date(),
      ...(releaseDate && { releaseDate }),
    },
  );
  if (!claimed || !shouldNotify) return null;

  return Notification.create({
    userId: entry.userId,
    type: "new_release",
    title: entry.title,
    body:
      entry.cinemaType === "movie"
        ? `${entry.title} is out now — ready when you are.`
        : `${entry.title} has premiered — the wait is over.`,
    data: {
      tmdbId: entry.tmdbId,
      cinemaType: entry.cinemaType,
      posterPath: entry.posterPath ?? null,
    },
  });
};

// ── Per-type checks ───────────────────────────────────────────────────────────

const checkMovieRelease = async (entry) => {
  const info = await tmdb.get(`/movie/${entry.tmdbId}`);
  const dateStr = info?.release_date;
  if (!dateStr) return null; // TBA — keep checking on later passes

  const released = new Date(dateStr);
  if (Number.isNaN(released.getTime())) return null;
  if (released > new Date()) return null; // still upcoming — the stored date may
  // shift with delays, which is exactly why we re-resolve it here instead of
  // trusting a date captured at add time.

  return sealRelease(entry, released, released >= entry.createdAt);
};

const checkAnime = async (entry) => {
  const created = [];
  // Anime entries store the MAL id in tmdbId (always scoped by cinemaType).
  const data = await getAnimeByMalId(entry.tmdbId);
  const media = data?.data?.Media;
  if (!media) return created;
  if (media.status === "NOT_YET_RELEASED") return created; // nothing premiered
  // yet — and a sequel can't exist before the entry itself airs, so stop.

  if (entry.status === "watchlist" && !entry.releaseNotifiedAt) {
    const { year, month, day } = media.startDate ?? {};
    const premiered =
      year && month && day ? new Date(Date.UTC(year, month - 1, day)) : null;

    // Status says it's out. Without a full start date we can't tell whether
    // that happened before or after the user added it — seal silently rather
    // than risk announcing a long-released title.
    const notif = await sealRelease(
      entry,
      premiered,
      premiered != null && premiered >= entry.createdAt,
    );
    if (notif) created.push(notif);
  }

  const sequelNotif = await checkAnimeSequels(entry, media);
  if (sequelNotif) created.push(sequelNotif);
  return created;
};

/**
 * Anime "new season" detection. AniList models seasons as separate media
 * linked by SEQUEL relations, so instead of TMDB's season list we walk the
 * sequel chain and count how many entries in it have actually premiered.
 * The seasonNotifiedCount marker holds that count (not a season number like
 * TV): seeded silently on first pass, a later increase is news.
 */
const checkAnimeSequels = async (entry, media) => {
  const released = [];
  const visited = new Set([media.id]);
  let edges = media.relations?.edges ?? [];

  // AniList only exposes direct relations, so hop node-by-node (each hop is
  // Redis-cached for a day and shared across users). Stop at the first
  // unreleased sequel — nothing beyond it can have premiered before it.
  for (let hops = 0; hops < 10; hops++) {
    const next = edges.find(
      (e) =>
        e.relationType === "SEQUEL" &&
        isSeasonNode(e.node) &&
        !visited.has(e.node.id),
    )?.node;
    if (!next) break;
    visited.add(next.id);

    if (next.status !== "RELEASING" && next.status !== "FINISHED") break;
    released.push(next);
    edges = await getRelationsById(next.id);
  }

  if (entry.seasonNotifiedCount == null) {
    await LibraryEntry.updateOne(
      { _id: entry._id, seasonNotifiedCount: null },
      { seasonNotifiedCount: released.length },
    );
    return null;
  }

  if (released.length <= entry.seasonNotifiedCount) return null;

  const claimed = await LibraryEntry.findOneAndUpdate(
    { _id: entry._id, seasonNotifiedCount: entry.seasonNotifiedCount },
    { seasonNotifiedCount: released.length },
  );
  if (!claimed) return null;

  // Announce under the sequel's own name — anime sequel titles carry their
  // season branding ("... 2nd Season"), which beats a fabricated number.
  const newest = released[released.length - 1];
  const newestTitle =
    newest.title?.english || newest.title?.romaji || entry.title;
  return Notification.create({
    userId: entry.userId,
    type: "new_season",
    title: entry.title,
    body: `${newestTitle} has premiered — the story continues.`,
    data: {
      // The sequel's MAL id when it has one, so tapping through opens the
      // new season's detail screen rather than the one they already saw.
      tmdbId: newest.idMal ?? entry.tmdbId,
      cinemaType: entry.cinemaType,
      posterPath: entry.posterPath ?? null,
    },
  });
};

const checkTvSeasons = async (entry) => {
  const info = await tmdb.get(`/tv/${entry.tmdbId}`);
  if (!Array.isArray(info?.seasons)) return null;

  const now = new Date();
  const latestAired = info.seasons.reduce((max, s) => {
    if (!s.air_date || s.season_number <= 0) return max; // skip specials/TBA
    return new Date(s.air_date) <= now ? Math.max(max, s.season_number) : max;
  }, 0);

  if (entry.seasonNotifiedCount == null) {
    // First pass for this entry: record what already exists without
    // announcing it — only seasons airing from now on are news.
    await LibraryEntry.updateOne(
      { _id: entry._id, seasonNotifiedCount: null },
      { seasonNotifiedCount: latestAired },
    );
    return null;
  }

  if (latestAired <= entry.seasonNotifiedCount) return null;

  const claimed = await LibraryEntry.findOneAndUpdate(
    { _id: entry._id, seasonNotifiedCount: entry.seasonNotifiedCount },
    { seasonNotifiedCount: latestAired },
  );
  if (!claimed) return null;

  return Notification.create({
    userId: entry.userId,
    type: "new_season",
    title: entry.title,
    body:
      latestAired === 1
        ? `${entry.title} has premiered — Season 1 is airing now.`
        : `Season ${latestAired} of ${entry.title} just premiered.`,
    data: {
      tmdbId: entry.tmdbId,
      cinemaType: entry.cinemaType,
      posterPath: entry.posterPath ?? null,
      season: latestAired,
    },
  });
};

// ── The pass ──────────────────────────────────────────────────────────────────

const generateReleaseNotifications = async (userId) => {
  const entries = await LibraryEntry.find({
    userId,
    $or: [
      // Unresolved movie releases the user is waiting on.
      { cinemaType: "movie", status: "watchlist", releaseNotifiedAt: null },
      // Shows and anime are tracked for new seasons/sequels as long as
      // they're not dropped (anime premieres resolve in the same check).
      {
        cinemaType: { $in: ["tv", "anime"] },
        status: { $in: ["watchlist", "watched"] },
      },
    ],
  }).select(
    "userId tmdbId cinemaType title posterPath status createdAt releaseNotifiedAt seasonNotifiedCount",
  );

  // Sequential on purpose: iterations are mostly Redis hits, and the misses
  // stay gentle on the AniList rate budget shared with the recommender.
  const created = [];
  for (const entry of entries) {
    try {
      if (entry.cinemaType === "movie") {
        const notif = await checkMovieRelease(entry);
        if (notif) created.push(notif);
      } else if (entry.cinemaType === "anime") {
        created.push(...(await checkAnime(entry)));
      } else {
        const notif = await checkTvSeasons(entry);
        if (notif) created.push(notif);
      }
    } catch (err) {
      // One broken title (removed upstream, API hiccup) must not kill the pass.
      console.error(
        `[notifications] check failed for ${entry.cinemaType}/${entry.tmdbId}: ${err.message}`,
      );
    }
  }
  return created;
};

// ── Daily push sweep ──────────────────────────────────────────────────────────

/**
 * Runs a generation pass for every user with trackable entries and pushes
 * whatever it created. This exists for the push channel only — the inbox
 * stays compute-on-read — because a phone in a pocket can't trigger a read.
 * Scheduled daily in server.js.
 */
const sweepAllUsers = async () => {
  const userIds = await LibraryEntry.distinct("userId", {
    $or: [
      { cinemaType: "movie", status: "watchlist", releaseNotifiedAt: null },
      {
        cinemaType: { $in: ["tv", "anime"] },
        status: { $in: ["watchlist", "watched"] },
      },
    ],
  });

  let pushed = 0;
  for (const userId of userIds) {
    const created = await generateReleaseNotifications(userId).catch((err) => {
      console.error(`[sweep] pass failed for ${userId}: ${err.message}`);
      return [];
    });
    for (const notif of created) {
      await sendPushForNotification(notif);
      pushed++;
    }
  }
  console.log(
    `[sweep] checked ${userIds.length} users, pushed ${pushed} notifications`,
  );
};

// ── Entry point ───────────────────────────────────────────────────────────────

const inFlight = new Map();

/**
 * Runs a generation pass without ever blocking the caller longer than
 * timeBoxMs. A pass that outlives the box keeps running in the background and
 * its notifications simply appear on the next fetch. Concurrent calls for the
 * same user share one pass instead of racing the upstream APIs.
 */
const generateWithTimeBox = async (userId, timeBoxMs = 2500) => {
  const key = String(userId);

  let pass = inFlight.get(key);
  if (!pass) {
    pass = generateReleaseNotifications(userId)
      .catch((err) =>
        console.error(`[notifications] generation failed: ${err.message}`),
      )
      .finally(() => inFlight.delete(key));
    inFlight.set(key, pass);
  }

  let timer;
  await Promise.race([
    pass,
    new Promise((resolve) => {
      timer = setTimeout(resolve, timeBoxMs);
    }),
  ]);
  clearTimeout(timer);
};

module.exports = {
  generateWithTimeBox,
  generateReleaseNotifications,
  sweepAllUsers,
};
