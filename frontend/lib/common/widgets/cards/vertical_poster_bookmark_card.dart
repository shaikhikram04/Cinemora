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
    this.radius = WSizes.radiusXxl,
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
    final poster = Container(
      width: widget.width + 8.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius.r),
        color: context.colors.surfaceChip,
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
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 13.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: context.colors.tertiary, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      widget.rating,
                      style: TextStyle(
                        color: context.colors.tertiary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${widget.cinemaType.name} • ${widget.year}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.colors.mutedSecondaryVibe,
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
