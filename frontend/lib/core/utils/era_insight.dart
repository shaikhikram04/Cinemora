import 'dart:math' as math;

import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';

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

// Weights mirror the recommender's taste vector (recommender/engine/taste_vector.py)
// so the app keeps one mental model of "how much does a library entry count".
const _statusBase = {
  WatchStatus.watched: 3.0,
  WatchStatus.watching: 1.5,
  WatchStatus.watchlist: 0.5,
  WatchStatus.dropped: -2.0,
};

// Share of a typical modern library per decade. The whole point of the lift
// step below: without it almost every user is labelled 2010s/2020s, because
// that's simply where most content lives — a correct answer that says nothing
// about them. Tune by feel; these are not load-bearing constants.
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

double _weightOf(LibraryEntryModel entry) {
  final base = _statusBase[entry.status] ?? 0.0;
  final rewatchMultiplier =
      1 + 0.5 * math.min(math.max(entry.watchedAt.length - 1, 0), 3);

  // Only a finished title carries a verdict: a 5★ rewatch lifts its decade, a
  // 1★ one drags it down. Anything unwatched is neutral on quality.
  final rating = entry.userRating;
  final ratingMultiplier =
      entry.status == WatchStatus.watched && rating != null
          ? ((rating - 2.5) / 2.5).clamp(-1.0, 1.0)
          : 1.0;

  return base * rewatchMultiplier * ratingMultiplier;
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
    weights[decade] = (weights[decade] ?? 0) + _weightOf(entry);
    counts[decade] = (counts[decade] ?? 0) + 1;
  }

  if (datedTitles < _minDatedTitles) return null;

  // A decade the user mostly dropped or panned nets out negative; floor it at
  // zero so it can't invert the share ratio below.
  final positive = {
    for (final e in weights.entries) e.key: math.max(e.value, 0.0),
  };
  final total = positive.values.fold(0.0, (sum, w) => sum + w);
  if (total <= 0) return null;

  final shares = {for (final e in positive.entries) e.key: e.value / total};

  // Tie-break on share, then on recency, so the pick is stable.
  int compare(String a, String b, double Function(String) score) {
    final byScore = score(b).compareTo(score(a));
    if (byScore != 0) return byScore;
    final byShare = shares[b]!.compareTo(shares[a]!);
    if (byShare != 0) return byShare;
    return b.compareTo(a);
  }

  final eligible = shares.keys
      .where((d) =>
          counts[d]! >= _minDecadeTitles && shares[d]! >= _minDecadeShare)
      .toList();

  final String winner;
  if (eligible.isNotEmpty) {
    double lift(String d) =>
        shares[d]! / (_baselineShare[d] ?? _fallbackBaseline);
    winner = (eligible..sort((a, b) => compare(a, b, lift))).first;
  } else {
    // Signal spread too thin for the lift guards — fall back to plain weighted
    // mode rather than saying nothing.
    winner =
        (shares.keys.toList()..sort((a, b) => compare(a, b, (d) => shares[d]!)))
            .first;
  }

  return EraInsight(
    label: winner,
    sharePercent: shares[winner]! * 100,
    titleCount: counts[winner]!,
  );
}
