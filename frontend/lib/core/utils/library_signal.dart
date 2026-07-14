import 'dart:math' as math;

import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';

// Weights mirror the recommender's taste vector (recommender/engine/taste_vector.py)
// so the app keeps one mental model of "how much does a library entry count".
const _statusBase = {
  WatchStatus.watched: 3.0,
  WatchStatus.watching: 1.5,
  WatchStatus.watchlist: 0.5,
  WatchStatus.dropped: -2.0,
};

/// How much one library entry counts toward a derived taste insight.
///
/// Shared by the era and language tiles: they answer different questions off
/// the same library, and a user would rightly find it odd if a 1★ drop dragged
/// down their era but not their language.
double libraryEntryWeight(LibraryEntryModel entry) {
  final base = _statusBase[entry.status] ?? 0.0;
  final rewatchMultiplier =
      1 + 0.5 * math.min(math.max(entry.watchedAt.length - 1, 0), 3);

  // Only a finished title carries a verdict: a 5★ rewatch lifts its bucket, a
  // 1★ one drags it down. Anything unwatched is neutral on quality.
  final rating = entry.userRating;
  final ratingMultiplier =
      entry.status == WatchStatus.watched && rating != null
          ? ((rating - 2.5) / 2.5).clamp(-1.0, 1.0)
          : 1.0;

  return base * rewatchMultiplier * ratingMultiplier;
}

/// Picks the bucket a user most over-indexes on relative to a typical library,
/// rather than the one they've simply watched most of.
///
/// The lift step is the whole point: without it almost every user is labelled
/// 2010s, or English, because that's simply where most content lives — a
/// correct answer that says nothing about them.
///
/// Returns null when there isn't enough signal to make a claim; callers should
/// show a "still learning" state rather than inventing an answer.
BucketInsight? deriveTopBucket({
  required Map<String, double> weights,
  required Map<String, int> counts,
  required int totalTitles,
  required Map<String, double> baselineShare,
  required double fallbackBaseline,
  required int minTotalTitles,
  required int minBucketTitles,
  required double minBucketShare,
}) {
  if (totalTitles < minTotalTitles) return null;

  // A bucket the user mostly dropped or panned nets out negative; floor it at
  // zero so it can't invert the share ratio below.
  final positive = {
    for (final e in weights.entries) e.key: math.max(e.value, 0.0),
  };
  final total = positive.values.fold(0.0, (sum, w) => sum + w);
  if (total <= 0) return null;

  final shares = {for (final e in positive.entries) e.key: e.value / total};

  // Tie-break on share, then on key, so the pick is stable across rebuilds.
  int compare(String a, String b, double Function(String) score) {
    final byScore = score(b).compareTo(score(a));
    if (byScore != 0) return byScore;
    final byShare = shares[b]!.compareTo(shares[a]!);
    if (byShare != 0) return byShare;
    return b.compareTo(a);
  }

  final eligible = shares.keys
      .where((k) =>
          counts[k]! >= minBucketTitles && shares[k]! >= minBucketShare)
      .toList();

  final String winner;
  if (eligible.isNotEmpty) {
    double lift(String k) =>
        shares[k]! / (baselineShare[k] ?? fallbackBaseline);
    winner = (eligible..sort((a, b) => compare(a, b, lift))).first;
  } else {
    // Signal spread too thin for the lift guards — fall back to plain weighted
    // mode rather than saying nothing.
    winner =
        (shares.keys.toList()..sort((a, b) => compare(a, b, (k) => shares[k]!)))
            .first;
  }

  return BucketInsight(
    key: winner,
    sharePercent: shares[winner]! * 100,
    titleCount: counts[winner]!,
  );
}

/// The winning bucket and how much of the user's signal it accounts for.
class BucketInsight {
  final String key;
  final double sharePercent; // share of weighted signal, 0–100
  final int titleCount;

  const BucketInsight({
    required this.key,
    required this.sharePercent,
    required this.titleCount,
  });
}
