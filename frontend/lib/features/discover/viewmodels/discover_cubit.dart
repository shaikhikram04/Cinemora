import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/features/discover/models/search_result_item.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  final DiscoverRepository _repo;
  final SharedPreferences _prefs;
  Timer? _debounce;

  static const _recentKey = 'discover_recent_searches';
  static const _maxRecent = 10;

  int _searchGen = 0;
  int _genreGen = 0;

  // Maps the filter chip index to a content type string used in the repo
  static const _filterTypes = ['all', 'movie', 'anime', 'tv'];

  DiscoverCubit(this._repo, this._prefs)
      : super(DiscoverState.initial(_loadSavedRecent(_prefs)));

  // ── Browse filters ────────────────────────────────────────────────────────

  void selectFilter(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
    // Re-run search immediately if we're in search mode with an active query
    if (state.isSearching && state.searchQuery.isNotEmpty) {
      _doSearch(state.searchQuery, filterIndex: index);
    }
    // Re-run genre browse if in genre mode
    if (state.isGenreBrowse && _currentGenreId != null) {
      _doGenreBrowse(_currentGenreId!, label: state.activeGenreLabel ?? '');
    }
  }

  // ── Search lifecycle ──────────────────────────────────────────────────────

  void onSearchFocused() {
    if (state.isBrowsing) {
      emit(state.copyWith(viewMode: DiscoverViewMode.searchActive));
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        searchStatus: DiscoverSearchStatus.idle,
        searchResults: [],
        clearError: true,
      ));
      return;
    }

    // Only update query text now; defer loading status until debounce settles.
    emit(state.copyWith(searchQuery: trimmed));

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (isClosed) return;
      emit(state.copyWith(searchStatus: DiscoverSearchStatus.loading));
      _doSearch(trimmed);
    });
  }

  void onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _debounce?.cancel();
    _saveToRecent(trimmed);
    emit(state.copyWith(
      searchQuery: trimmed,
      searchStatus: DiscoverSearchStatus.loading,
    ));
    _doSearch(trimmed);
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(state.copyWith(
      viewMode: DiscoverViewMode.browse,
      searchStatus: DiscoverSearchStatus.idle,
      searchQuery: '',
      searchResults: [],
      clearError: true,
      clearGenreLabel: true,
    ));
  }

  /// Called when a recent search chip or trending item is tapped.
  /// The view must update the TextEditingController externally via a callback.
  void repeatSearch(String term) {
    _debounce?.cancel();
    _saveToRecent(term);
    emit(state.copyWith(
      viewMode: DiscoverViewMode.searchActive,
      searchQuery: term,
      searchStatus: DiscoverSearchStatus.loading,
    ));
    _doSearch(term);
  }

  // ── Recent searches ───────────────────────────────────────────────────────

  void removeRecentSearch(String item) {
    final list = List<String>.from(state.recentSearches)..remove(item);
    emit(state.copyWith(recentSearches: list));
    _persistRecent(list);
  }

  void clearAllRecentSearches() {
    emit(state.copyWith(recentSearches: []));
    _persistRecent([]);
  }

  // ── Genre browse ──────────────────────────────────────────────────────────

  int? _currentGenreId;

  void browseGenre(String label, int tmdbGenreId) {
    _currentGenreId = tmdbGenreId;
    emit(state.copyWith(
      viewMode: DiscoverViewMode.genreResults,
      activeGenreLabel: label,
      searchStatus: DiscoverSearchStatus.loading,
      searchResults: [],
      clearError: true,
    ));
    _doGenreBrowse(tmdbGenreId, label: label);
  }

  void exitGenreBrowse() {
    _currentGenreId = null;
    emit(state.copyWith(
      viewMode: DiscoverViewMode.browse,
      searchStatus: DiscoverSearchStatus.idle,
      searchResults: [],
      clearError: true,
      clearGenreLabel: true,
    ));
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _doSearch(String query, {int? filterIndex}) async {
    final gen = ++_searchGen;
    final fi = filterIndex ?? state.selectedFilterIndex;
    final type = _filterTypes[fi]; // 'all' | 'movie' | 'anime' | 'tv'

    try {
      final List<SearchResultItem> results;
      switch (type) {
        case 'movie':
          results = await _repo.searchMovies(query);
          break;
        case 'tv':
          results = await _repo.searchSeries(query);
          break;
        case 'anime':
          results = await _repo.searchAnime(query);
          break;
        default:
          results = await _repo.searchAll(query);
      }

      if (isClosed || gen != _searchGen) return;
      emit(state.copyWith(
        searchStatus: results.isEmpty
            ? DiscoverSearchStatus.empty
            : DiscoverSearchStatus.success,
        searchResults: results,
        clearError: true,
      ));
    } catch (e) {
      if (isClosed || gen != _searchGen) return;
      emit(state.copyWith(
        searchStatus: DiscoverSearchStatus.failure,
        errorMessage: 'Something went wrong. Tap to retry.',
      ));
    }
  }

  Future<void> _doGenreBrowse(int genreId, {required String label}) async {
    final gen = ++_genreGen;
    final fi = state.selectedFilterIndex;
    // Genre browse only supports TMDB types (movies + series)
    // If filter is 'anime' (index 2) or 'all' (index 0), default to both
    try {
      List<SearchResultItem> results;
      if (fi == 1) {
        // Movies only
        results = await _repo.discoverByGenre(genreId, 'movie');
      } else if (fi == 3) {
        // Series only
        results = await _repo.discoverByGenre(genreId, 'tv');
      } else {
        // All or Anime → show both movies + series merged
        final both = await Future.wait([
          _repo.discoverByGenre(genreId, 'movie'),
          _repo.discoverByGenre(genreId, 'tv'),
        ]);
        results = [...both[0], ...both[1]];
      }

      if (isClosed || gen != _genreGen) return;
      emit(state.copyWith(
        searchStatus: results.isEmpty
            ? DiscoverSearchStatus.empty
            : DiscoverSearchStatus.success,
        searchResults: results,
        clearError: true,
      ));
    } catch (e) {
      if (isClosed || gen != _genreGen) return;
      emit(state.copyWith(
        searchStatus: DiscoverSearchStatus.failure,
        errorMessage: 'Could not load $label content.',
      ));
    }
  }

  void _saveToRecent(String term) {
    final list = List<String>.from(state.recentSearches)
      ..remove(term); // dedupe
    list.insert(0, term);
    if (list.length > _maxRecent) list.removeLast();
    emit(state.copyWith(recentSearches: list));
    _persistRecent(list);
  }

  void _persistRecent(List<String> list) {
    _prefs.setStringList(_recentKey, list);
  }

  static List<String> _loadSavedRecent(SharedPreferences prefs) {
    return prefs.getStringList(_recentKey) ?? [];
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
