import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/settings/viewmodels/notification_settings_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/notification_settings_state.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

// Only toggles for notifications that actually exist are shown here — groups
// for unbuilt features (social, achievements…) were removed rather than
// shipping switches wired to nothing. Re-add a group when its feature ships.

// ─── View ─────────────────────────────────────────────────────────────────────

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => NotificationSettingsCubit(ctx.read<UserRepository>()),
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
                  child: state.status == NotificationSettingsStatus.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : ListView(
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
                              subtitle: 'Push alerts from your library',
                              masterValue: state.masterEnabled,
                              onMasterChanged: cubit.setMaster,
                              items: [
                                _NotifToggleItem(
                                  title: 'Watchlist Item Released',
                                  subtitle:
                                      'When a movie or anime you’re waiting on is out',
                                  value: state.pushNewRelease,
                                  onChanged: cubit.setNewRelease,
                                ),
                                _NotifToggleItem(
                                  title: 'New Season Available',
                                  subtitle:
                                      'When a tracked show or anime gets a new season',
                                  value: state.pushNewSeason,
                                  onChanged: cubit.setNewSeason,
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
              'These control push notifications only — everything still '
              'appears in your in-app inbox.',
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
