import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/utils/library_signal.dart';

/// The viewing personality a user's library points at — an archetype derived
/// from the genre they most over-index on, not the genres they ticked during
/// onboarding.
class GenreInsight {
  final String archetype; // 'The Detective'
  final String description;
  final String genre; // canonical genre behind it, 'Crime'
  final double sharePercent; // share of weighted genre-tag signal, 0–100
  final int titleCount; // titles carrying that genre

  const GenreInsight({
    required this.archetype,
    required this.description,
    required this.genre,
    required this.sharePercent,
    required this.titleCount,
  });
}

// Entries arrive from two sources that name the same taste differently: TMDB
// says 'Science Fiction' (and 'Sci-Fi & Fantasy' on TV), AniList says 'Sci-Fi'.
// Fold both onto one canonical genre before counting, or a user's sci-fi habit
// splits across three buckets and loses to a genre they care less about.
const _canonical = {
  // TMDB — film
  'action': 'Action',
  'adventure': 'Adventure',
  'comedy': 'Comedy',
  'crime': 'Crime',
  'documentary': 'Documentary',
  'drama': 'Drama',
  'fantasy': 'Fantasy',
  'history': 'History',
  'horror': 'Horror',
  'mystery': 'Mystery',
  'romance': 'Romance',
  'science fiction': 'Sci-Fi',
  'thriller': 'Thriller',
  'war': 'War',
  // A Western is a distinctive taste with no archetype of its own; it rides
  // with Adventure rather than being dropped entirely.
  'western': 'Adventure',

  // TMDB — TV compounds. Each folds onto its leading half: splitting one tag
  // across two buckets would let a single title vote twice.
  'action & adventure': 'Action',
  'sci-fi & fantasy': 'Sci-Fi',
  'war & politics': 'War',

  // AniList
  'psychological': 'Psychological',
  'sci-fi': 'Sci-Fi',
  'slice of life': 'Slice of Life',
  'sports': 'Sports',
  'supernatural': 'Supernatural',
  'mecha': 'Sci-Fi',
  'mahou shoujo': 'Fantasy',
};

// Anything outside the map above is skipped rather than counted — deliberately,
// and unlike `language_insight`, which hands an unknown code a fallback baseline
// so a rare language can still win. The unknowns here are not exotic taste, they
// are format and audience tags: Animation, Family, Kids, Music, TV Movie,
// Reality, News, Talk, Soap, Ecchi. Animation is the one that matters — TMDB
// stamps it on every anime film, so counting it would crown half this app's
// users "The Animator", which is a statement about the medium they watch rather
// than the stories they choose.

// Share of the genre tags in a typical library here, not of titles: entries
// carry up to three genres each, so these are shares of tags and a genre on
// every single title would still only read ~0.4. Same purpose as the era and
// language baselines — without the lift they feed, almost everyone is "Drama",
// which is true and tells them nothing. Tune by feel; not load-bearing.
const _baselineShare = {
  'Drama': 0.19,
  'Action': 0.13,
  'Comedy': 0.11,
  'Adventure': 0.08,
  'Thriller': 0.08,
  'Romance': 0.07,
  'Sci-Fi': 0.06,
  'Fantasy': 0.06,
  'Crime': 0.05,
  'Mystery': 0.04,
  'Horror': 0.04,
  'Supernatural': 0.025,
  'Psychological': 0.02,
  'Slice of Life': 0.02,
  'Documentary': 0.015,
  'History': 0.01,
  'War': 0.01,
  'Sports': 0.005,
};

// Every canonical genre above has a baseline, so this only guards a genre added
// to `_canonical` without one.
const _fallbackBaseline = 0.02;

const _minTaggedTitles = 8; // below this, any personality claim is noise
const _minGenreTitles = 3; // guards lift: one horror film must not crown Horror
const _minGenreShare = 0.08;

const _archetypes = {
  'Drama': 'The Story Seeker',
  'Psychological': 'The Mind Bender',
  'Slice of Life': 'The Quiet Observer',
  'Sci-Fi': 'The World Builder',
  'Fantasy': 'The World Builder',
  'Supernatural': 'The World Builder',
  'Action': 'The Thrill Seeker',
  'Thriller': 'The Thrill Seeker',
  'Adventure': 'The Explorer',
  'Crime': 'The Detective',
  'Mystery': 'The Detective',
  'Horror': 'The Brave Soul',
  'Romance': 'The Romantic',
  'Comedy': 'The Light Heart',
  'Documentary': 'The Realist',
  'History': 'The Historian',
  'War': 'The Historian',
  'Sports': 'The Competitor',
};

const _descriptions = {
  'The Story Seeker':
      'You enjoy emotionally driven stories, character-focused narratives and the slow burn of a life unfolding.',
  'The Mind Bender':
      'You go looking for the films that rearrange you — unreliable narrators, moral vertigo, endings that reopen the whole story.',
  'The Quiet Observer':
      'You find the drama in small moments: ordinary lives, quiet rooms and the things left unsaid.',
  'The World Builder':
      'You love expansive universes, speculative fiction and stories that challenge imagination.',
  'The Thrill Seeker':
      'You crave high-stakes action, suspense and edge-of-your-seat storytelling.',
  'The Explorer':
      'You are in it for the journey — new places, long odds and the pull of what is over the next ridge.',
  'The Detective':
      'You\'re drawn to puzzles, moral ambiguity and stories where secrets slowly unravel.',
  'The Brave Soul':
      'You embrace tension, atmosphere and the art of facing the unknown.',
  'The Romantic':
      'You appreciate human connection, heartfelt stories and emotional depth.',
  'The Light Heart':
      'You watch to feel better than when you sat down — sharp wit, good company and stories that keep things buoyant.',
  'The Realist':
      'You would rather watch the real thing: true stories, real stakes and the world explained.',
  'The Historian':
      'You are drawn to the weight of the past — real events, hard choices and the stories that outlast the people in them.',
  'The Competitor':
      'You are here for the training montage, the underdog and the thin margin between winning and losing.',
};

/// Picks the genre the user most over-indexes on relative to a typical library
/// and maps it to a viewing personality.
///
/// Deliberately reads the library rather than `user.preferences.genres`: the
/// onboarding picks record what a user says they want, are frozen at signup,
/// and would happily label someone a Story Seeker for having ticked Drama once.
///
/// Returns null when there isn't enough signal to make a claim — callers should
/// show nothing rather than invent a personality.
GenreInsight? deriveViewingPersonality(List<LibraryEntryModel> entries) {
  final weights = <String, double>{};
  final counts = <String, int>{};
  var taggedTitles = 0;

  for (final entry in entries) {
    // An entry carries up to three genres and votes once in each. Deduped so a
    // title tagged both 'Action' and 'Action & Adventure' can't vote twice.
    final genres = entry.genres
        .map((g) => _canonical[g.trim().toLowerCase()])
        .whereType<String>()
        .toSet();
    if (genres.isEmpty) continue;

    taggedTitles++;
    final weight = libraryEntryWeight(entry);
    for (final genre in genres) {
      weights[genre] = (weights[genre] ?? 0) + weight;
      counts[genre] = (counts[genre] ?? 0) + 1;
    }
  }

  final top = deriveTopBucket(
    weights: weights,
    counts: counts,
    totalTitles: taggedTitles,
    baselineShare: _baselineShare,
    fallbackBaseline: _fallbackBaseline,
    minTotalTitles: _minTaggedTitles,
    minBucketTitles: _minGenreTitles,
    minBucketShare: _minGenreShare,
  );
  if (top == null) return null;

  final archetype = _archetypes[top.key];
  if (archetype == null) return null;

  return GenreInsight(
    archetype: archetype,
    description: _descriptions[archetype]!,
    genre: top.key,
    sharePercent: top.sharePercent,
    titleCount: top.titleCount,
  );
}
