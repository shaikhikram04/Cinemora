import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'poster_image.dart';

enum CinemaType { movie, anime, series }

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
  });

  @override
  State<VerticalPosterBookmarkCard> createState() =>
      _VerticalPosterBookmarkCardState();
}

class _VerticalPosterBookmarkCardState
    extends State<VerticalPosterBookmarkCard> {
  bool _inWatchlist = false;

  @override
  Widget build(BuildContext context) {
    final poster = Container(
      width: widget.width + 8.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius.r),
        color: WColors.surfaceChip,
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
            inWatchlist: _inWatchlist,
            titleOnImage: false,
            onAddToWatchlist: () {
              setState(() => _inWatchlist = !_inWatchlist);
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
                    color: WColors.foreground,
                    fontSize: 13.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: WColors.tertiary, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      widget.rating,
                      style: TextStyle(
                        color: WColors.tertiary,
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
                    color: WColors.mutedSecondaryVibe,
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
