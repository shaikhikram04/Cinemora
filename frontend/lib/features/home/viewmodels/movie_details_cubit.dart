import 'package:flutter_bloc/flutter_bloc.dart';
import 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit() : super(const MovieDetailsState());

  void toggleWatchlist() =>
      emit(state.copyWith(isInWatchlist: !state.isInWatchlist));

  void toggleWatched() => emit(state.copyWith(isWatched: !state.isWatched));

  void updateRating(double value) =>
      emit(state.copyWith(userRating: value, showRatingSuccess: true));

  void toggleTags() => emit(state.copyWith(showAllTags: !state.showAllTags));
}
