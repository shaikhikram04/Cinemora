import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class WSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onTapSuffix;
  final String suffixLabel;

  const WSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onTapSuffix,
    this.suffixLabel = 'See all ›',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12.sp, color: iconColor),
        ),
        SizedBox(width: WSizes.sm.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onTapSuffix != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
              onTap: onTapSuffix,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  suffixLabel,
                  style: TextStyle(
                    color: context.colors.accentRedAlt,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
