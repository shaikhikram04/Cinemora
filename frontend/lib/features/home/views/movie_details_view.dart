import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';
import 'package:watchary/features/home/viewmodels/movie_details_cubit.dart';
import 'package:watchary/features/home/viewmodels/movie_details_state.dart';
import 'package:watchary/features/home/widgets/movie_details_content.dart';
import 'package:watchary/features/home/widgets/post_rating_bottom_sheet.dart';

class MovieDetailsView extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;

  const MovieDetailsView({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieDetailsCubit(),
      child: _MovieDetailsContent(
        movieTitle: movieTitle,
        movieImage: movieImage,
        rating: rating,
      ),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;

  const _MovieDetailsContent({
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
  });

  void _openRankingsSheet(BuildContext context, MovieDetailsState state) {
    showPostRatingSheet(
      context,
      movieTitle: movieTitle,
      movieImage: movieImage,
      movieType: 'Movie',
      userRating: state.userRating,
      ratingLabel: ratingLabelFor(state.userRating),
      ratingColor: ratingColorFor(state.userRating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        final cubit = context.read<MovieDetailsCubit>();
        return Scaffold(
          backgroundColor: WColors.background,
          body: MovieDetailsContent(
            movieTitle: movieTitle,
            movieImage: movieImage,
            rating: rating,
            isInWatchlist: state.isInWatchlist,
            isWatched: state.isWatched,
            userRating: state.userRating,
            showAllTags: state.showAllTags,
            showRatingSuccess: state.showRatingSuccess,
            onToggleWatchlist: cubit.toggleWatchlist,
            onToggleWatched: cubit.toggleWatched,
            onRate: cubit.updateRating,
            onToggleTags: cubit.toggleTags,
            onManageRankings: () => _openRankingsSheet(context, state),
          ),
        );
      },
    );
  }
}
