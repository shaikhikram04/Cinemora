import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<LibraryEntryModel> entries;
  final String? errorMessage;
  // Transient — set on mutation failure, cleared after the view consumes it.
  final String? mutationError;
  final String selectedType;
  final String selectedStatus;
  final String selectedSort;
  final bool isSortOpen;
  final String searchQuery;

  // Precomputed on construction — derived from entries + filter params.
  // Computed once per state emit, not once per widget rebuild.
  late final List<LibraryEntryModel> filteredEntries;
  late final Map<String, int> statusCounts;
  late final int watchedCount;
  late final int moviesWatched;
  late final int seriesWatched;
  late final int animeWatched;
  static const _statuses = ['Watchlist', 'Watched', 'Dropped'];

  LibraryState({
    this.status = LibraryStatus.initial,
    this.entries = const [],
    this.errorMessage,
    this.mutationError,
    this.selectedType = 'All',
    this.selectedStatus = 'Watchlist',
    this.selectedSort = 'Recently added',
    this.isSortOpen = false,
    this.searchQuery = '',
  }) {
    filteredEntries = _buildFiltered();
    statusCounts = {
      for (final s in _statuses)
        s: s == 'Watched'
            ? entries.where(_isWatched).length
            : entries.where((e) => e.status == WatchStatus.fromDisplayName(s)).length,
    };
    watchedCount = entries.where(_isWatched).length;
    moviesWatched = entries
        .where((e) => e.cinemaType == CinemaType.movie && _isWatched(e))
        .length;
    seriesWatched = entries
        .where((e) => e.cinemaType == CinemaType.tv && _isWatched(e))
        .length;
    animeWatched = entries
        .where((e) => e.cinemaType == CinemaType.anime && _isWatched(e))
        .length;
  }

  static bool _isWatched(LibraryEntryModel e) => e.hasBeenWatched;

  List<LibraryEntryModel> _buildFiltered() {
    final typeFilter = CinemaType.fromDisplayName(selectedType);
    final statusFilter = WatchStatus.fromDisplayName(selectedStatus);

    final result = entries.where((entry) {
      final typeMatch = typeFilter == null || entry.cinemaType == typeFilter;
      final statusMatch = statusFilter == WatchStatus.watched
          ? _isWatched(entry)
          : entry.status == statusFilter;
      final searchMatch = searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(searchQuery.toLowerCase());
      return typeMatch && statusMatch && searchMatch;
    }).toList();

    switch (selectedSort) {
      case 'Recently updated':
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case 'Highest rated':
        result.sort((a, b) => (b.userRating ?? b.tmdbRating ?? 0)
            .compareTo(a.userRating ?? a.tmdbRating ?? 0));
      case 'Lowest rated':
        result.sort((a, b) => (a.userRating ?? a.tmdbRating ?? 0)
            .compareTo(b.userRating ?? b.tmdbRating ?? 0));
      case 'Release date':
        result.sort((a, b) => (int.tryParse(b.releaseYear ?? '0') ?? 0)
            .compareTo(int.tryParse(a.releaseYear ?? '0') ?? 0));
      case 'Alphabetical':
        result.sort((a, b) => a.title.compareTo(b.title));
      case 'Runtime':
        result.sort(
            (a, b) => (b.runtimeMinutes ?? 0).compareTo(a.runtimeMinutes ?? 0));
      default: // 'Recently added'
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  LibraryState copyWith({
    LibraryStatus? status,
    List<LibraryEntryModel>? entries,
    String? errorMessage,
    String? mutationError,
    bool clearMutationError = false,
    String? selectedType,
    String? selectedStatus,
    String? selectedSort,
    bool? isSortOpen,
    String? searchQuery,
  }) {
    return LibraryState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage ?? this.errorMessage,
      mutationError:
          clearMutationError ? null : (mutationError ?? this.mutationError),
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
        errorMessage,
        mutationError,
        selectedType,
        selectedStatus,
        selectedSort,
        isSortOpen,
        searchQuery,
      ];
}
