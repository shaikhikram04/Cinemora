import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/buttons/action_button.dart';
import 'package:cinemora/common/widgets/buttons/circle_icon_button.dart';
import 'package:cinemora/common/widgets/buttons/pill_chip.dart';
import 'package:cinemora/common/widgets/buttons/toggle_action_button.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/widgets/discover_chip.dart';
import 'package:cinemora/features/home/widgets/rating_meter.dart';

class MovieDetailsContent extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final bool showAllTags;
  final bool showRatingSuccess;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleWatched;
  final ValueChanged<double> onRate;
  final VoidCallback onToggleTags;
  final VoidCallback onManageRankings;

  const MovieDetailsContent({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
    required this.isInWatchlist,
    required this.isWatched,
    required this.userRating,
    required this.showAllTags,
    required this.showRatingSuccess,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
    required this.onRate,
    required this.onToggleTags,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroHeader(
            movieTitle: movieTitle,
            movieImage: movieImage,
            rating: rating,
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
                  onToggleWatchlist: onToggleWatchlist,
                  onToggleWatched: onToggleWatched,
                ),
                SizedBox(height: 16.h),
                const _WhereToWatchSection(),
                SizedBox(height: 20.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
                const _OverviewSection(),
                SizedBox(height: 20.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
                const _CastSection(),
                SizedBox(height: 16.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
                _UserRatingSection(
                  userRating: userRating,
                  onRate: onRate,
                  showRatingSuccess: showRatingSuccess,
                  onManageRankings: onManageRankings,
                ),
                SizedBox(height: 28.h),
                Divider(color: context.colors.border),
                SizedBox(height: 16.h),
                _RecommendationsSection(movieTitle: movieTitle),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;

  const _HeroHeader({
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: WSizes.imageDetailsHeroHeight.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(movieImage),
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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shared!')),
                      );
                    },
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
          bottom: 24.h,
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
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
                  SizedBox(width: 8.w),
                  const Expanded(
                    child: Row(
                      children: [
                        WPillChip(text: 'Action'),
                        SizedBox(width: 6),
                        WPillChip(text: 'Crime'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Title
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
              // Year + runtime
              Text(
                '2008  •  2h 32m',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colors.mutedForeground,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 2.h),
              // Director
              Text(
                'Dir. Christopher Nolan',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colors.mutedSecondaryDeep,
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

// ─── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isInWatchlist;
  final bool isWatched;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleWatched;

  const _ActionButtons({
    required this.isInWatchlist,
    required this.isWatched,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WToggleActionButton(
                selected: isInWatchlist,
                selectedLabel: 'In Watchlist',
                unselectedLabel: 'Add to Watchlist',
                selectedIcon: Icons.bookmark,
                unselectedIcon: Icons.bookmark_outline,
                onTap: onToggleWatchlist,
                selectedBackground: context.colors.primary.withValues(alpha: 0.14),
                unselectedBackground: context.colors.accentRed.withValues(alpha: 0.9),
                selectedBorder: context.colors.primary,
                unselectedBorder: context.colors.border,
                selectedForeground: context.colors.primary,
                unselectedForeground: context.colors.primaryForeground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: WToggleActionButton(
                selected: isWatched,
                selectedLabel: 'Watched',
                unselectedLabel: 'Mark Watched',
                selectedIcon: Icons.check_circle,
                unselectedIcon: Icons.check_circle_outline,
                onTap: onToggleWatched,
                selectedBackground: context.colors.success.withValues(alpha: 0.1),
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
        SizedBox(
          width: double.infinity,
          child: WActionButton(
            label: 'Watch Trailer',
            icon: Icons.play_arrow_rounded,
            filled: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening trailer...')),
              );
            },
            outlinedBackgroundColor: context.colors.surfaceOverlay,
            filledBackgroundColor: context.colors.accentRed,
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
    {'name': 'Netflix', 'type': 'Subscription', 'color': 0xFFE50914},
    {'name': 'Prime Video', 'type': 'Subscription', 'color': 0xFF00A8E1},
    {'name': 'Disney+', 'type': 'Subscription', 'color': 0xFF0C3492},
    {'name': 'Apple TV+', 'type': 'Buy / Rent', 'color': 0xFF323234},
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
                    color: context.colors.accentRed,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Available on ${_platforms.length} platforms',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.foreground,
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
                  color: context.colors.primary,
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
  final Color color;

  const _ProviderCard({
    required this.name,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  size: 13.sp, color: context.colors.mutedSecondaryDeep),
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
                  type,
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
      'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice. With Commissioner Gordon and Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets — but the Joker has far darker plans in store.';

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
            color: context.colors.foreground,
            fontFamily: 'Inter',
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
              color: context.colors.mutedForeground,
              height: 1.65,
              fontFamily: 'Inter',
            ),
          ),
          secondChild: Text(
            _text,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.colors.mutedForeground,
              height: 1.65,
              fontFamily: 'Inter',
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
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Cast ─────────────────────────────────────────────────────────────────────

class _CastSection extends StatelessWidget {
  const _CastSection();

  static const _castMembers = [
    {
      'photo':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&h=200&fit=crop&crop=face',
      'name': 'Christian Bale',
      'character': 'Bruce Wayne',
      'initials': 'CB',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',
      'name': 'Heath Ledger',
      'character': 'The Joker',
      'initials': 'HL',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',
      'name': 'Aaron Eckhart',
      'character': 'Harvey Dent',
      'initials': 'AE',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face',
      'name': 'Maggie Gyllenhaal',
      'character': 'Rachel Dawes',
      'initials': 'MG',
    },
    {
      'photo':
          'https://images.unsplash.com/photo-1542909168-82c3e7fdca5c?w=200&h=200&fit=crop&crop=face',
      'name': 'Michael Caine',
      'character': 'Alfred',
      'initials': 'MC',
    },
  ];

  static final _fallbackColors = [
    const Color(0xFF718096), // accentBlueMuted
    const Color(0xFFEB4B6B), // accentPink
    const Color(0xFFE0A838), // warning
    const Color(0xFFE84B57), // accentRed
    const Color(0xFF8C8C97), // mutedSecondaryAlt
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
            color: context.colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _castMembers.length,
            itemBuilder: (context, index) {
              final member = _castMembers[index];
              final fallbackColor =
                  _fallbackColors[index % _fallbackColors.length];
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.borderStrong,
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
                          color: context.colors.foreground,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(
                      width: 74.w,
                      child: Text(
                        member['character']!,
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

// ─── User rating ──────────────────────────────────────────────────────────────

class _UserRatingSection extends StatelessWidget {
  final double userRating;
  final ValueChanged<double> onRate;
  final bool showRatingSuccess;
  final VoidCallback onManageRankings;

  const _UserRatingSection({
    required this.userRating,
    required this.onRate,
    required this.showRatingSuccess,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = userRating <= 0 ? 4.5 : userRating;
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
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colors.foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Tap star halves to rate',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.colors.mutedForeground,
                    fontFamily: 'Inter',
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
                  color: ratingColor.withValues(alpha: 0.35),
                  width: 0.6,
                ),
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
              _StarRatingBar(
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
              if (showRatingSuccess && userRating > 0) ...[
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
                    fontSize: 10.sp,
                    color: context.colors.mutedSecondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'All-Time Favorites',
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

class _StarRatingBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;
  final double size;
  final Color? starColor;

  const _StarRatingBar({
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
              color: rating >= value - 0.5 ? resolvedStarColor : context.colors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Recommendations ──────────────────────────────────────────────────────────

class _RecommendationsSection extends StatefulWidget {
  final String movieTitle;

  const _RecommendationsSection({required this.movieTitle});

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

  static const _recommendations = [
    {
      'title': 'Breaking Bad',
      'rating': '9.5',
      'image':
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Attack on Titan',
      'rating': '9.1',
      'image':
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Interstellar',
      'rating': '8.7',
      'image':
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=600&auto=format&fit=crop',
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
            fontFamily: 'Inter',
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
                  fontFamily: 'Inter',
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing all recommendations...')),
              ),
              child: Text(
                'See all >',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                  fontFamily: 'Inter',
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
            itemCount: _recommendations.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final rec = _recommendations[index];
              return VerticalPosterBookmarkCard(
                title: rec['title']!,
                rating: rec['rating']!,
                image: rec['image']!,
                width: WSizes.posterImageWidth.w,
                imageHeight: WSizes.posterImageHeight.h,
                cinemaType: CinemaType.series,
                year: '2008',
              );
            },
          ),
        ),
      ],
    );
  }
}
