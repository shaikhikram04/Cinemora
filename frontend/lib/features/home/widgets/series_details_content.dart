import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/toggle_action_button.dart';
import 'package:cinemora/common/widgets/buttons/trailer_button.dart';
import 'package:cinemora/common/widgets/states/w_error_state.dart';
import 'package:cinemora/common/widgets/detail/cast_section.dart';
import 'package:cinemora/common/widgets/detail/crew_section.dart';
import 'package:cinemora/common/widgets/detail/detail_hero_shell.dart';
import 'package:cinemora/common/widgets/detail/detail_rating_section.dart';
import 'package:cinemora/common/widgets/detail/detail_recommendations_section.dart';
import 'package:cinemora/common/widgets/detail/genres_section.dart';
import 'package:cinemora/common/widgets/detail/overview_section.dart';
import 'package:cinemora/common/widgets/detail/where_to_watch_section.dart';
import 'package:cinemora/common/widgets/dialogs/unmark_watched_dialog.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/features/home/views/trailer_player_screen.dart';
import 'package:cinemora/common/widgets/rating/star_rating_bar.dart';

// ─── Root content widget ─────────────────────────────────────────────────────

class SeriesDetailsContent extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String? backdropImage;
  final String rating;
  final String source;
  final int? seriesId;
  final TmdbTvDetail? detail;
  final bool isDetailLoading;
  final bool hasDetailFailed;
  final VoidCallback? onRetryDetail;

  final List<SeriesSeason> seasons;
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

  final ValueChanged<int> onSeasonSelected;
  final VoidCallback onToggleShowWatchlist;
  final VoidCallback onToggleShowWatched;
  final ValueChanged<int> onToggleSeasonWatchlist;
  final ValueChanged<int> onToggleSeasonWatched;
  final ValueChanged<String> onToggleEpisodeWatched;
  final void Function(int season, double rating) onRateSeason;
  final ValueChanged<double> onRateShow;
  final ValueChanged<int> onToggleSeasonExpanded;

  const SeriesDetailsContent({
    super.key,
    required this.seriesTitle,
    required this.seriesImage,
    this.backdropImage,
    required this.rating,
    this.source = 'tmdb',
    this.seriesId,
    this.detail,
    this.isDetailLoading = false,
    this.hasDetailFailed = false,
    this.onRetryDetail,
    required this.seasons,
    required this.selectedSeasonIndex,
    required this.showInWatchlist,
    required this.isShowWatched,
    required this.seasonsInWatchlist,
    required this.seasonsWatched,
    required this.episodesWatched,
    required this.seasonRatings,
    required this.showRating,
    required this.expandedSeasons,
    required this.showRatingSuccess,
    required this.onSeasonSelected,
    required this.onToggleShowWatchlist,
    required this.onToggleShowWatched,
    required this.onToggleSeasonWatchlist,
    required this.onToggleSeasonWatched,
    required this.onToggleEpisodeWatched,
    required this.onRateSeason,
    required this.onRateShow,
    required this.onToggleSeasonExpanded,
  });

  SeriesSeason? get _currentSeason => seasons.isNotEmpty
      ? seasons[selectedSeasonIndex.clamp(0, seasons.length - 1)]
      : null;

  @override
  Widget build(BuildContext context) {
    final imageUrl = backdropImage != null && backdropImage!.isNotEmpty
        ? backdropImage!
        : seriesImage;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeroShell(
            imageUrl: imageUrl,
            bottomContent: _SeriesHeroMeta(
              seriesTitle: seriesTitle,
              rating: rating,
              isAnime: source != 'tmdb',
              seasonCount: seasons.length,
              yearRange: detail?.yearRange,
              creator: detail?.creator,
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShowActionButtons(
                  showInWatchlist: showInWatchlist,
                  isShowWatched: isShowWatched,
                  showRating: showRating,
                  onToggleShowWatchlist: onToggleShowWatchlist,
                  onToggleShowWatched: onToggleShowWatched,
                  seriesTitle: seriesTitle,
                  trailerKey: detail?.trailerKey,
                ),
                SizedBox(height: 16.h),
                // Everything below is driven by the detail fetch. Without it
                // there is nothing to lay out, so say so instead of rendering
                // a page that looks like the show simply has no seasons, no
                // cast and no overview. The hero and the action buttons stay —
                // that data came from the previous screen and from the local
                // library, and both still work.
                if (hasDetailFailed) ...[
                  WErrorState.card(
                    message: "Couldn't load the details for this title.",
                    onRetry: onRetryDetail,
                  ),
                  SizedBox(height: 32.h),
                ] else ...[
                  if (isDetailLoading ||
                      (detail?.providers.isNotEmpty ?? false)) ...[
                    WhereToWatchSection(
                      providers: detail?.providers,
                      isLoading: isDetailLoading,
                    ),
                    SizedBox(height: 20.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                  ],
                  OverviewSection(
                    overview: detail?.overview,
                    isLoading: isDetailLoading,
                  ),
                  SizedBox(height: 20.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                  if (isDetailLoading ||
                      (detail?.genres.isNotEmpty ?? false)) ...[
                    GenresSection(
                      genres: detail?.genres ?? const [],
                      isLoading: isDetailLoading,
                    ),
                    SizedBox(height: 20.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                  ],
                  if (seasons.isEmpty && isDetailLoading)
                    _SeasonsSkeleton()
                  else if (_currentSeason != null)
                    _SeasonsSection(
                      seasons: seasons,
                      selectedSeasonIndex: selectedSeasonIndex,
                      currentSeason: _currentSeason!,
                      seasonsInWatchlist: seasonsInWatchlist,
                      seasonsWatched: seasonsWatched,
                      episodesWatched: episodesWatched,
                      seasonRatings: seasonRatings,
                      expandedSeasons: expandedSeasons,
                      onSeasonSelected: onSeasonSelected,
                      onToggleSeasonWatchlist: onToggleSeasonWatchlist,
                      onToggleSeasonWatched: onToggleSeasonWatched,
                      onToggleEpisodeWatched: onToggleEpisodeWatched,
                      onRateSeason: onRateSeason,
                      onToggleSeasonExpanded: onToggleSeasonExpanded,
                    ),
                  if (isDetailLoading ||
                      (detail?.cast.isNotEmpty ?? false)) ...[
                    SizedBox(height: 24.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                    CastSection(
                      cast: detail?.cast,
                      isLoading: isDetailLoading,
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                  ],
                  if (isDetailLoading ||
                      (detail?.crew.isNotEmpty ?? false)) ...[
                    CrewSection(
                      crew: detail?.crew,
                      isLoading: isDetailLoading,
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                  ],
                  DetailRatingSection(
                    title: 'Your Overall Rating',
                    subtitle: 'Rate the whole show',
                    rating: showRating,
                    showRatingSuccess: showRatingSuccess,
                    rankingLabel: 'Best TV Shows',
                    onRate: onRateShow,
                  ),
                  SizedBox(height: 28.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                  DetailRecommendationsSection(
                    cinemaType:
                        source == 'tmdb' ? CinemaType.tv : CinemaType.anime,
                    sourceId: seriesId,
                  ),
                  SizedBox(height: 32.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Series hero metadata ─────────────────────────────────────────────────────

class _SeriesHeroMeta extends StatelessWidget {
  final String seriesTitle;
  final String rating;
  final bool isAnime;
  final int seasonCount;
  final String? yearRange;
  final String? creator;

  const _SeriesHeroMeta({
    required this.seriesTitle,
    required this.rating,
    this.isAnime = false,
    required this.seasonCount,
    this.yearRange,
    this.creator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: context.colors.tertiary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: context.colors.tertiary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded,
                      color: context.colors.tertiary, size: 11.sp),
                  SizedBox(width: 4.w),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: context.colors.accentPurple.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: context.colors.accentPurple.withValues(alpha: 0.45)),
              ),
              child: Text(
                isAnime ? 'ANIME' : 'SERIES',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colors.accentPurple,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          seriesTitle,
          style: TextStyle(
            fontSize: WSizes.fontSize3xl.sp,
            fontWeight: FontWeight.w800,
            color: context.colors.foreground,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            if (seasonCount > 0) ...[
              Icon(Icons.layers_rounded,
                  size: 13.sp, color: context.colors.mutedSecondary),
              SizedBox(width: 4.w),
              Text(
                '$seasonCount Season${seasonCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (yearRange != null && yearRange!.isNotEmpty)
                Text(
                  '  •  $yearRange',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colors.mutedForeground,
                  ),
                ),
            ] else if (yearRange != null && yearRange!.isNotEmpty)
              Text(
                yearRange!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colors.mutedForeground,
                ),
              ),
          ],
        ),
        SizedBox(height: WSizes.sectionSpaceLg.h),
      ],
    );
  }
}

// ─── Show-level action buttons ────────────────────────────────────────────────

class _ShowActionButtons extends StatelessWidget {
  final bool showInWatchlist;
  final bool isShowWatched;
  final double showRating;
  final VoidCallback onToggleShowWatchlist;
  final VoidCallback onToggleShowWatched;
  final String seriesTitle;
  final String? trailerKey;

  const _ShowActionButtons({
    required this.showInWatchlist,
    required this.isShowWatched,
    required this.showRating,
    required this.onToggleShowWatchlist,
    required this.onToggleShowWatched,
    required this.seriesTitle,
    this.trailerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ToggleActionButton(
                selected: showInWatchlist,
                selectedLabel: 'In Watchlist',
                unselectedLabel: isShowWatched ? 'Rewatch' : 'Add to Watchlist',
                selectedIcon: Icons.bookmark_rounded,
                unselectedIcon: isShowWatched
                    ? Icons.replay_rounded
                    : Icons.bookmark_add_outlined,
                onTap: onToggleShowWatchlist,
                selectedBackground:
                    context.colors.primary.withValues(alpha: 0.14),
                unselectedBackground: isShowWatched
                    ? context.colors.chartBlue.withValues(alpha: 0.1)
                    : context.colors.accentRed.withValues(alpha: 0.9),
                selectedBorder: context.colors.primary,
                unselectedBorder: isShowWatched
                    ? context.colors.chartBlue.withValues(alpha: 0.5)
                    : context.colors.border,
                selectedForeground: context.colors.primary,
                unselectedForeground: isShowWatched
                    ? context.colors.chartBlue
                    : context.colors.primaryForeground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ToggleActionButton(
                selected: isShowWatched,
                selectedLabel: 'Watched',
                unselectedLabel: 'Mark Watched',
                selectedIcon: Icons.check_circle_rounded,
                unselectedIcon: Icons.check_circle_outline_rounded,
                onTap: isShowWatched
                    ? () => showUnmarkWatchedDialog(context,
                        onConfirm: onToggleShowWatched, userRating: showRating)
                    : onToggleShowWatched,
                selectedBackground:
                    context.colors.success.withValues(alpha: 0.1),
                unselectedBackground:
                    context.colors.surfaceOverlay.withValues(alpha: 0.15),
                selectedBorder: context.colors.success,
                unselectedBorder: context.colors.border,
                selectedForeground: context.colors.success,
                unselectedForeground: context.colors.foreground,
              ),
            ),
          ],
        ),
        if (trailerKey != null) ...[
          SizedBox(height: 12.h),
          TrailerButton(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrailerPlayerScreen(
                  trailerKey: trailerKey!,
                  title: seriesTitle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Seasons skeleton ─────────────────────────────────────────────────────────

class _SeasonsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonLine(width: 70.w),
              SizedBox(width: 8.w),
              Container(
                width: 24.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Container(
                  width: 80.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;

  const _SkeletonLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}

// ─── Seasons section ──────────────────────────────────────────────────────────

class _SeasonsSection extends StatelessWidget {
  final List<SeriesSeason> seasons;
  final int selectedSeasonIndex;
  final SeriesSeason currentSeason;
  final List<int> seasonsInWatchlist;
  final List<int> seasonsWatched;
  final List<String> episodesWatched;
  final Map<int, double> seasonRatings;
  final List<int> expandedSeasons;
  final ValueChanged<int> onSeasonSelected;
  final ValueChanged<int> onToggleSeasonWatchlist;
  final ValueChanged<int> onToggleSeasonWatched;
  final ValueChanged<String> onToggleEpisodeWatched;
  final void Function(int season, double rating) onRateSeason;
  final ValueChanged<int> onToggleSeasonExpanded;

  const _SeasonsSection({
    required this.seasons,
    required this.selectedSeasonIndex,
    required this.currentSeason,
    required this.seasonsInWatchlist,
    required this.seasonsWatched,
    required this.episodesWatched,
    required this.seasonRatings,
    required this.expandedSeasons,
    required this.onSeasonSelected,
    required this.onToggleSeasonWatchlist,
    required this.onToggleSeasonWatched,
    required this.onToggleEpisodeWatched,
    required this.onRateSeason,
    required this.onToggleSeasonExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final inWatchlist = seasonsInWatchlist.contains(currentSeason.number);
    final isWatched = seasonsWatched.contains(currentSeason.number);
    final isExpanded = expandedSeasons.contains(currentSeason.number);
    final currentRating = seasonRatings[currentSeason.number] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SEASONS',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: context.colors.accentRed,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: context.colors.surfaceRaised,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: context.colors.borderStrong),
              ),
              child: Text(
                '${seasons.length}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.mutedSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(seasons.length, (i) {
              final s = seasons[i];
              final selected = i == selectedSeasonIndex;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onSeasonSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.colors.primary
                          : context.colors.surfaceChip,
                      borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                      border: Border.all(
                        color: selected
                            ? context.colors.primary
                            : context.colors.surfaceChipBorder,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: context.colors.primary
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Season ${s.number}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : context.colors.mutedSecondary,
                            fontSize: 13.sp,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          s.year,
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.85)
                                : context.colors.mutedSecondaryDeep,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised,
            borderRadius: BorderRadius.circular(WSizes.radius3xl.r),
            border: Border.all(color: context.colors.borderStrong),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Season ${currentSeason.number}',
                            style: TextStyle(
                              color: context.colors.foreground,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              _MetaPill(
                                icon: Icons.calendar_today_rounded,
                                label: currentSeason.year,
                              ),
                              SizedBox(width: 6.w),
                              _MetaPill(
                                icon: Icons.play_circle_outline_rounded,
                                label: '${currentSeason.episodeCount} episodes',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: context.colors.tertiary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                            color: context.colors.tertiary
                                .withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: context.colors.tertiary, size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            currentSeason.rating,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: context.colors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ToggleActionButton(
                        selected: inWatchlist,
                        selectedLabel: 'In Watchlist',
                        unselectedLabel: 'Add Season',
                        selectedIcon: Icons.bookmark_rounded,
                        unselectedIcon: Icons.bookmark_add_outlined,
                        onTap: () =>
                            onToggleSeasonWatchlist(currentSeason.number),
                        selectedBackground:
                            context.colors.primary.withValues(alpha: 0.14),
                        unselectedBackground: context.colors.surfaceMuted,
                        selectedBorder: context.colors.primary,
                        unselectedBorder: context.colors.borderStrong,
                        selectedForeground: context.colors.primary,
                        unselectedForeground: context.colors.mutedSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ToggleActionButton(
                        selected: isWatched,
                        selectedLabel: 'Watched',
                        unselectedLabel: 'Mark Watched',
                        selectedIcon: Icons.check_circle_rounded,
                        unselectedIcon: Icons.check_circle_outline_rounded,
                        onTap: () =>
                            onToggleSeasonWatched(currentSeason.number),
                        selectedBackground:
                            context.colors.success.withValues(alpha: 0.1),
                        unselectedBackground: context.colors.surfaceMuted,
                        selectedBorder: context.colors.success,
                        unselectedBorder: context.colors.borderStrong,
                        selectedForeground: context.colors.success,
                        unselectedForeground: context.colors.mutedSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      'EPISODES',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.mutedSecondaryDeep,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                        child:
                            Container(height: 1, color: context.colors.border)),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              _EpisodeList(
                season: currentSeason,
                episodesWatched: episodesWatched,
                isExpanded: isExpanded,
                onToggleEpisodeWatched: onToggleEpisodeWatched,
                onToggleExpanded: () =>
                    onToggleSeasonExpanded(currentSeason.number),
              ),
              const _SeasonRatingDivider(),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: _SeasonRatingSection(
                  seasonNumber: currentSeason.number,
                  rating: currentRating,
                  onRate: (r) => onRateSeason(currentSeason.number, r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceBorderAlt,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: context.colors.mutedSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.mutedSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Episode list ─────────────────────────────────────────────────────────────

class _EpisodeList extends StatelessWidget {
  final SeriesSeason season;
  final List<String> episodesWatched;
  final bool isExpanded;
  final ValueChanged<String> onToggleEpisodeWatched;
  final VoidCallback onToggleExpanded;

  static const _collapsedCount = 3;

  const _EpisodeList({
    required this.season,
    required this.episodesWatched,
    required this.isExpanded,
    required this.onToggleEpisodeWatched,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = season.episodes;
    final visibleEpisodes =
        isExpanded ? episodes : episodes.take(_collapsedCount).toList();
    final remaining = episodes.length - _collapsedCount;

    return Column(
      children: [
        ...visibleEpisodes.map((ep) {
          final key = 'S${season.number}E${ep.number}';
          final watched = episodesWatched.contains(key);
          return _EpisodeRow(
            episode: ep,
            watched: watched,
            onToggle: () => onToggleEpisodeWatched(key),
          );
        }),
        if (episodes.length > _collapsedCount)
          GestureDetector(
            onTap: onToggleExpanded,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded
                        ? 'Show less'
                        : 'Show $remaining more episode${remaining > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.accentRed,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: context.colors.accentRed,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  final SeriesEpisode episode;
  final bool watched;
  final VoidCallback onToggle;

  const _EpisodeRow({
    required this.episode,
    required this.watched,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 22.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: watched
                    ? context.colors.success.withValues(alpha: 0.12)
                    : context.colors.surfaceBorderAlt,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: watched
                      ? context.colors.success.withValues(alpha: 0.4)
                      : context.colors.border,
                ),
              ),
              child: Text(
                'E${episode.number}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: watched
                      ? context.colors.success
                      : context.colors.mutedSecondaryDeep,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                episode.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: watched
                      ? context.colors.mutedSecondary
                      : context.colors.foreground,
                  decoration: watched ? TextDecoration.lineThrough : null,
                  decorationColor: context.colors.mutedSecondary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              episode.runtime,
              style: TextStyle(
                fontSize: 11.sp,
                color: context.colors.mutedSecondaryDeep,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10.w),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                watched
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(watched),
                size: 20.sp,
                color: watched
                    ? context.colors.success
                    : context.colors.mutedSecondaryDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonRatingDivider extends StatelessWidget {
  const _SeasonRatingDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            'RATE SEASON',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.mutedSecondaryDeep,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Container(height: 1, color: context.colors.border)),
        ],
      ),
    );
  }
}

// ─── Season rating ────────────────────────────────────────────────────────────

class _SeasonRatingSection extends StatelessWidget {
  final int seasonNumber;
  final double rating;
  final ValueChanged<double> onRate;

  const _SeasonRatingSection({
    required this.seasonNumber,
    required this.rating,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final hasRated = rating > 0;
    final displayRating = hasRated ? rating : 0.0;
    final ratingColor = hasRated
        ? ratingColorFor(displayRating)
        : context.colors.mutedSecondaryDeep;
    final ratingLabel =
        hasRated ? ratingLabelFor(displayRating) : 'Tap to rate';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Season $seasonNumber Rating',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.foreground,
              ),
            ),
            if (hasRated)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: ratingColor.withValues(alpha: 0.35), width: 0.6),
                ),
                child: Row(
                  children: [
                    Text(
                      displayRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(Icons.star_rounded, size: 11.sp, color: ratingColor),
                  ],
                ),
              )
            else
              Text(
                ratingLabel,
                style: TextStyle(
                    fontSize: 11.sp, color: context.colors.mutedSecondaryDeep),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        StarRatingBar(
          rating: displayRating,
          onRate: onRate,
          size: 36.0.sp,
          starColor: ratingColor,
        ),
      ],
    );
  }
}
