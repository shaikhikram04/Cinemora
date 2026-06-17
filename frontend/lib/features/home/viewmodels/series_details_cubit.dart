import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/movie_details_state.dart';
import 'series_details_state.dart';

class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  final HomeRepository? _repo;
  final int? _id;
  final String _source;

  SeriesDetailsCubit({
    HomeRepository? repo,
    int? id,
    String source = 'tmdb',
    List<SeriesSeason> initialSeasons = const [],
  })  : _repo = repo,
        _id = id,
        _source = source,
        super(SeriesDetailsState(seasons: initialSeasons)) {
    if (id != null && repo != null) _loadDetail();
  }

  // ── Season selection ────────────────────────────────────────────────────────

  void selectSeason(int index) {
    emit(state.copyWith(selectedSeasonIndex: index));
    if (_repo == null || state.seasons.isEmpty) return;

    final season = state.seasons[index];
    if (state.loadedSeasonNumbers.contains(season.number)) return;

    if (_source == 'tmdb') {
      _loadTmdbSeasonEpisodes(season.number);
    } else if (_source == 'jikan' && season.malId != null) {
      _loadJikanSeasonEpisodes(season.malId!, season.number);
    }
  }

  // ── Watchlist / watched ──────────────────────────────────────────────────────

  void toggleShowWatchlist() =>
      emit(state.copyWith(showInWatchlist: !state.showInWatchlist));

  void toggleShowWatched() =>
      emit(state.copyWith(isShowWatched: !state.isShowWatched));

  void toggleSeasonWatchlist(int seasonNumber) {
    final list = List<int>.from(state.seasonsInWatchlist);
    if (list.contains(seasonNumber)) {
      list.remove(seasonNumber);
    } else {
      list.add(seasonNumber);
    }
    emit(state.copyWith(seasonsInWatchlist: list));
  }

  void toggleSeasonWatched(int seasonNumber) {
    final watched = List<int>.from(state.seasonsWatched);
    final episodes = List<String>.from(state.episodesWatched);
    if (watched.contains(seasonNumber)) {
      watched.remove(seasonNumber);
    } else {
      watched.add(seasonNumber);
      final season = state.seasons.where((s) => s.number == seasonNumber).firstOrNull;
      if (season != null) {
        for (final ep in season.episodes) {
          final key = 'S${seasonNumber}E${ep.number}';
          if (!episodes.contains(key)) episodes.add(key);
        }
      }
    }
    emit(state.copyWith(seasonsWatched: watched, episodesWatched: episodes));
  }

  void toggleEpisodeWatched(String key) {
    final list = List<String>.from(state.episodesWatched);
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
    emit(state.copyWith(episodesWatched: list));
  }

  void rateSeason(int seasonNumber, double rating) {
    final ratings = Map<int, double>.from(state.seasonRatings);
    ratings[seasonNumber] = rating;
    emit(state.copyWith(seasonRatings: ratings));
  }

  void rateShow(double rating) =>
      emit(state.copyWith(showRating: rating, showRatingSuccess: true));

  void toggleSeasonExpanded(int seasonNumber) {
    final list = List<int>.from(state.expandedSeasons);
    if (list.contains(seasonNumber)) {
      list.remove(seasonNumber);
    } else {
      list.add(seasonNumber);
    }
    emit(state.copyWith(expandedSeasons: list));
  }

  // ── API loading ─────────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    emit(state.copyWith(detailStatus: DetailStatus.loading));
    try {
      final detail = _source == 'jikan'
          ? await _repo!.fetchAnimeDetail(_id!)
          : await _repo!.fetchTvDetail(_id!);

      // For jikan, start at the season that matches the opened anime's malId
      int startIndex = 0;
      if (_source == 'jikan') {
        final idx = detail.seasons.indexWhere((s) => s.malId == _id);
        if (idx >= 0) startIndex = idx;
      }

      emit(state.copyWith(
        detail: detail,
        seasons: detail.seasons,
        selectedSeasonIndex: startIndex,
        detailStatus: DetailStatus.loaded,
      ));

      // Auto-load episodes for the initially selected season
      if (_source == 'tmdb' && detail.seasons.isNotEmpty) {
        _loadTmdbSeasonEpisodes(detail.seasons.first.number);
      } else if (_source == 'jikan' && detail.seasons.isNotEmpty) {
        final currentSeason = detail.seasons[startIndex];
        if (currentSeason.malId != null) {
          _loadJikanSeasonEpisodes(currentSeason.malId!, currentSeason.number);
        }
      }
    } catch (_) {
      emit(state.copyWith(detailStatus: DetailStatus.failed));
    }
  }

  Future<void> _loadTmdbSeasonEpisodes(int seasonNumber) async {
    try {
      final updatedSeason = await _repo!.fetchTvSeasonEpisodes(_id!, seasonNumber);
      final updatedDetail = state.detail?.copyWithSeasonEpisodes(updatedSeason);
      final updatedSeasons = state.seasons
          .map((s) => s.number == seasonNumber ? updatedSeason : s)
          .toList();
      final loaded = Set<int>.from(state.loadedSeasonNumbers)..add(seasonNumber);
      emit(state.copyWith(
        detail: updatedDetail,
        seasons: updatedSeasons,
        loadedSeasonNumbers: loaded,
      ));
    } catch (_) {
      final loaded = Set<int>.from(state.loadedSeasonNumbers)..add(seasonNumber);
      emit(state.copyWith(loadedSeasonNumbers: loaded));
    }
  }

  Future<void> _loadJikanSeasonEpisodes(int malId, int seasonNumber) async {
    try {
      final episodes = await _repo!.fetchAnimeEpisodes(malId);
      if (episodes.isEmpty) {
        final loaded = Set<int>.from(state.loadedSeasonNumbers)..add(seasonNumber);
        emit(state.copyWith(loadedSeasonNumbers: loaded));
        return;
      }
      final updatedSeason = state.seasons
          .firstWhere((s) => s.number == seasonNumber)
          .copyWith(episodes: episodes);
      final updatedDetail = state.detail?.copyWithSeasonEpisodes(updatedSeason);
      final updatedSeasons = state.seasons
          .map((s) => s.number == seasonNumber ? updatedSeason : s)
          .toList();
      final loaded = Set<int>.from(state.loadedSeasonNumbers)..add(seasonNumber);
      emit(state.copyWith(
        detail: updatedDetail,
        seasons: updatedSeasons,
        loadedSeasonNumbers: loaded,
      ));
    } catch (_) {
      final loaded = Set<int>.from(state.loadedSeasonNumbers)..add(seasonNumber);
      emit(state.copyWith(loadedSeasonNumbers: loaded));
    }
  }
}
