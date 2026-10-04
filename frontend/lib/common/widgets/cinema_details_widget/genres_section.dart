import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/pill_chip.dart';
import 'package:cinemora/common/widgets/shimmer/shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

// Placeholder chip geometry: three stand-ins at plausible genre-label widths,
// local because nothing outside this skeleton refers to them.
const double _skeletonChipHeight = 32.0;
const List<double> _skeletonChipWidths = [78.0, 96.0, 64.0];

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

    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: TextStyle(
            fontSize: AppSizes.fontSize16.sp,
            fontWeight: FontWeight.bold,
            color: colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: AppSizes.space10.h),
        if (isLoading && genres.isEmpty)
          AppShimmer(
            child: Wrap(
              spacing: AppSizes.space8.w,
              runSpacing: AppSizes.space8.h,
              children: [
                for (final width in _skeletonChipWidths)
                  _SkeletonChip(width: width.w),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppSizes.space8.w,
            runSpacing: AppSizes.space8.h,
            children: genres
                .map((g) => PillChip(
                      text: g,
                      backgroundColor:
                          colors.surfaceOverlay.withValues(alpha: 0.12),
                      borderColor: colors.border,
                      textColor: colors.foreground,
                      fontSize: AppSizes.fontSize12,
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
      height: _skeletonChipHeight.h,
      decoration: BoxDecoration(
        // Shimmer masks its child's shapes with its own colors, so the
        // placeholder stays plain white rather than taking a theme color.
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
      ),
    );
  }
}
