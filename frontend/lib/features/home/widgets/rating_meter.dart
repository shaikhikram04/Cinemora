import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';

class RatingMeter extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color ratingColor;

  const RatingMeter({
    super.key,
    required this.rating,
    required this.starSize,
    required this.ratingColor,
  });

  @override
  Widget build(BuildContext context) {
    final starSlotWidth = starSize + 4.w;
    final totalWidth = starSlotWidth * 5;
    final fillFraction = (rating / 5).clamp(0.0, 1.0);

    final stopCount = kRatingGradientColors.length;
    final lastStopIndex =
        (((rating / 5.0) * (stopCount - 1)).ceil()).clamp(1, stopCount - 1);
    final activeColors = kRatingGradientColors.sublist(0, lastStopIndex + 1);

    return SizedBox(
      width: totalWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          height: 4.h,
          child: Stack(
            children: [
              Container(color: WColors.border.withValues(alpha: 0.45)),
              FractionallySizedBox(
                widthFactor: fillFraction,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: activeColors),
                    boxShadow: [
                      BoxShadow(
                        color: ratingColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
