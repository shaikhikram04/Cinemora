import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<LibraryEntryModel> entries;
  final LibraryStatsModel? stats;
  final String? errorMessage;
  final String selectedType;
  final String selectedStatus;
  final String selectedSort;
  final bool isSortOpen;
  final String searchQuery;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.entries = const [],
    this.stats,
    this.errorMessage,
    this.selectedType = 'All',
    this.selectedStatus = 'Watchlist',
    this.selectedSort = 'Recently added',
    this.isSortOpen = false,
    this.searchQuery = '',
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<LibraryEntryModel>? entries,
    LibraryStatsModel? stats,
    String? errorMessage,
    String? selectedType,
    String? selectedStatus,
    String? selectedSort,
    bool? isSortOpen,
    String? searchQuery,
  }) {
    return LibraryState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort: selectedSort ?? this.selectedSort,
      isSortOpen: isSortOpen ?? this.isSortOpen,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        entries,
        stats,
        errorMessage,
        selectedType,
        selectedStatus,
        selectedSort,
        isSortOpen,
        searchQuery,
      ];
}
