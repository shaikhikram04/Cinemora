import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/utils/tmdb_url_utils.dart';
import 'package:cinemora/features/franchise/models/franchise_detail.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'franchise_detail_state.dart';

class FranchiseDetailCubit extends Cubit<FranchiseDetailState> {
  final FranchiseRepository _repo;
  final LibraryCubit _libraryCubit;
  final int collectionId;

  FranchiseDetailCubit(
    this._repo,
    this._libraryCubit,
    this.collectionId,
  ) : super(const FranchiseDetailState()) {
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(status: FranchiseDetailStatus.loading));
    try {
      final detail = await _repo.getCollection(collectionId);
      emit(state.copyWith(
        status: FranchiseDetailStatus.success,
        detail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(status: FranchiseDetailStatus.failure));
    }
  }

  void retry() => _load();

  /// Adds or removes a single movie's watchlist entry — mirrors the poster
  /// bookmark toggle used elsewhere (e.g. HomeFeedCubit._toggleBookmark).
  Future<void> toggleWatchlist(
    FranchiseMovieItem movie, {
    required bool isWatchlisted,
  }) {
    if (isWatchlisted) {
      return _libraryCubit.removeEntry(movie.id, CinemaType.movie);
    }
    return _libraryCubit.addToWatchlist(
      tmdbId: movie.id,
      cinemaType: CinemaType.movie,
      title: movie.title,
      posterPath: extractTmdbPosterPath(movie.posterUrl),
      releaseYear: movie.year,
      tmdbRating: movie.rating > 0 ? movie.rating : null,
    );
  }

  /// Adds every movie in the franchise that isn't already in the user's
  /// library to their watchlist. Leaves existing entries (watched, dropped,
  /// already-watchlisted) untouched.
  Future<void> addAllToWatchlist(List<FranchiseMovieItem> pending) async {
    if (pending.isEmpty || state.isBulkAdding) return;
    emit(state.copyWith(isBulkAdding: true));
    try {
      for (final movie in pending) {
        await _libraryCubit.addToWatchlist(
          tmdbId: movie.id,
          cinemaType: CinemaType.movie,
          title: movie.title,
          posterPath: extractTmdbPosterPath(movie.posterUrl),
          releaseYear: movie.year,
          tmdbRating: movie.rating > 0 ? movie.rating : null,
        );
      }
    } finally {
      if (!isClosed) emit(state.copyWith(isBulkAdding: false));
    }
  }
}
