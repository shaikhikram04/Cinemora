import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/features/rankings/models/ranking_item.dart';
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
}
