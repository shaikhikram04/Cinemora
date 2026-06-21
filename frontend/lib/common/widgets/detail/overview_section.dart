import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 10.h),
        if (widget.isLoading && !hasText)
          WShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: double.infinity),
                SizedBox(height: 6.h),
                _SkeletonLine(width: double.infinity),
                SizedBox(height: 6.h),
                _SkeletonLine(width: 200.w),
              ],
            ),
          )
        else ...[
          AnimatedCrossFade(
            firstChild: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.mutedForeground,
                height: 1.65,
                fontFamily: 'Inter',
              ),
            ),
            secondChild: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.mutedForeground,
                height: 1.65,
                fontFamily: 'Inter',
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (hasText) ...[
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Read Less' : 'Read More',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
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
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
