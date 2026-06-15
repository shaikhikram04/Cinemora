import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class WToggleActionButton extends StatelessWidget {
  final bool selected;
  final String selectedLabel;
  final String unselectedLabel;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final VoidCallback onTap;
  final Color selectedBackground;
  final Color unselectedBackground;
  final Color selectedBorder;
  final Color unselectedBorder;
  final Color selectedForeground;
  final Color unselectedForeground;

  const WToggleActionButton({
    super.key,
    required this.selected,
    required this.selectedLabel,
    required this.unselectedLabel,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.onTap,
    this.selectedBackground = WColors.successSoft,
    this.unselectedBackground = WColors.surfaceOverlay,
    this.selectedBorder = WColors.success,
    this.unselectedBorder = WColors.border,
    this.selectedForeground = WColors.success,
    this.unselectedForeground = WColors.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? selectedBackground : unselectedBackground;
    final borderColor = selected ? selectedBorder : unselectedBorder;
    final foregroundColor = selected ? selectedForeground : unselectedForeground;
    final icon = selected ? selectedIcon : unselectedIcon;
    final label = selected ? selectedLabel : unselectedLabel;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: WSizes.sectionSpaceSm.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
            border: Border.all(
              color: selected ? borderColor.withValues(alpha: 0.5) : borderColor,
              width: selected ? 0.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}