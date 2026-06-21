import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/utils/tmdb_url_utils.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final HomeRepository _repo;
  final LibraryRepository _library;
  final LibraryCubit _libraryCubit;
  final int? _tmdbId;
  final String _title;
  final String? _posterUrl;
  final double? _tmdbRating;

  MovieDetailsCubit(
    this._repo,
    this._library,
    this._libraryCubit,
    this._tmdbId, {
    required String title,
    String? posterUrl,
    double? tmdbRating,
  })  : _title = title,
        _posterUrl = posterUrl,
        _tmdbRating = tmdbRating,
        super(const MovieDetailsState()) {
    if (_tmdbId != null) _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = _tmdbId;
    if (id == null) return;
    emit(state.copyWith(detailStatus: DetailStatus.loading));
    try {
      final detail = await _repo.fetchMovieDetail(id);
      LibraryEntryModel? entry;
      try {
        entry = await _library.getEntry(id, CinemaType.movie);
      } catch (_) {}
      emit(state.copyWith(
        detail: detail,
        detailStatus: DetailStatus.loaded,
        isInWatchlist: entry?.status == WatchStatus.watchlist,
        isWatched: entry?.status == WatchStatus.watched,
        userRating: entry?.userRating ?? 0.0,
      ));
    } catch (_) {
      emit(state.copyWith(detailStatus: DetailStatus.failed));
    }
  }

  Future<void> toggleWatchlist() async {
    final id = _tmdbId;
    if (state.isInWatchlist) {
      emit(state.copyWith(isInWatchlist: false));
      if (id == null) return;
      try {
        await _library.deleteEntry(id, CinemaType.movie);
        _libraryCubit.removeEntryLocal(id, CinemaType.movie);
      } catch (_) {
        emit(state.copyWith(isInWatchlist: true));
      }
    } else {
      final wasWatched = state.isWatched;
      emit(state.copyWith(isInWatchlist: true, isWatched: false));
      if (id == null) return;
      try {
        final entry = await _library.upsertEntry(
          tmdbId: id,
          cinemaType: CinemaType.movie,
          title: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear: state.detail?.year,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
          runtimeMinutes: state.detail?.runtimeMinutes,
          status: WatchStatus.watchlist,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        emit(state.copyWith(isInWatchlist: false, isWatched: wasWatched));
      }
    }
  }

  Future<void> toggleWatched() async {
    final id = _tmdbId;
    if (state.isWatched) {
      emit(state.copyWith(isWatched: false));
      if (id == null) return;
      try {
        await _library.deleteEntry(id, CinemaType.movie);
        _libraryCubit.removeEntryLocal(id, CinemaType.movie);
      } catch (_) {
        emit(state.copyWith(isWatched: true));
      }
    } else {
      final wasInWatchlist = state.isInWatchlist;
      emit(state.copyWith(isWatched: true, isInWatchlist: false));
      if (id == null) return;
      try {
        final entry = await _library.upsertEntry(
          tmdbId: id,
          cinemaType: CinemaType.movie,
          title: _title,
          posterPath: extractTmdbPosterPath(_posterUrl),
          releaseYear: state.detail?.year,
          genres: state.detail?.genres ?? [],
          tmdbRating: _tmdbRating,
          runtimeMinutes: state.detail?.runtimeMinutes,
          status: WatchStatus.watched,
        );
        _libraryCubit.syncEntry(entry);
      } catch (_) {
        emit(state.copyWith(isWatched: false, isInWatchlist: wasInWatchlist));
      }
    }
  }

  Future<void> updateRating(double value) async {
    final id = _tmdbId;
    final prevRating = state.userRating;
    final wasWatched = state.isWatched;
    final wasInWatchlist = state.isInWatchlist;
    emit(state.copyWith(
      userRating: value,
      showRatingSuccess: true,
      isWatched: true,
      isInWatchlist: false,
    ));
    if (id == null) return;
    try {
      final entry = await _library.upsertEntry(
        tmdbId: id,
        cinemaType: CinemaType.movie,
        title: _title,
        posterPath: extractTmdbPosterPath(_posterUrl),
        releaseYear: state.detail?.year,
        genres: state.detail?.genres ?? [],
        tmdbRating: _tmdbRating,
        runtimeMinutes: state.detail?.runtimeMinutes,
        status: WatchStatus.watched,
        userRating: value,
      );
      _libraryCubit.syncEntry(entry);
    } catch (_) {
      emit(state.copyWith(
        userRating: prevRating,
        isWatched: wasWatched,
        isInWatchlist: wasInWatchlist,
      ));
    }
  }

  void toggleTags() => emit(state.copyWith(showAllTags: !state.showAllTags));
}
