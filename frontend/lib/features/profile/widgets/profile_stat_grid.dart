import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/library_stats_model.dart';

/// 2×2 grid summarising watched totals by cinema type.
class ProfileStatGrid extends StatelessWidget {
  final LibraryStatsModel? stats;
  final bool isLoading;

  const ProfileStatGrid({
    super.key,
    required this.stats,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEntries ?? 0;
    final movies = stats?.movies ?? 0;
    final series = stats?.tvShows ?? 0;
    final anime = stats?.anime ?? 0;
    final moviePct = total > 0 ? '${((movies / total) * 100).round()}%' : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Titles Watched',
                value: isLoading ? '—' : total.toString(),
                icon: Icons.movie_filter_rounded,
                color: context.colors.accentRed,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Movies',
                value: isLoading ? '—' : movies.toString(),
                icon: Icons.local_movies_rounded,
                color: context.colors.accentRedAlt,
                badge: isLoading ? null : moviePct,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Series',
                value: isLoading ? '—' : series.toString(),
                icon: Icons.tv_rounded,
                color: context.colors.chartPurple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Anime',
                value: isLoading ? '—' : anime.toString(),
                icon: Icons.auto_awesome_rounded,
                color: context.colors.chartYellow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.colors.mutedSecondaryDeep,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
        ],
      ),
    );
  }
}
