import 'package:equatable/equatable.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';

enum RankingPlacementStatus { comparing, placed }

class RankingPlacementState extends Equatable {
  final List<RankingEntry> entries;
  final RankingEntry newEntry;
  final int low;
  final int high;
  final int stepsTaken;
  final RankingPlacementStatus status;
  final int? finalPosition;

  const RankingPlacementState({
    required this.entries,
    required this.newEntry,
    required this.low,
    required this.high,
    required this.stepsTaken,
    required this.status,
    this.finalPosition,
  });

  // Middle of the current search range — the item we compare against
  int get mid => (low + high) ~/ 2;

  bool get isDone => low >= high;

  RankingEntry get currentComparison => entries[mid];

  // ceil(log2(n+1)) — max comparisons needed for binary search over n items
  int get maxSteps {
    final n = entries.length;
    if (n == 0) return 0;
    int steps = 0;
    int power = 1;
    while (power <= n) {
      power <<= 1;
      steps++;
    }
    return steps;
  }

  RankingPlacementState copyWith({
    List<RankingEntry>? entries,
    int? low,
    int? high,
    int? stepsTaken,
    RankingPlacementStatus? status,
    int? finalPosition,
  }) {
    return RankingPlacementState(
      entries: entries ?? this.entries,
      newEntry: newEntry,
      low: low ?? this.low,
      high: high ?? this.high,
      stepsTaken: stepsTaken ?? this.stepsTaken,
      status: status ?? this.status,
      finalPosition: finalPosition ?? this.finalPosition,
    );
  }

  @override
  List<Object?> get props =>
      [entries, newEntry, low, high, stepsTaken, status, finalPosition];
}
