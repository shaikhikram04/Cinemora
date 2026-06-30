import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'ranking_detail_state.dart';

class RankingDetailCubit extends Cubit<RankingDetailState> {
  RankingDetailCubit({required List<RankingEntry> entries})
      : super(RankingDetailState(entries: List.of(entries)));

  void move(int index, int direction) {
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= state.entries.length) return;
    final updated = List.of(state.entries);
    final item = updated.removeAt(index);
    updated.insert(newIndex, item);
    emit(state.copyWith(entries: updated));
  }

  // Called by ReorderableListView — newIndex is already adjusted for removal
  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final updated = List.of(state.entries);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    emit(state.copyWith(entries: updated));
  }

  void removeEntry(int index) {
    final updated = List.of(state.entries)..removeAt(index);
    emit(state.copyWith(entries: updated));
  }
}
