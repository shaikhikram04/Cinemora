import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class CurvedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const CurvedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = AppSizes.appBarActionSize,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedBackground =
        backgroundColor ?? colors.surfaceMuted.withValues(alpha: 0.2);
    final resolvedIconColor = iconColor ?? colors.foreground;
    return Material(
      color: resolvedBackground,
      borderRadius: BorderRadius.circular(AppSizes.radius16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius16.r),
        onTap: onTap,
        child: Container(
          width: size.w,
          height: size.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius16.r),
            border: Border.all(color: colors.borderStrong),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize.sp, color: resolvedIconColor),
        ),
      ),
    );
  }
}
