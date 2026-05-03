import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class WMediaPosterCard extends StatelessWidget {
  final String image;
  final double width;
  final double imageHeight;
  final String? title;
  final String? rating;
  final double radius;
  final VoidCallback? onTap;
  final bool showBookmark;
  final bool showRatingBadge;
  final Widget Function(BuildContext context, String title, String? rating)?
      footerBuilder;
  final Widget Function(BuildContext context, String rating)? badgeBuilder;

  const WMediaPosterCard({
    super.key,
    required this.image,
    required this.width,
    this.imageHeight = WSizes.imagePosterHeight,
    this.title,
    this.rating,
    this.radius = WSizes.radiusXxl,
    this.onTap,
    this.showBookmark = true,
    this.showRatingBadge = true,
    this.footerBuilder,
    this.badgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final poster = SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight.h,
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
                  if (showRatingBadge && rating != null)
                    Positioned(
                      left: 6.w,
                      top: 6.h,
                      child: badgeBuilder?.call(context, rating!) ??
                          _MiniBadge(
                            icon: Icons.star_rounded,
                            text: rating!,
                            background: Colors.black.withValues(alpha: 0.35),
                            iconColor: WColors.tertiary,
                          ),
                    ),
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
                ],
              ),
            ),
          ),
          if (footerBuilder != null && title != null)
            footerBuilder!(context, title!, rating)
          else ...[
            SizedBox(height: 8.h),
            if (title != null)
              Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: WColors.foreground,
                  fontSize: 13.sp,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (rating != null) ...[
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
                    rating!,
                    style: TextStyle(
                      color: WColors.tertiary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );

    if (onTap == null) {
      return poster;
    }

    return GestureDetector(
      onTap: onTap,
      child: poster,
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