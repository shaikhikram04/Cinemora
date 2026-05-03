import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class WSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onSeeAllTap;
  final String seeAllLabel;

  const WSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onSeeAllTap,
    this.seeAllLabel = 'See all ›',
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
        Text(
          title,
          style: TextStyle(
            color: WColors.foreground,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (onSeeAllTap != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
              onTap: onSeeAllTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  seeAllLabel,
                  style: TextStyle(
                    color: WColors.accentRedAlt,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        else
          Text(
            seeAllLabel,
            style: TextStyle(
              color: WColors.accentRedAlt,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}