import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class WCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  const WCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = WColors.surfaceMuted,
    this.iconColor = WColors.foreground,
    this.size = WSizes.appBarActionSize,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        onTap: onTap,
        child: Container(
          width: size.w,
          height: size.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
            border: Border.all(color: WColors.borderStrong),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize.sp, color: iconColor),
        ),
      ),
    );
  }
}