import 'package:equatable/equatable.dart';
import 'package:cinemora/features/discover/models/search_result_item.dart';

enum DiscoverViewMode { browse, searchActive, genreResults }

enum DiscoverSearchStatus { idle, loading, success, empty, failure }

class DiscoverState extends Equatable {
  // ── Browse filters ────────────────────────────────────────────────────────
  final int selectedFilterIndex;
  final List<String> recentSearches;

  // ── View mode ─────────────────────────────────────────────────────────────
  final DiscoverViewMode viewMode;

  // ── Search ────────────────────────────────────────────────────────────────
  final DiscoverSearchStatus searchStatus;
  final String searchQuery;
  final List<SearchResultItem> searchResults;
  final String? errorMessage;

  // ── Genre browse ──────────────────────────────────────────────────────────
  final String? activeGenreLabel;

  const DiscoverState({
    this.selectedFilterIndex = 0,
    this.recentSearches = const [],
    this.viewMode = DiscoverViewMode.browse,
    this.searchStatus = DiscoverSearchStatus.idle,
    this.searchQuery = '',
    this.searchResults = const [],
    this.errorMessage,
    this.activeGenreLabel,
  });

  factory DiscoverState.initial(List<String> savedRecent) => DiscoverState(
        recentSearches: savedRecent,
      );

  bool get isSearching => viewMode == DiscoverViewMode.searchActive;
  bool get isBrowsing => viewMode == DiscoverViewMode.browse;
  bool get isGenreBrowse => viewMode == DiscoverViewMode.genreResults;

  DiscoverState copyWith({
    int? selectedFilterIndex,
    List<String>? recentSearches,
    DiscoverViewMode? viewMode,
    DiscoverSearchStatus? searchStatus,
    String? searchQuery,
    List<SearchResultItem>? searchResults,
    String? errorMessage,
    bool clearError = false,
    String? activeGenreLabel,
    bool clearGenreLabel = false,
  }) {
    return DiscoverState(
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      recentSearches: recentSearches ?? this.recentSearches,
      viewMode: viewMode ?? this.viewMode,
      searchStatus: searchStatus ?? this.searchStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeGenreLabel:
          clearGenreLabel ? null : (activeGenreLabel ?? this.activeGenreLabel),
    );
  }

  @override
  List<Object?> get props => [
        selectedFilterIndex,
        recentSearches,
        viewMode,
        searchStatus,
        searchQuery,
        searchResults,
        errorMessage,
        activeGenreLabel,
      ];
}
