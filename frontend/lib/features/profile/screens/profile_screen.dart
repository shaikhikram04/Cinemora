import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _profileImage =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80';

  static const _favoritePosters = [
    _PosterItem(
      image:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
      title: 'Interstellar',
      rating: 5.0,
      tag: 'Movie',
    ),
    _PosterItem(
      image:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=400&q=80',
      title: 'Whiplash',
      rating: 4.8,
      tag: 'Movie',
    ),
    _PosterItem(
      image:
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=400&q=80',
      title: 'Monster',
      rating: 5.0,
      tag: 'Anime',
    ),
  ];

  static const _achievementItems = [
    _AchievementItem(
      title: 'Marathoner',
      subtitle: '1000+ hours watched',
      tier: 'LEGENDARY',
      badgeImage: 'assets/images/achievement_badges/marathoner_badge.png',
      ringColor: Color(0xFFF2B64A),
      glowColor: Color(0xFF6D4A1E),
    ),
    _AchievementItem(
      title: 'Cinephile',
      subtitle: 'Watched 100 Titles',
      tier: 'RARE',
      badgeImage: 'assets/images/achievement_badges/cinephile_badge.png',
      ringColor: Color(0xFF2CB6FF),
      glowColor: Color(0xFF3A5895),
    ),
    _AchievementItem(
      title: 'Critic',
      subtitle: 'Rated 200 Titles',
      tier: 'EPIC',
      badgeImage: 'assets/images/achievement_badges/critic_badge.png',
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF60409A),
    ),
    _AchievementItem(
      title: 'Anime Explorer',
      subtitle: 'Watched 50 Anime',
      tier: 'RARE',
      badgeImage: 'assets/images/achievement_badges/anime_exploler_badge.png',
      ringColor: Color(0xFF2CB6FF),
      glowColor: Color(0xFF3B5589),
    ),
    _AchievementItem(
      title: 'List Curator',
      subtitle: 'Created 10 Rankings',
      tier: 'EPIC',
      badgeImage: 'assets/images/achievement_badges/list_curator_badge.png',
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF5D3A9E),
    ),
    _AchievementItem(
      title: 'Completionist',
      subtitle: 'Finished 25 series',
      tier: 'COMMON',
      badgeImage: 'assets/images/achievement_badges/completionist_badge.png',
      ringColor: Color(0xFF8C949F),
      glowColor: Color(0xFF4A556A),
    ),
    _AchievementItem(
      title: 'World Cinema Master',
      subtitle: '18 / 50 countries',
      badgeImage: 'assets/images/achievement_badges/marathoner_badge.png',
      tier: 'LEGENDARY',
      ringColor: Color(0xFFF2B64A),
      glowColor: Color(0xFFAE8D6B),
      isLocked: true,
      progress: 0.36,
    ),
    _AchievementItem(
      title: "Director's Eye",
      subtitle: '11 / 20 directors',
      badgeImage: 'assets/images/achievement_badges/cinephile_badge.png',
      tier: 'EPIC',
      ringColor: Color(0xFF8C5CFF),
      glowColor: Color(0xFF635090),
      isLocked: true,
      progress: 0.55,
    ),
    _AchievementItem(
      title: '???',
      subtitle: 'Hidden Achievement',
      badgeImage: 'assets/images/achievement_badges/critic_badge.png',
      tier: 'HIDDEN',
      ringColor: Color(0xFF3C414D),
      glowColor: Color(0xFF3A4251),
      isLocked: true,
      progress: 0.0,
      isHidden: true,
    ),
  ];

  static const _tasteTags = [
    _TasteTag('Drama', WColors.accentRedAlt),
    _TasteTag('Thriller', WColors.warning),
    _TasteTag('Psychological', WColors.chartYellow),
    _TasteTag('Crime', WColors.chartBlue),
    _TasteTag('Sci-Fi', WColors.chartPurple),
    _TasteTag('Mystery', Color.fromARGB(255, 188, 113, 225)),
  ];

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

  static const _recentActivity = [
    _ActivityItem(
      icon: Icons.star_border_rounded,
      title: 'Rated Dune: Part Two',
      subtitle: '2h ago',
      rating: 4.5,
    ),
    _ActivityItem(
      icon: Icons.remove_red_eye_rounded,
      title: 'Finished Attack on Titan',
      subtitle: 'Anime  •  Yesterday',
    ),
    _ActivityItem(
      icon: Icons.favorite_border_rounded,
      title: 'Added Interstellar to Favorites',
      subtitle: 'Movie  •  2d ago',
    ),
    _ActivityItem(
      icon: Icons.list_alt_rounded,
      title: 'Created ranking: Best Sci-Fi Movies',
      subtitle: '12 titles  •  3d ago',
    ),
    _ActivityItem(
      icon: Icons.star_border_rounded,
      title: 'Rated Frieren',
      subtitle: '5d ago',
      rating: 4.5,
    ),
  ];

  static const _settings = [
    _SettingsItem(
      icon: Icons.palette_outlined,
      title: 'Appearance',
      subtitle: 'Theme, accent',
    ),
    _SettingsItem(
      icon: Icons.notifications_none_rounded,
      title: 'Notifications',
      subtitle: 'Releases, reminders',
    ),
    _SettingsItem(
      icon: Icons.shield_outlined,
      title: 'Privacy & Security',
      subtitle: 'Account, data',
    ),
    _SettingsItem(
      icon: Icons.support_agent_rounded,
      title: 'Support',
      subtitle: 'Help center',
    ),
    _SettingsItem(
      icon: Icons.info_outline_rounded,
      title: 'About',
      subtitle: 'Version 1.0.0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WColors.background,
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                WSizes.screenPadding.w,
                12.h,
                WSizes.screenPadding.w,
                90.h,
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                const _TopBar(),
                SizedBox(height: 14.h),
                _ProfileCard(profileImage: _profileImage),
                SizedBox(height: 14.h),
                const _StatGrid(),
                SizedBox(height: 32.h),
                const _SectionHeader(
                  title: 'Your Cinema Journey',
                  subtitle: 'An evolving portrait of your taste',
                ),
                SizedBox(height: 10.h),
                const _InsightCard(),
                SizedBox(height: 32.h),
                const _SectionHeader(
                  title: 'Collection',
                  subtitle: 'Your library at a glance',
                ),
                SizedBox(height: 10.h),
                const _CollectionCard(),
                SizedBox(height: 32.h),
                const _SectionHeader(
                  title: 'Taste Profile',
                  subtitle: 'What defines your watch list',
                ),
                SizedBox(height: 10.h),
                _TasteProfileSection(tags: _tasteTags),
                SizedBox(height: 32.h),
                _SectionHeader(
                  title: 'Top Favorites',
                  subtitle: 'Your trophy shelf',
                  trailing: const _SeeAllChip(label: 'See all'),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: WSizes.imageCarouselHeight.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => VerticalPosterBookmarkCard(
                      image: _favoritePosters[index].image,
                      width: WSizes.posterImageWidth,
                      imageHeight: WSizes.posterImageHeight,
                      title: _favoritePosters[index].title,
                      rating: _favoritePosters[index].rating.toStringAsFixed(1),
                      cinemaType: CinemaType.movie,
                      year: '2022',
                    ),
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemCount: _favoritePosters.length,
                  ),
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
                              color: WColors.foreground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' / 9',
                            style: TextStyle(
                              color: WColors.mutedSecondaryVibe,
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
                            color: WColors.mutedSecondary, fontSize: 10.sp),
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
                  trailing:
                      const _IconPill(icon: Icons.add_rounded, label: 'New'),
                ),
                SizedBox(height: 16.h),
                _RankingGrid(cards: _rankingCards),
                SizedBox(height: 32.h),
                const _SectionHeader(
                  title: 'Recent Activity',
                  subtitle: 'The latest from your archive',
                ),
                SizedBox(height: 10.h),
                _ActivityCard(items: _recentActivity),
                SizedBox(height: 32.h),
                const _SectionHeader(
                  title: 'Settings',
                  subtitle: 'Preferences & account',
                ),
                SizedBox(height: 10.h),
                _SettingsCard(items: _settings),
                SizedBox(height: 32.h),
                Text(
                  'Watchary - v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WColors.mutedSecondaryHeader,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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
              color: WColors.foreground,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: WColors.surfaceRaised.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: WColors.border),
          ),
          child: Icon(
            Icons.settings_rounded,
            size: 18.sp,
            color: WColors.mutedSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String profileImage;

  const _ProfileCard({required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: WColors.surfaceRaised,
        border: Border.all(color: WColors.borderStrong),
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
                    color: WColors.accentPurple.withValues(alpha: 0.4),
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
                    color: WColors.accentRed.withValues(alpha: 0.4),
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
                      WColors.accentPurple.withValues(alpha: 0.8),
                      WColors.accentRed.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 48.r,
                  backgroundColor: WColors.surfaceRaised2,
                  backgroundImage: NetworkImage(profileImage),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Ikram',
                style: TextStyle(
                  color: WColors.foreground,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '@ikram_watches',
                style: TextStyle(
                  color: WColors.mutedSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Film • Anime • Series\nEnthusiast',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WColors.mutedSecondarySoft,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_rounded,
                    gradient: LinearGradient(
                      colors: [
                        WColors.accentRed,
                        WColors.accentRedAlt,
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _ActionButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    background: WColors.surfaceRaised.withValues(alpha: 0.2),
                    border: WColors.borderStrong,
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
          Icon(icon, size: 14.sp, color: WColors.primaryForeground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: WColors.primaryForeground,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: _StatCard(
                label: 'Titles Watched',
                value: '523',
                icon: Icons.movie_filter_rounded,
                color: WColors.accentRed,
              ),
            ),
            SizedBox(width: 12.w),
            const Expanded(
              child: _StatCard(
                label: 'Movies',
                value: '325',
                icon: Icons.local_movies_rounded,
                color: WColors.accentRedAlt,
                badge: '62% ',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            const Expanded(
              child: _StatCard(
                label: 'Series',
                value: '132',
                icon: Icons.tv_rounded,
                color: WColors.chartPurple,
              ),
            ),
            SizedBox(width: 12.w),
            const Expanded(
              child: _StatCard(
                label: 'Anime',
                value: '66',
                icon: Icons.auto_awesome_rounded,
                color: WColors.chartYellow,
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
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: WColors.borderStrong),
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
                    color: WColors.mutedSecondaryDeep,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: TextStyle(
                    color: WColors.foreground,
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
                  color: WColors.foreground,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: WColors.mutedSecondary,
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

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF2B1C29),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: WColors.borderStrong),
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
                    color: WColors.accentPurple.withValues(alpha: 0.3),
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
                    color: WColors.accentRed.withValues(alpha: 0.3),
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
                Text(
                  "You've watched 523 titles across Movies, Series and Anime. Drama and Psychological stories dominate your collection. Your average rating of 4.3 suggests you're selective about what you watch.",
                  style: TextStyle(
                    color: WColors.mutedSecondarySoft,
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

class _CollectionCard extends StatelessWidget {
  const _CollectionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: WColors.surfaceChipBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
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
                    values: const [0.62, 0.25, 0.13],
                    colors: const [
                      WColors.accentRed,
                      WColors.chartPurple,
                      WColors.chartYellow,
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '523',
                      style: TextStyle(
                        color: WColors.foreground,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'TITLES',
                      style: TextStyle(
                        color: WColors.mutedSecondaryDeep,
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
              const Expanded(
                child: _LegendItem(
                  label: 'Movies',
                  value: '325',
                  percent: '62%',
                  color: WColors.accentRed,
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: _LegendItem(
                  label: 'Series',
                  value: '132',
                  percent: '25%',
                  color: WColors.chartPurple,
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: _LegendItem(
                  label: 'Anime',
                  value: '66',
                  percent: '13%',
                  color: WColors.chartYellow,
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
        color: WColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WColors.borderStrong),
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
                  color: WColors.mutedSecondary,
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
                  color: WColors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                percent,
                style: TextStyle(
                  color: WColors.mutedSecondary,
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

class _TasteProfileSection extends StatelessWidget {
  final List<_TasteTag> tags;

  const _TasteProfileSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags
              .map((tag) => _TagChip(label: tag.label, color: tag.color))
              .toList(growable: false),
        ),
        SizedBox(height: 16.h),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: WColors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: WColors.borderStrong),
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
                        color: WColors.accentPurple.withValues(alpha: 0.3),
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
                        color: WColors.accentRed.withValues(alpha: 0.3),
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
                        color: WColors.mutedSecondaryDeep,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'The Story Seeker',
                      style: TextStyle(
                        color: WColors.accentRedAlt,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'You enjoy emotionally driven stories, psychological mysteries and character-focused narratives.',
                      style: TextStyle(
                        color: WColors.mutedSecondarySoft,
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
            const Expanded(
              child: _InfoTile(
                title: 'FAVORITE ERA',
                value: '2010s',
              ),
            ),
            SizedBox(width: 10.w),
            const Expanded(
              child: _InfoTile(
                title: 'MOST WATCHED',
                value: 'Movies',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            const Expanded(
              child: _InfoTile(
                title: 'AVERAGE RATING',
                value: '4.3',
                accent: '⭐',
                valueColor: Color(0xFFF8DF3C),
              ),
            ),
            SizedBox(width: 10.w),
            const Expanded(
              child: _InfoTile(
                title: 'FAVORITE GENRE',
                value: 'Drama',
                valueColor: WColors.accentRedAlt,
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
  final String? accent;
  final Color? valueColor;

  const _InfoTile({
    required this.title,
    required this.value,
    this.accent,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: WColors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? WColors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (accent != null) ...[
                SizedBox(width: 4.w),
                Text(
                  accent!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

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
            color: WColors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: WColors.borderStrong),
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
                      color: WColors.mutedSecondary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${((unlockedCount / totalCount) * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(
                      color: WColors.warning,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999.r),
                      child: LinearProgressIndicator(
                        value: unlockedCount / totalCount,
                        minHeight: 8.h,
                        backgroundColor:
                            WColors.surfaceTint.withValues(alpha: 0.7),
                        valueColor: AlwaysStoppedAnimation(WColors.warning),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${totalCount - unlockedCount} remaining — keep watching to unlock more.',
                style: TextStyle(
                  color: WColors.mutedSecondaryAlt,
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.glowColor,
                      blurRadius: 42.r,
                      spreadRadius: 8.r,
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
                              WColors.surfaceTint.withValues(alpha: 0.6),
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
                          color: WColors.background.withValues(alpha: 0.8),
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
                                  scale: 1.0,
                                ),
                              ),
                            if (item.isHidden)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.question_mark,
                                    size: 32.sp,
                                    color: WColors.mutedSecondary,
                                  ),
                                ],
                              )
                            else if (item.isLocked)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 28.sp,
                                    color: WColors.mutedSecondary,
                                  ),
                                ],
                              ),
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
                ? WColors.mutedSecondary
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
                ? WColors.mutedSecondary
                : WColors.foreground,
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
            color: WColors.mutedSecondary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

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

    canvas.drawCircle(
      center,
      radius,
      basePaint..color = backgroundColor,
    );

    if (progress <= 0) {
      return;
    }

    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      basePaint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

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
        color: WColors.surfaceRaised.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: WColors.borderStrong),
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
                      color: WColors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_rounded,
                            size: 12.sp, color: WColors.primaryForeground),
                        SizedBox(width: 4.w),
                        Text(
                          item.count.toString(),
                          style: TextStyle(
                            color: WColors.primaryForeground,
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
                    color: WColors.foreground,
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
                    color: WColors.mutedSecondary,
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

class _ActivityCard extends StatelessWidget {
  final List<_ActivityItem> items;

  const _ActivityCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) => _ActivityRow(
            item: items[index],
            showDivider: index != items.length - 1,
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
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
                  color: WColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: WColors.borderStrong),
                ),
                child:
                    Icon(item.icon, size: 18.sp, color: WColors.mutedSecondary),
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
                        color: WColors.foreground,
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
                                (index) => Padding(
                                  padding: EdgeInsets.only(right: 2.w),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 10.sp,
                                    color: index < item.rating!.floor()
                                        ? WColors.mutedSecondary
                                        : WColors.surfaceTint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '•  ',
                            style: TextStyle(
                              color: WColors.mutedSecondary,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: WColors.mutedSecondary,
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
          if (showDivider) ...[
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 1.2,
              height: 28.h,
              color: WColors.borderStrong,
            )
          ],
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) => _SettingsRow(
            item: items[index],
            showDivider: index != items.length - 1,
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItem item;
  final bool showDivider;

  const _SettingsRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showDivider ? WColors.borderStrong : Colors.transparent,
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: WColors.surfaceRaised2,
              shape: BoxShape.circle,
            ),
            child:
                Icon(item.icon, size: 18.sp, color: WColors.mutedSecondarySoft),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: WColors.mutedSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 18.sp, color: WColors.mutedSecondaryHeader),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Pill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: WColors.surfaceOverlay.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: WColors.mutedSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: WColors.mutedSecondary,
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
        color: WColors.mutedSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: WColors.mutedSecondary),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            color: WColors.mutedSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PosterItem {
  final String image;
  final String title;
  final double rating;
  final String tag;

  const _PosterItem({
    required this.image,
    required this.title,
    required this.rating,
    required this.tag,
  });
}

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

class _TasteTag {
  final String label;
  final Color color;

  const _TasteTag(this.label, this.color);
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

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? rating;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.rating,
  });
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
