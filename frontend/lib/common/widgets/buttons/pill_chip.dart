import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class WPillChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  const WPillChip({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor = WColors.surfaceTint,
    this.borderColor = WColors.borderStrong,
    this.textColor = WColors.primaryForeground,
    this.horizontalPadding = WSizes.chipHorizontalPadding,
    this.verticalPadding = WSizes.chipVerticalPadding,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.w,
        vertical: verticalPadding.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize.sp,
          color: textColor,
        ),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
        onTap: onTap,
        child: child,
      ),
    );
  }
}