import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/rating/star_rating_bar.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/home/widgets/rating_meter.dart';
import 'package:cinemora/features/tour/models/tour_step.dart';
import 'package:cinemora/features/tour/widgets/tour_anchor.dart';

class DetailRatingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final bool showRatingSuccess;
  final String rankingLabel;
  final ValueChanged<double> onRate;

  /// True once the detail fetch has settled. The first-run tour scrolls this
  /// section into view, and the sections above it (providers, genres, cast,
  /// crew) all change height when TMDB responds — scrolling before that lands
  /// on an offset that immediately moves.
  final bool isReadyForTour;

  const DetailRatingSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.showRatingSuccess,
    required this.rankingLabel,
    required this.onRate,
    this.isReadyForTour = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasRated = rating > 0;
    final ratingColor =
        hasRated ? ratingColorFor(rating) : colors.mutedSecondaryDeep;
    final ratingLabel = hasRated ? ratingLabelFor(rating) : null;
    final ratingEmoji = hasRated ? ratingEmojiFor(rating) : null;
    const starSize = AppSizes.icon48;

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
                    fontSize: AppSizes.fontSize16.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: AppSizes.space6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppSizes.fontSize12.sp,
                    color: colors.mutedForeground,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            if (hasRated)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.space10.w,
                  vertical: AppSizes.space6.h,
                ),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSizes.radius18.r),
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
                        fontSize: AppSizes.fontSize12.sp,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                    SizedBox(width: AppSizes.space4.w),
                    Icon(Icons.star_rounded,
                        size: AppSizes.icon12.sp, color: ratingColor),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: AppSizes.space14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.space16.w,
            vertical: AppSizes.space24.h,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceTint.withValues(alpha: 0.18),
            borderRadius: BorderRadius.all(
              Radius.elliptical(AppSizes.radius20.r, AppSizes.radius18.r),
            ),
            border: Border.all(
              color: colors.surfaceChipBorder.withValues(alpha: 0.8),
              width: 0.7,
            ),
          ),
          child: Column(
            children: [
              if (hasRated) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ratingEmoji!,
                        style: TextStyle(fontSize: AppSizes.fontSize24.sp)),
                    SizedBox(width: AppSizes.space8.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: AppSizes.fontSize24.sp,
                        fontWeight: FontWeight.w800,
                        color: ratingColor,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: AppSizes.space8.w),
                    Text(
                      ratingLabel!,
                      style: TextStyle(
                        fontSize: AppSizes.fontSize14.sp,
                        fontWeight: FontWeight.w600,
                        color: ratingColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.space14.h),
              ] else ...[
                Text(
                  'Tap the stars to rate',
                  style: TextStyle(
                    fontSize: AppSizes.fontSize14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.mutedSecondaryDeep,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: AppSizes.space14.h),
              ],
              TourAnchor(
                step: TourStep.rateTitle,
                autoScroll: isReadyForTour,
                child: StarRatingBar(
                  rating: hasRated ? rating : 0.0,
                  onRate: onRate,
                  starColor: ratingColor,
                  size: starSize.sp,
                ),
              ),
              if (hasRated) ...[
                SizedBox(height: AppSizes.space16.h),
                RatingMeter(
                  rating: rating,
                  starSize: starSize.sp,
                  ratingColor: ratingColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
