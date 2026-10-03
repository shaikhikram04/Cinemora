import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class AppActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final Color? filledBackgroundColor;
  final Color? outlinedBackgroundColor;
  final EdgeInsetsGeometry? padding;

  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.filledBackgroundColor,
    this.outlinedBackgroundColor,
    this.padding,
  });

  EdgeInsets get defaultPadding => EdgeInsets.symmetric(
      horizontal: AppSizes.buttonHorizontalPadding.w,
      vertical: AppSizes.buttonVerticalPadding.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backgroundColor = filled
        ? (filledBackgroundColor ?? colors.accentRedAlt)
        : (outlinedBackgroundColor ?? colors.surfaceRaised);
    final foregroundColor = colors.primaryForeground;

    return Material(
      color: backgroundColor.withValues(alpha: filled ? 1 : 0.8),
      borderRadius: BorderRadius.circular(AppSizes.buttonRadiusFull.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadiusFull.r),
        onTap: onTap,
        child: Container(
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadiusFull.r),
            border: Border.all(
              color: filled ? Colors.transparent : colors.surfaceRaised2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: colors.accentRedAlt.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.icon18.sp, color: foregroundColor),
              SizedBox(width: AppSizes.compactHorizontalPadding.w),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: AppSizes.fontSize14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
