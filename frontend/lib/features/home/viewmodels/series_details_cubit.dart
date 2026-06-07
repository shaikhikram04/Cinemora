import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/features/home/models/series_season.dart';
import 'series_details_state.dart';

class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  final List<SeriesSeason> seasons;

  SeriesDetailsCubit({required this.seasons})
      : super(const SeriesDetailsState());

  void selectSeason(int index) =>
      emit(state.copyWith(selectedSeasonIndex: index));

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
      final season = seasons.firstWhere((s) => s.number == seasonNumber);
      for (final ep in season.episodes) {
        final key = 'S${seasonNumber}E${ep.number}';
        if (!episodes.contains(key)) episodes.add(key);
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
}
