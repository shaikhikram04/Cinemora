import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/tmdb_url_utils.dart';
import 'package:cinemora/features/home/models/home_recommendations.dart';
import 'package:cinemora/features/home/models/jikan_anime_item.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/models/similar_item.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';

// Home tabs. `type` null = "For You" (mixed / all types).
const homeTabs = <({String label, CinemaType? type})>[
  (label: '✨   For You', type: null),
  (label: '🎬   Movies', type: CinemaType.movie),
  (label: '⛩️   Anime', type: CinemaType.anime),
  (label: '📺   Series', type: CinemaType.tv),
];

class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _repository;
  final LibraryCubit _library;
  late final StreamSubscription _librarySub;

  HomeFeedCubit(this._repository, this._library)
      : super(const HomeFeedState()) {
    _librarySub = _library.stream.listen((_) => _syncBookmarkedIds());
    _syncBookmarkedIds();
    loadFeed();
  }

  void _syncBookmarkedIds() {
    final status = {for (final e in _library.state.entries) e.tmdbId: e.status};
    final current = state.libraryStatus;
    if (status.length == current.length &&
        status.entries.every((kv) => current[kv.key] == kv.value)) {
      return;
    }
    emit(state.copyWith(libraryStatus: status));
  }

  @override
  Future<void> close() {
    _librarySub.cancel();
    return super.close();
  }

  CinemaType? get _selectedType =>
      homeTabs.firstWhere((t) => t.label == state.selectedTab).type;

  void selectTab(String tab) {
    if (tab == state.selectedTab) return;
    emit(state.copyWith(selectedTab: tab));
    loadFeed();
  }

  Future<void> loadFeed() async {
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));
    final type = _selectedType;

    // Recommendations (Pick of Week, Because You Ranked, Critically Acclaimed)
    // and the type-scoped Trending Now row fail independently.
    final results = await Future.wait([
      _repository
          .fetchHomeRecommendations(type: type)
          .catchError((_) => const HomeRecommendations()),
      _fetchTrending(type).catchError((_) => <MoviePoster>[]),
    ]);

    final recommendations = results[0] as HomeRecommendations;
    final trending = results[1] as List<MoviePoster>;
    // For You / Movies use movie posters; Series uses tv; Anime uses anime.
    final trendingType = type ?? CinemaType.movie;

    final everythingEmpty = trending.isEmpty &&
        recommendations.pickOfWeek.isEmpty &&
        recommendations.criticallyAcclaimed.isEmpty;
    if (everythingEmpty) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: 'Could not load feed. Tap to retry.',
      ));
      return;
    }

    emit(state.copyWith(
      status: FeedStatus.success,
      pickOfWeek: recommendations.pickOfWeek.map(_fromSimilar).toList(),
      trending: trending,
      trendingType: trendingType,
      criticallyAcclaimed:
          recommendations.criticallyAcclaimed.map(_fromSimilar).toList(),
      becauseYouRankedAnchorTitle: recommendations.becauseYouRankedAnchorTitle,
      becauseYouRanked:
          recommendations.becauseYouRanked.map(_fromSimilar).toList(),
      errorMessage: null,
    ));
  }

  // Trending Now is raw Node popularity data, scoped to the tab's type.
  Future<List<MoviePoster>> _fetchTrending(CinemaType? type) async {
    switch (type) {
      case CinemaType.anime:
        final anime = await _repository.fetchTopAnime();
        return anime.map(_fromAnime).toList();
      case CinemaType.tv:
        final series = await _repository.fetchTrendingSeries();
        return series.take(10).map(_fromTmdb).toList();
      case CinemaType.movie:
      case null:
        final movies = await _repository.fetchTrendingMovies();
        return movies.take(10).map(_fromTmdb).toList();
    }
  }

  void bookmarkFromPoster(MoviePoster item, CinemaType type) {
    final id = item.id;
    if (id == null) return;
    _toggleBookmark(
      id: id,
      title: item.title,
      cinemaType: type,
      posterPath: extractTmdbPosterPath(item.image),
      year: item.year,
      tmdbRating: double.tryParse(item.rating),
    );
  }

  void _toggleBookmark({
    required int id,
    required String title,
    required CinemaType cinemaType,
    String? posterPath,
    String? year,
    double? tmdbRating,
  }) {
    final isWatchlisted = state.libraryStatus[id] == WatchStatus.watchlist;
    final updated = Map<int, WatchStatus>.from(state.libraryStatus);
    if (isWatchlisted) {
      updated.remove(id);
    } else {
      updated[id] = WatchStatus.watchlist;
    }
    emit(state.copyWith(libraryStatus: updated));

    if (isWatchlisted) {
      _library.removeEntry(id, cinemaType);
    } else {
      _library.addToWatchlist(
        tmdbId: id,
        cinemaType: cinemaType,
        title: title,
        posterPath: posterPath,
        releaseYear: year,
        tmdbRating: tmdbRating,
      );
    }
  }

  static MoviePoster _fromTmdb(TmdbItem e) => MoviePoster(
        id: e.id,
        title: e.title,
        rating: e.ratingDisplay,
        image: e.posterUrl,
        backdropImage: e.backdropUrl.isNotEmpty ? e.backdropUrl : null,
        year: e.year,
      );

  static MoviePoster _fromAnime(JikanAnimeItem e) => MoviePoster(
        id: e.id,
        title: e.title,
        rating: e.ratingDisplay,
        image: e.imageUrl,
        year: e.year?.toString() ?? '',
        tag: 'Anime',
      );

  static MoviePoster _fromSimilar(SimilarItem e) => MoviePoster(
        id: e.sourceId,
        title: e.title,
        rating: e.ratingDisplay,
        image: e.posterUrl,
        year: e.year ?? '',
        tag: e.cinemaType == 'anime' ? 'Anime' : null,
        cinemaType: e.cinemaType,
        source: e.source,
      );
}
