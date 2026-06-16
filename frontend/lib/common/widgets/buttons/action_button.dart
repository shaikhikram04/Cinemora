import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class WActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final double height;
  final Color? filledBackgroundColor;
  final Color? outlinedBackgroundColor;

  const WActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.height = WSizes.buttonHeightMd,
    this.filledBackgroundColor,
    this.outlinedBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = filled
        ? (filledBackgroundColor ?? context.colors.accentRedAlt)
        : (outlinedBackgroundColor ?? context.colors.surfaceRaised);

    return SizedBox(
      height: height.h,
      child: Material(
        color: backgroundColor.withValues(alpha: filled ? 1 : 0.8),
        borderRadius: BorderRadius.circular(WSizes.buttonRadiusFull.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(WSizes.buttonRadiusFull.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WSizes.buttonRadiusFull.r),
              border: Border.all(
                color: filled ? Colors.transparent : context.colors.surfaceRaised2,
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: context.colors.accentRedAlt.withValues(alpha: 0.30),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}