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
                _TagsSection(
                  showAllTags: showAllTags,
                  onToggleTags: onToggleTags,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: GestureDetector(
                onTap: () => onRate((index + 1).toDouble()),
                child: Icon(
                  index < userRating.toInt()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: index < userRating.toInt()
                      ? WColors.success
                      : WColors.border,
                  size: 42.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Masterpiece',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: WColors.success,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  final bool showAllTags;
  final VoidCallback onToggleTags;

  const _TagsSection({
    required this.showAllTags,
    required this.onToggleTags,
  });

  @override
  Widget build(BuildContext context) {
    const allTags = ['Masterpiece', 'Rewatchable', 'Thriller', 'Must Watch'];
    final visibleTags = showAllTags ? allTags : allTags.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: WColors.foreground,
                fontFamily: 'Inter',
              ),
            ),
            GestureDetector(
              onTap: onToggleTags,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: WColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: visibleTags
              .map(
                (tag) => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: WColors.success.withValues(alpha: 0.5),
                      width: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: WColors.success,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      {'title': 'Inception', 'rating': '8.8', 'years': '2010'},
      {'title': 'Dune: Part Two', 'rating': '8.7', 'years': '2024'},
      {'title': '1917', 'rating': '8.3', 'years': '2019'},
      {
        'title': 'Everything Everywhere All...',
        'rating': '7.8',
        'years': '2022'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You Might Also Like',
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
        SizedBox(
          height: 210.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return VerticalPosterBookmarkCard(
                image:
                    'https://images.unsplash.com/photo-1616530940355-351fabd9524b?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                width: 100.w,
                imageHeight: 140,
                title: recommendation['title']!,
                rating: recommendation['rating']!,
                cinemaType: CinemaType.movie,
                year: '2008',
              );
            },
          ),
        ),
      ],
    );
  }
}
