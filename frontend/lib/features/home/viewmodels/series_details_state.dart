import 'package:equatable/equatable.dart';

class SeriesDetailsState extends Equatable {
  final int selectedSeasonIndex;
  final bool showInWatchlist;
  final bool isShowWatched;
  final List<int> seasonsInWatchlist;
  final List<int> seasonsWatched;
  final List<String> episodesWatched;
  final Map<int, double> seasonRatings;
  final double showRating;
  final List<int> expandedSeasons;
  final bool showRatingSuccess;

  const SeriesDetailsState({
    this.selectedSeasonIndex = 0,
    this.showInWatchlist = false,
    this.isShowWatched = false,
    this.seasonsInWatchlist = const [],
    this.seasonsWatched = const [],
    this.episodesWatched = const [],
    this.seasonRatings = const {},
    this.showRating = 0.0,
    this.expandedSeasons = const [],
    this.showRatingSuccess = false,
  });

  SeriesDetailsState copyWith({
    int? selectedSeasonIndex,
    bool? showInWatchlist,
    bool? isShowWatched,
    List<int>? seasonsInWatchlist,
    List<int>? seasonsWatched,
    List<String>? episodesWatched,
    Map<int, double>? seasonRatings,
    double? showRating,
    List<int>? expandedSeasons,
    bool? showRatingSuccess,
  }) {
    return SeriesDetailsState(
      selectedSeasonIndex: selectedSeasonIndex ?? this.selectedSeasonIndex,
      showInWatchlist: showInWatchlist ?? this.showInWatchlist,
      isShowWatched: isShowWatched ?? this.isShowWatched,
      seasonsInWatchlist: seasonsInWatchlist ?? this.seasonsInWatchlist,
      seasonsWatched: seasonsWatched ?? this.seasonsWatched,
      episodesWatched: episodesWatched ?? this.episodesWatched,
      seasonRatings: seasonRatings ?? this.seasonRatings,
      showRating: showRating ?? this.showRating,
      expandedSeasons: expandedSeasons ?? this.expandedSeasons,
      showRatingSuccess: showRatingSuccess ?? this.showRatingSuccess,
    );
  }

  @override
  List<Object> get props => [
        selectedSeasonIndex,
        showInWatchlist,
        isShowWatched,
        seasonsInWatchlist,
        seasonsWatched,
        episodesWatched,
        seasonRatings,
        showRating,
        expandedSeasons,
        showRatingSuccess,
      ];
}
