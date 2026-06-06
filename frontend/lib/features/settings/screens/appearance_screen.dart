import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  int _selectedTheme = 0; // 0=dark, 1=light, 2=system

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
                  // Theme
                  _SectionLabel(label: 'THEME'),
                  SizedBox(height: 10.h),
                  Row(
                    children: List.generate(3, (i) {
                      const labels = ['Dark', 'Light', 'System'];
                      const icons = [
                        Icons.dark_mode_outlined,
                        Icons.light_mode_outlined,
                        Icons.phone_android_rounded,
                      ];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 10.w : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTheme = i),
                            child: _ThemeOptionCard(
                              label: labels[i],
                              icon: icons[i],
                              selected: _selectedTheme == i,
                              isDark: i == 0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 28.h),
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
              'Appearance',
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

// ── Theme option card ────────────────────────────────────────────────────────

class _ThemeOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;

  const _ThemeOptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: selected
            ? WColors.accentPurple.withValues(alpha: 0.10)
            : WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: selected
              ? WColors.accentPurple.withValues(alpha: 0.4)
              : WColors.borderStrong,
          width: selected ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected ? WColors.accentPurple : WColors.mutedSecondaryDeep,
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: selected ? WColors.foreground : WColors.mutedSecondary,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (selected) ...[
            SizedBox(height: 6.h),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: WColors.accentPurple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
