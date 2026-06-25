import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class DiscoverRecentSearches extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const DiscoverRecentSearches({
    super.key,
    required this.recentSearches,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: context.colors.mutedForeground,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'Recent',
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: recentSearches
                .map((item) => _RecentChip(
                      label: item,
                      onTap: () => onTap(item),
                      onRemove: () => onRemove(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 10.w, right: 4.w, top: 7.h, bottom: 7.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(color: context.colors.surfaceChipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 13.sp,
              color: context.colors.mutedForeground,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: context.colors.mutedSecondaryAlt,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  Icons.close_rounded,
                  size: 12.sp,
                  color: context.colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
