import 'package:equatable/equatable.dart';

class LibraryState extends Equatable {
  final String selectedType;
  final String selectedStatus;
  final String selectedSort;
  final bool isSortOpen;
  final String searchQuery;

  const LibraryState({
    this.selectedType = 'All',
    this.selectedStatus = 'Watchlist',
    this.selectedSort = 'Recently added',
    this.isSortOpen = false,
    this.searchQuery = '',
  });

  LibraryState copyWith({
    String? selectedType,
    String? selectedStatus,
    String? selectedSort,
    bool? isSortOpen,
    String? searchQuery,
  }) {
    return LibraryState(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort: selectedSort ?? this.selectedSort,
      isSortOpen: isSortOpen ?? this.isSortOpen,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
        selectedType,
        selectedStatus,
        selectedSort,
        isSortOpen,
        searchQuery,
      ];
}
