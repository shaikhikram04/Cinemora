import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class DiscoverTrendingSection extends StatelessWidget {
  const DiscoverTrendingSection({super.key});

  static const List<String> _items = [
    'Christopher Nolan',
    'MAPPA Anime',
    'Psychological Thriller',
    'Attack on Titan',
    'Breaking Bad',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: WColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 7.w),
              Text(
                'Trending Searches',
                style: TextStyle(
                  color: WColors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Trending list ───────────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) => _TrendingItem(
              rank: index + 1,
              title: _items[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingItem extends StatefulWidget {
  final int rank;
  final String title;

  const _TrendingItem({required this.rank, required this.title});

  @override
  State<_TrendingItem> createState() => _TrendingItemState();
}

class _TrendingItemState extends State<_TrendingItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: WColors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: WColors.surfaceChipBorder.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 24.w,
              child: Text(
                '${widget.rank}',
                style: TextStyle(
                  color: WColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // Title
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: WColors.foreground,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Trending arrow icon
            Icon(
              Icons.north_east_rounded,
              size: 16.sp,
              color: WColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
