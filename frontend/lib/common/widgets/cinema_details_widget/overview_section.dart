import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/shimmer/shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

// Placeholder line geometry, local to this skeleton: two full-width lines and a
// short one, so the block reads as a paragraph that ends mid-line.
const double _skeletonLineHeight = 12.0;
const double _skeletonLineRadius = 6.0;
const double _skeletonLastLineWidth = 200.0;

class OverviewSection extends StatefulWidget {
  final String? overview;
  final bool isLoading;

  const OverviewSection({super.key, this.overview, this.isLoading = false});

  @override
  State<OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.overview ?? '';
    final hasText = text.isNotEmpty;
    final colors = context.colors;
    // Both crossfade children render the same prose; only the clamp differs.
    final bodyStyle = TextStyle(
      fontSize: AppSizes.fontSize14.sp,
      color: colors.mutedForeground,
      height: 1.65,
      fontFamily: 'Inter',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: AppSizes.fontSize16.sp,
            fontWeight: FontWeight.bold,
            color: colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: AppSizes.space10.h),
        if (widget.isLoading && !hasText)
          AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonLine(width: double.infinity),
                SizedBox(height: AppSizes.space6.h),
                const _SkeletonLine(width: double.infinity),
                SizedBox(height: AppSizes.space6.h),
                _SkeletonLine(width: _skeletonLastLineWidth.w),
              ],
            ),
          )
        else ...[
          AnimatedCrossFade(
            firstChild: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: bodyStyle,
            ),
            secondChild: Text(text, style: bodyStyle),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (hasText) ...[
            SizedBox(height: AppSizes.space8.h),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Read Less' : 'Read More',
                style: TextStyle(
                  fontSize: AppSizes.fontSize14.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;

  const _SkeletonLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _skeletonLineHeight.h,
      decoration: BoxDecoration(
        // Shimmer masks its child's shapes with its own colors, so the
        // placeholder stays plain white rather than taking a theme color.
        color: Colors.white,
        borderRadius: BorderRadius.circular(_skeletonLineRadius.r),
      ),
    );
  }
}
