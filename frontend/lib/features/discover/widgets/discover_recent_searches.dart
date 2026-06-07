import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class DiscoverRecentSearches extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onRemove;

  const DiscoverRecentSearches({
    super.key,
    required this.recentSearches,
    required this.onRemove,
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
                color: WColors.mutedForeground,
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'Recent',
                style: TextStyle(
                  color: WColors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
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
                      onTap: () {},
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: WColors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(color: WColors.surfaceChipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 13.sp,
              color: WColors.mutedForeground,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: WColors.mutedSecondaryAlt,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
