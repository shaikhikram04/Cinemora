import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
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
                      color:
                          context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
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
                            color: context.colors.accentPurple
                                .withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: context.colors.accentPurple
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            'This product uses the TMDb API but is not endorsed or certified by TMDb.',
                            style: TextStyle(
                              color: context.colors.mutedSecondary,
                              fontSize: 11.sp,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Footer
                  Center(
                    child: Text(
                      '© 2026 Cinemora. Made with ♥ for cinema lovers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.mutedSecondaryHeader,
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
          color: context.colors.mutedSecondaryDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
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
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: context.colors.borderStrong),
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
                    color: context.colors.accentRed.withValues(alpha: 0.25),
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
                    color: context.colors.accentPurple.withValues(alpha: 0.2),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colors.accentPurple,
                        context.colors.accentRed,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accentRed.withValues(alpha: 0.35),
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
                  'Cinemora',
                  style: TextStyle(
                    color: context.colors.foreground,
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
                    color: context.colors.mutedSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceRaised2,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: context.colors.borderStrong),
                  ),
                  child: Text(
                    'Version 1.0.0 (Build 100)',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
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
            color: context.colors.mutedSecondary,
            fontSize: 12.sp,
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
