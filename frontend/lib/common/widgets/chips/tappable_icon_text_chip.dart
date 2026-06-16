import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class TappableIconTextChip extends StatelessWidget {
  const TappableIconTextChip({
    super.key,
    required this.onTap,
    required this.selected,
    required this.icon,
    required this.label,
    this.iconSize = 15,
    this.textSize = 13,
  });

  final VoidCallback onTap;
  final bool selected;
  final IconData icon;
  final String label;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary : context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(
            color: selected ? context.colors.primary : context.colors.surfaceChipBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize.sp,
              color: selected ? Colors.white : context.colors.mutedForeground,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : context.colors.mutedSecondaryAlt,
                fontSize: textSize.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
