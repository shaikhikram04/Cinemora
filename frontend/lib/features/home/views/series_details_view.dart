import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/series_details_cubit.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/home/viewmodels/series_details_state.dart';
import 'package:cinemora/features/home/widgets/post_rating_bottom_sheet.dart';
import 'package:cinemora/features/home/widgets/series_details_content.dart';

class SeriesDetailsView extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String? backdropImage;
  final String rating;
  final int? id;
  final String source;
  final int? focusSeason;

  const SeriesDetailsView({
    super.key,
    required this.seriesTitle,
    required this.seriesImage,
    this.backdropImage,
    required this.rating,
    this.id,
    this.source = 'tmdb',
    this.focusSeason,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SeriesDetailsCubit(
        repo: context.read<HomeRepository>(),
        library: context.read<LibraryRepository>(),
        libraryCubit: context.read<LibraryCubit>(),
        id: id,
        source: source,
        title: seriesTitle,
        posterUrl: seriesImage,
        tmdbRating: double.tryParse(rating),
        focusSeason: focusSeason,
      ),
      child: _SeriesDetailsContent(
        seriesTitle: seriesTitle,
        seriesImage: seriesImage,
        backdropImage: backdropImage,
        rating: rating,
      ),
    );
  }
}

class _SeriesDetailsContent extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String? backdropImage;
  final String rating;

  const _SeriesDetailsContent({
    required this.seriesTitle,
    required this.seriesImage,
    this.backdropImage,
    required this.rating,
  });

  void _openSeasonRatingSheet(
    BuildContext context,
    int seasonNumber,
    double rating,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPostRatingSheet(
        context,
        movieTitle: '$seriesTitle – Season $seasonNumber',
        movieImage: seriesImage,
        movieType: 'Series',
        userRating: rating,
        ratingLabel: ratingLabelFor(rating),
        ratingColor: ratingColorFor(rating),
      );
    });
  }

  void _openShowRankingsSheet(BuildContext context, SeriesDetailsState state) {
    showPostRatingSheet(
      context,
      movieTitle: seriesTitle,
      movieImage: seriesImage,
      movieType: 'Series',
      userRating: state.showRating,
      ratingLabel: ratingLabelFor(state.showRating),
      ratingColor: ratingColorFor(state.showRating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SeriesDetailsCubit, SeriesDetailsState>(
      listenWhen: (prev, curr) =>
          curr.mutationError != null && curr.mutationError != prev.mutationError,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.mutationError!)),
        );
        context.read<SeriesDetailsCubit>().clearMutationError();
      },
      builder: (context, state) {
        final cubit = context.read<SeriesDetailsCubit>();
        final seasons = state.seasons;
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SeriesDetailsContent(
            seriesTitle: seriesTitle,
            seriesImage: seriesImage,
            backdropImage: backdropImage,
            rating: rating,
            detail: state.detail,
            isDetailLoading: state.isDetailLoading,
            seasons: seasons,
            selectedSeasonIndex: state.selectedSeasonIndex,
            showInWatchlist: state.showInWatchlist,
            isShowWatched: state.isShowWatched,
            seasonsInWatchlist: state.seasonsInWatchlist,
            seasonsWatched: state.seasonsWatched,
            episodesWatched: state.episodesWatched,
            seasonRatings: state.seasonRatings,
            showRating: state.showRating,
            expandedSeasons: state.expandedSeasons,
            showRatingSuccess: state.showRatingSuccess,
            onSeasonSelected: cubit.selectSeason,
            onToggleShowWatchlist: cubit.toggleShowWatchlist,
            onToggleShowWatched: cubit.toggleShowWatched,
            onToggleSeasonWatchlist: cubit.toggleSeasonWatchlist,
            onToggleSeasonWatched: cubit.toggleSeasonWatched,
            onToggleEpisodeWatched: cubit.toggleEpisodeWatched,
            onRateSeason: (seasonNumber, r) {
              cubit.rateSeason(seasonNumber, r);
              _openSeasonRatingSheet(context, seasonNumber, r);
            },
            onRateShow: cubit.rateShow,
            onToggleSeasonExpanded: cubit.toggleSeasonExpanded,
            onManageRankings: () => _openShowRankingsSheet(context, state),
          ),
        );
      },
    );
  }
}
