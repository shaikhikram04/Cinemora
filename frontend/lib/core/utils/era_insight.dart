import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/utils/library_signal.dart';

/// The decade a user's taste over-indexes on, derived from their library.
class EraInsight {
  final String label; // '1980s', 'Pre-1970s', …
  final double sharePercent; // share of weighted signal, 0–100
  final int titleCount; // titles from that decade

  const EraInsight({
    required this.label,
    required this.sharePercent,
    required this.titleCount,
  });
}

// Share of a typical modern library per decade. Without the lift these feed,
// almost every user is labelled 2010s/2020s, because that's simply where most
// content lives. Tune by feel; these are not load-bearing constants.
const _baselineShare = {
  'Pre-1970s': 0.02,
  '1970s': 0.03,
  '1980s': 0.05,
  '1990s': 0.10,
  '2000s': 0.15,
  '2010s': 0.35,
  '2020s': 0.30,
};
const _fallbackBaseline = 0.05; // any decade we haven't tabulated (a future 2030s)

const _minDatedTitles = 8; // below this, any era claim is noise
const _minDecadeTitles = 3; // guards lift: one 1965 film must not crown Pre-1970s
const _minDecadeShare = 0.08;

final _yearPattern = RegExp(r'(?:19|20)\d{2}');

String? _decadeOf(String? releaseYear) {
  if (releaseYear == null) return null;
  final match = _yearPattern.firstMatch(releaseYear);
  if (match == null) return null;
  final year = int.parse(match.group(0)!);
  if (year < 1970) return 'Pre-1970s';
  return '${(year ~/ 10) * 10}s';
}

/// Picks the decade the user most over-indexes on relative to a typical
/// library, rather than the one they've simply watched most of.
///
/// Returns null when there isn't enough signal to make a claim — callers should
/// show a "still learning" state rather than inventing an era.
EraInsight? deriveFavoriteEra(List<LibraryEntryModel> entries) {
  final weights = <String, double>{};
  final counts = <String, int>{};
  var datedTitles = 0;

  for (final entry in entries) {
    final decade = _decadeOf(entry.releaseYear);
    if (decade == null) continue;
    datedTitles++;
    weights[decade] = (weights[decade] ?? 0) + libraryEntryWeight(entry);
    counts[decade] = (counts[decade] ?? 0) + 1;
  }

  final top = deriveTopBucket(
    weights: weights,
    counts: counts,
    totalTitles: datedTitles,
    baselineShare: _baselineShare,
    fallbackBaseline: _fallbackBaseline,
    minTotalTitles: _minDatedTitles,
    minBucketTitles: _minDecadeTitles,
    minBucketShare: _minDecadeShare,
  );
  if (top == null) return null;

  return EraInsight(
    label: top.key,
    sharePercent: top.sharePercent,
    titleCount: top.titleCount,
  );
}
