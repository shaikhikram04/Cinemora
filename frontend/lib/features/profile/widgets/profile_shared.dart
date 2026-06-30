import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

/// Small uppercase pill used as a section badge (e.g. "INSIGHT").
class ProfilePill extends StatelessWidget {
  final String label;
  final IconData icon;

  const ProfilePill({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: context.colors.mutedSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded skeleton block shown while a card's data is loading.
class ProfileLoadingPlaceholder extends StatelessWidget {
  final double height;

  const ProfileLoadingPlaceholder({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceTint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

/// Compact accent-colored progress spinner.
class ProfileLoadingSpinner extends StatelessWidget {
  const ProfileLoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.colors.accentRed,
      ),
    );
  }
}
