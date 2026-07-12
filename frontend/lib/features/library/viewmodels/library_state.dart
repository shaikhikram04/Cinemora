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
  final List<LibraryEntryModel> filteredEntries;
  final Map<String, int> statusCounts;
  final int watchedCount;
  final int moviesWatched;
  final int seriesWatched;
  final int animeWatched;
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
  })  : filteredEntries = _buildFiltered(
          entries,
          selectedType,
          selectedStatus,
          selectedSort,
          searchQuery,
        ),
        statusCounts = _buildStatusCounts(entries),
        watchedCount = entries.where(_isWatched).length,
        moviesWatched = entries
            .where((e) => e.cinemaType == CinemaType.movie && _isWatched(e))
            .length,
        seriesWatched = entries
            .where((e) => e.cinemaType == CinemaType.tv && _isWatched(e))
            .length,
        animeWatched = entries
            .where((e) => e.cinemaType == CinemaType.anime && _isWatched(e))
            .length;

  // Bypasses recomputation in copyWith when the underlying inputs (entries,
  // filters, sort, search) didn't actually change — used so that unrelated
  // state changes (toggling the sort panel, clearing a mutation error) don't
  // re-scan and re-sort the whole library.
  const LibraryState._cached({
    required this.status,
    required this.entries,
    required this.errorMessage,
    required this.mutationError,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedSort,
    required this.isSortOpen,
    required this.searchQuery,
    required this.filteredEntries,
    required this.statusCounts,
    required this.watchedCount,
    required this.moviesWatched,
    required this.seriesWatched,
    required this.animeWatched,
  });

  static bool _isWatched(LibraryEntryModel e) => e.hasBeenWatched;

  static Map<String, int> _buildStatusCounts(
      List<LibraryEntryModel> entries) {
    return {
      for (final s in _statuses)
        s: s == 'Watched'
            ? entries.where(_isWatched).length
            : entries
                .where((e) => e.status == WatchStatus.fromDisplayName(s))
                .length,
    };
  }

  static List<LibraryEntryModel> _buildFiltered(
    List<LibraryEntryModel> entries,
    String selectedType,
    String selectedStatus,
    String selectedSort,
    String searchQuery,
  ) {
    final typeFilter = CinemaType.fromDisplayName(selectedType);
    final statusFilter = WatchStatus.fromDisplayName(selectedStatus);
    final lowerQuery = searchQuery.toLowerCase();

    final result = entries.where((entry) {
      final typeMatch = typeFilter == null || entry.cinemaType == typeFilter;
      final statusMatch = statusFilter == WatchStatus.watched
          ? _isWatched(entry)
          : entry.status == statusFilter;
      final searchMatch =
          lowerQuery.isEmpty || entry.title.toLowerCase().contains(lowerQuery);
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
    final newEntries = entries ?? this.entries;
    final newType = selectedType ?? this.selectedType;
    final newStatus = selectedStatus ?? this.selectedStatus;
    final newSort = selectedSort ?? this.selectedSort;
    final newQuery = searchQuery ?? this.searchQuery;

    final entriesChanged = entries != null;
    final filtersChanged = entriesChanged ||
        selectedType != null ||
        selectedStatus != null ||
        selectedSort != null ||
        searchQuery != null;

    return LibraryState._cached(
      status: status ?? this.status,
      entries: newEntries,
      errorMessage: errorMessage ?? this.errorMessage,
      mutationError:
          clearMutationError ? null : (mutationError ?? this.mutationError),
      selectedType: newType,
      selectedStatus: newStatus,
      selectedSort: newSort,
      isSortOpen: isSortOpen ?? this.isSortOpen,
      searchQuery: newQuery,
      filteredEntries: filtersChanged
          ? _buildFiltered(newEntries, newType, newStatus, newSort, newQuery)
          : filteredEntries,
      statusCounts:
          entriesChanged ? _buildStatusCounts(newEntries) : statusCounts,
      watchedCount: entriesChanged
          ? newEntries.where(_isWatched).length
          : watchedCount,
      moviesWatched: entriesChanged
          ? newEntries
              .where((e) => e.cinemaType == CinemaType.movie && _isWatched(e))
              .length
          : moviesWatched,
      seriesWatched: entriesChanged
          ? newEntries
              .where((e) => e.cinemaType == CinemaType.tv && _isWatched(e))
              .length
          : seriesWatched,
      animeWatched: entriesChanged
          ? newEntries
              .where((e) => e.cinemaType == CinemaType.anime && _isWatched(e))
              .length
          : animeWatched,
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
