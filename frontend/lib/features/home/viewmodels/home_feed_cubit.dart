import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/utils/tmdb_url_utils.dart';
import 'package:cinemora/features/home/models/jikan_anime_item.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';

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
    final ids = {for (final e in _library.state.entries) e.tmdbId};
    if (ids.length == state.bookmarkedIds.length &&
        ids.every(state.bookmarkedIds.contains)) return;
    emit(state.copyWith(bookmarkedIds: ids));
  }

  @override
  Future<void> close() {
    _librarySub.cancel();
    return super.close();
  }

  void selectTab(String tab) => emit(state.withTab(tab));

  void toggleMood(String label) {
    final newMood = state.selectedMood == label ? null : label;
    emit(state.withMood(newMood));
  }

  Future<void> loadFeed() async {
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));

    // Each section fails independently — a Jikan timeout won't wipe out TMDB sections.
    final results = await Future.wait([
      _repository.fetchTrendingMovies().catchError((_) => <TmdbItem>[]),
      _repository.fetchTrendingSeries().catchError((_) => <TmdbItem>[]),
      _repository.fetchTopAnime().catchError((_) => <JikanAnimeItem>[]),
    ]);

    final movies = results[0] as List<TmdbItem>;
    final series = results[1] as List<TmdbItem>;
    final anime = results[2] as List<JikanAnimeItem>;

    // Only show full error state if everything failed.
    if (movies.isEmpty && series.isEmpty && anime.isEmpty) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: 'Could not load feed. Tap to retry.',
      ));
      return;
    }

    emit(state.copyWith(
      status: FeedStatus.success,
      hero: movies.isNotEmpty ? movies.first : null,
      trendingMovies: movies.take(10).map(_fromTmdb).toList(),
      criticallyAcclaimed: movies.skip(10).map(_fromTmdb).toList(),
      trendingSeries: series.take(10).map(_fromTmdb).toList(),
      topAnime: anime.map(_fromAnime).toList(),
      errorMessage: null,
    ));
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

  void bookmarkHero(TmdbItem hero) {
    _toggleBookmark(
      id: hero.id,
      title: hero.title,
      cinemaType: CinemaType.fromJson(hero.mediaType),
      posterPath: hero.posterPath,
      year: hero.year,
      tmdbRating: hero.voteAverage,
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
    final isBookmarked = state.bookmarkedIds.contains(id);
    final updated = Set<int>.from(state.bookmarkedIds);
    if (isBookmarked) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    emit(state.copyWith(bookmarkedIds: updated));

    if (isBookmarked) {
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
}
