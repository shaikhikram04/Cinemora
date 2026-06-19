import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/common/widgets/buttons/action_button.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/common/widgets/headers/section_header.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/home/models/movie_poster.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_cubit.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/watch_together/widgets/watch_together_card.dart';

const _kTabs = ['✨   For You', '🎬   Movies', '⛩️   Anime', '📺   Series'];

const _kMoods = [
  (label: 'Emotional', emoji: '🥲'),
  (label: 'Mind-Blown', emoji: '🤯'),
  (label: 'Scared', emoji: '😱'),
];

// ── Entry point ───────────────────────────────────────────────────────────────

class HomeFeedView extends StatelessWidget {
  const HomeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HomeFeedCubit(ctx.read<HomeRepository>(), ctx.read<LibraryCubit>()),
      child: const _HomeFeedContent(),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _HomeFeedContent extends StatelessWidget {
  const _HomeFeedContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        final cubit = context.read<HomeFeedCubit>();
        final loading = state.isLoading;

        return Container(
          decoration: BoxDecoration(color: context.colors.background),
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
                  onNotificationTap: () =>
                      context.push(AppRoutes.notifications),
                ),
                SizedBox(height: 12.h),
                _CategoryTabs(
                    selectedTab: state.selectedTab,
                    onSelected: cubit.selectTab),
                SizedBox(height: 14.h),
                const WatchTogetherCard(),
                SizedBox(height: 16.h),

                // Hero card
                if (loading)
                  _HeroCardSkeleton()
                else if (state.status == FeedStatus.failure)
                  _ErrorBanner(
                      message: state.errorMessage, onRetry: cubit.loadFeed)
                else
                  _HeroCard(
                    hero: state.hero,
                    isBookmarked: state.hero != null &&
                        state.bookmarkedIds.contains(state.hero!.id),
                    onDetailsPressed: state.hero == null
                        ? () {}
                        : () => context.push(
                              AppRoutes.movieDetails,
                              extra: MovieRouteArgs(
                                title: state.hero!.title,
                                image: state.hero!.posterUrl,
                                backdropImage:
                                    state.hero!.backdropUrl.isNotEmpty
                                        ? state.hero!.backdropUrl
                                        : null,
                                rating: state.hero!.ratingDisplay,
                                id: state.hero!.id,
                              ),
                            ),
                    onWatchlistPressed: state.hero == null
                        ? () {}
                        : () => cubit.bookmarkHero(state.hero!),
                  ),
                SizedBox(height: 24.h),

                // Trending Now
                WSectionHeader(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: context.colors.accentRed,
                  title: 'Trending Now',
                ),
                SizedBox(height: 10.h),
                loading
                    ? _SkeletonCarousel()
                    : _PosterCarousel(
                        items: state.trendingMovies,
                        type: CinemaType.movie,
                        bookmarkedIds: state.bookmarkedIds,
                        onBookmark: (item) =>
                            cubit.bookmarkFromPoster(item, CinemaType.movie),
                        onTap: (item) => context.push(
                          AppRoutes.movieDetails,
                          extra: MovieRouteArgs(
                            title: item.title,
                            image: item.image,
                            backdropImage: item.backdropImage,
                            rating: item.rating,
                            id: item.id,
                          ),
                        ),
                      ),
                SizedBox(height: 24.h),

                // Top Anime
                WSectionHeader(
                  icon: Icons.movie_filter_rounded,
                  iconColor: context.colors.accentPurple,
                  title: 'Top Anime This Season',
                ),
                SizedBox(height: 10.h),
                loading
                    ? _SkeletonCarousel()
                    : _PosterCarousel(
                        items: state.topAnime,
                        type: CinemaType.anime,
                        bookmarkedIds: state.bookmarkedIds,
                        onBookmark: (item) =>
                            cubit.bookmarkFromPoster(item, CinemaType.anime),
                        onTap: (item) => context.push(
                          AppRoutes.seriesDetails,
                          extra: SeriesRouteArgs(
                            title: item.title,
                            image: item.image,
                            rating: item.rating,
                            id: item.id,
                            source: 'jikan',
                          ),
                        ),
                      ),
                SizedBox(height: 24.h),

                _MoodPickerCard(
                  selectedMood: state.selectedMood,
                  onSelected: cubit.toggleMood,
                ),
                SizedBox(height: 24.h),

                // Binge-Worthy Series
                WSectionHeader(
                  icon: Icons.live_tv_rounded,
                  iconColor: context.colors.warning,
                  title: 'Binge-Worthy Series',
                ),
                SizedBox(height: 10.h),
                loading
                    ? _SkeletonCarousel()
                    : _PosterCarousel(
                        items: state.trendingSeries,
                        type: CinemaType.series,
                        bookmarkedIds: state.bookmarkedIds,
                        onBookmark: (item) =>
                            cubit.bookmarkFromPoster(item, CinemaType.series),
                        onTap: (item) => context.push(
                          AppRoutes.seriesDetails,
                          extra: SeriesRouteArgs(
                            title: item.title,
                            image: item.image,
                            backdropImage: item.backdropImage,
                            rating: item.rating,
                            id: item.id,
                            source: 'tmdb',
                          ),
                        ),
                      ),
                SizedBox(height: 24.h),

                // Critically Acclaimed
                WSectionHeader(
                  icon: Icons.star_rounded,
                  iconColor: context.colors.tertiary,
                  title: 'Critically Acclaimed',
                ),
                SizedBox(height: 10.h),
                loading
                    ? _SkeletonCarousel()
                    : _PosterCarousel(
                        items: state.criticallyAcclaimed,
                        type: CinemaType.movie,
                        bookmarkedIds: state.bookmarkedIds,
                        onBookmark: (item) =>
                            cubit.bookmarkFromPoster(item, CinemaType.movie),
                        onTap: (item) => context.push(
                          AppRoutes.movieDetails,
                          extra: MovieRouteArgs(
                            title: item.title,
                            image: item.image,
                            backdropImage: item.backdropImage,
                            rating: item.rating,
                            id: item.id,
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

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorBanner({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        height: 284.h,
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: context.colors.surfaceBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: context.colors.mutedForeground, size: 36.sp),
            SizedBox(height: 12.h),
            Text(
              message ?? 'Could not load feed.',
              style: TextStyle(
                color: context.colors.mutedForeground,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Tap to retry',
              style: TextStyle(
                color: context.colors.accentRed,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton widgets ──────────────────────────────────────────────────────────

class _HeroCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: Container(
        height: 284.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
        ),
      ),
    );
  }
}

class _SkeletonCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: SizedBox(
        height: WSizes.imageCarouselHeight.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, __) => Container(
            width: WSizes.posterImageWidth.w + 8.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WSizes.radiusXxl.r),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Poster carousel ───────────────────────────────────────────────────────────

class _PosterCarousel extends StatelessWidget {
  final List<MoviePoster> items;
  final CinemaType type;
  final void Function(MoviePoster) onTap;
  final Set<int> bookmarkedIds;
  final void Function(MoviePoster) onBookmark;

  const _PosterCarousel({
    required this.items,
    required this.type,
    required this.onTap,
    required this.bookmarkedIds,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
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
            year: item.year,
            isBookmarked: item.id != null && bookmarkedIds.contains(item.id),
            onBookmark: () => onBookmark(item),
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const _Header({this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening',
              style: TextStyle(
                color: context.colors.mutedForeground,
                fontSize: 12.sp,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Hey, Ikram 👋',
              style: TextStyle(
                color: context.colors.foreground,
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
                  color: context.colors.surfaceMuted,
                  border: Border.all(color: context.colors.borderStrong),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: context.colors.foreground,
                  size: 21.sp,
                ),
              ),
              Positioned(
                right: 11.w,
                top: 11.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: context.colors.accentRed,
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
            color: selected
                ? context.colors.accentRed
                : context.colors.surfaceRaised,
            borderRadius: BorderRadius.circular(999.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(999.r),
              onTap: () => onSelected(tab),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : context.colors.borderStrong,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: context.colors.accentRed
                                .withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : context.colors.mutedForeground,
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
  final TmdbItem? hero;
  final bool isBookmarked;
  final VoidCallback onDetailsPressed;
  final VoidCallback onWatchlistPressed;

  const _HeroCard({
    required this.hero,
    required this.isBookmarked,
    required this.onDetailsPressed,
    required this.onWatchlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = hero != null
        ? (hero!.backdropUrl.isNotEmpty ? hero!.backdropUrl : hero!.posterUrl)
        : '';

    return Container(
      height: 284.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: context.colors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
              color: Colors.black54, blurRadius: 26, offset: Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: context.colors.surfaceMuted))
            else
              Container(color: context.colors.surfaceMuted),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.colors.accentRed,
                        borderRadius: BorderRadius.circular(999.r),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.accentRed
                                .withValues(alpha: 0.32),
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
                  if (hero != null)
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: context.colors.tertiary, size: 16.sp),
                        SizedBox(width: 3.w),
                        Text(
                          hero!.ratingDisplay,
                          style: TextStyle(
                            color: context.colors.tertiary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          hero!.mediaTypeLabel,
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hero!.year.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Text(
                            hero!.year,
                            style: TextStyle(
                              color: context.colors.mutedSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  SizedBox(height: 6.h),
                  Text(
                    hero?.title ?? '',
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
                          label: isBookmarked ? 'In Watchlist' : 'Watchlist',
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.add_rounded,
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
            context.colors.accentPurple.withValues(alpha: 0.12),
            context.colors.accentRed.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: context.colors.accentRed.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.accentPink,
                  context.colors.accentPurple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Ranking Lists',
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '6 curated lists · Drag to reorder',
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: context.colors.mutedForeground, size: 22.sp),
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
        color: context.colors.surfaceMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.surfaceBorderAlt),
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
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentPurple,
                      context.colors.accentPink
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    size: 17.sp, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Mood Picker',
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "What's your vibe tonight?",
                    style: TextStyle(
                      color: context.colors.mutedSecondaryDeep,
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
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: context.colors.surfaceBorderAlt),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      color: context.colors.surfaceMuted,
                    ),
                    child: Icon(Icons.movie_rounded,
                        color: context.colors.mutedForeground, size: 22.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Pick for you',
                          style: TextStyle(
                            color: context.colors.mutedSecondaryHighlight,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Coming soon…',
                          style: TextStyle(
                            color: context.colors.foreground,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
      color: selected ? context.colors.accentRed : context.colors.surfaceChip,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : context.colors.surfaceChipBorder,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color:
                  selected ? Colors.white : context.colors.mutedSecondaryVibe,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
