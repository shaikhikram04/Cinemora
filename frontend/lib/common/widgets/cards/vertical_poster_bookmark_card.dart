import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'poster_image.dart';

class VerticalPosterBookmarkCard extends StatefulWidget {
  final String image;
  final double width;
  final double imageHeight;
  final String title;
  final String rating;
  final String year;
  final double radius;
  final VoidCallback? onTap;
  final CinemaType cinemaType;
  final WatchStatus? watchStatus;
  final VoidCallback? onBookmark;

  const VerticalPosterBookmarkCard({
    super.key,
    required this.image,
    required this.width,
    required this.imageHeight,
    required this.title,
    required this.rating,
    required this.cinemaType,
    required this.year,
    this.radius = AppSizes.radius18,
    this.onTap,
    this.watchStatus,
    this.onBookmark,
  });

  @override
  State<VerticalPosterBookmarkCard> createState() =>
      _VerticalPosterBookmarkCardState();
}

class _VerticalPosterBookmarkCardState
    extends State<VerticalPosterBookmarkCard> {
  late WatchStatus? _watchStatus;

  @override
  void initState() {
    super.initState();
    _watchStatus = widget.watchStatus;
  }

  @override
  void didUpdateWidget(VerticalPosterBookmarkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.watchStatus != widget.watchStatus) {
      setState(() => _watchStatus = widget.watchStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final poster = Container(
      width: widget.width + AppSizes.space8.w,
      padding: EdgeInsets.all(AppSizes.space4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius.r),
        color: colors.surfaceChip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PosterImage(
            image: widget.image,
            height: widget.imageHeight,
            radius: widget.radius,
            rating: widget.rating,
            showBookmark: true,
            watchStatus: _watchStatus,
            titleOnImage: false,
            onAddToWatchlist: (_watchStatus != null &&
                    _watchStatus != WatchStatus.watchlist)
                ? null
                : () {
                    setState(() => _watchStatus =
                        _watchStatus == null ? WatchStatus.watchlist : null);
                    widget.onBookmark?.call();
                  },
          ),
          SizedBox(height: AppSizes.space8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.space4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: AppSizes.fontSize14.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSizes.space4.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: colors.tertiary, size: AppSizes.icon12.sp),
                    SizedBox(width: AppSizes.space4.w),
                    Text(
                      widget.rating,
                      style: TextStyle(
                        color: colors.tertiary,
                        fontSize: AppSizes.fontSize12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${widget.cinemaType.name} • ${widget.year}",
                  style: TextStyle(
                    fontSize: AppSizes.fontSize12.sp,
                    color: colors.mutedSecondaryVibe,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.onTap == null) return poster;
    return GestureDetector(onTap: widget.onTap, child: poster);
  }
}
