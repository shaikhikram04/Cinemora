import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/appearance_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/appearance_state.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AppearanceCubit(ctx.read<ThemeModeCubit>()),
      child: const _AppearanceContent(),
    );
  }
}

class _AppearanceContent extends StatelessWidget {
  const _AppearanceContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppearanceCubit, AppearanceState>(
      builder: (context, state) {
        final cubit = context.read<AppearanceCubit>();
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsTopBar(title: 'Appearance'),
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
                              padding:
                                  EdgeInsets.only(right: i < 2 ? 10.w : 0),
                              child: GestureDetector(
                                onTap: () => cubit.selectTheme(i),
                                child: _ThemeOptionCard(
                                  label: labels[i],
                                  icon: icons[i],
                                  selected: state.selectedTheme == i,
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
      },
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
            ? context.colors.accentPurple.withValues(alpha: 0.10)
            : context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: selected
              ? context.colors.accentPurple.withValues(alpha: 0.4)
              : context.colors.borderStrong,
          width: selected ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected ? context.colors.accentPurple : context.colors.mutedSecondaryDeep,
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: selected ? context.colors.foreground : context.colors.mutedSecondary,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (selected) ...[
            SizedBox(height: 6.h),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: context.colors.accentPurple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
