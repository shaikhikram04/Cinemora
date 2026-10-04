import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/common/widgets/images/curved_network_image.dart';

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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.space12.w),
        decoration: BoxDecoration(
          color: colors.surfaceChip,
          borderRadius: BorderRadius.circular(AppSizes.radius12.r),
          border: Border.all(
            color: colors.surfaceChipBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            CurvedNetworkImage(
              url: collection.posterUrl,
              width: 44,
              height: 62,
              placeholder: Icon(
                Icons.collections_bookmark_rounded,
                color: colors.mutedForeground,
                size: AppSizes.icon22.sp,
              ),
            ),
            SizedBox(width: AppSizes.space12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part of a Collection',
                    style: TextStyle(
                      color: colors.mutedForeground,
                      fontSize: AppSizes.fontSize12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSizes.space2.h),
                  Text(
                    collection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.foreground,
                      fontSize: AppSizes.fontSize14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.mutedForeground,
              size: AppSizes.icon22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
