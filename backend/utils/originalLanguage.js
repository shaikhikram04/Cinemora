const tmdb = require("../config/tmdb");

/**
 * Resolves a library entry's ISO 639-1 original language.
 *
 * Detail pages send it (they already hold the full TMDB/AniList payload), but
 * the quick-add surfaces — home carousels, franchise pages, bulk add — only
 * carry a poster's worth of data. Rather than thread the language through every
 * card model and rely on each new surface remembering to pass it, we resolve it
 * here, behind the one door every library write goes through.
 *
 * The TMDB lookup is cached for 24h and only runs on writes, never on a read
 * path. A failure returns undefined rather than throwing — a language we can't
 * determine must never block someone adding a title.
 */
const resolveOriginalLanguage = async (originalLanguage, cinemaType, tmdbId) => {
  if (originalLanguage) return String(originalLanguage).toLowerCase();

  // Anime entries store a MAL/AniList id in `tmdbId`, so a TMDB lookup here
  // would happily return an unrelated title. The anime detail page sends the
  // real country of origin; everywhere else Japanese is the honest default.
  if (cinemaType === "anime") return "ja";

  if (!tmdbId) return undefined;

  try {
    const path = cinemaType === "tv" ? `/tv/${tmdbId}` : `/movie/${tmdbId}`;
    const data = await tmdb.get(path);
    return data?.original_language?.toLowerCase() || undefined;
  } catch (err) {
    console.error(
      `[Library] original_language lookup failed for ${cinemaType} ${tmdbId}:`,
      err.message,
    );
    return undefined;
  }
};

module.exports = { resolveOriginalLanguage };
