import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Release Alerts
  bool _releaseAlertsEnabled = true;
  bool _newSeasonAvailable = true;
  bool _newEpisodeAvailable = true;
  bool _upcomingMovieRelease = true;
  bool _streamingChanges = false;

  // Watchlist Alerts
  bool _watchlistAlertsEnabled = true;
  bool _watchlistItemReleased = true;
  bool _watchlistItemTrending = false;

  // Social
  bool _socialEnabled = true;
  bool _likesOnRankings = true;
  bool _comments = true;
  bool _newFollowers = true;
  bool _friendActivity = false;

  // Achievements
  bool _achievementsEnabled = true;
  bool _badgeUnlocks = true;
  bool _milestones = true;
  bool _collectionProgress = false;

  // System
  bool _systemEnabled = false;
  bool _appUpdates = false;
  bool _productAnnouncements = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
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

                  // Release Alerts
                  _NotifGroupCard(
                    icon: Icons.movie_filter_rounded,
                    iconColor: WColors.accentRed,
                    title: 'Release Alerts',
                    subtitle: 'Movies, shows & streaming updates',
                    masterValue: _releaseAlertsEnabled,
                    onMasterChanged: (v) => setState(() {
                      _releaseAlertsEnabled = v;
                      if (!v) {
                        _newSeasonAvailable = false;
                        _newEpisodeAvailable = false;
                        _upcomingMovieRelease = false;
                        _streamingChanges = false;
                      }
                    }),
                    items: [
                      _NotifToggleItem(
                        title: 'New Season Available',
                        subtitle:
                            'When a new season drops for a tracked series',
                        value: _releaseAlertsEnabled && _newSeasonAvailable,
                        onChanged: _releaseAlertsEnabled
                            ? (v) => setState(() => _newSeasonAvailable = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'New Episode Available',
                        subtitle: 'Per-episode alerts for ongoing shows',
                        value: _releaseAlertsEnabled && _newEpisodeAvailable,
                        onChanged: _releaseAlertsEnabled
                            ? (v) => setState(() => _newEpisodeAvailable = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Upcoming Movie Release',
                        subtitle: 'Before a tracked movie hits theatres',
                        value: _releaseAlertsEnabled && _upcomingMovieRelease,
                        onChanged: _releaseAlertsEnabled
                            ? (v) => setState(() => _upcomingMovieRelease = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Streaming Availability Changes',
                        subtitle: 'When titles arrive or leave platforms',
                        value: _releaseAlertsEnabled && _streamingChanges,
                        onChanged: _releaseAlertsEnabled
                            ? (v) => setState(() => _streamingChanges = v)
                            : null,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Watchlist Alerts
                  _NotifGroupCard(
                    icon: Icons.bookmark_outline_rounded,
                    iconColor: WColors.warning,
                    title: 'Watchlist Alerts',
                    subtitle: 'Updates from your watchlist',
                    masterValue: _watchlistAlertsEnabled,
                    onMasterChanged: (v) => setState(() {
                      _watchlistAlertsEnabled = v;
                      if (!v) {
                        _watchlistItemReleased = false;
                        _watchlistItemTrending = false;
                      }
                    }),
                    items: [
                      _NotifToggleItem(
                        title: 'Watchlist Item Released',
                        subtitle: 'When something on your list is out',
                        value:
                            _watchlistAlertsEnabled && _watchlistItemReleased,
                        onChanged: _watchlistAlertsEnabled
                            ? (v) => setState(() => _watchlistItemReleased = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Watchlist Item Trending',
                        subtitle: 'When your item gains traction',
                        value:
                            _watchlistAlertsEnabled && _watchlistItemTrending,
                        onChanged: _watchlistAlertsEnabled
                            ? (v) => setState(() => _watchlistItemTrending = v)
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Social
                  _NotifGroupCard(
                    icon: Icons.people_outline_rounded,
                    iconColor: WColors.chartBlue,
                    title: 'Social',
                    subtitle: 'Activity from your network',
                    masterValue: _socialEnabled,
                    onMasterChanged: (v) => setState(() {
                      _socialEnabled = v;
                      if (!v) {
                        _likesOnRankings = false;
                        _comments = false;
                        _newFollowers = false;
                        _friendActivity = false;
                      }
                    }),
                    items: [
                      _NotifToggleItem(
                        title: 'Likes on Rankings',
                        subtitle: 'When someone likes your ranking lists',
                        value: _socialEnabled && _likesOnRankings,
                        onChanged: _socialEnabled
                            ? (v) => setState(() => _likesOnRankings = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Comments',
                        subtitle: 'Replies and comments on your content',
                        value: _socialEnabled && _comments,
                        onChanged: _socialEnabled
                            ? (v) => setState(() => _comments = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'New Followers',
                        subtitle: 'When someone follows your profile',
                        value: _socialEnabled && _newFollowers,
                        onChanged: _socialEnabled
                            ? (v) => setState(() => _newFollowers = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Friend Activity',
                        subtitle: 'What your friends are watching',
                        value: _socialEnabled && _friendActivity,
                        onChanged: _socialEnabled
                            ? (v) => setState(() => _friendActivity = v)
                            : null,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Achievements
                  _NotifGroupCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: WColors.chartYellow,
                    title: 'Achievements',
                    subtitle: 'Badges, milestones & progress',
                    masterValue: _achievementsEnabled,
                    onMasterChanged: (v) => setState(() {
                      _achievementsEnabled = v;
                      if (!v) {
                        _badgeUnlocks = false;
                        _milestones = false;
                        _collectionProgress = false;
                      }
                    }),
                    items: [
                      _NotifToggleItem(
                        title: 'Badge Unlocks',
                        subtitle: 'When you earn a new achievement badge',
                        value: _achievementsEnabled && _badgeUnlocks,
                        onChanged: _achievementsEnabled
                            ? (v) => setState(() => _badgeUnlocks = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Milestones',
                        subtitle: 'Significant collection milestones',
                        value: _achievementsEnabled && _milestones,
                        onChanged: _achievementsEnabled
                            ? (v) => setState(() => _milestones = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Collection Progress',
                        subtitle: 'Progress towards locked achievements',
                        value: _achievementsEnabled && _collectionProgress,
                        onChanged: _achievementsEnabled
                            ? (v) => setState(() => _collectionProgress = v)
                            : null,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // System
                  _NotifGroupCard(
                    icon: Icons.settings_outlined,
                    iconColor: WColors.mutedSecondarySoft,
                    title: 'System',
                    subtitle: 'App updates & announcements',
                    masterValue: _systemEnabled,
                    onMasterChanged: (v) => setState(() {
                      _systemEnabled = v;
                      if (!v) {
                        _appUpdates = false;
                        _productAnnouncements = false;
                      }
                    }),
                    items: [
                      _NotifToggleItem(
                        title: 'App Updates',
                        subtitle: 'Notifications about new app versions',
                        value: _systemEnabled && _appUpdates,
                        onChanged: _systemEnabled
                            ? (v) => setState(() => _appUpdates = v)
                            : null,
                      ),
                      _NotifToggleItem(
                        title: 'Product Announcements',
                        subtitle: 'New features and improvements',
                        value: _systemEnabled && _productAnnouncements,
                        onChanged: _systemEnabled
                            ? (v) => setState(() => _productAnnouncements = v)
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
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 12.h, WSizes.screenPadding.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: WColors.surfaceRaised.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: WColors.border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16.sp, color: WColors.mutedSecondary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
        color: WColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_rounded,
              size: 18.sp, color: WColors.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Manage which notifications Watchary can send you.',
              style: TextStyle(
                color: WColors.mutedSecondarySoft,
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
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.borderStrong),
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
                            color: WColors.foreground,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: WColors.mutedSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: masterValue,
                    onChanged: onMasterChanged,
                    activeTrackColor: WColors.accentRed,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 14.w, right: 14.w),
              height: 0.5,
              color: WColors.borderStrong,
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
                            ? WColors.foreground
                            : WColors.mutedSecondaryDeep,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: WColors.accentRed,
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: EdgeInsets.only(left: 64.w),
            height: 0.5,
            color: WColors.borderStrong,
          ),
      ],
    );
  }
}
