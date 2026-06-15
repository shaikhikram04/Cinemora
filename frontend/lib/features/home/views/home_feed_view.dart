import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/buttons/action_button.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/common/widgets/headers/section_header.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_cubit.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';
import 'package:cinemora/features/watch_together/widgets/watch_together_card.dart';

// ── Static content (not business state) ───────────────────────────────────────

const _kHeroImage =
    'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=1200&q=80';

const _kProfileImage =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80';

const _kTrending = [
  MoviePoster(
    title: 'Inception',
    rating: '8.8',
    image:
        'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'The Dark Knight',
    rating: '9',
    image:
        'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=687&auto=format&fit=crop',
  ),
  MoviePoster(
    title: 'Dune: Part Two',
    rating: '8.7',
    image:
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=700&q=80',
  ),
];

const _kAnime = [
  MoviePoster(
    title: 'Attack on Titan',
    rating: '9.1',
    tag: 'Anime',
    actionAdded: true,
    image:
        'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a0b9?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'Fullmetal Alchemist',
    rating: '9.1',
    tag: 'Anime',
    image:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'Steins;Gate',
    rating: '9.1',
    tag: 'Anime',
    image:
        'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=700&q=80',
  ),
];

const _kSeries = [
  MoviePoster(
    title: 'Breaking Bad',
    rating: '9.5',
    tag: 'Series',
    actionAdded: true,
    image:
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'True Detective',
    rating: '9',
    tag: 'Series',
    image:
        'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'Succession',
    rating: '8.9',
    tag: 'Series',
    image:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=700&q=80',
  ),
];

const _kCriticallyAcclaimed = [
  MoviePoster(
    title: 'Inception',
    rating: '8.8',
    tag: 'Movie',
    image:
        'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=700&q=80',
  ),
  MoviePoster(
    title: 'The Dark Knight',
    rating: '9',
    tag: 'Movie',
    actionAdded: true,
    image:
        'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=687&auto=format&fit=crop',
  ),
  MoviePoster(
    title: 'Dune: Part Two',
    rating: '8.7',
    tag: 'Movie',
    actionAdded: true,
    image:
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=700&q=80',
  ),
];

const _kMoods = [
  (label: 'Emotional', emoji: '🥲'),
  (label: 'Mind-Blown', emoji: '🤯'),
  (label: 'Scared', emoji: '😱'),
];

const _kTabs = ['✨   For You', '🎬   Movies', '⛩️   Anime', '📺   Series'];

// ── Entry point ───────────────────────────────────────────────────────────────

class HomeFeedView extends StatelessWidget {
  const HomeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(),
      child: const _HomeFeedContent(),
    );
  }
}

// ── View — reads HomeFeedState, no UI-only state needed ───────────────────────

class _HomeFeedContent extends StatelessWidget {
  const _HomeFeedContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        final cubit = context.read<HomeFeedCubit>();
        return Container(
          decoration: const BoxDecoration(color: WColors.background),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                WSizes.screenPadding.w,
                6.h,
                WSizes.screenPadding.w,
                42.h,
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                _Header(
                  profileImage: _kProfileImage,
                  onNotificationTap: () =>
                      context.push(AppRoutes.notifications),
                ),
                SizedBox(height: 12.h),
                _CategoryTabs(
                  selectedTab: state.selectedTab,
                  onSelected: cubit.selectTab,
                ),
                SizedBox(height: 14.h),
                const WatchTogetherCard(),
                SizedBox(height: 16.h),
                _HeroCard(
                  image: _kHeroImage,
                  onDetailsPressed: () => context.push(
                    AppRoutes.movieDetails,
                    extra: const MovieRouteArgs(
                      title: 'Inception',
                      image: _kHeroImage,
                      rating: '8.8',
                    ),
                  ),
                  onWatchlistPressed: () {},
                ),
                SizedBox(height: 24.h),
                const WSectionHeader(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: WColors.accentRed,
                  title: 'Trending Now',
                ),
                SizedBox(height: 10.h),
                _PosterCarousel(
                  items: _kTrending,
                  type: CinemaType.movie,
                  onTap: (item) => context.push(
                    AppRoutes.movieDetails,
                    extra: MovieRouteArgs(
                      title: item.title,
                      image: item.image,
                      rating: item.rating,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                const WSectionHeader(
                  icon: Icons.movie_filter_rounded,
                  iconColor: WColors.accentPurple,
                  title: 'Top Anime This Season',
                ),
                SizedBox(height: 10.h),
                _PosterCarousel(
                  items: _kAnime,
                  type: CinemaType.anime,
                  onTap: (item) => context.push(
                    AppRoutes.seriesDetails,
                    extra: SeriesRouteArgs(
                      title: item.title,
                      image: item.image,
                      rating: item.rating,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _MoodPickerCard(
                  selectedMood: state.selectedMood,
                  onSelected: cubit.toggleMood,
                ),
                SizedBox(height: 24.h),
                const WSectionHeader(
                  icon: Icons.live_tv_rounded,
                  iconColor: WColors.warning,
                  title: 'Binge-Worthy Series',
                ),
                SizedBox(height: 10.h),
                _PosterCarousel(
                  items: _kSeries,
                  type: CinemaType.series,
                  onTap: (item) => context.push(
                    AppRoutes.seriesDetails,
                    extra: SeriesRouteArgs(
                      title: item.title,
                      image: item.image,
                      rating: item.rating,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                const WSectionHeader(
                  icon: Icons.star_rounded,
                  iconColor: WColors.tertiary,
                  title: 'Critically Acclaimed',
                ),
                SizedBox(height: 10.h),
                _PosterCarousel(
                  items: _kCriticallyAcclaimed,
                  type: CinemaType.movie,
                  onTap: (item) => context.push(
                    AppRoutes.movieDetails,
                    extra: MovieRouteArgs(
                      title: item.title,
                      image: item.image,
                      rating: item.rating,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                const _RankingCard(),
                SizedBox(height: 18.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable carousel ─────────────────────────────────────────────────────────

class _PosterCarousel extends StatelessWidget {
  final List<MoviePoster> items;
  final CinemaType type;
  final void Function(MoviePoster) onTap;

  const _PosterCarousel({
    required this.items,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: WSizes.imageCarouselHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, index) {
          final item = items[index];
          return VerticalPosterBookmarkCard(
            image: item.image,
            width: WSizes.posterImageWidth.w,
            imageHeight: WSizes.posterImageHeight.h,
            title: item.title,
            rating: item.rating,
            cinemaType: type,
            year: '2008',
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String profileImage;
  final VoidCallback? onNotificationTap;

  const _Header({required this.profileImage, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: WColors.accentRedSoft, width: 2),
            image: DecorationImage(
              image: NetworkImage(profileImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening',
              style: TextStyle(
                color: WColors.mutedForeground,
                fontSize: 12.sp,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Hey, Ikram 👋',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 18.sp,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(16, 18)),
                  color: WColors.surfaceMuted,
                  border: Border.all(color: WColors.borderStrong),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: WColors.foreground,
                  size: 21.sp,
                ),
              ),
              Positioned(
                right: 11.w,
                top: 11.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: WColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Category tabs ─────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onSelected;

  const _CategoryTabs({required this.selectedTab, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _kTabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          final tab = _kTabs[index];
          final selected = tab == selectedTab;
          return Material(
            color: selected ? WColors.accentRed : WColors.surfaceRaised,
            borderRadius: BorderRadius.circular(999.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(999.r),
              onTap: () => onSelected(tab),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: selected ? Colors.transparent : WColors.borderStrong,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: WColors.accentRed.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: selected ? Colors.white : WColors.mutedForeground,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String image;
  final VoidCallback onDetailsPressed;
  final VoidCallback onWatchlistPressed;

  const _HeroCard({
    required this.image,
    required this.onDetailsPressed,
    required this.onWatchlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 284.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: WColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(image, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.34),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                  stops: const [0.0, 0.60, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: WColors.accentRed,
                        borderRadius: BorderRadius.circular(999.r),
                        boxShadow: [
                          BoxShadow(
                            color: WColors.accentRed.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 13.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'TRENDING #1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: WColors.tertiary, size: 16.sp),
                      SizedBox(width: 3.w),
                      Text(
                        '8.8',
                        style: TextStyle(
                          color: WColors.tertiary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Sci-Fi',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Action',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '2h 28m',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Inception',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: WActionButton(
                          label: 'Details',
                          icon: Icons.play_arrow_rounded,
                          filled: true,
                          onTap: onDetailsPressed,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: WActionButton(
                          label: 'Watchlist',
                          icon: Icons.add_rounded,
                          filled: false,
                          onTap: onWatchlistPressed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ranking card ──────────────────────────────────────────────────────────────

class _RankingCard extends StatelessWidget {
  const _RankingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WColors.accentPurple.withValues(alpha: 0.12),
            WColors.accentRed.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.accentRed.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [WColors.accentPink, WColors.accentPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Ranking Lists',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '6 curated lists · Drag to reorder',
                  style: TextStyle(
                    color: WColors.mutedSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: WColors.mutedForeground, size: 22.sp),
        ],
      ),
    );
  }
}

// ── Mood picker card ──────────────────────────────────────────────────────────

class _MoodPickerCard extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onSelected;

  const _MoodPickerCard({required this.selectedMood, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final showPick = selectedMood == 'Emotional';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: WColors.surfaceMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.surfaceBorderAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [WColors.accentPurple, WColors.accentPink],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 17.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Mood Picker',
                    style: TextStyle(
                      color: WColors.foreground,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "What's your vibe tonight?",
                    style: TextStyle(
                      color: WColors.mutedSecondaryDeep,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _kMoods.map((mood) {
              final selected = selectedMood == mood.label;
              return _MoodChip(
                text: '${mood.emoji} ${mood.label}',
                selected: selected,
                onTap: () => onSelected(mood.label),
              );
            }).toList(),
          ),
          if (showPick) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: WColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: WColors.surfaceBorderAlt),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?auto=format&fit=crop&w=400&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Pick for you',
                          style: TextStyle(
                            color: WColors.mutedSecondaryHighlight,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Oppenheimer',
                          style: TextStyle(
                            color: WColors.foreground,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: WColors.tertiary, size: 13.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '8.3',
                              style: TextStyle(
                                color: WColors.tertiary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Drama',
                              style: TextStyle(
                                color: WColors.mutedSecondaryAlt,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: WColors.accentRed,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Mood chip ─────────────────────────────────────────────────────────────────

class _MoodChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _MoodChip(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? WColors.accentRed : WColors.surfaceChip,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected ? Colors.transparent : WColors.surfaceChipBorder,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : WColors.mutedSecondaryVibe,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
