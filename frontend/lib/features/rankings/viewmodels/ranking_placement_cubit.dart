import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'ranking_placement_state.dart';

class RankingPlacementCubit extends Cubit<RankingPlacementState> {
  RankingPlacementCubit({
    required List<RankingEntry> entries,
    required RankingEntry newEntry,
  }) : super(
          // Empty list → insert newEntry immediately so state.entries is [newEntry]
          entries.isEmpty
              ? RankingPlacementState(
                  entries: [newEntry],
                  newEntry: newEntry,
                  low: 0,
                  high: 0,
                  stepsTaken: 0,
                  status: RankingPlacementStatus.placed,
                  finalPosition: 1,
                )
              : RankingPlacementState(
                  entries: entries,
                  newEntry: newEntry,
                  low: 0,
                  high: entries.length,
                  stepsTaken: 0,
                  status: RankingPlacementStatus.comparing,
                  finalPosition: null,
                ),
        );

  /// New item is better than current comparison → insert before it
  void chooseNew() {
    final next = state.copyWith(
      high: state.mid,
      stepsTaken: state.stepsTaken + 1,
    );
    next.isDone ? _place(next.low) : emit(next);
  }

  /// Existing item is better → new item goes after it
  void chooseExisting() {
    final next = state.copyWith(
      low: state.mid + 1,
      stepsTaken: state.stepsTaken + 1,
    );
    next.isDone ? _place(next.low) : emit(next);
  }

  /// Too close to call → place right after the current comparison item
  void chooseTie() => _place(state.mid + 1);

  void _place(int position) {
    final updated = List<RankingEntry>.of(state.entries);
    updated.insert(position, state.newEntry);
    emit(state.copyWith(
      entries: updated,
      status: RankingPlacementStatus.placed,
      finalPosition: position + 1, // 1-indexed rank
      low: position,
      high: position,
    ));
  }
}
