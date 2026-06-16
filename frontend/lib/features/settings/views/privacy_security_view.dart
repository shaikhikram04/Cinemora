import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/settings/viewmodels/privacy_security_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/privacy_security_state.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

class PrivacySecurityView extends StatelessWidget {
  const PrivacySecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrivacySecurityCubit(),
      child: const _PrivacySecurityContent(),
    );
  }
}

class _PrivacySecurityContent extends StatelessWidget {
  const _PrivacySecurityContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivacySecurityCubit, PrivacySecurityState>(
      builder: (context, state) {
        final cubit = context.read<PrivacySecurityCubit>();
        return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(title: 'Privacy & Security'),
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
                  // Profile Visibility
                  _SectionLabel(label: 'PROFILE VISIBILITY'),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _VisibilityOption(
                              icon: Icons.public_rounded,
                              label: 'Public Profile',
                              description: 'Anyone can view your profile',
                              selected: state.publicProfile,
                              onTap: () =>
                                  cubit.setPublicProfile(true),
                            ),
                            SizedBox(width: 12.w),
                            _VisibilityOption(
                              icon: Icons.lock_outline_rounded,
                              label: 'Private Profile',
                              description: 'Only you can view your profile',
                              selected: !state.publicProfile,
                              onTap: () =>
                                  cubit.setPublicProfile(false),
                            ),
                          ],
                        ),
                        if (!state.publicProfile) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: context.colors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color:
                                      context.colors.warning.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 14.sp, color: context.colors.warning),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Private profiles cannot be found in search or rankings discovery.',
                                    style: TextStyle(
                                      color: context.colors.warning,
                                      fontSize: 11.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Content Visibility
                  _SectionLabel(label: 'CONTENT VISIBILITY'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _ToggleRow(
                            icon: Icons.star_outline_rounded,
                            iconColor: context.colors.chartYellow,
                            title: 'Show Ratings',
                            subtitle: 'Your ratings are visible to others',
                            value: state.showRatings,
                            onChanged: cubit.setShowRatings,
                          ),
                          _Divider(),
                          _ToggleRow(
                            icon: Icons.list_alt_rounded,
                            iconColor: context.colors.chartBlue,
                            title: 'Show Rankings',
                            subtitle: 'Your ranking lists are discoverable',
                            value: state.showRankings,
                            onChanged: cubit.setShowRankings,
                          ),
                          _Divider(),
                          _ToggleRow(
                            icon: Icons.history_rounded,
                            iconColor: context.colors.chartGreen,
                            title: 'Show Watch History',
                            subtitle: 'Others can see what you\'ve watched',
                            value: state.showWatchHistory,
                            onChanged: cubit.setShowWatchHistory,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Security
                  _SectionLabel(label: 'SECURITY'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _ActionRow(
                            icon: Icons.lock_reset_rounded,
                            iconColor: context.colors.chartBlue,
                            title: 'Change Password',
                            subtitle: 'Last changed 3 months ago',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionRow(
                            icon: Icons.devices_rounded,
                            iconColor: context.colors.chartBlue,
                            title: 'Active Sessions',
                            subtitle: '2 devices currently signed in',
                            trailing:
                                _Badge(label: '2', color: context.colors.chartBlue),
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionRow(
                            icon: Icons.logout_rounded,
                            iconColor: context.colors.warning,
                            title: 'Logout All Devices',
                            subtitle: 'Sign out from every device',
                            isLast: true,
                            onTap: () => _showLogoutAllDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Data Control
                  _SectionLabel(label: 'DATA CONTROL'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _ActionRow(
                            icon: Icons.download_rounded,
                            iconColor: context.colors.chartGreen,
                            title: 'Download My Data',
                            subtitle: 'Get a copy of all your Watchary data',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionRow(
                            icon: Icons.delete_outline_rounded,
                            iconColor: context.colors.accentRed,
                            title: 'Delete Account',
                            subtitle: 'Permanently delete your account',
                            titleColor: context.colors.accentRed,
                            isLast: true,
                            onTap: () => _showDeleteAccountDialog(context),
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
    );
      },
    );
  }

  void _showLogoutAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Logout All Devices',
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You will be signed out from all devices including this one. Are you sure?',
          style: TextStyle(
            color: context.colors.mutedSecondarySoft,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: context.colors.mutedSecondarySoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Logout All',
              style: TextStyle(
                  color: context.colors.warning, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: context.colors.accentRed,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This is permanent and cannot be undone. All your data — collection, rankings, achievements — will be deleted forever.',
          style: TextStyle(
            color: context.colors.mutedSecondarySoft,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: context.colors.mutedSecondarySoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Delete',
              style: TextStyle(
                  color: context.colors.accentRed, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.mutedSecondaryDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 64.w),
      height: 0.5,
      color: context.colors.borderStrong,
    );
  }
}

// ── Visibility option ────────────────────────────────────────────────────────

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: selected
                ? context.colors.chartBlue.withValues(alpha: 0.10)
                : context.colors.surfaceRaised2,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? context.colors.chartBlue.withValues(alpha: 0.4)
                  : context.colors.borderStrong,
              width: selected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 18.sp,
                    color: selected
                        ? context.colors.chartBlue
                        : context.colors.mutedSecondaryDeep,
                  ),
                  if (selected)
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: context.colors.chartBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 10.sp, color: Colors.white),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  color: selected ? context.colors.foreground : context.colors.mutedSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  color: context.colors.mutedSecondaryDeep,
                  fontSize: 10.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toggle row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
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
            value: value,
            onChanged: onChanged,
            activeTrackColor: context.colors.accentRed,
          ),
        ],
      ),
    );
  }
}

// ── Action row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
                        color: titleColor ?? context.colors.foreground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
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
              if (trailing != null) ...[trailing!, SizedBox(width: 8.w)],
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: context.colors.mutedSecondaryHeader,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
