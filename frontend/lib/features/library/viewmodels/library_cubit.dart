import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryRepository _repo;

  LibraryCubit(this._repo) : super(const LibraryState());

  static const types = ['All', 'Movies', 'Series', 'Anime'];
  static const statuses = ['Watchlist', 'Watched', 'Dropped'];
  static const sortOptions = [
    'Recently added',
    'Recently updated',
    'Highest rated',
    'Lowest rated',
    'Release date',
    'Alphabetical',
    'Runtime',
  ];

  static String displayToApiStatus(String display) => display.toLowerCase();

  static String displayToApiType(String display) {
    switch (display) {
      case 'Movies':
        return 'movie';
      case 'Series':
        return 'tv';
      case 'Anime':
        return 'anime';
      default:
        return '';
    }
  }

  Future<void> loadData() async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      List<LibraryEntryModel> entries = [];
      LibraryStatsModel? stats;
      await Future.wait([
        _repo.fetchEntries().then((v) => entries = v),
        _repo.fetchStats().then((v) => stats = v),
      ]);
      emit(state.copyWith(
        status: LibraryStatus.loaded,
        entries: entries,
        stats: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: ApiClient.parseError(e).userMessage,
      ));
    }
  }

  // ── Computed stats ─────────────────────────────────────────────────────────

  Map<String, int> get statusCounts => {
        for (final s in statuses)
          s: state.entries
              .where((e) => e.status == displayToApiStatus(s))
              .length,
      };

  int get totalEntries => state.entries.length;

  int get watchedCount =>
      state.entries.where((e) => e.status == 'watched').length;

  int get moviesWatched => state.entries
      .where((e) => e.cinemaType == 'movie' && e.status == 'watched')
      .length;

  int get seriesWatched => state.entries
      .where((e) => e.cinemaType == 'tv' && e.status == 'watched')
      .length;

  int get animeWatched => state.entries
      .where((e) => e.cinemaType == 'anime' && e.status == 'watched')
      .length;

  int get totalWatchedMinutes {
    int total = 0;
    for (final e in state.entries) {
      if (e.status == 'watched' && e.runtimeMinutes != null) {
        final eps =
            e.cinemaType == 'movie' ? 1 : (e.progress?.totalEpisodes ?? 1);
        total += e.runtimeMinutes! * eps;
      }
    }
    return total;
  }

  // ── Filtered + sorted list ─────────────────────────────────────────────────

  List<LibraryEntryModel> get filteredEntries {
    final apiStatus = displayToApiStatus(state.selectedStatus);
    final apiType = displayToApiType(state.selectedType);

    final filtered = state.entries.where((entry) {
      final typeMatch =
          state.selectedType == 'All' || entry.cinemaType == apiType;
      final statusMatch = entry.status == apiStatus;
      final searchMatch = state.searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(state.searchQuery.toLowerCase());
      return typeMatch && statusMatch && searchMatch;
    }).toList();

    switch (state.selectedSort) {
      case 'Recently updated':
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case 'Highest rated':
        filtered.sort((a, b) => (b.userRating ?? b.tmdbRating ?? 0)
            .compareTo(a.userRating ?? a.tmdbRating ?? 0));
      case 'Lowest rated':
        filtered.sort((a, b) => (a.userRating ?? a.tmdbRating ?? 0)
            .compareTo(b.userRating ?? b.tmdbRating ?? 0));
      case 'Release date':
        filtered.sort((a, b) => (int.tryParse(b.releaseYear ?? '0') ?? 0)
            .compareTo(int.tryParse(a.releaseYear ?? '0') ?? 0));
      case 'Alphabetical':
        filtered.sort((a, b) => a.title.compareTo(b.title));
      case 'Runtime':
        filtered.sort(
            (a, b) => (b.runtimeMinutes ?? 0).compareTo(a.runtimeMinutes ?? 0));
      default: // 'Recently added'
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  // ── Filter / sort actions ─────────────────────────────────────────────────

  void selectType(String type) => emit(state.copyWith(selectedType: type));

  void selectStatus(String status) =>
      emit(state.copyWith(selectedStatus: status));

  void toggleSortPanel() => emit(state.copyWith(isSortOpen: !state.isSortOpen));

  void updateSearch(String query) => emit(state.copyWith(searchQuery: query));

  void selectSort(String sort) =>
      emit(state.copyWith(selectedSort: sort, isSortOpen: false));

  // ── Entry mutations ────────────────────────────────────────────────────────

  Future<void> addToWatchlist({
    required int tmdbId,
    required String cinemaType,
    required String title,
    String? posterPath,
    String? releaseYear,
    double? tmdbRating,
  }) async {
    try {
      final entry = await _repo.upsertEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: title,
        posterPath: posterPath,
        releaseYear: releaseYear,
        tmdbRating: tmdbRating,
      );
      syncEntry(entry);
    } catch (_) {}
  }

  /// Deletes a show-level entry. cinemaType is required for the compound key.
  Future<void> removeEntry(int tmdbId, String cinemaType) async {
    final entries = List<LibraryEntryModel>.from(state.entries);
    final idx = entries.indexWhere(
        (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    if (idx < 0) return;
    final original = entries[idx];
    entries.removeAt(idx);
    emit(state.copyWith(entries: entries));

    try {
      await _repo.deleteEntry(tmdbId, cinemaType);
    } catch (_) {
      final rolled = List<LibraryEntryModel>.from(state.entries);
      rolled.insert(idx, original);
      emit(state.copyWith(entries: rolled));
    }
  }

  Future<void> updateEntryStatus(
      int tmdbId, String cinemaType, String displayStatus) async {
    final apiStatus = displayToApiStatus(displayStatus);
    final entries = List<LibraryEntryModel>.from(state.entries);
    final idx = entries.indexWhere(
        (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    if (idx < 0) return;

    final original = entries[idx];
    entries[idx] =
        original.copyWith(status: apiStatus, updatedAt: DateTime.now());
    emit(state.copyWith(entries: entries));

    try {
      final confirmed =
          await _repo.updateEntry(tmdbId, cinemaType, status: apiStatus);
      final refreshed = List<LibraryEntryModel>.from(state.entries);
      final i = refreshed.indexWhere(
          (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
      if (i >= 0) refreshed[i] = confirmed;
      emit(state.copyWith(entries: refreshed));
    } catch (_) {
      // Keep optimistic state — next loadData() will re-sync with server
    }
  }

  /// Inserts or replaces a single entry matched on (tmdbId, cinemaType).
  void syncEntry(LibraryEntryModel entry) {
    final entries = List<LibraryEntryModel>.from(state.entries);
    final idx = entries.indexWhere(
        (e) => e.tmdbId == entry.tmdbId && e.cinemaType == entry.cinemaType);
    if (idx >= 0) {
      entries[idx] = entry;
    } else {
      entries.add(entry);
    }
    emit(state.copyWith(entries: entries));
  }

  /// Removes an entry from state without an API call.
  void removeEntryLocal(int tmdbId, String cinemaType) {
    final entries = List<LibraryEntryModel>.from(state.entries)
      ..removeWhere(
          (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    emit(state.copyWith(entries: entries));
  }
}
