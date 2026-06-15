import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class MoodChip extends StatelessWidget {
  final String text;
  final bool highlighted;

  const MoodChip({
    super.key,
    required this.text,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        highlighted ? WColors.primary : const Color.fromARGB(18, 108, 108, 108);
    final textColor = highlighted ? WColors.primary : WColors.mutedForeground;
    final backgroundColor = highlighted
        ? WColors.primary.withAlpha(30)
        : const Color.fromARGB(255, 54, 54, 54).withAlpha(130);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: WSizes.sm, vertical: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        color: backgroundColor,
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
