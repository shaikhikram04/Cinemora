import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/settings/viewmodels/notification_settings_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/notification_settings_state.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

// ─── View ─────────────────────────────────────────────────────────────────────

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationSettingsCubit(),
      child: const _NotificationSettingsContent(),
    );
  }
}

class _NotificationSettingsContent extends StatelessWidget {
  const _NotificationSettingsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationSettingsCubit>();
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsTopBar(title: 'Notifications'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      100.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _NotifBanner(),
                      SizedBox(height: 24.h),
                      _NotifGroupCard(
                        icon: Icons.movie_filter_rounded,
                        iconColor: context.colors.accentRed,
                        title: 'Release Alerts',
                        subtitle: 'Movies, shows & streaming updates',
                        masterValue: state.releaseAlertsEnabled,
                        onMasterChanged: cubit.setReleaseAlerts,
                        items: [
                          _NotifToggleItem(
                            title: 'New Season Available',
                            subtitle:
                                'When a new season drops for a tracked series',
                            value: state.releaseAlertsEnabled &&
                                state.newSeasonAvailable,
                            onChanged: state.releaseAlertsEnabled
                                ? cubit.setNewSeasonAvailable
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'New Episode Available',
                            subtitle: 'Per-episode alerts for ongoing shows',
                            value: state.releaseAlertsEnabled &&
                                state.newEpisodeAvailable,
                            onChanged: state.releaseAlertsEnabled
                                ? cubit.setNewEpisodeAvailable
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Upcoming Movie Release',
                            subtitle: 'Before a tracked movie hits theatres',
                            value: state.releaseAlertsEnabled &&
                                state.upcomingMovieRelease,
                            onChanged: state.releaseAlertsEnabled
                                ? cubit.setUpcomingMovieRelease
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Streaming Availability Changes',
                            subtitle: 'When titles arrive or leave platforms',
                            value: state.releaseAlertsEnabled &&
                                state.streamingChanges,
                            onChanged: state.releaseAlertsEnabled
                                ? cubit.setStreamingChanges
                                : null,
                            isLast: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _NotifGroupCard(
                        icon: Icons.bookmark_outline_rounded,
                        iconColor: context.colors.warning,
                        title: 'Watchlist Alerts',
                        subtitle: 'Updates from your watchlist',
                        masterValue: state.watchlistAlertsEnabled,
                        onMasterChanged: cubit.setWatchlistAlerts,
                        items: [
                          _NotifToggleItem(
                            title: 'Watchlist Item Released',
                            subtitle: 'When something on your list is out',
                            value: state.watchlistAlertsEnabled &&
                                state.watchlistItemReleased,
                            onChanged: state.watchlistAlertsEnabled
                                ? cubit.setWatchlistItemReleased
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Watchlist Item Trending',
                            subtitle: 'When your item gains traction',
                            value: state.watchlistAlertsEnabled &&
                                state.watchlistItemTrending,
                            onChanged: state.watchlistAlertsEnabled
                                ? cubit.setWatchlistItemTrending
                                : null,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _NotifGroupCard(
                        icon: Icons.people_outline_rounded,
                        iconColor: context.colors.chartBlue,
                        title: 'Social',
                        subtitle: 'Activity from your network',
                        masterValue: state.socialEnabled,
                        onMasterChanged: cubit.setSocial,
                        items: [
                          _NotifToggleItem(
                            title: 'Likes on Rankings',
                            subtitle: 'When someone likes your ranking lists',
                            value: state.socialEnabled && state.likesOnRankings,
                            onChanged: state.socialEnabled
                                ? cubit.setLikesOnRankings
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Comments',
                            subtitle: 'Replies and comments on your content',
                            value: state.socialEnabled && state.comments,
                            onChanged:
                                state.socialEnabled ? cubit.setComments : null,
                          ),
                          _NotifToggleItem(
                            title: 'New Followers',
                            subtitle: 'When someone follows your profile',
                            value: state.socialEnabled && state.newFollowers,
                            onChanged: state.socialEnabled
                                ? cubit.setNewFollowers
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Friend Activity',
                            subtitle: 'What your friends are watching',
                            value: state.socialEnabled && state.friendActivity,
                            onChanged: state.socialEnabled
                                ? cubit.setFriendActivity
                                : null,
                            isLast: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _NotifGroupCard(
                        icon: Icons.emoji_events_outlined,
                        iconColor: context.colors.chartYellow,
                        title: 'Achievements',
                        subtitle: 'Badges, milestones & progress',
                        masterValue: state.achievementsEnabled,
                        onMasterChanged: cubit.setAchievements,
                        items: [
                          _NotifToggleItem(
                            title: 'Badge Unlocks',
                            subtitle: 'When you earn a new achievement badge',
                            value:
                                state.achievementsEnabled && state.badgeUnlocks,
                            onChanged: state.achievementsEnabled
                                ? cubit.setBadgeUnlocks
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Milestones',
                            subtitle: 'Significant collection milestones',
                            value:
                                state.achievementsEnabled && state.milestones,
                            onChanged: state.achievementsEnabled
                                ? cubit.setMilestones
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Collection Progress',
                            subtitle: 'Progress towards locked achievements',
                            value: state.achievementsEnabled &&
                                state.collectionProgress,
                            onChanged: state.achievementsEnabled
                                ? cubit.setCollectionProgress
                                : null,
                            isLast: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _NotifGroupCard(
                        icon: Icons.settings_outlined,
                        iconColor: context.colors.mutedSecondarySoft,
                        title: 'System',
                        subtitle: 'App updates & announcements',
                        masterValue: state.systemEnabled,
                        onMasterChanged: cubit.setSystem,
                        items: [
                          _NotifToggleItem(
                            title: 'App Updates',
                            subtitle: 'Notifications about new app versions',
                            value: state.systemEnabled && state.appUpdates,
                            onChanged: state.systemEnabled
                                ? cubit.setAppUpdates
                                : null,
                          ),
                          _NotifToggleItem(
                            title: 'Product Announcements',
                            subtitle: 'New features and improvements',
                            value: state.systemEnabled &&
                                state.productAnnouncements,
                            onChanged: state.systemEnabled
                                ? cubit.setProductAnnouncements
                                : null,
                            isLast: true,
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
      },
    );
  }
}

// ── Notification banner ──────────────────────────────────────────────────────

class _NotifBanner extends StatelessWidget {
  const _NotifBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: context.colors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_rounded,
              size: 18.sp, color: context.colors.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Manage which notifications Cinemora can send you.',
              style: TextStyle(
                color: context.colors.mutedSecondarySoft,
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification group card ──────────────────────────────────────────────────

class _NotifGroupCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool masterValue;
  final ValueChanged<bool> onMasterChanged;
  final List<_NotifToggleItem> items;

  const _NotifGroupCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.masterValue,
    required this.onMasterChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            // Group header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, size: 19.sp, color: iconColor),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: context.colors.foreground,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: masterValue,
                    onChanged: onMasterChanged,
                    activeTrackColor: context.colors.accentRed,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 14.w, right: 14.w),
              height: 0.5,
              color: context.colors.borderStrong,
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

// ── Notification toggle item ─────────────────────────────────────────────────

class _NotifToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLast;

  const _NotifToggleItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(width: 50.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: onChanged != null
                            ? context.colors.foreground
                            : context.colors.mutedSecondaryDeep,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.colors.mutedSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: context.colors.accentRed,
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: EdgeInsets.only(left: 64.w),
            height: 0.5,
            color: context.colors.borderStrong,
          ),
      ],
    );
  }
}
