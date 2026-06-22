import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryRepository _repo;

  LibraryCubit(this._repo) : super(LibraryState());

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

  Future<void> loadData() async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      final entries = await _repo.fetchEntries();
      emit(state.copyWith(
        status: LibraryStatus.loaded,
        entries: entries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: ApiClient.parseError(e).userMessage,
      ));
    }
  }

  // ── Computed stats (precomputed in LibraryState) ──────────────────────────

  Map<String, int> get statusCounts => state.statusCounts;
  int get totalEntries => state.entries.length;
  int get watchedCount => state.watchedCount;
  int get moviesWatched => state.moviesWatched;
  int get seriesWatched => state.seriesWatched;
  int get animeWatched => state.animeWatched;

  // ── Filtered + sorted list (precomputed in LibraryState) ──────────────────

  List<LibraryEntryModel> get filteredEntries => state.filteredEntries;

  // ── Filter / sort actions ─────────────────────────────────────────────────

  void clearMutationError() => emit(state.copyWith(clearMutationError: true));

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
    required CinemaType cinemaType,
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
    } catch (e) {
      emit(state.copyWith(mutationError: ApiClient.parseError(e).userMessage));
    }
  }

  /// Deletes a show-level entry. cinemaType is required for the compound key.
  Future<void> removeEntry(int tmdbId, CinemaType cinemaType) async {
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
      int tmdbId, CinemaType cinemaType, String displayStatus) async {
    final newStatus = WatchStatus.fromDisplayName(displayStatus);
    final entries = List<LibraryEntryModel>.from(state.entries);
    final idx = entries.indexWhere(
        (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    if (idx < 0) return;

    final original = entries[idx];
    entries[idx] =
        original.copyWith(status: newStatus, updatedAt: DateTime.now());
    emit(state.copyWith(entries: entries));

    try {
      final confirmed =
          await _repo.updateEntry(tmdbId, cinemaType, status: newStatus);
      final refreshed = List<LibraryEntryModel>.from(state.entries);
      final i = refreshed.indexWhere(
          (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
      if (i >= 0) refreshed[i] = confirmed;
      emit(state.copyWith(entries: refreshed));
    } catch (e) {
      emit(state.copyWith(mutationError: ApiClient.parseError(e).userMessage));
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

  /// Moves a watched entry back to Watchlist for rewatching.
  /// watchedAt is left untouched — a new timestamp is added only when the
  /// user marks it as watched again.
  Future<void> markAsRewatch(int tmdbId, CinemaType cinemaType) async {
    final entries = List<LibraryEntryModel>.from(state.entries);
    final idx = entries.indexWhere(
        (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    if (idx < 0) return;

    final original = entries[idx];
    entries[idx] = original.copyWith(
      status: WatchStatus.watchlist,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(entries: entries));

    try {
      final confirmed =
          await _repo.updateEntry(tmdbId, cinemaType, status: WatchStatus.watchlist);
      final refreshed = List<LibraryEntryModel>.from(state.entries);
      final i = refreshed.indexWhere(
          (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
      if (i >= 0) refreshed[i] = confirmed;
      emit(state.copyWith(entries: refreshed));
    } catch (e) {
      emit(state.copyWith(mutationError: ApiClient.parseError(e).userMessage));
    }
  }

  /// Removes an entry from state without an API call.
  void removeEntryLocal(int tmdbId, CinemaType cinemaType) {
    final entries = List<LibraryEntryModel>.from(state.entries)
      ..removeWhere(
          (e) => e.tmdbId == tmdbId && e.cinemaType == cinemaType);
    emit(state.copyWith(entries: entries));
  }
}
