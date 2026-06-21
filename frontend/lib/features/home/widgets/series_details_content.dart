import 'package:cinemora/core/models/cinema_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cinemora/common/widgets/buttons/circle_icon_button.dart';
import 'package:cinemora/common/widgets/dialogs/unmark_watched_dialog.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/common/widgets/buttons/pill_chip.dart';
import 'package:cinemora/common/widgets/buttons/toggle_action_button.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/features/home/views/trailer_player_screen.dart';
import 'package:cinemora/features/home/widgets/discover_chip.dart';
import 'package:cinemora/features/home/widgets/rating_meter.dart';

// ─── Root content widget ─────────────────────────────────────────────────────

class SeriesDetailsContent extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String? backdropImage;
  final String rating;
  final TmdbTvDetail? detail;
  final bool isDetailLoading;

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
  final VoidCallback onManageRankings;

  const SeriesDetailsContent({
    super.key,
    required this.seriesTitle,
    required this.seriesImage,
    this.backdropImage,
    required this.rating,
    this.detail,
    this.isDetailLoading = false,
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
    required this.onManageRankings,
  });

  SeriesSeason? get _currentSeason => seasons.isNotEmpty
      ? seasons[selectedSeasonIndex.clamp(0, seasons.length - 1)]
      : null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeriesHeroHeader(
            seriesTitle: seriesTitle,
            seriesImage: seriesImage,
            backdropImage: backdropImage,
            rating: rating,
            seasonCount: seasons.length,
            genres: detail?.genres ?? const [],
            yearRange: detail?.yearRange,
            creator: detail?.creator,
            isLoading: isDetailLoading,
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
                  context: context,
                ),
                SizedBox(height: 16.h),
                // Where to watch — hide spacer + divider when section is invisible
                if (isDetailLoading ||
                    (detail?.providers.isNotEmpty ?? false)) ...[
                  _WhereToWatchSection(
                    providers: detail?.providers,
                    isLoading: isDetailLoading,
                  ),
                  SizedBox(height: 20.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                ],
                _OverviewSection(
                  overview: detail?.overview,
                  isLoading: isDetailLoading,
                ),
                SizedBox(height: 20.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
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
                // Cast — hide spacer + divider when section is invisible
                if (isDetailLoading || (detail?.cast.isNotEmpty ?? false)) ...[
                  SizedBox(height: 24.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                  _CastSection(
                    cast: detail?.cast,
                    isLoading: isDetailLoading,
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: context.colors.border),
                  SizedBox(height: 16.h),
                ],
                _ShowRatingSection(
                  showRating: showRating,
                  onRate: onRateShow,
                  showRatingSuccess: showRatingSuccess,
                  onManageRankings: onManageRankings,
                ),
                SizedBox(height: 28.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
                _RecommendationsSection(seriesTitle: seriesTitle),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _SeriesHeroHeader extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String? backdropImage;
  final String rating;
  final int seasonCount;
  final List<String> genres;
  final String? yearRange;
  final String? creator;
  final bool isLoading;

  const _SeriesHeroHeader({
    required this.seriesTitle,
    required this.seriesImage,
    this.backdropImage,
    required this.rating,
    required this.seasonCount,
    required this.genres,
    this.yearRange,
    this.creator,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: WSizes.imageDetailsHeroHeight.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                backdropImage != null && backdropImage!.isNotEmpty
                    ? backdropImage!
                    : seriesImage,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  context.colors.background.withValues(alpha: 0.65),
                  context.colors.background.withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.3, 0.68, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w,
                vertical: 12.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WCircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    iconColor: Colors.white,
                  ),
                  WCircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared!')),
                    ),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    iconColor: Colors.white,
                    iconSize: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 24.w,
          right: 24.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: context.colors.tertiary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color:
                              context.colors.tertiary.withValues(alpha: 0.4)),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color:
                          context.colors.accentPurple.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: context.colors.accentPurple
                              .withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      'SERIES',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: context.colors.accentPurple,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Row(
                      children: genres.isNotEmpty
                          ? genres
                              .take(2)
                              .map((g) => Padding(
                                    padding: EdgeInsets.only(right: 6.w),
                                    child: WPillChip(text: g),
                                  ))
                              .toList()
                          : [
                              if (isLoading)
                                Container(
                                  width: 50.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                            ],
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
              if (creator != null && creator!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  'Created by $creator',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colors.mutedSecondaryDeep,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
              SizedBox(height: WSizes.sectionSpaceLg.h),
            ],
          ),
        ),
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
  final BuildContext context;

  const _ShowActionButtons({
    required this.showInWatchlist,
    required this.isShowWatched,
    required this.showRating,
    required this.onToggleShowWatchlist,
    required this.onToggleShowWatched,
    required this.seriesTitle,
    required this.context,
    this.trailerKey,
  });

  @override
  Widget build(BuildContext _) {
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
                unselectedIcon: isShowWatched ? Icons.replay_rounded : Icons.bookmark_add_outlined,
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
          _TrailerButton(
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

// ─── Where to watch ───────────────────────────────────────────────────────────

class _WhereToWatchSection extends StatelessWidget {
  final List<StreamingProvider>? providers;
  final bool isLoading;

  const _WhereToWatchSection({this.providers, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final list = providers ?? const [];
    if (!isLoading && list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WATCH NOW',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.accentRed,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          isLoading
              ? 'Checking platforms…'
              : 'Available on ${list.length} platform${list.length == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: isLoading
              ? _ProviderSkeletons()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, i) => _ProviderCard(provider: list[i]),
                ),
        ),
      ],
    );
  }
}

class _ProviderSkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, __) => Container(
          width: 98.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final StreamingProvider provider;

  const _ProviderCard({required this.provider});

  Future<void> _launch() async {
    final url = provider.webUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        width: 98.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(color: context.colors.borderStrong, width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProviderLogo(provider: provider),
                Icon(Icons.open_in_new_rounded,
                    size: 13.sp, color: context.colors.mutedSecondaryDeep),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    provider.type,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.mutedSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final StreamingProvider provider;

  const _ProviderLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final assetPath = provider.assetPath;
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          assetPath,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackLogo(provider: provider),
        ),
      );
    }
    if (provider.logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          provider.logoUrl!,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackLogo(provider: provider),
        ),
      );
    }
    return _FallbackLogo(provider: provider);
  }
}

class _FallbackLogo extends StatelessWidget {
  final StreamingProvider provider;

  const _FallbackLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        provider.name.isNotEmpty ? provider.name[0] : '?',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Overview ─────────────────────────────────────────────────────────────────

class _OverviewSection extends StatefulWidget {
  final String? overview;
  final bool isLoading;

  const _OverviewSection({this.overview, this.isLoading = false});

  @override
  State<_OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<_OverviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.overview ?? '';
    final hasText = text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: 10.h),
        if (widget.isLoading && !hasText)
          WShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: double.infinity),
                SizedBox(height: 6.h),
                _SkeletonLine(width: double.infinity),
                SizedBox(height: 6.h),
                _SkeletonLine(width: 200.w),
              ],
            ),
          )
        else ...[
          AnimatedCrossFade(
            firstChild: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.mutedForeground,
                height: 1.65,
              ),
            ),
            secondChild: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.mutedForeground,
                height: 1.65,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (hasText) ...[
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Read Less' : 'Read More',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
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
        _CompactStarBar(
          rating: displayRating,
          onRate: onRate,
          starColor: ratingColor,
        ),
      ],
    );
  }
}

class _CompactStarBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;
  final Color starColor;

  const _CompactStarBar({
    required this.rating,
    required this.onRate,
    required this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = 36.0.sp;
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        IconData icon;
        if (rating >= value) {
          icon = Icons.star_rounded;
        } else if (rating >= value - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        final slotWidth = size + 4.w;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final isLeftHalf = details.localPosition.dx < slotWidth / 2;
            onRate(isLeftHalf ? index + 0.5 : index + 1.0);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Icon(
              icon,
              size: size,
              color: rating >= value - 0.5 ? starColor : context.colors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Cast ─────────────────────────────────────────────────────────────────────

class _CastSection extends StatelessWidget {
  final List<CastMember>? cast;
  final bool isLoading;

  const _CastSection({this.cast, this.isLoading = false});

  static final _fallbackColors = [
    const Color(0xFF718096),
    const Color(0xFFEB4B6B),
    const Color(0xFFE0A838),
    const Color(0xFFE84B57),
    const Color(0xFF8C8C97),
  ];

  @override
  Widget build(BuildContext context) {
    final members = cast ?? const [];
    if (!isLoading && members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 130.h,
          child: isLoading && members.isEmpty
              ? _CastSkeletons()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                    final member = members[i];
                    final fallbackColor =
                        _fallbackColors[i % _fallbackColors.length];
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Column(
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.borderStrong,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: member.profileUrl != null
                                  ? Image.network(
                                      member.profileUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _InitialAvatar(
                                        name: member.name,
                                        color: fallbackColor,
                                      ),
                                    )
                                  : _InitialAvatar(
                                      name: member.name,
                                      color: fallbackColor,
                                    ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: 74.w,
                            child: Text(
                              member.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.foreground,
                                height: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          SizedBox(
                            width: 74.w,
                            child: Text(
                              member.character,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _InitialAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CastSkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Column(
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              _SkeletonLine(width: 60.w),
              SizedBox(height: 4.h),
              _SkeletonLine(width: 44.w),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton line ────────────────────────────────────────────────────────────

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

// ─── Overall show rating ──────────────────────────────────────────────────────

class _ShowRatingSection extends StatelessWidget {
  final double showRating;
  final ValueChanged<double> onRate;
  final bool showRatingSuccess;
  final VoidCallback onManageRankings;

  const _ShowRatingSection({
    required this.showRating,
    required this.onRate,
    required this.showRatingSuccess,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = showRating <= 0 ? 4.5 : showRating;
    final ratingColor = ratingColorFor(displayRating);
    final ratingLabel = ratingLabelFor(displayRating);
    final ratingEmoji = ratingEmojiFor(displayRating);
    const starSize = 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Overall Rating',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colors.foreground,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Rate the whole show',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: ratingColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                    color: ratingColor.withValues(alpha: 0.35), width: 0.6),
              ),
              child: Row(
                children: [
                  Text(
                    displayRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ratingColor,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.star_rounded, size: 12.sp, color: ratingColor),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: context.colors.surfaceTint.withValues(alpha: 0.18),
            borderRadius: BorderRadius.all(Radius.elliptical(20.r, 18.r)),
            border: Border.all(
              color: context.colors.surfaceChipBorder.withValues(alpha: 0.8),
              width: 0.7,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ratingEmoji, style: TextStyle(fontSize: 24.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    displayRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: ratingColor,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    ratingLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: ratingColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _FullStarBar(
                rating: displayRating,
                onRate: onRate,
                starColor: ratingColor,
                size: starSize.sp,
              ),
              SizedBox(height: 16.h),
              RatingMeter(
                rating: displayRating,
                starSize: starSize.sp,
                ratingColor: ratingColor,
              ),
              if (showRatingSuccess && showRating > 0) ...[
                SizedBox(height: 18.h),
                _RatingSuccessChip(
                  emoji: ratingEmoji,
                  ratingColor: ratingColor,
                  onManageRankings: onManageRankings,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingSuccessChip extends StatelessWidget {
  final String emoji;
  final Color ratingColor;
  final VoidCallback onManageRankings;

  const _RatingSuccessChip({
    required this.emoji,
    required this.ratingColor,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
        border: Border.all(color: ratingColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added to',
                  style: TextStyle(
                      fontSize: 10.sp, color: context.colors.mutedSecondary),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Best TV Shows',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: ratingColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onManageRankings,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: ratingColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                border: Border.all(color: ratingColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Manage Rankings',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: ratingColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullStarBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;
  final double size;
  final Color? starColor;

  const _FullStarBar({
    required this.rating,
    required this.onRate,
    required this.size,
    this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedStarColor = starColor ?? context.colors.border;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        IconData icon;
        if (rating >= value) {
          icon = Icons.star_rounded;
        } else if (rating >= value - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        final slotWidth = size + 4.w;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final isLeftHalf = details.localPosition.dx < slotWidth / 2;
            onRate(isLeftHalf ? index + 0.5 : index + 1.0);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Icon(
              icon,
              size: size,
              color: rating >= value - 0.5
                  ? resolvedStarColor
                  : context.colors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Recommendations ──────────────────────────────────────────────────────────

class _RecommendationsSection extends StatefulWidget {
  final String seriesTitle;

  const _RecommendationsSection({required this.seriesTitle});

  @override
  State<_RecommendationsSection> createState() =>
      _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<_RecommendationsSection> {
  int _selectedTab = 0;

  static const _tabs = [
    'Similar Titles',
    'Same Director',
    'Same Genre',
    'Trending Now',
  ];

  static const _items = [
    {
      'title': 'Game of Thrones',
      'rating': '9.2',
      'image':
          'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'The Last of Us',
      'rating': '8.8',
      'image':
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Succession',
      'rating': '8.9',
      'image':
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.accentRed,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Because You Loved This',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.foreground,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See all >',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: DiscoverChip(
                    label: _tabs[i],
                    selected: _selectedTab == i,
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: WSizes.imageCarouselHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) {
              return VerticalPosterBookmarkCard(
                title: _items[i]['title']!,
                rating: _items[i]['rating']!,
                image: _items[i]['image']!,
                width: WSizes.posterImageWidth.w,
                imageHeight: WSizes.posterImageHeight.h,
                cinemaType: CinemaType.tv,
                year: '2023',
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Trailer button ───────────────────────────────────────────────────────────

class _TrailerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TrailerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE84B57), Color(0xFFBF2D38)],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE84B57).withValues(alpha: 0.38),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  'WATCH TRAILER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
