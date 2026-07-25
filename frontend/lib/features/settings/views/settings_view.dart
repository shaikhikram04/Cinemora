import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';
import 'package:cinemora/features/settings/widgets/settings_ui.dart';

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
                // Rows carry their own gutter, so the list gives back exactly
                // that much to keep titles on the screen-padding grid.
                padding: EdgeInsets.fromLTRB(
                  (WSizes.screenPadding - kSettingsRowGutter).w,
                  20.h,
                  (WSizes.screenPadding - kSettingsRowGutter).w,
                  100.h,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  SettingsGroup(
                    label: 'ACCOUNT',
                    children: [
                      SettingsRow(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        onTap: () => context.push(AppRoutes.editProfile),
                      ),
                    ],
                  ),
                  SizedBox(height: kSettingsGroupSpacing.h),
                  SettingsGroup(
                    label: 'PREFERENCES',
                    children: [
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        onTap: () =>
                            context.push(AppRoutes.notificationSettings),
                      ),
                      // The one row with a trailing value, because it reports
                      // live state rather than restating the title.
                      BlocBuilder<ThemeModeCubit, ThemeMode>(
                        builder: (context, mode) => SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          title: 'Theme',
                          value: _themeLabel(mode),
                          onTap: () => context.push(AppRoutes.appearance),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kSettingsGroupSpacing.h),
                  SettingsGroup(
                    label: 'SUPPORT',
                    children: [
                      SettingsRow(
                        icon: Icons.support_agent_rounded,
                        title: 'Contact Support',
                        onTap: () => context.push(AppRoutes.helpSupport),
                      ),
                    ],
                  ),
                  SizedBox(height: 36.h),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: kSettingsRowGutter.w),
                    child: SettingsDangerButton(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      onTap: () => _showSignOutDialog(context),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const _VersionFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'Dark',
        ThemeMode.light => 'Light',
        ThemeMode.system => 'System',
      };

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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

// ── Version footer ───────────────────────────────────────────────────────────

// Version is information, not a destination — so it reads as a footer instead
// of occupying a tappable row that leads nowhere.
class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  // Resolved once per app run rather than per rebuild — it crosses a platform
  // channel, and the answer can't change while the app is alive.
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: context.colors.mutedSecondaryHeader,
      fontSize: 11.sp,
    );

    return Column(
      children: [
        Text(
          'CINEMORA',
          style: style.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
        SizedBox(height: 4.h),
        FutureBuilder<PackageInfo>(
          future: _packageInfo,
          builder: (context, snapshot) {
            final info = snapshot.data;
            // Hold the line box while the channel resolves so the footer
            // doesn't shift under the user on first paint.
            return Visibility(
              visible: info != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(
                info == null
                    ? 'Version'
                    : 'Version ${info.version} (Build ${info.buildNumber})',
                style: style,
              ),
            );
          },
        ),
      ],
    );
  }
}
