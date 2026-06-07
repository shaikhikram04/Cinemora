import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';

// Shared between movie_details_content and series_details_content.

class DiscoverChip extends StatelessWidget {
  final String label;
  final bool selected;

  const DiscoverChip({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? WColors.accentRed.withValues(alpha: 0.2)
        : WColors.surfaceOverlay.withValues(alpha: 0.2);
    final border = selected
        ? WColors.accentRed.withValues(alpha: 0.6)
        : WColors.border.withValues(alpha: 0.2);
    final foreground = selected ? WColors.accentRed : WColors.mutedForeground;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
