import 'package:equatable/equatable.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/features/home/viewmodels/movie_details_state.dart';

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
  final TmdbTvDetail? detail;
  final DetailStatus detailStatus;
  final List<SeriesSeason> seasons;
  final Set<int> loadedSeasonNumbers;
  // Transient — set on mutation failure, cleared after the view consumes it.
  final String? mutationError;

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
    this.detail,
    this.detailStatus = DetailStatus.initial,
    this.seasons = const [],
    this.loadedSeasonNumbers = const {},
    this.mutationError,
  });

  bool get isDetailLoading => detailStatus == DetailStatus.loading;

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
    TmdbTvDetail? detail,
    DetailStatus? detailStatus,
    List<SeriesSeason>? seasons,
    Set<int>? loadedSeasonNumbers,
    String? mutationError,
    bool clearMutationError = false,
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
      detail: detail ?? this.detail,
      detailStatus: detailStatus ?? this.detailStatus,
      seasons: seasons ?? this.seasons,
      loadedSeasonNumbers: loadedSeasonNumbers ?? this.loadedSeasonNumbers,
      mutationError: clearMutationError ? null : (mutationError ?? this.mutationError),
    );
  }

  @override
  List<Object?> get props => [
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
        detail,
        detailStatus,
        seasons,
        loadedSeasonNumbers,
        mutationError,
      ];
}
