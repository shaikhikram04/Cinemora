import 'package:equatable/equatable.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';

enum FranchiseViewMode { featured, searchActive }

enum FranchiseStatus { idle, loading, success, empty, failure }

class FranchiseListState extends Equatable {
  final FranchiseViewMode viewMode;

  final FranchiseStatus featuredStatus;
  final List<FranchiseSummary> featured;

  final FranchiseStatus searchStatus;
  final String searchQuery;
  final List<FranchiseSummary> searchResults;
  final String? errorMessage;

  const FranchiseListState({
    this.viewMode = FranchiseViewMode.featured,
    this.featuredStatus = FranchiseStatus.idle,
    this.featured = const [],
    this.searchStatus = FranchiseStatus.idle,
    this.searchQuery = '',
    this.searchResults = const [],
    this.errorMessage,
  });

  bool get isSearching => viewMode == FranchiseViewMode.searchActive;

  FranchiseListState copyWith({
    FranchiseViewMode? viewMode,
    FranchiseStatus? featuredStatus,
    List<FranchiseSummary>? featured,
    FranchiseStatus? searchStatus,
    String? searchQuery,
    List<FranchiseSummary>? searchResults,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FranchiseListState(
      viewMode: viewMode ?? this.viewMode,
      featuredStatus: featuredStatus ?? this.featuredStatus,
      featured: featured ?? this.featured,
      searchStatus: searchStatus ?? this.searchStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        viewMode,
        featuredStatus,
        featured,
        searchStatus,
        searchQuery,
        searchResults,
        errorMessage,
      ];
}
