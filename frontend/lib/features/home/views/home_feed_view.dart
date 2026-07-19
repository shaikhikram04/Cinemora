import 'dart:async';

import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/watch_status.dart';
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
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/views/mood_chat_view.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_cubit.dart';
import 'package:cinemora/features/home/viewmodels/home_feed_state.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_cubit.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_state.dart';

final _kTabs = homeTabs.map((t) => t.label).toList();

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
      create: (ctx) =>
          HomeFeedCubit(ctx.read<HomeRepository>(), ctx.read<LibraryCubit>()),
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
      // Bookmark toggles (here or anywhere else in the app) only change
      // libraryStatus — every poster card resolves its own bookmark status
      // via a scoped BlocSelector below, so this rebuild would otherwise
      // tear down and rebuild the entire feed (hero, all carousels, images)
      // for a single icon flip.
      buildWhen: (prev, curr) =>
          prev.copyWith(libraryStatus: const {}) !=
          curr.copyWith(libraryStatus: const {}),
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

                // Hero — Pick of the Week (falls back to the top trending item
                // when the user has no personalized picks yet, e.g. cold start).
                if (loading)
                  _HeroCardSkeleton()
                else if (state.status == FeedStatus.failure)
                  _ErrorBanner(
                      message: state.errorMessage, onRetry: cubit.loadFeed)
                else if (state.pickOfWeek.isNotEmpty)
                  _PickOfWeekHero(
                    picks: state.pickOfWeek,
                    onBookmark: (item) => cubit.bookmarkFromPoster(
                      item,
                      CinemaType.fromJson(item.cinemaType ?? 'movie'),
                    ),
                    onDetails: (item) => _navigateToMixedPoster(context, item),
                  )
                else if (state.trending.isNotEmpty)
                  _FallbackHero(
                    item: state.trending.first,
                    type: state.trendingType,
                    onDetails: () => _navigateToTyped(
                        context, state.trending.first, state.trendingType),
                    onBookmark: () => cubit.bookmarkFromPoster(
                        state.trending.first, state.trendingType),
                  ),
                SizedBox(height: 24.h),

                // Trending Now — scoped to the selected tab's type.
                // Hidden entirely (not just the carousel) when the fetch
                // failed and left the list empty, so no orphaned header
                // floats over blank space.
                if (loading || state.trending.isNotEmpty) ...[
                  WSectionHeader(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: context.colors.accentRed,
                    title: 'Trending Now',
                  ),
                  SizedBox(height: 10.h),
                  loading
                      ? _SkeletonCarousel()
                      : _PosterCarousel(
                          items: state.trending,
                          type: state.trendingType,
                          onBookmark: (item) => cubit.bookmarkFromPoster(
                              item, state.trendingType),
                          onTap: (item) => _navigateToTyped(
                              context, item, state.trendingType),
                        ),
                  SizedBox(height: 24.h),
                ],

                if (state.becauseYouRanked.isNotEmpty) ...[
                  // Because You Ranked <anchor>
                  WSectionHeader(
                    icon: Icons.favorite_rounded,
                    iconColor: context.colors.accentRed,
                    title: state.becauseYouRankedAnchorTitle != null
                        ? 'Because You Ranked ${state.becauseYouRankedAnchorTitle}'
                        : 'Because You Ranked This',
                  ),
                  SizedBox(height: 10.h),
                  _PosterCarousel(
                    items: state.becauseYouRanked,
                    type: CinemaType.movie,
                    onBookmark: (item) => cubit.bookmarkFromPoster(
                      item,
                      CinemaType.fromJson(item.cinemaType ?? 'movie'),
                    ),
                    onTap: (item) => _navigateToMixedPoster(context, item),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Critically Acclaimed — hidden entirely when empty (see
                // Trending Now above for why).
                if (loading || state.criticallyAcclaimed.isNotEmpty) ...[
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
                          onBookmark: (item) => cubit.bookmarkFromPoster(
                            item,
                            CinemaType.fromJson(item.cinemaType ?? 'movie'),
                          ),
                          onTap: (item) =>
                              _navigateToMixedPoster(context, item),
                        ),
                  SizedBox(height: 24.h),
                ],

                _MoodPickerCard(
                  onOpen: ([String? starter]) => context.push(
                    AppRoutes.moodChat,
                    extra: MoodChatArgs(starter: starter),
                  ),
                ),
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

// Fixed-type carousels (Trending Now) — every item is the carousel's own
// cinema type, so route by that type directly.
void _navigateToTyped(BuildContext context, MoviePoster item, CinemaType type) {
  if (type == CinemaType.movie) {
    context.push(
      AppRoutes.movieDetails,
      extra: MovieRouteArgs(
        title: item.title,
        image: item.image,
        backdropImage: item.backdropImage,
        rating: item.rating,
        id: item.id,
      ),
    );
  } else {
    context.push(
      AppRoutes.seriesDetails,
      extra: SeriesRouteArgs(
        title: item.title,
        image: item.image,
        backdropImage: item.backdropImage,
        rating: item.rating,
        id: item.id,
        source: type == CinemaType.anime ? 'jikan' : 'tmdb',
      ),
    );
  }
}

// Shared by mixed-type carousels (Critically Acclaimed, Because You Ranked)
// where each poster may carry its own cinemaType/source rather than the
// carousel's fixed type — routes to the right detail screen per item.
void _navigateToMixedPoster(BuildContext context, MoviePoster item) {
  if (item.cinemaType == null || item.cinemaType == 'movie') {
    context.push(
      AppRoutes.movieDetails,
      extra: MovieRouteArgs(
        title: item.title,
        image: item.image,
        backdropImage: item.backdropImage,
        rating: item.rating,
        id: item.id,
      ),
    );
  } else {
    context.push(
      AppRoutes.seriesDetails,
      extra: SeriesRouteArgs(
        title: item.title,
        image: item.image,
        backdropImage: item.backdropImage,
        rating: item.rating,
        id: item.id,
        source: item.cinemaType == 'anime' ? 'jikan' : 'tmdb',
      ),
    );
  }
}

// ── Poster carousel ───────────────────────────────────────────────────────────

class _PosterCarousel extends StatelessWidget {
  final List<MoviePoster> items;
  final CinemaType type;
  final void Function(MoviePoster) onTap;
  final void Function(MoviePoster) onBookmark;

  const _PosterCarousel({
    required this.items,
    required this.type,
    required this.onTap,
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
          // Scoped to this item's bookmark status only, so toggling one
          // card's bookmark doesn't rebuild the rest of the carousel.
          return BlocSelector<HomeFeedCubit, HomeFeedState, WatchStatus?>(
            selector: (s) => item.id != null ? s.libraryStatus[item.id] : null,
            builder: (context, watchStatus) => VerticalPosterBookmarkCard(
              image: item.image,
              width: WSizes.posterImageWidth.w,
              imageHeight: WSizes.posterImageHeight.h,
              title: item.title,
              rating: item.rating,
              cinemaType: item.cinemaType != null
                  ? CinemaType.fromJson(item.cinemaType!)
                  : type,
              year: item.year,
              watchStatus: watchStatus,
              onBookmark: () => onBookmark(item),
              onTap: () => onTap(item),
            ),
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
              // Unread dot — driven by the app-level NotificationsCubit so it
              // clears live as items are read in the inbox.
              BlocSelector<NotificationsCubit, NotificationsState, bool>(
                selector: (state) => state.unreadCount > 0,
                builder: (context, hasUnread) => hasUnread
                    ? Positioned(
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
                      )
                    : const SizedBox.shrink(),
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

// ── Pick of the Week hero (swipeable) ─────────────────────────────────────────

class _PickOfWeekHero extends StatefulWidget {
  final List<MoviePoster> picks;
  final void Function(MoviePoster) onBookmark;
  final void Function(MoviePoster) onDetails;

  const _PickOfWeekHero({
    required this.picks,
    required this.onBookmark,
    required this.onDetails,
  });

  @override
  State<_PickOfWeekHero> createState() => _PickOfWeekHeroState();
}

class _PickOfWeekHeroState extends State<_PickOfWeekHero> {
  final _controller = PageController();
  int _page = 0;
  Timer? _autoScrollTimer;

  static const _autoScrollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.picks.length <= 1) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % widget.picks.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _PickOfWeekHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.picks.length != widget.picks.length) _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 284.h,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _autoScrollTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.picks.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final item = widget.picks[i];
                return BlocSelector<HomeFeedCubit, HomeFeedState, bool>(
                  selector: (s) =>
                      item.id != null &&
                      s.libraryStatus[item.id] == WatchStatus.watchlist,
                  builder: (context, isBookmarked) => _HeroCardShell(
                    imageUrl: item.image,
                    badgeLabel: 'PICK OF THE WEEK',
                    badgeIcon: Icons.auto_awesome_rounded,
                    rating: item.rating,
                    typeLabel: CinemaType.fromJson(item.cinemaType ?? 'movie')
                        .displayName,
                    year: item.year,
                    title: item.title,
                    isBookmarked: isBookmarked,
                    onDetailsPressed: () => widget.onDetails(item),
                    onWatchlistPressed: () => widget.onBookmark(item),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.picks.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.picks.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 18.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: active
                      ? context.colors.accentRed
                      : context.colors.mutedSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ── Fallback hero ─────────────────────────────────────────────────────────────

// Shown when the user has no personalized Pick of the Week yet (cold start /
// logged out): the top trending item of the current tab, single card.
class _FallbackHero extends StatelessWidget {
  final MoviePoster item;
  final CinemaType type;
  final VoidCallback onDetails;
  final VoidCallback onBookmark;

  const _FallbackHero({
    required this.item,
    required this.type,
    required this.onDetails,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeFeedCubit, HomeFeedState, bool>(
      selector: (s) =>
          item.id != null && s.libraryStatus[item.id] == WatchStatus.watchlist,
      builder: (context, isBookmarked) => _HeroCardShell(
        imageUrl: item.image,
        badgeLabel: 'TRENDING #1',
        badgeIcon: Icons.local_fire_department_rounded,
        rating: item.rating,
        typeLabel: type.displayName,
        year: item.year,
        title: item.title,
        isBookmarked: isBookmarked,
        onDetailsPressed: onDetails,
        onWatchlistPressed: onBookmark,
      ),
    );
  }
}

// ── Shared hero visual ────────────────────────────────────────────────────────

class _HeroCardShell extends StatelessWidget {
  final String imageUrl;
  final String badgeLabel;
  final IconData badgeIcon;
  final String rating;
  final String typeLabel;
  final String year;
  final String title;
  final bool isBookmarked;
  final VoidCallback onDetailsPressed;
  final VoidCallback onWatchlistPressed;

  const _HeroCardShell({
    required this.imageUrl,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.rating,
    required this.typeLabel,
    required this.year,
    required this.title,
    required this.isBookmarked,
    required this.onDetailsPressed,
    required this.onWatchlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenW = MediaQuery.of(context).size.width;
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
                  // Width only — passing both dims stretches the decode
                  // to that exact box and distorts the image if its real
                  // aspect ratio doesn't match.
                  cacheWidth: (screenW * dpr).round(),
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
                          Icon(badgeIcon, size: 13.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            badgeLabel,
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
                          color: context.colors.tertiary, size: 16.sp),
                      SizedBox(width: 3.w),
                      Text(
                        rating,
                        style: TextStyle(
                          color: context.colors.tertiary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          color: context.colors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (year.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          year,
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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ── Mood picker card ──────────────────────────────────────────────────────────

// Maps the quick-mood chips to a natural opening message for the chat.
const _kMoodStarters = {
  'Emotional': "I'm feeling emotional tonight — something that'll move me.",
  'Mind-Blown': 'I want something mind-blowing.',
  'Scared': "I'm in the mood for something scary.",
};

class _MoodPickerCard extends StatelessWidget {
  // Opens the mood chat, optionally seeded with a starter message.
  final void Function([String? starter]) onOpen;

  const _MoodPickerCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onOpen(),
      child: Container(
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
                Expanded(
                  child: Column(
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
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.colors.mutedForeground, size: 22.sp),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _kMoods.map((mood) {
                return _MoodChip(
                  text: '${mood.emoji} ${mood.label}',
                  selected: false,
                  onTap: () => onOpen(_kMoodStarters[mood.label]),
                );
              }).toList(),
            ),
          ],
        ),
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
