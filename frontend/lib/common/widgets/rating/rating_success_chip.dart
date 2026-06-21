import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class RatingSuccessChip extends StatelessWidget {
  final String emoji;
  final Color ratingColor;
  final String rankingLabel;
  final VoidCallback onManageRankings;

  const RatingSuccessChip({
    super.key,
    required this.emoji,
    required this.ratingColor,
    required this.rankingLabel,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
        border: Border.all(color: ratingColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added to',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.colors.mutedSecondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  rankingLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: ratingColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onManageRankings,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: ratingColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                border: Border.all(color: ratingColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Manage Rankings',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: ratingColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
