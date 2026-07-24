import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemora/common/widgets/buttons/toggle_action_button.dart';
import 'package:cinemora/common/widgets/buttons/trailer_button.dart';
import 'package:cinemora/common/widgets/detail/cast_section.dart';
import 'package:cinemora/common/widgets/detail/crew_section.dart';
import 'package:cinemora/common/widgets/detail/detail_hero_shell.dart';
import 'package:cinemora/common/widgets/detail/detail_rating_section.dart';
import 'package:cinemora/common/widgets/detail/detail_recommendations_section.dart';
import 'package:cinemora/common/widgets/detail/franchise_banner_section.dart';
import 'package:cinemora/common/widgets/detail/genres_section.dart';
import 'package:cinemora/common/widgets/detail/overview_section.dart';
import 'package:cinemora/common/widgets/detail/where_to_watch_section.dart';
import 'package:cinemora/common/widgets/dialogs/unmark_watched_dialog.dart';
import 'package:cinemora/common/widgets/states/w_error_state.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/features/home/views/trailer_player_screen.dart';

class MovieDetailsContent extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String? backdropImage;
  final String rating;
  final int? movieId;
  final TmdbMovieDetail? detail;
  final bool isDetailLoading;
  final bool hasDetailFailed;
  final VoidCallback? onRetryDetail;
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final bool showAllTags;
  final bool showRatingSuccess;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleWatched;
  final ValueChanged<double> onRate;
  final VoidCallback onToggleTags;

  const MovieDetailsContent({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    this.backdropImage,
    required this.rating,
    this.movieId,
    this.detail,
    this.isDetailLoading = false,
    this.hasDetailFailed = false,
    this.onRetryDetail,
    required this.isInWatchlist,
    required this.isWatched,
    required this.userRating,
    required this.showAllTags,
    required this.showRatingSuccess,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
    required this.onRate,
    required this.onToggleTags,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = backdropImage != null && backdropImage!.isNotEmpty
        ? backdropImage!
        : movieImage;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeroShell(
            imageUrl: imageUrl,
            bottomContent: _MovieHeroMeta(
              movieTitle: movieTitle,
              rating: rating,
              runtime: detail?.runtime,
              year: detail?.year,
              director: detail?.director,
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActionButtons(
                  isInWatchlist: isInWatchlist,
                  isWatched: isWatched,
                  userRating: userRating,
                  onToggleWatchlist: onToggleWatchlist,
                  onToggleWatched: onToggleWatched,
                  movieTitle: movieTitle,
                  trailerKey: detail?.trailerKey,
                ),
                SizedBox(height: 16.h),
                // Everything below is driven by the TMDB detail fetch. Without
                // it there is nothing to lay out, so say so instead of
                // rendering a page that looks like the movie simply has no
                // cast, no overview and no genres. The hero and the action
                // buttons stay — that data came from the previous screen and
                // from the local library, and both still work.
                if (hasDetailFailed) ...[
                  WErrorState.card(
                    message: "Couldn't load the details for this title.",
                    onRetry: onRetryDetail,
                  ),
                  SizedBox(height: 24.h),
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
                  if (isDetailLoading ||
                      (detail?.cast.isNotEmpty ?? false)) ...[
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
                  if (detail?.collection != null) ...[
                    _FranchiseBanner(collection: detail!.collection!),
                    SizedBox(height: 16.h),
                    Divider(color: context.colors.border),
                    SizedBox(height: 16.h),
                  ],
                  DetailRatingSection(
                    title: 'Your Rating',
                    subtitle: 'Tap star halves to rate',
                    rating: userRating,
                    showRatingSuccess: showRatingSuccess,
                    rankingLabel: 'All-Time Favorites',
                    onRate: onRate,
                  ),
                  SizedBox(height: 28.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                  DetailRecommendationsSection(
                    cinemaType: CinemaType.movie,
                    sourceId: movieId,
                  ),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Franchise banner ─────────────────────────────────────────────────────────

class _FranchiseBanner extends StatelessWidget {
  final FranchiseSummary collection;

  const _FranchiseBanner({required this.collection});

  @override
  Widget build(BuildContext context) {
    return FranchiseBannerSection(
      collection: collection,
      onTap: () => context.push(
        AppRoutes.franchiseDetail,
        extra: FranchiseRouteArgs(
          collectionId: collection.id,
          name: collection.name,
          backdropUrl: collection.backdropUrl,
        ),
      ),
    );
  }
}

// ─── Movie hero metadata ──────────────────────────────────────────────────────

class _MovieHeroMeta extends StatelessWidget {
  final String movieTitle;
  final String rating;
  final String? runtime;
  final String? year;
  final String? director;

  const _MovieHeroMeta({
    required this.movieTitle,
    required this.rating,
    this.runtime,
    this.year,
    this.director,
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
                color: context.colors.accentRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: context.colors.accentRed.withValues(alpha: 0.4)),
              ),
              child: Text(
                'MOVIE',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colors.accentRed,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          movieTitle,
          style: TextStyle(
            fontSize: WSizes.fontSize3xl.sp,
            fontWeight: FontWeight.w800,
            color: context.colors.foreground,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          _buildMetaLine(),
          style: TextStyle(
            fontSize: 13.sp,
            color: context.colors.mutedForeground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: WSizes.sectionSpaceLg.h),
      ],
    );
  }

  String _buildMetaLine() {
    if (year == null && runtime == null) return '';
    final parts = <String>[];
    if (year != null && year!.isNotEmpty) parts.add(year!);
    if (runtime != null) parts.add(runtime!);
    return parts.join('  •  ');
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleWatched;
  final String? trailerKey;
  final String movieTitle;

  const _ActionButtons({
    required this.isInWatchlist,
    required this.isWatched,
    required this.userRating,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
    required this.movieTitle,
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
                selected: isInWatchlist,
                selectedLabel: 'In Watchlist',
                unselectedLabel: isWatched ? 'Rewatch' : 'Add to Watchlist',
                selectedIcon: Icons.bookmark,
                unselectedIcon:
                    isWatched ? Icons.replay_rounded : Icons.bookmark_outline,
                onTap: onToggleWatchlist,
                selectedBackground:
                    context.colors.primary.withValues(alpha: 0.14),
                unselectedBackground: isWatched
                    ? context.colors.chartBlue.withValues(alpha: 0.1)
                    : context.colors.accentRed.withValues(alpha: 0.9),
                selectedBorder: context.colors.primary,
                unselectedBorder: isWatched
                    ? context.colors.chartBlue.withValues(alpha: 0.5)
                    : context.colors.border,
                selectedForeground: context.colors.primary,
                unselectedForeground: isWatched
                    ? context.colors.chartBlue
                    : context.colors.primaryForeground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ToggleActionButton(
                selected: isWatched,
                selectedLabel: 'Watched',
                unselectedLabel: 'Mark Watched',
                selectedIcon: Icons.check_circle,
                unselectedIcon: Icons.check_circle_outline,
                onTap: isWatched
                    ? () => showUnmarkWatchedDialog(context,
                        onConfirm: onToggleWatched, userRating: userRating)
                    : onToggleWatched,
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
        SizedBox(height: 12.h),
        if (trailerKey != null)
          TrailerButton(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrailerPlayerScreen(
                  trailerKey: trailerKey!,
                  title: movieTitle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
