import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class TappableTextChip extends StatelessWidget {
  const TappableTextChip({
    super.key,
    required this.onToggle,
    required this.isSelected,
    required this.text,
  });

  final VoidCallback onToggle;
  final bool isSelected;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? WColors.primary.withValues(alpha: 0.15)
              : WColors.surfaceChip.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(
            color: isSelected
                ? WColors.primary.withValues(alpha: 0.6)
                : WColors.surfaceChipBorder,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? WColors.primary : WColors.mutedSecondaryAlt,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
