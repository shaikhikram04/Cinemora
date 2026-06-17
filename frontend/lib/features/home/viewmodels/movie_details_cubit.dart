import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final HomeRepository _repo;
  final int? _tmdbId;

  MovieDetailsCubit(this._repo, this._tmdbId) : super(const MovieDetailsState()) {
    if (_tmdbId != null) _loadDetail();
  }

  void toggleWatchlist() =>
      emit(state.copyWith(isInWatchlist: !state.isInWatchlist));

  void toggleWatched() => emit(state.copyWith(isWatched: !state.isWatched));

  void updateRating(double value) =>
      emit(state.copyWith(userRating: value, showRatingSuccess: true));

  void toggleTags() => emit(state.copyWith(showAllTags: !state.showAllTags));

  Future<void> _loadDetail() async {
    emit(state.copyWith(detailStatus: DetailStatus.loading));
    try {
      final detail = await _repo.fetchMovieDetail(_tmdbId!);
      emit(state.copyWith(detail: detail, detailStatus: DetailStatus.loaded));
    } catch (_) {
      emit(state.copyWith(detailStatus: DetailStatus.failed));
    }
  }
}
