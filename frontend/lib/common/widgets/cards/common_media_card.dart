import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

typedef BadgeBuilder = Widget Function(BuildContext context, String rating);

class PosterImage extends StatelessWidget {
  final String image;
  final double height;
  final double radius;
  final String? rating;
  final bool showBookmark;
  final BadgeBuilder? badgeBuilder;
  final bool titleOnImage;
  final String? title;

  const PosterImage({
    super.key,
    required this.image,
    this.height = WSizes.imagePosterHeight,
    this.radius = WSizes.radiusXxl,
    this.rating,
    this.showBookmark = false,
    this.badgeBuilder,
    this.titleOnImage = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: const [
          BoxShadow(
            color: WColors.shadowMedium,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: WColors.surfaceMuted,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: WColors.mutedSecondary,
                  size: 22.sp,
                ),
              ),
            ),
            const _PosterGradient(),
            if (showBookmark)
              Positioned(
                right: 6.w,
                top: 6.h,
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 13.sp,
                    color: WColors.accentRed,
                  ),
                ),
              ),
            if (titleOnImage && title != null)
              Positioned(
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: WColors.tertiary,
                            size: 11.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            rating!,
                            style: TextStyle(
                              color: WColors.tertiary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              height: (1.8).h,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterGradient extends StatelessWidget {
  const _PosterGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.78),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color iconColor;

  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: iconColor),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
