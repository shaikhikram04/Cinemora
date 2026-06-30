import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/features/profile/widgets/profile_shared.dart';

/// Highlighted narrative summary of the user's watch history.
class ProfileInsightCard extends StatelessWidget {
  final LibraryStatsModel? stats;
  final UserModel? user;
  final bool isLoading;

  const ProfileInsightCard({
    super.key,
    required this.stats,
    required this.user,
    required this.isLoading,
  });

  String _buildInsightText() {
    if (stats == null) {
      return "Start watching to build your cinema journey.";
    }
    final total = stats!.totalEntries;
    final topGenre = stats!.topGenreName ??
        (user?.preferences.genres.isNotEmpty == true
            ? user!.preferences.genres.first
            : 'Drama');

    return "You've watched $total titles across Movies, Series and Anime. "
        "$topGenre stories dominate your collection.";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF2B1C29),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -40,
            left: -10,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 80,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.3),
                    blurRadius: 150,
                    offset: const Offset(0, 10),
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfilePill(
                    label: 'INSIGHT', icon: Icons.auto_awesome_rounded),
                SizedBox(height: 10.h),
                isLoading
                    ? ProfileLoadingPlaceholder(height: 60.h)
                    : Text(
                        _buildInsightText(),
                        style: TextStyle(
                          color: context.colors.mutedSecondarySoft,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
