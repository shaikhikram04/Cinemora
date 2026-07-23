import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/assets_path.dart';

class FranchiseCard extends StatelessWidget {
  final FranchiseSummary franchise;
  final VoidCallback onTap;

  const FranchiseCard({
    super.key,
    required this.franchise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: context.colors.surfaceChipBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            _PosterThumbnail(url: franchise.posterUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    franchise.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (franchise.movieCount != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      '${franchise.movieCount} movie${franchise.movieCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: context.colors.mutedForeground,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

class _PosterThumbnail extends StatelessWidget {
  final String url;

  const _PosterThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
      child: Container(
        width: 54.w,
        height: 76.h,
        color: context.colors.surfaceMuted,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: AppIcon(
        AppIcons.movie,
        color: context.colors.mutedForeground,
        size: 22.sp,
      ),
    );
  }
}
