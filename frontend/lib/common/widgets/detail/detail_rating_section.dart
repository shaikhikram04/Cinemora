import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/rating/rating_success_chip.dart';
import 'package:cinemora/common/widgets/rating/star_rating_bar.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/widgets/rating_meter.dart';

class DetailRatingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final bool showRatingSuccess;
  final String rankingLabel;
  final ValueChanged<double> onRate;
  final VoidCallback onManageRankings;

  const DetailRatingSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.showRatingSuccess,
    required this.rankingLabel,
    required this.onRate,
    required this.onManageRankings,
  });

  @override
  Widget build(BuildContext context) {
    final hasRated = rating > 0;
    final ratingColor =
        hasRated ? ratingColorFor(rating) : context.colors.mutedSecondaryDeep;
    final ratingLabel = hasRated ? ratingLabelFor(rating) : null;
    final ratingEmoji = hasRated ? ratingEmojiFor(rating) : null;
    const starSize = 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colors.foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.colors.mutedForeground,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            if (hasRated)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: ratingColor.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.star_rounded, size: 12.sp, color: ratingColor),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: context.colors.surfaceTint.withValues(alpha: 0.18),
            borderRadius: BorderRadius.all(Radius.elliptical(20.r, 18.r)),
            border: Border.all(
              color: context.colors.surfaceChipBorder.withValues(alpha: 0.8),
              width: 0.7,
            ),
          ),
          child: Column(
            children: [
              if (hasRated) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ratingEmoji!, style: TextStyle(fontSize: 24.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: ratingColor,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      ratingLabel!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ratingColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
              ] else ...[
                Text(
                  'Tap the stars to rate',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.mutedSecondaryDeep,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 14.h),
              ],
              StarRatingBar(
                rating: hasRated ? rating : 0.0,
                onRate: onRate,
                starColor: ratingColor,
                size: starSize.sp,
              ),
              if (hasRated) ...[
                SizedBox(height: 16.h),
                RatingMeter(
                  rating: rating,
                  starSize: starSize.sp,
                  ratingColor: ratingColor,
                ),
              ],
              if (showRatingSuccess && hasRated) ...[
                SizedBox(height: 18.h),
                RatingSuccessChip(
                  emoji: ratingEmoji!,
                  ratingColor: ratingColor,
                  rankingLabel: rankingLabel,
                  onManageRankings: onManageRankings,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
