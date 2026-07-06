import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';

class FranchiseBannerSection extends StatelessWidget {
  final FranchiseSummary collection;
  final VoidCallback onTap;

  const FranchiseBannerSection({
    super.key,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: context.colors.surfaceChipBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
              child: Container(
                width: 44.w,
                height: 62.h,
                color: context.colors.surfaceMuted,
                child: collection.posterUrl.isNotEmpty
                    ? Image.network(
                        collection.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.collections_bookmark_rounded,
                          color: context.colors.mutedForeground,
                          size: 20.sp,
                        ),
                      )
                    : Icon(
                        Icons.collections_bookmark_rounded,
                        color: context.colors.mutedForeground,
                        size: 20.sp,
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part of a Collection',
                    style: TextStyle(
                      color: context.colors.mutedForeground,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    collection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.mutedForeground,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
