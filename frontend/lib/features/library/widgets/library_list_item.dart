import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/library/models/library_item.dart';

class LibraryListItem extends StatelessWidget {
  final LibraryItem item;

  const LibraryListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        children: [
          // ── Thumbnail ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90.w,
                    height: 110.h,
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: context.colors.surfaceMuted,
                      ),
                    ),
                  ),
                  // Dark overlay
                  Container(
                    width: 90.w,
                    height: 110.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Year · type · genre
                  Row(
                    children: [
                      Text(
                        item.year,
                        style: TextStyle(
                          color: context.colors.mutedSecondary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _dot(context),
                      Text(
                        item.type.toUpperCase(),
                        style: TextStyle(
                          color: _typeColor(context, item.type),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _dot(context),
                      Icon(Icons.star_rounded,
                          color: context.colors.tertiary, size: 13.sp),
                      SizedBox(width: 3.w),
                      Text(
                        item.rating,
                        style: TextStyle(
                          color: context.colors.tertiary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' TMDb',
                        style: TextStyle(
                          color: context.colors.mutedSecondaryDeep,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // User stars
                  if (item.userRating > 0) ...[
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        // Stars
                        if (item.userRating > 0) ...[
                          Text(
                            item.userRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: ratingColorFor(item.userRating),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _StarRow(rating: item.userRating),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text('•',
            style:
                TextStyle(color: context.colors.mutedSecondaryDeep, fontSize: 11.sp)),
      );

  Color _typeColor(BuildContext context, String type) {
    switch (type) {
      case 'Anime':
        return context.colors.warning;
      case 'Series':
        return context.colors.accentPurple;
      default:
        return context.colors.accentRed;
    }
  }
}

class _StarRow extends StatelessWidget {
  final double rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && i < rating;
        return Icon(
          half ? Icons.star_half_rounded : Icons.star_rounded,
          size: 24.sp,
          color: full || half
              ? ratingColorFor(rating)
              : context.colors.mutedSecondaryHeader,
        );
      }),
    );
  }
}
