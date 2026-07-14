import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/pill_chip.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class GenresSection extends StatelessWidget {
  final List<String> genres;
  final bool isLoading;

  const GenresSection({
    super.key,
    this.genres = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && genres.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 10.h),
        if (isLoading && genres.isEmpty)
          WShimmer(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _SkeletonChip(width: 78.w),
                _SkeletonChip(width: 96.w),
                _SkeletonChip(width: 64.w),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: genres
                .map((g) => WPillChip(
                      text: g,
                      backgroundColor:
                          context.colors.surfaceOverlay.withValues(alpha: 0.12),
                      borderColor: context.colors.border,
                      textColor: context.colors.foreground,
                      horizontalPadding: 14,
                      verticalPadding: 7,
                      fontSize: 13,
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _SkeletonChip extends StatelessWidget {
  final double width;

  const _SkeletonChip({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
      ),
    );
  }
}
