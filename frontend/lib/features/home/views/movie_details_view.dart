import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/common/widgets/states/on_reconnect.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/movie_details_cubit.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/home/viewmodels/movie_details_state.dart';
import 'package:cinemora/features/home/widgets/movie_details_content.dart';
import 'package:cinemora/features/home/widgets/post_rating_bottom_sheet.dart';

class MovieDetailsView extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String? backdropImage;
  final String rating;
  final int? tmdbId;

  const MovieDetailsView({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    this.backdropImage,
    required this.rating,
    this.tmdbId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieDetailsCubit(
        context.read<HomeRepository>(),
        context.read<LibraryRepository>(),
        context.read<LibraryCubit>(),
        tmdbId,
        title: movieTitle,
        posterUrl: movieImage,
        tmdbRating: double.tryParse(rating),
      ),
      child: _MovieDetailsContent(
        movieTitle: movieTitle,
        movieImage: movieImage,
        backdropImage: backdropImage,
        rating: rating,
        tmdbId: tmdbId,
      ),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String? backdropImage;
  final String rating;
  final int? tmdbId;

  const _MovieDetailsContent({
    required this.movieTitle,
    required this.movieImage,
    this.backdropImage,
    required this.rating,
    this.tmdbId,
  });

  void _showRankingsSheet(BuildContext context, MovieDetailsState state) {
    showPostRatingSheet(
      context,
      movieTitle: movieTitle,
      movieImage: movieImage,
      movieType: 'Movie',
      movieYear: state.detail?.year ?? '',
      userRating: state.userRating,
      ratingLabel: ratingLabelFor(state.userRating),
      ratingColor: ratingColorFor(state.userRating),
      genres: state.detail?.genres ?? [],
      tmdbId: tmdbId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MovieDetailsCubit, MovieDetailsState>(
      listenWhen: (prev, curr) =>
          (prev.userRating != curr.userRating && curr.userRating > 0) ||
          (!prev.isWatched && curr.isWatched) ||
          (curr.mutationError != null &&
              curr.mutationError != prev.mutationError),
      listener: (context, state) {
        if (state.mutationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mutationError!)),
          );
          context.read<MovieDetailsCubit>().clearMutationError();
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showRankingsSheet(context, state),
        );
      },
      builder: (context, state) {
        final cubit = context.read<MovieDetailsCubit>();
        return OnReconnect(
          onReconnect: () {
            if (state.hasDetailFailed) cubit.retryDetail();
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: MovieDetailsContent(
              movieTitle: movieTitle,
              movieImage: movieImage,
              backdropImage: backdropImage,
              rating: rating,
              movieId: tmdbId,
              detail: state.detail,
              isDetailLoading: state.isDetailLoading,
              hasDetailFailed: state.hasDetailFailed,
              onRetryDetail: cubit.retryDetail,
              isInWatchlist: state.isInWatchlist,
              isWatched: state.isWatched,
              userRating: state.userRating,
              showAllTags: state.showAllTags,
              showRatingSuccess: state.showRatingSuccess,
              onToggleWatchlist: cubit.toggleWatchlist,
              onToggleWatched: cubit.toggleWatched,
              onRate: cubit.updateRating,
              onToggleTags: cubit.toggleTags,
            ),
          ),
        );
      },
    );
  }
}
