import 'package:flutter_bloc/flutter_bloc.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit() : super(const DiscoverState());

  void selectFilter(int index) =>
      emit(state.copyWith(selectedFilterIndex: index));

  void toggleGenre(int index) {
    final list = List<int>.from(state.selectedGenreIndices);
    if (list.contains(index)) {
      list.remove(index);
    } else {
      list.add(index);
    }
    emit(state.copyWith(selectedGenreIndices: list));
  }

  void removeRecentSearch(String item) {
    final list = List<String>.from(state.recentSearches)..remove(item);
    emit(state.copyWith(recentSearches: list));
  }
}
