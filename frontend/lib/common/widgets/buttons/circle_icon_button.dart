import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class WCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const WCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = WSizes.appBarActionSize,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedBackground = backgroundColor ?? colors.surfaceMuted;
    final resolvedIconColor = iconColor ?? colors.foreground;
    return Material(
      color: resolvedBackground,
      borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        onTap: onTap,
        child: Container(
          width: size.w,
          height: size.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
            border: Border.all(color: colors.borderStrong),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize.sp, color: resolvedIconColor),
        ),
      ),
    );
  }
}