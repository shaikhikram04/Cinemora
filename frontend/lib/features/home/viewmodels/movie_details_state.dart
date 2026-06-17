import 'package:equatable/equatable.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';

enum DetailStatus { initial, loading, loaded, failed }

class MovieDetailsState extends Equatable {
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final bool showAllTags;
  final bool showRatingSuccess;
  final TmdbMovieDetail? detail;
  final DetailStatus detailStatus;

  const MovieDetailsState({
    this.isInWatchlist = false,
    this.isWatched = false,
    this.userRating = 5.0,
    this.showAllTags = false,
    this.showRatingSuccess = false,
    this.detail,
    this.detailStatus = DetailStatus.initial,
  });

  bool get isDetailLoading => detailStatus == DetailStatus.loading;

  MovieDetailsState copyWith({
    bool? isInWatchlist,
    bool? isWatched,
    double? userRating,
    bool? showAllTags,
    bool? showRatingSuccess,
    TmdbMovieDetail? detail,
    DetailStatus? detailStatus,
  }) {
    return MovieDetailsState(
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isWatched: isWatched ?? this.isWatched,
      userRating: userRating ?? this.userRating,
      showAllTags: showAllTags ?? this.showAllTags,
      showRatingSuccess: showRatingSuccess ?? this.showRatingSuccess,
      detail: detail ?? this.detail,
      detailStatus: detailStatus ?? this.detailStatus,
    );
  }

  @override
  List<Object?> get props => [
        isInWatchlist,
        isWatched,
        userRating,
        showAllTags,
        showRatingSuccess,
        detail,
        detailStatus,
      ];
}
