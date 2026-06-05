import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/buttons/action_button.dart';
import 'package:watchary/common/widgets/buttons/circle_icon_button.dart';
import 'package:watchary/common/widgets/buttons/pill_chip.dart';
import 'package:watchary/common/widgets/buttons/toggle_action_button.dart';
import 'package:watchary/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class SeriesEpisode {
  final int number;
  final String title;
  final String runtime;

  const SeriesEpisode({
    required this.number,
    required this.title,
    required this.runtime,
  });
}

class SeriesSeason {
  final int number;
  final String year;
  final String rating;
  final List<SeriesEpisode> episodes;

  const SeriesSeason({
    required this.number,
    required this.year,
    required this.rating,
    required this.episodes,
  });

  int get episodeCount => episodes.length;
}

// ─── Root content widget ─────────────────────────────────────────────────────

class SeriesDetailsContent extends StatelessWidget {
  final String seriesTitle;
  final String seriesImage;
  final String rating;
  final List<SeriesSeason> seasons;

  // State
  final int selectedSeasonIndex;
  final bool showInWatchlist;
  final bool isShowWatched;
  final Set<int> seasonsInWatchlist;
  final Set<int> seasonsWatched;
  final Set<String> episodesWatched;
  final Map<int, double> seasonRatings;
  final double showRating;
  final Set<int> expandedSeasons;
  final bool showRatingSuccess;

  // Callbacks
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
    required this.rating,
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

  SeriesSeason get _currentSeason => seasons[selectedSeasonIndex];

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
            rating: rating,
            seasonCount: seasons.length,
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
                  onToggleShowWatchlist: onToggleShowWatchlist,
                  onToggleShowWatched: onToggleShowWatched,
                  context: context,
                ),
                SizedBox(height: 16.h),
                const _WhereToWatchSection(),
                SizedBox(height: 20.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                const _OverviewSection(),
                SizedBox(height: 20.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                _SeasonsSection(
                  seasons: seasons,
                  selectedSeasonIndex: selectedSeasonIndex,
                  currentSeason: _currentSeason,
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
                SizedBox(height: 24.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                const _CastSection(),
                SizedBox(height: 16.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                _ShowRatingSection(
                  showRating: showRating,
                  onRate: onRateShow,
                  showRatingSuccess: showRatingSuccess,
                  onManageRankings: onManageRankings,
                ),
                SizedBox(height: 28.h),
                const Divider(color: WColors.border),
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
  final String rating;
  final int seasonCount;

  const _SeriesHeroHeader({
    required this.seriesTitle,
    required this.seriesImage,
    required this.rating,
    required this.seasonCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: WSizes.imageDetailsHeroHeight.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(seriesImage),
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
                  WColors.background.withValues(alpha: 0.65),
                  WColors.background.withValues(alpha: 0.96),
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
              // Badges row
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: WColors.tertiary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: WColors.tertiary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: WColors.tertiary, size: 11.sp),
                        SizedBox(width: 4.w),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: WColors.tertiary,
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
                      color: WColors.accentPurple.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: WColors.accentPurple.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      'SERIES',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: WColors.accentPurple,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Expanded(
                    child: Row(
                      children: [
                        WPillChip(text: 'Fantasy'),
                        SizedBox(width: 6),
                        WPillChip(text: 'Drama'),
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
                  color: WColors.foreground,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Icon(Icons.layers_rounded,
                      size: 13.sp, color: WColors.mutedSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    '$seasonCount Season${seasonCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: WColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '  •  2022 – Present',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: WColors.mutedForeground,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Created by Ryan Condal',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: WColors.mutedSecondaryDeep,
                  fontFamily: 'Inter',
                ),
              ),
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
  final VoidCallback onToggleShowWatchlist;
  final VoidCallback onToggleShowWatched;
  final BuildContext context;

  const _ShowActionButtons({
    required this.showInWatchlist,
    required this.isShowWatched,
    required this.onToggleShowWatchlist,
    required this.onToggleShowWatched,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WToggleActionButton(
                selected: showInWatchlist,
                selectedLabel: 'In Watchlist',
                unselectedLabel: 'Add to Watchlist',
                selectedIcon: Icons.bookmark_rounded,
                unselectedIcon: Icons.bookmark_add_outlined,
                onTap: onToggleShowWatchlist,
                selectedBackground: WColors.primary.withValues(alpha: 0.14),
                unselectedBackground: WColors.accentRed.withValues(alpha: 0.9),
                selectedBorder: WColors.primary,
                unselectedBorder: WColors.border,
                selectedForeground: WColors.primary,
                unselectedForeground: WColors.primaryForeground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: WToggleActionButton(
                selected: isShowWatched,
                selectedLabel: 'Watched',
                unselectedLabel: 'Mark Watched',
                selectedIcon: Icons.check_circle_rounded,
                unselectedIcon: Icons.check_circle_outline_rounded,
                onTap: onToggleShowWatched,
                selectedBackground: WColors.success.withValues(alpha: 0.1),
                unselectedBackground:
                    WColors.surfaceOverlay.withValues(alpha: 0.15),
                selectedBorder: WColors.success,
                unselectedBorder: WColors.border,
                selectedForeground: WColors.success,
                unselectedForeground: WColors.foreground,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: WActionButton(
            label: 'Watch Trailer',
            icon: Icons.play_arrow_rounded,
            filled: false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening trailer...')),
            ),
            outlinedBackgroundColor: WColors.surfaceOverlay,
            filledBackgroundColor: WColors.accentRed,
          ),
        ),
      ],
    );
  }
}

// ─── Where to watch ───────────────────────────────────────────────────────────

class _WhereToWatchSection extends StatelessWidget {
  const _WhereToWatchSection();

  static const _platforms = [
    {
      'name': 'Netflix',
      'type': 'Subscription',
      'detail': 'Season 1–5',
      'color': 0xFFE50914,
    },
    {
      'name': 'Prime Video',
      'type': 'Buy / Rent',
      'detail': 'Individual Seasons',
      'color': 0xFF00A8E1,
    },
    {
      'name': 'JioHotstar',
      'type': 'Subscription',
      'detail': 'All Seasons',
      'color': 0xFF7B2FBE,
    },
    {
      'name': 'Apple TV+',
      'type': 'Buy / Rent',
      'detail': 'HD Available',
      'color': 0xFF323234,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WATCH NOW',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: WColors.accentRed,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Available on ${_platforms.length} platforms',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: WColors.foreground,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Showing all platforms...')),
              ),
              child: Text(
                'Show more >',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: WColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _platforms.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, i) {
              return _ProviderCard(
                name: _platforms[i]['name']! as String,
                type: _platforms[i]['type']! as String,
                detail: _platforms[i]['detail']! as String,
                color: Color(_platforms[i]['color']! as int),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String type;
  final String detail;
  final Color color;

  const _ProviderCard({
    required this.name,
    required this.type,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised,
        borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
        border: Border.all(color: WColors.borderStrong, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  size: 13.sp, color: WColors.mutedSecondaryDeep),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: WColors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: WColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: WColors.mutedSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Overview ─────────────────────────────────────────────────────────────────

class _OverviewSection extends StatefulWidget {
  const _OverviewSection();

  @override
  State<_OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<_OverviewSection> {
  bool _expanded = false;

  static const _text =
      'The reign of House Targaryen begins with a succession crisis following the death of King Viserys I. Factions form around his daughter Rhaenyra and his second wife Alicent Hightower, threatening to tear the realm apart in a brutal civil war known as the Dance of the Dragons — a conflict that will change Westeros forever.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: WColors.foreground,
          ),
        ),
        SizedBox(height: 10.h),
        AnimatedCrossFade(
          firstChild: Text(
            _text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              color: WColors.mutedForeground,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            _text,
            style: TextStyle(
              fontSize: 14.sp,
              color: WColors.mutedForeground,
              height: 1.65,
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Read Less' : 'Read More',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: WColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Seasons section ──────────────────────────────────────────────────────────

class _SeasonsSection extends StatelessWidget {
  final List<SeriesSeason> seasons;
  final int selectedSeasonIndex;
  final SeriesSeason currentSeason;
  final Set<int> seasonsInWatchlist;
  final Set<int> seasonsWatched;
  final Set<String> episodesWatched;
  final Map<int, double> seasonRatings;
  final Set<int> expandedSeasons;
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
                color: WColors.accentRed,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: WColors.surfaceRaised,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: WColors.borderStrong),
              ),
              child: Text(
                '${seasons.length}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: WColors.mutedSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        // Season tabs
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
                      color:
                          selected ? WColors.primary : WColors.surfaceChip,
                      borderRadius:
                          BorderRadius.circular(WSizes.radiusXl.r),
                      border: Border.all(
                        color: selected
                            ? WColors.primary
                            : WColors.surfaceChipBorder,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color:
                                    WColors.primary.withValues(alpha: 0.35),
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
                                : WColors.mutedSecondary,
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          s.year,
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.85)
                                : WColors.mutedSecondaryDeep,
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
        // Season card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: WColors.surfaceRaised,
            borderRadius: BorderRadius.circular(WSizes.radius3xl.r),
            border: Border.all(color: WColors.borderStrong),
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
                              color: WColors.foreground,
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
                                label:
                                    '${currentSeason.episodeCount} episodes',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Season rating badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: WColors.tertiary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                            color: WColors.tertiary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: WColors.tertiary, size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            currentSeason.rating,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: WColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              // Season action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: WToggleActionButton(
                        selected: inWatchlist,
                        selectedLabel: 'In Watchlist',
                        unselectedLabel: 'Add Season',
                        selectedIcon: Icons.bookmark_rounded,
                        unselectedIcon: Icons.bookmark_add_outlined,
                        onTap: () =>
                            onToggleSeasonWatchlist(currentSeason.number),
                        selectedBackground:
                            WColors.primary.withValues(alpha: 0.14),
                        unselectedBackground: WColors.surfaceMuted,
                        selectedBorder: WColors.primary,
                        unselectedBorder: WColors.borderStrong,
                        selectedForeground: WColors.primary,
                        unselectedForeground: WColors.mutedSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: WToggleActionButton(
                        selected: isWatched,
                        selectedLabel: 'Watched',
                        unselectedLabel: 'Mark Watched',
                        selectedIcon: Icons.check_circle_rounded,
                        unselectedIcon: Icons.check_circle_outline_rounded,
                        onTap: () =>
                            onToggleSeasonWatched(currentSeason.number),
                        selectedBackground:
                            WColors.success.withValues(alpha: 0.1),
                        unselectedBackground: WColors.surfaceMuted,
                        selectedBorder: WColors.success,
                        unselectedBorder: WColors.borderStrong,
                        selectedForeground: WColors.success,
                        unselectedForeground: WColors.mutedSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Episodes header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      'EPISODES',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: WColors.mutedSecondaryDeep,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                        child: Container(height: 1, color: WColors.border)),
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
        color: WColors.surfaceBorderAlt,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: WColors.mutedSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: WColors.mutedSecondary,
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
  final Set<String> episodesWatched;
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
                      color: WColors.accentRed,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: WColors.accentRed,
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
                    ? WColors.success.withValues(alpha: 0.12)
                    : WColors.surfaceBorderAlt,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: watched
                      ? WColors.success.withValues(alpha: 0.4)
                      : WColors.border,
                ),
              ),
              child: Text(
                'E${episode.number}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color:
                      watched ? WColors.success : WColors.mutedSecondaryDeep,
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
                  color:
                      watched ? WColors.mutedSecondary : WColors.foreground,
                  decoration: watched ? TextDecoration.lineThrough : null,
                  decorationColor: WColors.mutedSecondary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              episode.runtime,
              style: TextStyle(
                fontSize: 11.sp,
                color: WColors.mutedSecondaryDeep,
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
                color:
                    watched ? WColors.success : WColors.mutedSecondaryDeep,
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
              color: WColors.mutedSecondaryDeep,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Container(height: 1, color: WColors.border)),
        ],
      ),
    );
  }
}

// ─── Season rating (compact) ──────────────────────────────────────────────────

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
    final ratingColor =
        hasRated ? ratingColorFor(displayRating) : WColors.mutedSecondaryDeep;
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
                color: WColors.foreground,
              ),
            ),
            if (hasRated)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: ratingColor.withValues(alpha: 0.35),
                      width: 0.6),
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
                    Icon(Icons.star_rounded,
                        size: 11.sp, color: ratingColor),
                  ],
                ),
              )
            else
              Text(
                ratingLabel,
                style: TextStyle(
                    fontSize: 11.sp, color: WColors.mutedSecondaryDeep),
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
              color: rating >= value - 0.5 ? starColor : WColors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Cast ─────────────────────────────────────────────────────────────────────

class _CastSection extends StatelessWidget {
  const _CastSection();

  static const _castMembers = [
    {
      'photo':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
      'name': 'Paddy Considine',
      'role': 'Viserys I',
      'initials': 'PC',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face',
      'name': 'Emma D\'Arcy',
      'role': 'Rhaenyra',
      'initials': 'ED',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
      'name': 'Matt Smith',
      'role': 'Daemon',
      'initials': 'MS',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',
      'name': 'Olivia Cooke',
      'role': 'Alicent',
      'initials': 'OC',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200&h=200&fit=crop&crop=face',
      'name': 'Rhys Ifans',
      'role': 'Otto Hightower',
      'initials': 'RI',
    },
  ];

  static const _fallbackColors = [
    WColors.accentBlueMuted,
    WColors.accentPink,
    WColors.warning,
    WColors.accentRed,
    WColors.mutedSecondaryAlt,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: WColors.foreground,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _castMembers.length,
            itemBuilder: (context, i) {
              final member = _castMembers[i];
              final fallbackColor =
                  _fallbackColors[i % _fallbackColors.length];
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WColors.borderStrong,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          member['photo']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: fallbackColor,
                            alignment: Alignment.center,
                            child: Text(
                              member['initials']!,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 74.w,
                      child: Text(
                        member['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: WColors.foreground,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(
                      width: 74.w,
                      child: Text(
                        member['role']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: WColors.mutedForeground,
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
                    color: WColors.foreground,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Rate the whole show',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: WColors.mutedForeground,
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
            color: WColors.surfaceTint.withValues(alpha: 0.18),
            borderRadius: BorderRadius.all(Radius.elliptical(20.r, 18.r)),
            border: Border.all(
              color: WColors.surfaceChipBorder.withValues(alpha: 0.8),
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
              _RatingMeter(
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
                      fontSize: 10.sp, color: WColors.mutedSecondary),
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
                border:
                    Border.all(color: ratingColor.withValues(alpha: 0.35)),
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
  final Color starColor;

  const _FullStarBar({
    required this.rating,
    required this.onRate,
    required this.size,
    this.starColor = WColors.border,
  });

  @override
  Widget build(BuildContext context) {
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
              color: rating >= value - 0.5 ? starColor : WColors.border,
            ),
          ),
        );
      }),
    );
  }
}

class _RatingMeter extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color ratingColor;

  const _RatingMeter({
    required this.rating,
    required this.starSize,
    required this.ratingColor,
  });

  @override
  Widget build(BuildContext context) {
    final starSlotWidth = starSize + 4.w;
    final totalWidth = starSlotWidth * 5;
    final fillFraction = (rating / 5).clamp(0.0, 1.0);

    final stopCount = kRatingGradientColors.length;
    final lastStopIndex =
        (((rating / 5.0) * (stopCount - 1)).ceil()).clamp(1, stopCount - 1);
    final activeColors = kRatingGradientColors.sublist(0, lastStopIndex + 1);

    return SizedBox(
      width: totalWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          height: 4.h,
          child: Stack(
            children: [
              Container(color: WColors.border.withValues(alpha: 0.45)),
              FractionallySizedBox(
                widthFactor: fillFraction,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: activeColors),
                    boxShadow: [
                      BoxShadow(
                        color: ratingColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: WColors.accentRed,
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
                  color: WColors.foreground,
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
                  color: WColors.primary,
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
                  child: _DiscoverChip(
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
                cinemaType: CinemaType.series,
                year: '2023',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DiscoverChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _DiscoverChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? WColors.accentRed.withValues(alpha: 0.2)
        : WColors.surfaceOverlay.withValues(alpha: 0.2);
    final border = selected
        ? WColors.accentRed.withValues(alpha: 0.6)
        : WColors.border.withValues(alpha: 0.2);
    final foreground =
        selected ? WColors.accentRed : WColors.mutedForeground;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
