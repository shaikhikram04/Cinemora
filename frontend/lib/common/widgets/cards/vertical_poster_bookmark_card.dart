import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'common_media_card.dart';

class VerticalPosterBookmarkCard extends StatelessWidget {
  final String image;
  final double width;
  final double imageHeight;
  final String title;
  final String rating;
  final double radius;
  final VoidCallback? onTap;

  const VerticalPosterBookmarkCard({
    super.key,
    required this.image,
    required this.width,
    this.imageHeight = WSizes.imagePosterHeight,
    required this.title,
    required this.rating,
    this.radius = WSizes.radiusXxl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final poster = SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PosterImage(
            image: image,
            height: imageHeight,
            radius: radius,
            rating: rating,
            showBookmark: true,
            titleOnImage: false,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
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
              Icon(
                Icons.star_rounded,
                color: WColors.tertiary,
                size: 12.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                rating,
                style: TextStyle(
                  color: WColors.tertiary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return poster;
    return GestureDetector(onTap: onTap, child: poster);
  }
}
