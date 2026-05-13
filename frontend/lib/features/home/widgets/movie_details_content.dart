import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/buttons/action_button.dart';
import 'package:watchary/common/widgets/buttons/circle_icon_button.dart';
import 'package:watchary/common/widgets/buttons/pill_chip.dart';
import 'package:watchary/common/widgets/buttons/toggle_action_button.dart';
import 'package:watchary/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class MovieDetailsContent extends StatelessWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;
  final bool isInWatchlist;
  final bool isWatched;
  final double userRating;
  final bool showAllTags;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleWatched;
  final ValueChanged<double> onRate;
  final VoidCallback onToggleTags;

  const MovieDetailsContent({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
    required this.isInWatchlist,
    required this.isWatched,
    required this.userRating,
    required this.showAllTags,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
    required this.onRate,
    required this.onToggleTags,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                SizedBox(height: 12.h),
                const Divider(color: WColors.border),
                SizedBox(height: 12.h),
                const _OverviewSection(),
                SizedBox(height: 24.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                const _CastSection(),
                SizedBox(height: 16.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                _UserRatingSection(
                  userRating: userRating,
                  onRate: onRate,
                ),
                SizedBox(height: 28.h),
                const Divider(color: WColors.border),
                SizedBox(height: 16.h),
                const _RecommendationsSection(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                  Colors.transparent,
                  WColors.background.withValues(alpha: 0.6),
                  WColors.background.withValues(alpha: 0.9),
                ],
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
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: WColors.tertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: WColors.tertiary, size: 12.sp),
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
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Row(
                      children: [
                        WPillChip(text: 'Action'),
                        SizedBox(width: 8),
                        WPillChip(text: 'Drama'),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                movieTitle,
                style: TextStyle(
                  fontSize: WSizes.fontSize3xl.sp,
                  fontWeight: FontWeight.w800,
                  color: WColors.foreground,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '2008   •   2h 32m   •   Christopher Nolan',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: WColors.mutedForeground,
                  fontFamily: 'Inter',
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: WSizes.sectionSpaceLg.h),
            ],
          ),
        )
      ],
    );
  }
}

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
                selected: isWatched,
                selectedLabel: 'Watched',
                unselectedLabel: 'Mark Watched',
                selectedIcon: Icons.check_circle,
                unselectedIcon: Icons.check_circle_outline,
                onTap: onToggleWatched,
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening trailer...')),
              );
            },
            outlinedBackgroundColor: WColors.surfaceOverlay,
            filledBackgroundColor: WColors.accentRed,
          ),
        ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

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
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
          style: TextStyle(
            fontSize: 14.sp,
            color: WColors.mutedForeground,
            height: 1.6,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _CastSection extends StatelessWidget {
  const _CastSection();

  @override
  Widget build(BuildContext context) {
    final castMembers = [
      {'initials': 'CB', 'name': 'Christian Bale', 'actor': 'Bruce Wayne'},
      {'initials': 'HL', 'name': 'Heath Ledger', 'actor': 'The Joker'},
      {'initials': 'AE', 'name': 'Aaron Eckhart', 'actor': 'Harvey Dent'},
      {'initials': 'MG', 'name': 'Maggie Gyllenhaal', 'actor': 'Rachel'},
      {'initials': 'MC', 'name': 'Michael Caine', 'actor': 'Alfred'},
    ];

    final colors = [
      WColors.accentBlueMuted,
      WColors.accentPink,
      WColors.warning,
      WColors.accentRed,
      WColors.mutedSecondaryAlt,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: WColors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: castMembers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Center(
                        child: Text(
                          castMembers[index]['initials']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 70.w,
                      child: Text(
                        castMembers[index]['name']!,
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
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: 70.w,
                      child: Text(
                        castMembers[index]['actor']!,
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

class _UserRatingSection extends StatelessWidget {
  final double userRating;
  final ValueChanged<double> onRate;

  const _UserRatingSection({
    required this.userRating,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = userRating <= 0 ? 4.5 : userRating;
    // Compute once — reused by label, emoji, star color, and meter
    final ratingColor = _ratingColor(displayRating);
    final ratingLabel = _ratingLabel(displayRating);
    final ratingEmoji = _ratingEmoji(displayRating);
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
                    color: WColors.foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Tap star halves to rate · Drag meter to adjust',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: WColors.mutedForeground,
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
                  Icon(
                    Icons.star_rounded,
                    size: 12.sp,
                    color: ratingColor,
                  ),
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
              _StarRatingBar(
                rating: displayRating,
                onRate: onRate,
                starColor: ratingColor,
                size: starSize.sp,
              ),
              SizedBox(height: 24.h),
              _RatingMeter(
                rating: displayRating,
                starSize: starSize.sp,
                ratingColor: ratingColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarRatingBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;
  final double size;
  final Color starColor;

  const _StarRatingBar({
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

        // Each slot wraps only the star icon + its own padding.
        // localPosition.dx is relative to this slot's top-left corner.
        final slotWidth = size + 4.w; // size + 2×2.w padding
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

/// The full color scale for ratings 0.5 → 5.0 (9 stops for 9 half-steps).
/// Stored as a top-level constant so it is created only once.
const List<Color> _kRatingGradientColors = [
  WColors.accentRed, // 0.5
  Colors.deepOrangeAccent, // 1.0
  Colors.orangeAccent, // 1.5
  Colors.amber, // 2.0
  Colors.amberAccent, // 2.5 – 3.0
  Colors.lightGreen, // 3.5
  Colors.green, // 4.0
  Colors.greenAccent, // 4.5
  Colors.tealAccent, // 5.0
];

class _RatingMeter extends StatelessWidget {
  /// Current rating value (0.5 – 5.0).
  final double rating;

  /// The rendered star size (sp) — used to compute exact meter width.
  final double starSize;

  /// Colour of the active rating (passed in, already computed once).
  final Color ratingColor;

  const _RatingMeter({
    required this.rating,
    required this.starSize,
    required this.ratingColor,
  });

  @override
  Widget build(BuildContext context) {
    // Each star occupies starSize + 2×2.w horizontal padding (see _StarRatingBar).
    final starSlotWidth = starSize + 4.w;
    final totalWidth = starSlotWidth * 5;

    // How far along the 0→5 scale the rating sits.
    final fillFraction = (rating / 5).clamp(0.0, 1.0);

    // Slice gradient up to the current rating stop only.
    final stopCount = _kRatingGradientColors.length;
    final lastStopIndex =
        (((rating / 5.0) * (stopCount - 1)).ceil()).clamp(1, stopCount - 1);
    final activeColors = _kRatingGradientColors.sublist(0, lastStopIndex + 1);

    return SizedBox(
      width: totalWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          height: 4.h,
          child: Stack(
            children: [
              // Background track
              Container(color: WColors.border.withValues(alpha: 0.45)),
              // Filled portion with gradient
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

String _ratingLabel(double value) {
  if (value == 5.0) return 'Masterpiece';
  if (value >= 4.5) return 'Excellent';
  if (value >= 4.0) return 'Great';
  if (value >= 3.5) return 'Good';
  if (value >= 3.0) return 'Decent';
  if (value >= 2.5) return 'Below Average';
  if (value >= 2.0) return 'Bad';
  if (value >= 1.5) return 'Very Bad';
  if (value >= 1.0) return 'Terrible';

  return 'Avoid it';
}

String _ratingEmoji(double value) {
  if (value == 5.0) return '🏆';
  if (value >= 4.5) return '🤩';
  if (value >= 4.0) return '😊';
  if (value >= 3.5) return '👍';
  if (value >= 3.0) return '😑';
  if (value >= 2.5) return '🤔';
  if (value >= 2.0) return '😐';
  if (value >= 1.5) return '😞';
  if (value >= 1.0) return '😤';

  return '💀';
}

Color _ratingColor(double value) {
  if (value == 5.0) return Colors.tealAccent;
  if (value >= 4.5) return Colors.greenAccent;
  if (value >= 4.0) return Colors.green;
  if (value >= 3.5) return Colors.lightGreen;
  if (value >= 3.0) return Colors.amberAccent;
  if (value >= 2.5) return Colors.amberAccent;
  if (value >= 2.0) return Colors.orangeAccent;
  if (value >= 1.5) return Colors.deepOrangeAccent;
  if (value >= 1.0) return WColors.accentRed;

  return WColors.accentRed;
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      {
        'title': 'Breaking Bad',
        'rating': '9.5',
        'tag': 'Series',
        'image':
            'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
      },
      {
        'title': 'Attack on Titan',
        'rating': '9.1',
        'tag': 'Anime',
        'image':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
      },
      {
        'title': 'Fullmetal Alchemist: Brotherhood',
        'rating': '9.1',
        'tag': 'Anime',
        'image':
            'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
      },
    ];

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
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You Might Also Love',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: WColors.foreground,
                fontFamily: 'Inter',
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Viewing all recommendations...'),
                  ),
                );
              },
              child: Text(
                'See all >',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: WColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _DiscoverChip(
                label: 'Similar Action',
                selected: true,
              ),
              SizedBox(width: 10.w),
              _DiscoverChip(
                label: 'Same Creator',
                selected: false,
              ),
              SizedBox(width: 10.w),
              _DiscoverChip(
                label: 'Also Trending',
                selected: false,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: WSizes.imageCarouselHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return VerticalPosterBookmarkCard(
                title: recommendation['title']!,
                rating: recommendation['rating']!,
                image: recommendation['image']!,
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

class _DiscoverChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _DiscoverChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? WColors.accentRed.withValues(alpha: 0.2)
        : WColors.surfaceOverlay.withValues(alpha: 0.2);
    final border = selected
        ? WColors.accentRed.withValues(alpha: 0.6)
        : WColors.border.withValues(alpha: 0.2);
    final foreground = selected ? WColors.accentRed : WColors.mutedForeground;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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
