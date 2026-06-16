import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

// Shared between movie_details_content and series_details_content.

class DiscoverChip extends StatelessWidget {
  final String label;
  final bool selected;

  const DiscoverChip({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? context.colors.accentRed.withValues(alpha: 0.2)
        : context.colors.surfaceOverlay.withValues(alpha: 0.2);
    final border = selected
        ? context.colors.accentRed.withValues(alpha: 0.6)
        : context.colors.border.withValues(alpha: 0.2);
    final foreground = selected ? context.colors.accentRed : context.colors.mutedForeground;

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
