import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/library/models/library_item.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit() : super(const LibraryState());

  static const types = ['All', 'Movies', 'Series', 'Anime'];
  static const statuses = ['Watchlist', 'Watched', 'Dropped'];
  static const sortOptions = [
    'Recently added',
    'Recently watched',
    'Highest rated',
    'Lowest rated',
    'Release date',
    'Alphabetical',
    'Runtime',
  ];
  static const statusCounts = {
    'Watched': 9,
    'Watchlist': 3,
    'Dropped': 2,
  };

  void selectType(String type) => emit(state.copyWith(selectedType: type));
  void selectStatus(String status) => emit(state.copyWith(selectedStatus: status));
  void toggleSortPanel() => emit(state.copyWith(isSortOpen: !state.isSortOpen));
  void updateSearch(String query) => emit(state.copyWith(searchQuery: query));

  void selectSort(String sort) =>
      emit(state.copyWith(selectedSort: sort, isSortOpen: false));

  List<LibraryItem> get sortedItems {
    final filtered = kLibraryItems.where((item) {
      final typeMatch =
          state.selectedType == 'All' || item.type == state.selectedType;
      final statusMatch = item.status == state.selectedStatus;
      final searchMatch = state.searchQuery.isEmpty ||
          item.title.toLowerCase().contains(state.searchQuery.toLowerCase());
      return typeMatch && statusMatch && searchMatch;
    }).toList();

    switch (state.selectedSort) {
      case 'Recently watched':
        filtered.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
      case 'Highest rated':
        filtered.sort((a, b) =>
            (double.tryParse(b.rating) ?? 0)
                .compareTo(double.tryParse(a.rating) ?? 0));
      case 'Lowest rated':
        filtered.sort((a, b) =>
            (double.tryParse(a.rating) ?? 0)
                .compareTo(double.tryParse(b.rating) ?? 0));
      case 'Release date':
        filtered.sort(
            (a, b) => int.parse(b.year).compareTo(int.parse(a.year)));
      case 'Alphabetical':
        filtered.sort((a, b) => a.title.compareTo(b.title));
      case 'Runtime':
        filtered.sort(
            (a, b) => b.runtimeMinutes.compareTo(a.runtimeMinutes));
      default:
        filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    return filtered;
  }
}
