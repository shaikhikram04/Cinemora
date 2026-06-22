import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';

enum FeedStatus { initial, loading, success, failure }

// Sentinel used in copyWith to distinguish "pass null" from "don't change"
const _kUnset = Object();

class HomeFeedState extends Equatable {
  final String selectedTab;
  final String? selectedMood;
  final FeedStatus status;
  final String? errorMessage;
  final TmdbItem? hero;
  final List<MoviePoster> trendingMovies;
  final List<MoviePoster> criticallyAcclaimed;
  final List<MoviePoster> trendingSeries;
  final List<MoviePoster> topAnime;
  final Map<int, WatchStatus> libraryStatus;

  const HomeFeedState({
    this.selectedTab = '✨   For You',
    this.selectedMood,
    this.status = FeedStatus.initial,
    this.errorMessage,
    this.hero,
    this.trendingMovies = const [],
    this.criticallyAcclaimed = const [],
    this.trendingSeries = const [],
    this.topAnime = const [],
    this.libraryStatus = const {},
  });

  HomeFeedState copyWith({
    String? selectedTab,
    Object? selectedMood = _kUnset,
    FeedStatus? status,
    Object? errorMessage = _kUnset,
    Object? hero = _kUnset,
    List<MoviePoster>? trendingMovies,
    List<MoviePoster>? criticallyAcclaimed,
    List<MoviePoster>? trendingSeries,
    List<MoviePoster>? topAnime,
    Map<int, WatchStatus>? libraryStatus,
  }) =>
      HomeFeedState(
        selectedTab: selectedTab ?? this.selectedTab,
        selectedMood: identical(selectedMood, _kUnset)
            ? this.selectedMood
            : selectedMood as String?,
        status: status ?? this.status,
        errorMessage: identical(errorMessage, _kUnset)
            ? this.errorMessage
            : errorMessage as String?,
        hero: identical(hero, _kUnset) ? this.hero : hero as TmdbItem?,
        trendingMovies: trendingMovies ?? this.trendingMovies,
        criticallyAcclaimed: criticallyAcclaimed ?? this.criticallyAcclaimed,
        trendingSeries: trendingSeries ?? this.trendingSeries,
        topAnime: topAnime ?? this.topAnime,
        libraryStatus: libraryStatus ?? this.libraryStatus,
      );

  HomeFeedState withTab(String tab) => copyWith(selectedTab: tab);
  HomeFeedState withMood(String? mood) => copyWith(selectedMood: mood);

  bool get isLoading => status == FeedStatus.loading;
  bool get hasData => status == FeedStatus.success;

  @override
  List<Object?> get props => [
        selectedTab,
        selectedMood,
        status,
        errorMessage,
        hero,
        trendingMovies,
        criticallyAcclaimed,
        trendingSeries,
        topAnime,
        libraryStatus,
      ];
}
