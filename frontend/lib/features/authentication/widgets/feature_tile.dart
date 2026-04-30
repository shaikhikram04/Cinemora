import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/themes/custom_theme/text_theme.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color trailingColor;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WSizes.radiusLg),
        color: WColors.card.withAlpha(150),
        border: Border.all(color: WColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: iconColor.withAlpha(30),
              border: Border.all(color: iconColor.withAlpha(100)),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: WSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WTextTheme.h3.copyWith(fontSize: 16.sp),
                ),
                Text(
                  subtitle,
                  style: WTextTheme.body.copyWith(fontSize: 13.sp),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 12.w,
            backgroundColor: trailingColor.withAlpha(45),
            child: Icon(Icons.check, size: 14.sp, color: trailingColor),
          ),
        ],
      ),
    );
  }
}
