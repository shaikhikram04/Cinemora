import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';
import 'package:watchary/features/home/models/series_season.dart';
import 'package:watchary/features/home/viewmodels/series_details_cubit.dart';
import 'package:watchary/features/home/viewmodels/series_details_state.dart';
import 'package:watchary/features/home/widgets/post_rating_bottom_sheet.dart';
import 'package:watchary/features/home/widgets/series_details_content.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kSeriesSeasons = [
  SeriesSeason(
    number: 1,
    year: '2022',
    rating: '8.5',
    episodes: [
      SeriesEpisode(
          number: 1, title: 'The Heirs of the Dragon', runtime: '66m'),
      SeriesEpisode(number: 2, title: 'The Rogue Prince', runtime: '54m'),
      SeriesEpisode(number: 3, title: 'Second of His Name', runtime: '56m'),
      SeriesEpisode(number: 4, title: 'King of the Narrow Sea', runtime: '58m'),
      SeriesEpisode(number: 5, title: 'We Light the Way', runtime: '53m'),
      SeriesEpisode(
          number: 6, title: 'The Princess and the Queen', runtime: '58m'),
      SeriesEpisode(number: 7, title: 'Driftmark', runtime: '55m'),
      SeriesEpisode(number: 8, title: 'The Lord of the Tides', runtime: '68m'),
      SeriesEpisode(number: 9, title: 'The Green Council', runtime: '60m'),
      SeriesEpisode(number: 10, title: 'The Black Queen', runtime: '69m'),
    ],
  ),
  SeriesSeason(
    number: 2,
    year: '2024',
    rating: '7.9',
    episodes: [
      SeriesEpisode(number: 1, title: 'A Son for a Son', runtime: '60m'),
      SeriesEpisode(number: 2, title: 'Rhaenyra the Cruel', runtime: '57m'),
      SeriesEpisode(number: 3, title: 'The Burning Mill', runtime: '55m'),
      SeriesEpisode(
          number: 4, title: 'The Red Dragon and the Gold', runtime: '59m'),
      SeriesEpisode(number: 5, title: 'Regent', runtime: '57m'),
      SeriesEpisode(number: 6, title: 'Smallfolk', runtime: '62m'),
      SeriesEpisode(number: 7, title: 'The Red Sowing', runtime: '58m'),
      SeriesEpisode(number: 8, title: 'The Meaning of Kings', runtime: '60m'),
    ],
  ),
];

// ─── View ─────────────────────────────────────────────────────────────────────

class SeriesDetailsView extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String rating;
  final List<SeriesSeason> seasons;

  const SeriesDetailsView({
    super.key,
    required this.seriesTitle,
    required this.seriesImage,
    required this.rating,
    this.seasons = _kSeriesSeasons,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SeriesDetailsCubit(seasons: seasons),
      child: _SeriesDetailsContent(
        seriesTitle: seriesTitle,
        seriesImage: seriesImage,
        rating: rating,
        seasons: seasons,
      ),
    );
  }
}

class _SeriesDetailsContent extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String rating;
  final List<SeriesSeason> seasons;

  const _SeriesDetailsContent({
    required this.seriesTitle,
    required this.seriesImage,
    required this.rating,
    required this.seasons,
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
    return BlocBuilder<SeriesDetailsCubit, SeriesDetailsState>(
      builder: (context, state) {
        final cubit = context.read<SeriesDetailsCubit>();
        return Scaffold(
          backgroundColor: WColors.background,
          body: SeriesDetailsContent(
            seriesTitle: seriesTitle,
            seriesImage: seriesImage,
            rating: rating,
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
            onRateSeason: (seasonNumber, rating) {
              cubit.rateSeason(seasonNumber, rating);
              _openSeasonRatingSheet(context, seasonNumber, rating);
            },
            onRateShow: (rating) {
              cubit.rateShow(rating);
            },
            onToggleSeasonExpanded: cubit.toggleSeasonExpanded,
            onManageRankings: () => _openShowRankingsSheet(context, state),
          ),
        );
      },
    );
  }
}
