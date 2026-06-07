import 'package:equatable/equatable.dart';

class MovieDetailsState extends Equatable {
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final bool showAllTags;
  final bool showRatingSuccess;

  const MovieDetailsState({
    this.isInWatchlist = false,
    this.isWatched = false,
    this.userRating = 5.0,
    this.showAllTags = false,
    this.showRatingSuccess = false,
  });

  MovieDetailsState copyWith({
    bool? isInWatchlist,
    bool? isWatched,
    double? userRating,
    bool? showAllTags,
    bool? showRatingSuccess,
  }) {
    return MovieDetailsState(
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isWatched: isWatched ?? this.isWatched,
      userRating: userRating ?? this.userRating,
      showAllTags: showAllTags ?? this.showAllTags,
      showRatingSuccess: showRatingSuccess ?? this.showRatingSuccess,
    );
  }

  @override
  List<Object> get props => [
        isInWatchlist,
        isWatched,
        userRating,
        showAllTags,
        showRatingSuccess,
      ];
}
