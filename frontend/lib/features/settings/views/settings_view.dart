import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(title: 'Settings'),
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
                  _buildSection(
                    context: context,
                    label: 'ACCOUNT',
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: context.colors.accentRed,
                        iconBg:
                            context.colors.accentRed.withValues(alpha: 0.12),
                        title: 'Edit Profile',
                        subtitle: 'Name, bio, avatar & cover',
                        onTap: () => context.push(AppRoutes.editProfile),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'NOTIFICATIONS',
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        iconColor: context.colors.warning,
                        iconBg: context.colors.warning.withValues(alpha: 0.12),
                        title: 'Notification Preferences',
                        subtitle: 'Releases, watchlist, social, achievements',
                        isLast: true,
                        onTap: () =>
                            context.push(AppRoutes.notificationSettings),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'APPEARANCE',
                    children: [
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: context.colors.accentPurple,
                        iconBg:
                            context.colors.accentPurple.withValues(alpha: 0.12),
                        title: 'Theme',
                        subtitle: 'Dark',
                        onTap: () => context.push(AppRoutes.appearance),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'PRIVACY & SECURITY',
                    children: [
                      _SettingsTile(
                        icon: Icons.visibility_outlined,
                        iconColor: context.colors.chartBlue,
                        iconBg:
                            context.colors.chartBlue.withValues(alpha: 0.12),
                        title: 'Privacy Controls',
                        subtitle: 'Profile & content visibility',
                        onTap: () => context.push(AppRoutes.privacySecurity),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'DATA & LIBRARY',
                    children: [
                      _SettingsTile(
                        icon: Icons.file_download_outlined,
                        iconColor: context.colors.chartGreen,
                        iconBg:
                            context.colors.chartGreen.withValues(alpha: 0.12),
                        title: 'Export Data',
                        subtitle: 'Collection, rankings, history',
                        onTap: () => context.push(AppRoutes.dataLibrary),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'SUPPORT',
                    children: [
                      _SettingsTile(
                        icon: Icons.support_agent_rounded,
                        iconColor: context.colors.mutedSecondarySoft,
                        iconBg: context.colors.mutedSecondarySoft
                            .withValues(alpha: 0.10),
                        title: 'Contact Support',
                        subtitle: 'Get help from the team',
                        onTap: () => context.push(AppRoutes.helpSupport),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    context: context,
                    label: 'ABOUT',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: context.colors.chartBlue,
                        iconBg:
                            context.colors.chartBlue.withValues(alpha: 0.12),
                        title: 'About Cinemora',
                        subtitle: 'Version 1.0.0 (Build 100)',
                        onTap: () => context.push(AppRoutes.about),
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: context.colors.chartBlue,
                        iconBg:
                            context.colors.chartBlue.withValues(alpha: 0.12),
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.article_outlined,
                        iconColor: context.colors.chartBlue,
                        iconBg:
                            context.colors.chartBlue.withValues(alpha: 0.12),
                        title: 'Terms of Service',
                        subtitle: 'Terms and conditions',
                        isLast: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  _SignOutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String label,
    required List<_SettingsTile> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(
              color: context.colors.mutedSecondaryDeep,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: context.colors.borderStrong),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              children: List.generate(children.length, (i) {
                return Column(
                  children: [
                    children[i],
                    if (i < children.length - 1)
                      Container(
                        margin: EdgeInsets.only(left: 64.w),
                        height: 0.5,
                        color: context.colors.borderStrong,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
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
                  color: iconBg,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: context.colors.mutedSecondary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

// ── Sign out ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignOutDialog(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: context.colors.accentRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: context.colors.accentRed.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                size: 18.sp, color: context.colors.accentRed),
            SizedBox(width: 8.w),
            Text(
              'Sign Out',
              style: TextStyle(
                color: context.colors.accentRed,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of Cinemora?',
          style: TextStyle(
            color: context.colors.mutedSecondarySoft,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.mutedSecondarySoft),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppAuthCubit>().signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: context.colors.accentRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
