import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/utils/library_signal.dart';

/// The language a user's taste over-indexes on, derived from their library.
class LanguageInsight {
  final String label; // 'Korean'
  final String code; // ISO 639-1, 'ko'
  final double sharePercent; // share of weighted signal, 0–100
  final int titleCount; // titles in that language

  const LanguageInsight({
    required this.label,
    required this.code,
    required this.sharePercent,
    required this.titleCount,
  });
}

// Share of a typical library in this app per language. These exist for the same
// reason the era baselines do: on raw share almost every user is "English",
// which is true and tells them nothing. Skewed toward this app's audience —
// English-dominant, heavy on anime (which lands in `ja`), with meaningful Indian
// and Korean tails. Tune by feel; not load-bearing.
const _baselineShare = {
  'en': 0.52,
  'ja': 0.16,
  'hi': 0.09,
  'ko': 0.05,
  'ta': 0.03,
  'te': 0.03,
  'es': 0.025,
  'ml': 0.02,
  'fr': 0.015,
  'zh': 0.015,
  'mr': 0.01,
  'de': 0.01,
};

// A language rare enough that we never tabulated it. Deliberately low: the
// guards below (3+ titles, 8%+ share) already stop a single foreign film from
// crowning itself, and past that bar an untabulated language genuinely is the
// most distinctive thing about the user's taste.
const _fallbackBaseline = 0.01;

const _minTaggedTitles = 8; // below this, any language claim is noise
const _minLanguageTitles =
    3; // guards lift: one Tamil film must not crown Tamil
const _minLanguageShare = 0.08;

// Only the languages we can plausibly meet. Anything else falls back to the
// raw code so the tile degrades to something honest rather than blank.
const _displayNames = {
  'en': 'English',
  'ja': 'Japanese',
  'ko': 'Korean',
  'hi': 'Hindi',
  'ta': 'Tamil',
  'te': 'Telugu',
  'ml': 'Malayalam',
  'mr': 'Marathi',
  'bn': 'Bengali',
  'kn': 'Kannada',
  'pa': 'Punjabi',
  'ur': 'Urdu',
  'zh': 'Chinese',
  'es': 'Spanish',
  'fr': 'French',
  'de': 'German',
  'it': 'Italian',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'tr': 'Turkish',
  'th': 'Thai',
  'sv': 'Swedish',
  'da': 'Danish',
  'nl': 'Dutch',
  'pl': 'Polish',
  'ar': 'Arabic',
  'fa': 'Persian',
  'he': 'Hebrew',
  'id': 'Indonesian',
  'vi': 'Vietnamese',
};

String languageLabel(String code) => _displayNames[code] ?? code.toUpperCase();

/// Picks the language the user most over-indexes on relative to a typical
/// library, rather than the one they've simply watched most of.
///
/// Entries added before the app started recording `originalLanguage` carry no
/// language and are skipped entirely — they don't count toward the minimum, so
/// a legacy library reads as "still learning" rather than being judged on the
/// handful of entries that happen to have the field.
///
/// Returns null when there isn't enough signal to make a claim.
LanguageInsight? deriveFavoriteLanguage(List<LibraryEntryModel> entries) {
  final weights = <String, double>{};
  final counts = <String, int>{};
  var taggedTitles = 0;

  for (final entry in entries) {
    final code = entry.originalLanguage?.toLowerCase();
    if (code == null || code.isEmpty) continue;
    taggedTitles++;
    weights[code] = (weights[code] ?? 0) + libraryEntryWeight(entry);
    counts[code] = (counts[code] ?? 0) + 1;
  }

  final top = deriveTopBucket(
    weights: weights,
    counts: counts,
    totalTitles: taggedTitles,
    baselineShare: _baselineShare,
    fallbackBaseline: _fallbackBaseline,
    minTotalTitles: _minTaggedTitles,
    minBucketTitles: _minLanguageTitles,
    minBucketShare: _minLanguageShare,
  );
  if (top == null) return null;

  return LanguageInsight(
    label: languageLabel(top.key),
    code: top.key,
    sharePercent: top.sharePercent,
    titleCount: top.titleCount,
  );
}
