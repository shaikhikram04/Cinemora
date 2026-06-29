import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/utils/tmdb_url_utils.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/movie_details_state.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'series_details_state.dart';

class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  final HomeRepository _repo;
  final LibraryRepository _library;
  final LibraryCubit _libraryCubit;
  final int? _id;
  final String _source;
  final String _title;
  final String? _posterUrl;
  final double? _tmdbRating;
  final int? _focusSeason;

  SeriesDetailsCubit({
    required HomeRepository repo,
    required LibraryRepository library,
    required LibraryCubit libraryCubit,
    int? id,
    String source = 'tmdb',
    List<SeriesSeason> initialSeasons = const [],
    String title = '',
    String? posterUrl,
    double? tmdbRating,
    int? focusSeason,
  })  : _repo = repo,
        _library = library,
        _libraryCubit = libraryCubit,
        _id = id,
        _source = source,
        _title = title,
        _posterUrl = posterUrl,
        _tmdbRating = tmdbRating,
        _focusSeason = focusSeason,
        super(_buildInitialState(
          libraryCubit: libraryCubit,
          id: id,
          source: source,
          initialSeasons: initialSeasons,
        )) {
    if (id != null) _loadDetail();
  }

  static SeriesDetailsState _buildInitialState({
    required LibraryCubit libraryCubit,
    required int? id,
    required String source,
    required List<SeriesSeason> initialSeasons,
  }) {
    if (id == null) return SeriesDetailsState(seasons: initialSeasons);
    final cinemaType = source == 'jikan' ? CinemaType.anime : CinemaType.tv;
    final entry = libraryCubit.state.entries
        .where((e) => e.tmdbId == id && e.cinemaType == cinemaType)
        .firstOrNull;
    final seasonsInWatchlist = entry?.seasons
            .where((s) => s.status == WatchStatus.watchlist)
            .map((s) => s.seasonNumber)
            .toList() ??
        [];
    final seasonsWatched = entry?.seasons
            .where((s) => s.status == WatchStatus.watched)
            .map((s) => s.seasonNumber)
            .toList() ??
        [];
    final seasonRatings = <int, double>{
      for (final s in entry?.seasons ?? [])
        if (s.rating != null) s.seasonNumber: s.rating!,
    };
    return SeriesDetailsState(
      seasons: initialSeasons,
      showInWatchlist: entry?.status == WatchStatus.watchlist,
      isShowWatched: entry?.status == WatchStatus.watched,
      showRating: entry?.userRating ?? 0.0,
      seasonsInWatchlist: seasonsInWatchlist,
      seasonsWatched: seasonsWatched,
      seasonRatings: seasonRatings,
    );
  }

  CinemaType get _cinemaType =>
      _source == 'jikan' ? CinemaType.anime : CinemaType.tv;

  String? get _firstAirYear {
    final range = state.detail?.yearRange ?? '';
    if (range.isEmpty) return null;
    return range.split(RegExp(r'\s*[–\-]\s*')).first.trim();
  }

  // Best available per-episode runtime: TMDB episode_run_time first,
  // then average of loaded episode runtimes (e.g. "45m" strings).
  int? get _episodeRuntime {
    if (state.detail?.runtimeMinutes != null) {
      return state.detail!.runtimeMinutes;
    }
    final runtimes = state.seasons
        .expand((s) => s.episodes)
        .map((ep) {
          final m = RegExp(r'(\d+)').firstMatch(ep.runtime);
          return m != null ? int.tryParse(m.group(1)!) : null;
        })
        .whereType<int>()
        .where((t) => t > 0)
        .toList();
    if (runtimes.isEmpty) return null;
    return (runtimes.reduce((a, b) => a + b) / runtimes.length).round();
  }

  // Total episode count across all seasons (from TMDB episode_count metadata).
  int? get _totalEpisodes {
    final total = state.seasons.fold(0, (sum, s) => sum + s.episodeCount);
    return total > 0 ? total : null;
  }

  // ── Season selection ────────────────────────────────────────────────────────

  void selectSeason(int index) {
    emit(state.copyWith(selectedSeasonIndex: index));
    if (state.seasons.isEmpty) return;

    final season = state.seasons[index];
    if (state.loadedSeasonNumbers.contains(season.number)) return;

    if (_source == 'tmdb') {
      _loadTmdbSeasonEpisodes(season.number);
    } else if (_source == 'jikan' && season.malId != null) {
      _loadJikanSeasonEpisodes(season.malId!, season.number);
    }
  }

  // ── Show-level watchlist / watched ──────────────────────────────────────────

  Future<void> toggleShowWatchlist() async {
    final id = _id;
    if (state.showInWatchlist) {
      emit(state.copyWith(showInWatchlist: false));
      if (id == null) return;
      try {
        await _library.deleteEntry(id, _cinemaType);
        _libraryCubit.removeEntryLocal(id, _cinemaType);
      } catch (_) {
        emit(state.copyWith(showInWatchlist: true));
      }
    } else {
      final wasWatched = state.isShowWatched;
      emit(state.copyWith(showInWatchlist: true, isShowWatched: false));
      if (id == null) return;
      try {
        final entry = await _library.upsertEntry(
          tmdbId: id,
          cinemaType: _cinemaType,
          title: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear: _firstAirYear,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
          runtimeMinutes: _episodeRuntime,
          status: WatchStatus.watchlist,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        emit(state.copyWith(showInWatchlist: false, isShowWatched: wasWatched));
      }
    }
  }

  Future<void> toggleShowWatched() async {
    final id = _id;
    if (state.isShowWatched) {
      emit(state.copyWith(isShowWatched: false, showRating: 0.0));
      if (id == null) return;
      try {
        await _library.deleteEntry(id, _cinemaType);
        _libraryCubit.removeEntryLocal(id, _cinemaType);
      } catch (_) {
        emit(state.copyWith(isShowWatched: true, showRating: state.showRating));
      }
    } else {
      final wasInWatchlist = state.showInWatchlist;
      emit(state.copyWith(isShowWatched: true, showInWatchlist: false));
      if (id == null) return;
      try {
        final entry = await _library.upsertEntry(
          tmdbId: id,
          cinemaType: _cinemaType,
          title: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear: _firstAirYear,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
          runtimeMinutes: _episodeRuntime,
          status: WatchStatus.watched,
          progress: LibraryProgress(totalEpisodes: _totalEpisodes),
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        emit(state.copyWith(
            isShowWatched: false, showInWatchlist: wasInWatchlist));
      }
    }
  }

  // ── Season-level watchlist / watched ────────────────────────────────────────

  Future<void> toggleSeasonWatchlist(int seasonNumber) async {
    final id = _id;
    final list = List<int>.from(state.seasonsInWatchlist);
    final season =
        state.seasons.where((s) => s.number == seasonNumber).firstOrNull;

    if (list.contains(seasonNumber)) {
      list.remove(seasonNumber);
      emit(state.copyWith(seasonsInWatchlist: list));
      if (id == null) return;
      try {
        final entry = await _library.deleteSeason(
          tmdbId: id,
          cinemaType: _cinemaType,
          seasonNumber: seasonNumber,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        list.add(seasonNumber);
        emit(state.copyWith(seasonsInWatchlist: list));
      }
    } else {
      list.add(seasonNumber);
      emit(state.copyWith(seasonsInWatchlist: list));
      if (id == null) return;
      try {
        final entry = await _library.upsertSeason(
          tmdbId: id,
          cinemaType: _cinemaType,
          seasonNumber: seasonNumber,
          seasonId: season?.libraryId,
          status: WatchStatus.watchlist,
          showTitle: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear:
              season?.year.isNotEmpty == true ? season!.year : _firstAirYear,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        list.remove(seasonNumber);
        emit(state.copyWith(seasonsInWatchlist: list));
      }
    }
  }

  Future<void> toggleSeasonWatched(int seasonNumber) async {
    final id = _id;
    final watched = List<int>.from(state.seasonsWatched);
    final episodes = List<String>.from(state.episodesWatched);
    final season =
        state.seasons.where((s) => s.number == seasonNumber).firstOrNull;

    if (watched.contains(seasonNumber)) {
      watched.remove(seasonNumber);
      emit(state.copyWith(seasonsWatched: watched, episodesWatched: episodes));
      if (id == null) return;
      try {
        final entry = await _library.deleteSeason(
          tmdbId: id,
          cinemaType: _cinemaType,
          seasonNumber: seasonNumber,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        watched.add(seasonNumber);
        emit(state.copyWith(seasonsWatched: watched));
      }
    } else {
      watched.add(seasonNumber);
      if (season != null) {
        for (final ep in season.episodes) {
          final key = 'S${seasonNumber}E${ep.number}';
          if (!episodes.contains(key)) episodes.add(key);
        }
      }
      emit(state.copyWith(seasonsWatched: watched, episodesWatched: episodes));
      if (id == null) return;
      try {
        final entry = await _library.upsertSeason(
          tmdbId: id,
          cinemaType: _cinemaType,
          seasonNumber: seasonNumber,
          seasonId: season?.libraryId,
          status: WatchStatus.watched,
          showTitle: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear:
              season?.year.isNotEmpty == true ? season!.year : _firstAirYear,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        watched.remove(seasonNumber);
        emit(state.copyWith(seasonsWatched: watched));
      }
    }
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

  // ── Rating ──────────────────────────────────────────────────────────────────

  Future<void> rateSeason(int seasonNumber, double rating) async {
    final id = _id;
    final previousRatings = Map<int, double>.from(state.seasonRatings);
    final previousWatched = List<int>.from(state.seasonsWatched);

    final ratings = Map<int, double>.from(state.seasonRatings);
    ratings[seasonNumber] = rating;
    final watched = List<int>.from(state.seasonsWatched);
    if (!watched.contains(seasonNumber)) watched.add(seasonNumber);
    emit(state.copyWith(seasonRatings: ratings, seasonsWatched: watched));

    if (id == null) return;
    final season =
        state.seasons.where((s) => s.number == seasonNumber).firstOrNull;
    try {
      final entry = await _library.upsertSeason(
        tmdbId: id,
        cinemaType: _cinemaType,
        seasonNumber: seasonNumber,
        seasonId: season?.libraryId,
        status: WatchStatus.watched,
        rating: rating,
        showTitle: _title,
        posterPath: extractTmdbPosterPath(_posterUrl),
        releaseYear:
            season?.year.isNotEmpty == true ? season!.year : _firstAirYear,
        genres: state.detail?.genres ?? [],
        tmdbRating: _tmdbRating,
      );
      _libraryCubit.syncEntry(entry);
    } catch (e) {
      emit(state.copyWith(
        seasonRatings: previousRatings,
        seasonsWatched: previousWatched,
        mutationError: 'Failed to save rating. Please try again.',
      ));
    }
  }

  Future<void> rateShow(double rating) async {
    final id = _id;
    final previousRating = state.showRating;
    final previousWatched = state.isShowWatched;
    final previousWatchlist = state.showInWatchlist;

    emit(state.copyWith(
      showRating: rating,
      showRatingSuccess: true,
      isShowWatched: true,
      showInWatchlist: false,
    ));
    if (id == null) return;
    try {
      final entry = await _library.upsertEntry(
        tmdbId: id,
        cinemaType: _cinemaType,
        title: _title,
        posterPath: extractTmdbPosterPath(_posterUrl),
        releaseYear: _firstAirYear,
        genres: state.detail?.genres ?? [],
        tmdbRating: _tmdbRating,
        runtimeMinutes: _episodeRuntime,
        status: WatchStatus.watched,
        userRating: rating,
        progress: LibraryProgress(totalEpisodes: _totalEpisodes),
      );
      _libraryCubit.syncEntry(entry);
    } catch (e) {
      emit(state.copyWith(
        showRating: previousRating,
        isShowWatched: previousWatched,
        showInWatchlist: previousWatchlist,
        showRatingSuccess: false,
        mutationError: 'Failed to save rating. Please try again.',
      ));
    }
  }

  void clearMutationError() => emit(state.copyWith(clearMutationError: true));

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
    final id = _id;
    if (id == null) return;
    emit(state.copyWith(detailStatus: DetailStatus.loading));
    try {
      final detail = _source == 'jikan'
          ? await _repo.fetchAnimeDetail(id)
          : await _repo.fetchTvDetail(id);

      int startIndex = 0;
      if (_source == 'jikan') {
        final idx = detail.seasons.indexWhere((s) => s.malId == id);
        if (idx >= 0) startIndex = idx;
      }
      if (_focusSeason != null) {
        final idx = detail.seasons.indexWhere((s) => s.number == _focusSeason);
        if (idx >= 0) startIndex = idx;
      }

      emit(state.copyWith(
        detail: detail,
        seasons: detail.seasons,
        selectedSeasonIndex: startIndex,
        detailStatus: DetailStatus.loaded,
      ));

      if (_source == 'tmdb' && detail.seasons.isNotEmpty) {
        _loadTmdbSeasonEpisodes(detail.seasons[startIndex].number);
      } else if (_source == 'jikan' && detail.seasons.isNotEmpty) {
        final currentSeason = detail.seasons[startIndex];
        final malId = currentSeason.malId;
        if (malId != null) {
          _loadJikanSeasonEpisodes(malId, currentSeason.number);
        }
      }
    } catch (_) {
      emit(state.copyWith(detailStatus: DetailStatus.failed));
    }
  }

  Future<void> _loadTmdbSeasonEpisodes(int seasonNumber) async {
    final id = _id;
    if (id == null) return;
    try {
      final updatedSeason = await _repo.fetchTvSeasonEpisodes(id, seasonNumber);
      final updatedDetail = state.detail?.copyWithSeasonEpisodes(updatedSeason);
      final updatedSeasons = state.seasons
          .map((s) => s.number == seasonNumber ? updatedSeason : s)
          .toList();
      final loaded = Set<int>.from(state.loadedSeasonNumbers)
        ..add(seasonNumber);
      emit(state.copyWith(
        detail: updatedDetail,
        seasons: updatedSeasons,
        loadedSeasonNumbers: loaded,
      ));
    } catch (_) {
      final loaded = Set<int>.from(state.loadedSeasonNumbers)
        ..add(seasonNumber);
      emit(state.copyWith(loadedSeasonNumbers: loaded));
    }
  }

  Future<void> _loadJikanSeasonEpisodes(int malId, int seasonNumber) async {
    try {
      final episodes = await _repo.fetchAnimeEpisodes(malId);
      if (episodes.isEmpty) {
        final loaded = Set<int>.from(state.loadedSeasonNumbers)
          ..add(seasonNumber);
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
      final loaded = Set<int>.from(state.loadedSeasonNumbers)
        ..add(seasonNumber);
      emit(state.copyWith(
        detail: updatedDetail,
        seasons: updatedSeasons,
        loadedSeasonNumbers: loaded,
      ));
    } catch (_) {
      final loaded = Set<int>.from(state.loadedSeasonNumbers)
        ..add(seasonNumber);
      emit(state.copyWith(loadedSeasonNumbers: loaded));
    }
  }
}
