import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/profile/widgets/profile_shared.dart';

/// Timeline of the user's most recent library changes.
class ProfileActivityCard extends StatelessWidget {
  final List<LibraryEntryModel> entries;
  final bool isLoading;

  const ProfileActivityCard({
    super.key,
    required this.entries,
    required this.isLoading,
  });

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}w ago';
    return '${(diff.inDays / 30).round()}mo ago';
  }

  static _ActivityData _toActivity(LibraryEntryModel e) {
    final time = '${e.displayType}  •  ${_timeAgo(e.updatedAt)}';
    if (e.status == WatchStatus.watched && (e.userRating ?? 0) > 0) {
      return _ActivityData(
        icon: Icons.star_border_rounded,
        title: 'Rated ${e.title}',
        subtitle: time,
        rating: e.userRating,
      );
    }
    if (e.status == WatchStatus.watched) {
      return _ActivityData(
        icon: Icons.remove_red_eye_rounded,
        title: 'Finished ${e.title}',
        subtitle: time,
      );
    }
    if (e.status == WatchStatus.watching) {
      return _ActivityData(
        icon: Icons.play_circle_outline_rounded,
        title: 'Watching ${e.title}',
        subtitle: time,
      );
    }
    if (e.status == WatchStatus.dropped) {
      return _ActivityData(
        icon: Icons.cancel_outlined,
        title: 'Dropped ${e.title}',
        subtitle: time,
      );
    }
    return _ActivityData(
      icon: Icons.bookmark_border_rounded,
      title: 'Added ${e.title} to Watchlist',
      subtitle: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: const ProfileLoadingSpinner(),
      );
    }

    if (entries.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: Text(
          'No activity yet — add titles to your library.',
          style:
              TextStyle(color: context.colors.mutedSecondary, fontSize: 13.sp),
        ),
      );
    }

    final items = entries.map(_toActivity).toList();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (i) => _ActivityRow(
            item: items[i],
            showDivider: i != items.length - 1,
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityData item;
  final bool showDivider;

  const _ActivityRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.borderStrong),
                ),
                child: Icon(item.icon,
                    size: 18.sp, color: context.colors.mutedSecondary),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        if (item.rating != null) ...[
                          SizedBox(
                            width: 60.w,
                            child: Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
                                  padding: EdgeInsets.only(right: 2.w),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 10.sp,
                                    color: i < item.rating!.floor()
                                        ? context.colors.mutedSecondary
                                        : context.colors.surfaceTint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text('•  ',
                              style: TextStyle(
                                  color: context.colors.mutedSecondary,
                                  fontSize: 10.sp)),
                        ],
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider)
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 1.2,
              height: 28.h,
              color: context.colors.borderStrong,
            ),
        ],
      ),
    );
  }
}

class _ActivityData {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? rating;

  const _ActivityData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.rating,
  });
}
