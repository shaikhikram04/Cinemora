import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';

enum FeedStatus { initial, loading, success, failure }

// Sentinel used in copyWith to distinguish "pass null" from "don't change"
const _kUnset = Object();

class HomeFeedState extends Equatable {
  final String selectedTab;
  final FeedStatus status;
  final String? errorMessage;
  final List<MoviePoster> pickOfWeek;
  // Trending Now — a single type-scoped list per selected tab (Node data).
  final List<MoviePoster> trending;
  final CinemaType trendingType;
  final List<MoviePoster> criticallyAcclaimed;
  final String? becauseYouRankedAnchorTitle;
  final List<MoviePoster> becauseYouRanked;
  final Map<int, WatchStatus> libraryStatus;

  const HomeFeedState({
    this.selectedTab = '✨   For You',
    this.status = FeedStatus.initial,
    this.errorMessage,
    this.pickOfWeek = const [],
    this.trending = const [],
    this.trendingType = CinemaType.movie,
    this.criticallyAcclaimed = const [],
    this.becauseYouRankedAnchorTitle,
    this.becauseYouRanked = const [],
    this.libraryStatus = const {},
  });

  HomeFeedState copyWith({
    String? selectedTab,
    FeedStatus? status,
    Object? errorMessage = _kUnset,
    List<MoviePoster>? pickOfWeek,
    List<MoviePoster>? trending,
    CinemaType? trendingType,
    List<MoviePoster>? criticallyAcclaimed,
    Object? becauseYouRankedAnchorTitle = _kUnset,
    List<MoviePoster>? becauseYouRanked,
    Map<int, WatchStatus>? libraryStatus,
  }) =>
      HomeFeedState(
        selectedTab: selectedTab ?? this.selectedTab,
        status: status ?? this.status,
        errorMessage: identical(errorMessage, _kUnset)
            ? this.errorMessage
            : errorMessage as String?,
        pickOfWeek: pickOfWeek ?? this.pickOfWeek,
        trending: trending ?? this.trending,
        trendingType: trendingType ?? this.trendingType,
        criticallyAcclaimed: criticallyAcclaimed ?? this.criticallyAcclaimed,
        becauseYouRankedAnchorTitle:
            identical(becauseYouRankedAnchorTitle, _kUnset)
                ? this.becauseYouRankedAnchorTitle
                : becauseYouRankedAnchorTitle as String?,
        becauseYouRanked: becauseYouRanked ?? this.becauseYouRanked,
        libraryStatus: libraryStatus ?? this.libraryStatus,
      );

  bool get isLoading => status == FeedStatus.loading;
  bool get hasData => status == FeedStatus.success;

  @override
  List<Object?> get props => [
        selectedTab,
        status,
        errorMessage,
        pickOfWeek,
        trending,
        trendingType,
        criticallyAcclaimed,
        becauseYouRankedAnchorTitle,
        becauseYouRanked,
        libraryStatus,
      ];
}
