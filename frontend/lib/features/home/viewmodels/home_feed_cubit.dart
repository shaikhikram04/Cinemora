import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/home/models/jikan_anime_item.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';

class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _repository;

  HomeFeedCubit(this._repository) : super(const HomeFeedState()) {
    loadFeed();
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
