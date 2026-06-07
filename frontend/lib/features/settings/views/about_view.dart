import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/settings/widgets/settings_top_bar.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(title: 'About'),
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
                  // App branding
                  _BrandingCard(),
                  SizedBox(height: 24.h),

                  // Credits
                  _SectionLabel(label: 'CREDITS'),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: WColors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: WColors.borderStrong),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CreditItem(
                          role: 'Design & Development',
                          name: 'Ikram Kolekar',
                        ),
                        SizedBox(height: 10.h),
                        _CreditItem(
                          role: 'Movie Data',
                          name: 'The Movie Database (TMDb)',
                        ),
                        SizedBox(height: 10.h),
                        _CreditItem(
                          role: 'Anime Data',
                          name: 'MyAnimeList API',
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: WColors.accentPurple.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  WColors.accentPurple.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            'This product uses the TMDb API but is not endorsed or certified by TMDb.',
                            style: TextStyle(
                              color: WColors.mutedSecondary,
                              fontSize: 11.sp,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Social links
                  _SectionLabel(label: 'FOLLOW US'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: WColors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: WColors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _DividerLine(),
                          _LinkRow(
                            icon: Icons.alternate_email_rounded,
                            iconColor: const Color(0xFF1DA1F2),
                            title: 'Twitter / X',
                            subtitle: '@watcharyapp',
                            onTap: () {},
                          ),
                          _DividerLine(),
                          _LinkRow(
                            icon: Icons.camera_alt_outlined,
                            iconColor: const Color(0xFFE1306C),
                            title: 'Instagram',
                            subtitle: '@watcharyapp',
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Footer
                  Center(
                    child: Text(
                      '© 2026 Watchary. Made with ♥ for cinema lovers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WColors.mutedSecondaryHeader,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
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
          color: WColors.mutedSecondaryDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 64.w),
      height: 0.5,
      color: WColors.borderStrong,
    );
  }
}

// ── Branding card ────────────────────────────────────────────────────────────

class _BrandingCard extends StatelessWidget {
  const _BrandingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Glow effects
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WColors.accentRed.withValues(alpha: 0.25),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WColors.accentPurple.withValues(alpha: 0.2),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // App icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        WColors.accentPurple,
                        WColors.accentRed,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: WColors.accentRed.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Watchary',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Cinema companion for enthusiasts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WColors.mutedSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: WColors.surfaceRaised2,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: WColors.borderStrong),
                  ),
                  child: Text(
                    'Version 1.0.0 (Build 100)',
                    style: TextStyle(
                      color: WColors.mutedSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
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

// ── Credit item ──────────────────────────────────────────────────────────────

class _CreditItem extends StatelessWidget {
  final String role;
  final String name;

  const _CreditItem({required this.role, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          role,
          style: TextStyle(
            color: WColors.mutedSecondary,
            fontSize: 12.sp,
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: WColors.foreground,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Link row ─────────────────────────────────────────────────────────────────

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isLast;

  const _LinkRow({
    required this.icon,
    required this.iconColor,
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_outward_rounded,
                  size: 16.sp, color: WColors.mutedSecondaryHeader),
            ],
          ),
        ),
      ),
    );
  }
}
