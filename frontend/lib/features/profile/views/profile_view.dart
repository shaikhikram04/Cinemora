import 'dart:math' as math;

import 'package:cinemora/core/models/cinema_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/assets_path.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/profile/viewmodels/profile_cubit.dart';
import 'package:cinemora/features/profile/viewmodels/profile_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProfileCubit(ctx.read<UserRepository>())..loadProfile(),
      child: const _ProfileContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  // Static achievement data — not yet backed by an API.
  static const _achievementItems = [
    _AchievementItem(
      title: 'Marathoner',
      subtitle: '1000+ hours watched',
      tier: 'LEGENDARY',
      badgeImage: AppImages.marathonerBadge,
      ringColor: Color(0xFFF2B64A),
      glowColor: Color(0xFF6D4A1E),
    ),
    _AchievementItem(
      title: 'Cinephile',
      subtitle: 'Watched 100 Titles',
      tier: 'RARE',
      badgeImage: AppImages.cinephileBadge,
      ringColor: Color(0xFF2CB6FF),
      glowColor: Color(0xFF3A5895),
    ),
    _AchievementItem(
      title: 'Critic',
      subtitle: 'Rated 200 Titles',
      tier: 'EPIC',
      badgeImage: AppImages.criticBadge,
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF60409A),
    ),
    _AchievementItem(
      title: 'Anime Explorer',
      subtitle: 'Watched 50 Anime',
      tier: 'RARE',
      badgeImage: AppImages.animeExplorerBadge,
      ringColor: Color(0xFF2CB6FF),
      glowColor: Color(0xFF3B5589),
    ),
    _AchievementItem(
      title: 'List Curator',
      subtitle: 'Created 10 Rankings',
      tier: 'EPIC',
      badgeImage: AppImages.listCuratorBadge,
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF5D3A9E),
    ),
    _AchievementItem(
      title: 'Completionist',
      subtitle: 'Finished 25 series',
      tier: 'COMMON',
      badgeImage: AppImages.completionistBadge,
      ringColor: Color(0xFF8C949F),
      glowColor: Color(0xFF4A556A),
    ),
    _AchievementItem(
      title: 'World Cinema Master',
      subtitle: '18 / 50 countries',
      badgeImage: AppImages.marathonerBadge,
      tier: 'LEGENDARY',
      ringColor: Color(0xFFF2B64A),
      glowColor: Color(0xFFAE8D6B),
      isLocked: true,
      progress: 0.36,
    ),
    _AchievementItem(
      title: "Director's Eye",
      subtitle: '11 / 20 directors',
      badgeImage: AppImages.cinephileBadge,
      tier: 'EPIC',
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF635090),
      isLocked: true,
      progress: 0.55,
    ),
    _AchievementItem(
      title: '???',
      subtitle: 'Hidden Achievement',
      badgeImage: AppImages.criticBadge,
      tier: 'HIDDEN',
      ringColor: Color(0xFF3C414D),
      glowColor: Color(0xFF3A4251),
      isLocked: true,
      progress: 0.0,
      isHidden: true,
    ),
  ];

  // Static ranking data — will be replaced when the Rankings feature is wired.
  static const _rankingCards = [
    _RankingCardData(
      title: 'Top Sci-Fi Movies',
      updated: 'Updated 2d ago',
      count: 12,
      color: Color(0xFF111C36),
      image:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
    ),
    _RankingCardData(
      title: 'Best Psychological',
      updated: 'Updated 1w ago',
      count: 18,
      color: Color(0xFF3A1422),
      image:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=400&q=80',
    ),
    _RankingCardData(
      title: 'Top Anime Endings',
      updated: 'Updated 3w ago',
      count: 10,
      color: Color(0xFF3B1E17),
      image:
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=400&q=80',
    ),
    _RankingCardData(
      title: 'Greatest Series',
      updated: 'Updated 1mo ago',
      count: 15,
      color: Color(0xFF142A22),
      image:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppAuthCubit, AppAuthState>(
      builder: (context, authState) {
        final user = authState is AppAuthAuthenticated ? authState.user : null;

        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return Container(
              color: context.colors.background,
              child: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: context.colors.accentRed,
                  backgroundColor: context.colors.surfaceRaised,
                  onRefresh: () => context.read<ProfileCubit>().loadProfile(),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      12.h,
                      WSizes.screenPadding.w,
                      90.h,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      const _TopBar(),
                      SizedBox(height: 14.h),
                      _ProfileCard(user: user),
                      SizedBox(height: 14.h),
                      _StatGrid(
                        stats: profileState.stats,
                        isLoading: profileState.status == ProfileStatus.loading,
                      ),
                      SizedBox(height: 32.h),
                      const _SectionHeader(
                        title: 'Your Cinema Journey',
                        subtitle: 'An evolving portrait of your taste',
                      ),
                      SizedBox(height: 10.h),
                      _InsightCard(
                        stats: profileState.stats,
                        user: user,
                        isLoading: profileState.status == ProfileStatus.loading,
                      ),
                      SizedBox(height: 32.h),
                      const _SectionHeader(
                        title: 'Collection',
                        subtitle: 'Your library at a glance',
                      ),
                      SizedBox(height: 10.h),
                      _CollectionCard(
                        stats: profileState.stats,
                        isLoading: profileState.status == ProfileStatus.loading,
                      ),
                      SizedBox(height: 32.h),
                      const _SectionHeader(
                        title: 'Taste Profile',
                        subtitle: 'What defines your watch list',
                      ),
                      SizedBox(height: 10.h),
                      _TasteProfileSection(user: user),
                      SizedBox(height: 32.h),
                      _SectionHeader(
                        title: 'Top Favorites',
                        subtitle: 'Your trophy shelf',
                        trailing: const _SeeAllChip(label: 'See all'),
                      ),
                      SizedBox(height: 16.h),
                      _TopFavoritesRow(
                        entries: profileState.topFavorites,
                        isLoading: profileState.status == ProfileStatus.loading,
                      ),
                      SizedBox(height: 32.h),
                      _SectionHeader(
                        title: '🏆 Hall of Achievements',
                        subtitle: 'A trophy cabinet of your cinema journey',
                        trailing: Column(
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: '6',
                                  style: TextStyle(
                                    color: context.colors.foreground,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / 9',
                                  style: TextStyle(
                                    color: context.colors.mutedSecondaryVibe,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'EARNED',
                              style: TextStyle(
                                  color: context.colors.mutedSecondary,
                                  fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _AchievementHallCard(items: _achievementItems),
                      SizedBox(height: 32.h),
                      _SectionHeader(
                        title: 'My Rankings',
                        subtitle: 'Curated lists',
                        trailing: const _SeeAllChip(label: 'See all'),
                      ),
                      SizedBox(height: 16.h),
                      _RankingGrid(cards: _rankingCards),
                      SizedBox(height: 32.h),
                      const _SectionHeader(
                        title: 'Recent Activity',
                        subtitle: 'The latest from your archive',
                      ),
                      SizedBox(height: 10.h),
                      _ActivityCard(
                        entries: profileState.recentActivity,
                        isLoading: profileState.status == ProfileStatus.loading,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.settings),
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: context.colors.surfaceRaised.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 20.sp,
              color: context.colors.mutedSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile card
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserModel? user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '—';
    final username = user?.displayUsername ?? '—';
    final bio = user?.bio ?? 'Film • Anime • Series';
    final avatarUrl = user?.avatar;

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: context.colors.surfaceRaised,
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentPurple.withValues(alpha: 0.8),
                      context.colors.accentRed.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 48.r,
                  backgroundColor: context.colors.surfaceRaised2,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person_rounded,
                          size: 40.sp, color: context.colors.mutedSecondary)
                      : null,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                name,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '@$username',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.mutedSecondarySoft,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.editProfile),
                    child: _ActionButton(
                      label: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      gradient: LinearGradient(
                        colors: [
                          context.colors.accentRed,
                          context.colors.accentRedAlt,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _ActionButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    background:
                        context.colors.surfaceRaised.withValues(alpha: 0.2),
                    border: context.colors.borderStrong,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? background;
  final Color? border;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.gradient,
    this.background,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: gradient,
        color: background,
        borderRadius: BorderRadius.circular(18.r),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: context.colors.primaryForeground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: context.colors.primaryForeground,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats grid
// ─────────────────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final LibraryStatsModel? stats;
  final bool isLoading;

  const _StatGrid({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEntries ?? 0;
    final movies = stats?.movies ?? 0;
    final series = stats?.tvShows ?? 0;
    final anime = stats?.anime ?? 0;
    final moviePct = total > 0 ? '${((movies / total) * 100).round()}%' : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Titles Watched',
                value: isLoading ? '—' : total.toString(),
                icon: Icons.movie_filter_rounded,
                color: context.colors.accentRed,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Movies',
                value: isLoading ? '—' : movies.toString(),
                icon: Icons.local_movies_rounded,
                color: context.colors.accentRedAlt,
                badge: isLoading ? null : moviePct,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Series',
                value: isLoading ? '—' : series.toString(),
                icon: Icons.tv_rounded,
                color: context.colors.chartPurple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Anime',
                value: isLoading ? '—' : anime.toString(),
                icon: Icons.auto_awesome_rounded,
                color: context.colors.chartYellow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.colors.mutedSecondaryDeep,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight card
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final LibraryStatsModel? stats;
  final UserModel? user;
  final bool isLoading;

  const _InsightCard({
    required this.stats,
    required this.user,
    required this.isLoading,
  });

  String _buildInsightText() {
    if (stats == null) {
      return "Start watching to build your cinema journey.";
    }
    final total = stats!.totalEntries;
    final hours = stats!.totalWatchHours;
    final topGenre = stats!.topGenreName ??
        (user?.preferences.genres.isNotEmpty == true
            ? user!.preferences.genres.first
            : 'Drama');

    return "You've watched $total titles across Movies, Series and Anime. "
        "$topGenre stories dominate your collection. "
        "You've spent $hours hours watching.";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF2B1C29),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -40,
            left: -10,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 80,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.3),
                    blurRadius: 150,
                    offset: const Offset(0, 10),
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Pill(label: 'INSIGHT', icon: Icons.auto_awesome_rounded),
                SizedBox(height: 10.h),
                isLoading
                    ? _LoadingPlaceholder(height: 60.h)
                    : Text(
                        _buildInsightText(),
                        style: TextStyle(
                          color: context.colors.mutedSecondarySoft,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection card (ring chart)
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionCard extends StatelessWidget {
  final LibraryStatsModel? stats;
  final bool isLoading;

  const _CollectionCard({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEntries ?? 0;
    final movies = stats?.movies ?? 0;
    final series = stats?.tvShows ?? 0;
    final anime = stats?.anime ?? 0;

    final movieFrac = total > 0 ? movies / total : 0.62;
    final seriesFrac = total > 0 ? series / total : 0.25;
    final animeFrac = total > 0 ? anime / total : 0.13;

    final moviePct = total > 0 ? '${((movies / total) * 100).round()}%' : '0%';
    final seriesPct = total > 0 ? '${((series / total) * 100).round()}%' : '0%';
    final animePct = total > 0 ? '${((anime / total) * 100).round()}%' : '0%';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.colors.surfaceChipBorder.withValues(alpha: 0.6),
        ),
      ),
      child: isLoading
          ? _LoadingPlaceholder(height: 180.h + 80.h)
          : Column(
              children: [
                SizedBox(
                  width: 180.w,
                  height: 180.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(180.w, 180.w),
                        painter: _RingChartPainter(
                          values: [movieFrac, seriesFrac, animeFrac],
                          colors: [
                            context.colors.accentRed,
                            context.colors.chartPurple,
                            context.colors.chartYellow,
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: context.colors.foreground,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'TITLES',
                            style: TextStyle(
                              color: context.colors.mutedSecondaryDeep,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _LegendItem(
                        label: 'Movies',
                        value: movies.toString(),
                        percent: moviePct,
                        color: context.colors.accentRed,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _LegendItem(
                        label: 'Series',
                        value: series.toString(),
                        percent: seriesPct,
                        color: context.colors.chartPurple,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _LegendItem(
                        label: 'Anime',
                        value: anime.toString(),
                        percent: animePct,
                        color: context.colors.chartYellow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised2,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                percent,
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Taste profile
// ─────────────────────────────────────────────────────────────────────────────

class _TasteProfileSection extends StatelessWidget {
  final UserModel? user;

  const _TasteProfileSection({required this.user});

  static final _genreColors = {
    'Drama': const Color(0xFFE74D5B), // accentRedAlt
    'Thriller': const Color(0xFFE0A838), // warning
    'Psychological': const Color(0xFFFBBF24), // chartYellow
    'Crime': const Color(0xFF60A5FA), // chartBlue
    'Sci-Fi': const Color(0xFFA78BFA), // chartPurple
    'Mystery': const Color.fromARGB(255, 188, 113, 225),
    'Action': const Color(0xFFE84B57), // accentRed
    'Horror': const Color(0xFFE74D5B), // accentRedAlt
    'Romance': const Color(0xFFFF6B8A),
    'Fantasy': const Color(0xFFA78BFA), // chartPurple
    'Documentary': const Color(0xFF10B981), // chartGreen
    'Animation': const Color(0xFFFBBF24), // chartYellow
  };

  static final Color _defaultColor = const Color(0xFF8F96A3); // mutedSecondary

  String _computePersonality(List<String> genres) {
    if (genres.contains('Psychological') || genres.contains('Drama')) {
      return 'The Story Seeker';
    }
    if (genres.contains('Sci-Fi') || genres.contains('Fantasy')) {
      return 'The World Builder';
    }
    if (genres.contains('Action') || genres.contains('Thriller')) {
      return 'The Thrill Seeker';
    }
    if (genres.contains('Crime') || genres.contains('Mystery')) {
      return 'The Detective';
    }
    if (genres.contains('Horror')) return 'The Brave Soul';
    if (genres.contains('Romance')) return 'The Romantic';
    return 'The Explorer';
  }

  String _personalityDesc(String personality) {
    switch (personality) {
      case 'The Story Seeker':
        return 'You enjoy emotionally driven stories, psychological mysteries and character-focused narratives.';
      case 'The World Builder':
        return 'You love expansive universes, speculative fiction and stories that challenge imagination.';
      case 'The Thrill Seeker':
        return 'You crave high-stakes action, suspense and edge-of-your-seat storytelling.';
      case 'The Detective':
        return 'You\'re drawn to puzzles, moral ambiguity and stories where secrets slowly unravel.';
      case 'The Brave Soul':
        return 'You embrace tension, atmosphere and the art of facing the unknown.';
      case 'The Romantic':
        return 'You appreciate human connection, heartfelt stories and emotional depth.';
      default:
        return 'Your taste spans genres and styles — you watch everything.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = user?.preferences.genres ?? [];
    final era = user?.preferences.era ?? '2010s';
    final language = user?.preferences.languages.isNotEmpty == true
        ? user!.preferences.languages.first
        : 'English';
    final personality = _computePersonality(genres);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genres.isEmpty
            ? Text(
                'No genres set yet — edit your profile to add taste.',
                style: TextStyle(
                    color: context.colors.mutedSecondary, fontSize: 13.sp),
              )
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: genres
                    .map((g) => _TagChip(
                          label: g,
                          color: _genreColors[g] ?? _defaultColor,
                        ))
                    .toList(growable: false),
              ),
        SizedBox(height: 16.h),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: context.colors.borderStrong),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -40,
                left: -10,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            context.colors.accentPurple.withValues(alpha: 0.3),
                        blurRadius: 80,
                        offset: const Offset(0, 10),
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accentRed.withValues(alpha: 0.3),
                        blurRadius: 150,
                        offset: const Offset(0, 10),
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIEWING PERSONALITY',
                      style: TextStyle(
                        color: context.colors.mutedSecondaryDeep,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      personality,
                      style: TextStyle(
                        color: context.colors.accentRedAlt,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _personalityDesc(personality),
                      style: TextStyle(
                        color: context.colors.mutedSecondarySoft,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                title: 'FAVORITE ERA',
                value: era,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _InfoTile(
                title: 'LANGUAGE',
                value: language,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Favorites
// ─────────────────────────────────────────────────────────────────────────────

class _TopFavoritesRow extends StatelessWidget {
  final List<LibraryEntryModel> entries;
  final bool isLoading;

  const _TopFavoritesRow({required this.entries, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: WSizes.imageCarouselHeight.h,
        child: const Center(child: _LoadingSpinner()),
      );
    }

    if (entries.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: Text(
          'Rate watched titles to see your top favorites.',
          style:
              TextStyle(color: context.colors.mutedSecondary, fontSize: 13.sp),
        ),
      );
    }

    return SizedBox(
      height: WSizes.imageCarouselHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return VerticalPosterBookmarkCard(
            image: entry.posterUrl,
            width: WSizes.posterImageWidth,
            imageHeight: WSizes.posterImageHeight,
            title: entry.title,
            rating: (entry.userRating ?? 0).toStringAsFixed(1),
            cinemaType: CinemaType.movie,
            year: entry.releaseYear ?? '',
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Achievements (static)
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementHallCard extends StatelessWidget {
  final List<_AchievementItem> items;

  const _AchievementHallCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = items.where((item) => !item.isLocked).length;
    final totalCount = items.length;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: context.colors.borderStrong),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COLLECTION PROGRESS',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${((unlockedCount / totalCount) * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(
                      color: context.colors.warning,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: LinearProgressIndicator(
                  value: unlockedCount / totalCount,
                  minHeight: 8.h,
                  backgroundColor:
                      context.colors.surfaceTint.withValues(alpha: 0.7),
                  valueColor: AlwaysStoppedAnimation(context.colors.warning),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${totalCount - unlockedCount} remaining — keep watching to unlock more.',
                style: TextStyle(
                  color: context.colors.mutedSecondaryAlt,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 184.h,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => SizedBox(
              width: 142.w,
              child: _AchievementBadge(item: items[index]),
            ),
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final _AchievementItem item;

  const _AchievementBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final progressValue =
        item.isHidden ? 0.0 : (item.isLocked ? item.progress : 1.0);

    return Column(
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (!item.isLocked && !item.isHidden)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.glowColor,
                        blurRadius: 36.r,
                        spreadRadius: 4.r,
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 142.r,
                height: 142.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 142.r,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          progress: progressValue,
                          color: item.ringColor,
                          backgroundColor:
                              context.colors.surfaceTint.withValues(alpha: 0.6),
                          strokeWidth: 3.r,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Container(
                        width: 136.r,
                        height: 136.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              context.colors.background.withValues(alpha: 0.8),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (item.badgeImage != null)
                              Opacity(
                                opacity:
                                    item.isHidden || item.isLocked ? 0.2 : 1.0,
                                child: Image.asset(
                                  item.badgeImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            if (item.isHidden)
                              Icon(Icons.question_mark,
                                  size: 32.sp,
                                  color: context.colors.mutedSecondary)
                            else if (item.isLocked)
                              Icon(Icons.lock_outline_rounded,
                                  size: 28.sp,
                                  color: context.colors.mutedSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item.tier.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: item.isHidden || item.isLocked
                ? context.colors.mutedSecondary
                : item.ringColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          item.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: item.isHidden || item.isLocked
                ? context.colors.mutedSecondary
                : context.colors.foreground,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.mutedSecondary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rankings (static)
// ─────────────────────────────────────────────────────────────────────────────

class _RankingGrid extends StatelessWidget {
  final List<_RankingCardData> cards;

  const _RankingGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _RankingCard(item: cards[0])),
            SizedBox(width: 12.w),
            Expanded(child: _RankingCard(item: cards[1])),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _RankingCard(item: cards[2])),
            SizedBox(width: 12.w),
            Expanded(child: _RankingCard(item: cards[3])),
          ],
        ),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  final _RankingCardData item;

  const _RankingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 108.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              color: item.color,
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 10.w,
                  top: 10.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: context.colors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_rounded,
                            size: 12.sp,
                            color: context.colors.primaryForeground),
                        SizedBox(width: 4.w),
                        Text(
                          item.count.toString(),
                          style: TextStyle(
                            color: context.colors.primaryForeground,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.updated,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Activity
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final List<LibraryEntryModel> entries;
  final bool isLoading;

  const _ActivityCard({required this.entries, required this.isLoading});

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}w ago';
    return '${(diff.inDays / 30).round()}mo ago';
  }

  static _ActivityData _toActivity(LibraryEntryModel e) {
    final time = '${e.displayType}  •  ${_timeAgo(e.updatedAt)}';
    if (e.status == WatchStatus.watched && (e.userRating ?? 0) > 0) {
      return _ActivityData(
        icon: Icons.star_border_rounded,
        title: 'Rated ${e.title}',
        subtitle: time,
        rating: e.userRating,
      );
    }
    if (e.status == WatchStatus.watched) {
      return _ActivityData(
        icon: Icons.remove_red_eye_rounded,
        title: 'Finished ${e.title}',
        subtitle: time,
      );
    }
    if (e.status == WatchStatus.watching) {
      return _ActivityData(
        icon: Icons.play_circle_outline_rounded,
        title: 'Watching ${e.title}',
        subtitle: time,
      );
    }
    if (e.status == WatchStatus.dropped) {
      return _ActivityData(
        icon: Icons.cancel_outlined,
        title: 'Dropped ${e.title}',
        subtitle: time,
      );
    }
    return _ActivityData(
      icon: Icons.bookmark_border_rounded,
      title: 'Added ${e.title} to Watchlist',
      subtitle: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: const _LoadingSpinner(),
      );
    }

    if (entries.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: Text(
          'No activity yet — add titles to your library.',
          style:
              TextStyle(color: context.colors.mutedSecondary, fontSize: 13.sp),
        ),
      );
    }

    final items = entries.map(_toActivity).toList();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (i) => _ActivityRow(
            item: items[i],
            showDivider: i != items.length - 1,
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityData item;
  final bool showDivider;

  const _ActivityRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.borderStrong),
                ),
                child: Icon(item.icon,
                    size: 18.sp, color: context.colors.mutedSecondary),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        if (item.rating != null) ...[
                          SizedBox(
                            width: 60.w,
                            child: Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
                                  padding: EdgeInsets.only(right: 2.w),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 10.sp,
                                    color: i < item.rating!.floor()
                                        ? context.colors.mutedSecondary
                                        : context.colors.surfaceTint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text('•  ',
                              style: TextStyle(
                                  color: context.colors.mutedSecondary,
                                  fontSize: 10.sp)),
                        ],
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider)
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 1.2,
              height: 28.h,
              color: context.colors.borderStrong,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Pill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: context.colors.mutedSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeAllChip extends StatelessWidget {
  final String label;

  const _SeeAllChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.mutedSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double height;

  const _LoadingPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceTint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.colors.accentRed,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint..color = backgroundColor);

    if (progress <= 0) return;

    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      basePaint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.backgroundColor != backgroundColor ||
      old.strokeWidth != strokeWidth;
}

class _RingChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _RingChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.w;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    var start = -1.57;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] * 6.283185307179586;
      paint.color = colors[i];
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep + 0.06;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementItem {
  final String title;
  final String subtitle;
  final String tier;
  final String? badgeImage;
  final Color ringColor;
  final Color glowColor;
  final bool isLocked;
  final bool isHidden;
  final double progress;

  const _AchievementItem({
    required this.title,
    required this.subtitle,
    required this.tier,
    this.badgeImage,
    required this.ringColor,
    required this.glowColor,
    this.isLocked = false,
    this.isHidden = false,
    this.progress = 0.0,
  });
}

class _RankingCardData {
  final String title;
  final String updated;
  final int count;
  final Color color;
  final String image;

  const _RankingCardData({
    required this.title,
    required this.updated,
    required this.count,
    required this.color,
    required this.image,
  });
}

class _ActivityData {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? rating;

  const _ActivityData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.rating,
  });
}
