import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/services/push_notifications_service.dart';
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
      create: (ctx) => NotificationSettingsCubit(
        ctx.read<UserRepository>(),
        ctx.read<PushNotificationsService>(),
      ),
      child: const _NotificationSettingsContent(),
    );
  }
}

class _NotificationSettingsContent extends StatefulWidget {
  const _NotificationSettingsContent();

  @override
  State<_NotificationSettingsContent> createState() =>
      _NotificationSettingsContentState();
}

class _NotificationSettingsContentState
    extends State<_NotificationSettingsContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    // Nothing tells the app when permission changes in system settings, so the
    // only reliable moment to re-check is coming back to the foreground.
    if (lifecycle == AppLifecycleState.resumed) {
      context.read<NotificationSettingsCubit>().refreshPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationSettingsCubit>();
        // The preference still belongs to the user, but flipping it changes
        // nothing the OS will deliver — so the switches go inert and the
        // banner explains why.
        final live = state.togglesAreLive;
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
                            _NotifBanner(
                              permission: state.permission,
                              isRequesting: state.isRequestingPermission,
                              onAllow: cubit.requestPermission,
                            ),
                            SizedBox(height: 24.h),
                            _NotifGroupCard(
                              icon: Icons.movie_filter_rounded,
                              iconColor: context.colors.accentRed,
                              title: 'Release Alerts',
                              subtitle: 'Push alerts from your library',
                              masterValue: state.masterEnabled,
                              onMasterChanged: live ? cubit.setMaster : null,
                              items: [
                                _NotifToggleItem(
                                  title: 'Watchlist Item Released',
                                  subtitle:
                                      'When a movie or anime you’re waiting on is out',
                                  value: state.pushNewRelease,
                                  onChanged:
                                      live ? cubit.setNewRelease : null,
                                ),
                                _NotifToggleItem(
                                  title: 'New Season Available',
                                  subtitle:
                                      'When a tracked show or anime gets a new season',
                                  value: state.pushNewSeason,
                                  onChanged: live ? cubit.setNewSeason : null,
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

/// Explains the screen when push can actually be delivered, and takes over as
/// a warning when it can't — a settings screen showing live-looking switches
/// over a blocked OS permission is telling the user something untrue.
class _NotifBanner extends StatelessWidget {
  final PushPermission permission;
  final bool isRequesting;
  final VoidCallback onAllow;

  const _NotifBanner({
    required this.permission,
    required this.isRequesting,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = permission != PushPermission.granted;
    final accent =
        blocked ? context.colors.accentRed : context.colors.warning;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                blocked
                    ? Icons.notifications_off_rounded
                    : Icons.notifications_active_rounded,
                size: 18.sp,
                color: accent,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  switch (permission) {
                    PushPermission.granted =>
                      'These control push notifications only — everything '
                          'still appears in your in-app inbox.',
                    PushPermission.askable =>
                      'Cinemora doesn’t have permission to send notifications '
                          'yet, so nothing below can reach you.',
                    PushPermission.blocked =>
                      'Notifications are turned off for Cinemora in your '
                          'device settings. Your inbox still fills, but '
                          'nothing below can reach your phone.',
                  },
                  style: TextStyle(
                    color: context.colors.mutedSecondarySoft,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (blocked) ...[
            SizedBox(height: 12.h),
            _BannerAction(
              // An askable permission can still be resolved in-app; a blocked
              // one only from the system screen, so don't offer a prompt that
              // would silently do nothing.
              label: permission == PushPermission.askable
                  ? 'Allow Notifications'
                  : 'Open Device Settings',
              isBusy: isRequesting,
              color: accent,
              onTap: permission == PushPermission.askable
                  ? onAllow
                  : () => AppSettings.openAppSettings(
                        type: AppSettingsType.notification,
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final String label;
  final bool isBusy;
  final Color color;
  final VoidCallback onTap;

  const _BannerAction({
    required this.label,
    required this.isBusy,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: isBusy
            ? Center(
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
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

  /// Null when the OS permission makes the switch inert.
  final ValueChanged<bool>? onMasterChanged;
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
                            // Matches how _NotifToggleItem dims itself, so the
                            // whole card reads as inert together.
                            color: onMasterChanged != null
                                ? context.colors.foreground
                                : context.colors.mutedSecondaryDeep,
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
