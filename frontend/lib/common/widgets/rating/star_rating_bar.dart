import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/core/constants/app_colors.dart';

class StarRatingBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;
  final double size;
  final Color? starColor;

  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRate,
    required this.size,
    this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = starColor ?? context.colors.border;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final IconData icon;
        if (rating >= value) {
          icon = Icons.star_rounded;
        } else if (rating >= value - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        final slotWidth = size + 4.w;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final isLeftHalf = details.localPosition.dx < slotWidth / 2;
            onRate(isLeftHalf ? index + 0.5 : index + 1.0);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Icon(
              icon,
              size: size,
              color: rating >= value - 0.5 ? resolvedColor : context.colors.border,
            ),
          ),
        );
      }),
    );
  }
}
