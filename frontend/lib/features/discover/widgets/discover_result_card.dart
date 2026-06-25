import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/discover/models/search_result_item.dart';

class DiscoverResultCard extends StatelessWidget {
  final SearchResultItem item;

  const DiscoverResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context),
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
            // ── Poster ─────────────────────────────────────────────
            _PosterThumbnail(url: item.posterUrl),
            SizedBox(width: 12.w),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _TypeBadge(
                          label: item.typeLabel, mediaType: item.mediaType),
                      if (item.year.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          item.year,
                          style: TextStyle(
                            color: context.colors.mutedForeground,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (item.rating > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFBBB24),
                          size: 13.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          item.ratingDisplay,
                          style: TextStyle(
                            color: const Color(0xFFFBBB24),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ── Chevron ────────────────────────────────────────────
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

  void _navigate(BuildContext context) {
    final posterUrl = item.posterUrl;
    final rating = item.ratingDisplay;

    if (item.mediaType == 'movie') {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: item.title,
          image: posterUrl,
          rating: rating,
          id: item.id,
        ),
      );
    } else {
      // tv or anime
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: item.title,
          image: posterUrl,
          rating: rating,
          id: item.id,
          source: item.source,
        ),
      );
    }
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
      child: Icon(
        Icons.movie_outlined,
        color: context.colors.mutedForeground,
        size: 22.sp,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final String mediaType;

  const _TypeBadge({required this.label, required this.mediaType});

  Color _color() {
    switch (mediaType) {
      case 'anime':
        return const Color(0xFFA78BFA);
      case 'tv':
        return const Color(0xFF60A5FA);
      default:
        return const Color(0xFFE63946);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(WSizes.radiusSm.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
