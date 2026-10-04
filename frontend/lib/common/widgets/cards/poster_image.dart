import 'package:cinemora/common/widgets/images/artwork_scrim.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemora/common/widgets/overlays/bookmark_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/watch_status.dart';

typedef BadgeBuilder = Widget Function(BuildContext context, String rating);

class PosterImage extends StatelessWidget {
  final String image;
  final double height;
  final double? width;
  final double radius;
  final String? rating;
  final bool showBookmark;
  final WatchStatus? watchStatus;
  final VoidCallback? onAddToWatchlist;
  final BadgeBuilder? badgeBuilder;
  final String? tag;
  final Color? tagColor;
  final bool actionAdded;
  final VoidCallback? onActionTap;
  final bool titleOnImage;
  final String? title;

  const PosterImage({
    super.key,
    required this.image,
    required this.height,
    this.width,
    this.radius = AppSizes.radius18,
    this.rating,
    this.showBookmark = false,
    this.watchStatus,
    this.onAddToWatchlist,
    this.badgeBuilder,
    this.tag,
    this.tagColor,
    this.actionAdded = false,
    this.onActionTap,
    this.titleOnImage = false,
    this.title,
  });

  /// The exact provider this widget renders with.
  ///
  /// Exposed so callers can warm the cache under the same key — `ImageCache`
  /// is keyed on the provider, and the resize below means a bare
  /// [CachedNetworkImageProvider] would land somewhere nothing reads. Anything
  /// preloading a poster must go through here rather than duplicating the
  /// arithmetic, or the two drift the moment a width changes and the preload
  /// silently starts costing an extra download instead of saving one.
  ///
  /// The inner provider must stay the same kind that [CurvedNetworkImage] uses,
  /// for the same reason: two provider types are two cache keys for one image.
  static ImageProvider providerFor(
    BuildContext context, {
    required String image,
    required double height,
    double? width,
  }) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return ResizeImage(
      CachedNetworkImageProvider(image),
      width: width != null ? (width * dpr).round() : null,
      height: width == null ? (height.h * dpr).round() : null,
      allowUpscaling: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Overlay chrome sits on top of photographic artwork, under the gradient
    // below — so its black/white are deliberately theme-independent rather
    // than theme tokens, which would invert and ruin contrast in light mode.
    final onArtwork = colors.primaryForeground;
    final renderedHeight = height.h;
    return Container(
      height: renderedHeight,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadowMedium,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decode at the rendered size instead of the source resolution —
            // TMDB posters come in far larger than the ~100-140dp we display
            // them at, and decoding full-res per card is a major scroll-jank
            // source in image-heavy carousels. Only ONE of the resize
            // dimensions is ever set: passing both stretches the decode to
            // that exact box, distorting the image if its real aspect ratio
            // doesn't match — specifying just one lets the decoder scale the
            // other to preserve the source's true proportions. See
            // [providerFor], which owns that decision for renderer and
            // preloader alike.
            Image(
              image: providerFor(
                context,
                image: image,
                height: height,
                width: width,
              ),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: colors.surfaceMuted,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: colors.mutedSecondary,
                    size: AppSizes.icon22.sp,
                  ),
                ),
              ),
            ),
            ArtworkScrim.bottom(midOpacity: 0.12, midStop: 0.5),
            if (showBookmark)
              Positioned.fill(
                child: BookmarkOverlay(
                  watchStatus: watchStatus,
                  onToggle: onAddToWatchlist,
                ),
              ),
            if (tag != null && tag!.isNotEmpty)
              Positioned(
                left: AppSizes.space8.w,
                top: AppSizes.space8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.space8.w,
                    vertical: AppSizes.space4.h,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor ?? colors.accentRed,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
                  ),
                  child: Text(
                    tag!.toUpperCase(),
                    style: TextStyle(
                      color: onArtwork,
                      fontSize: AppSizes.fontSize10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (badgeBuilder != null && rating != null)
              Positioned(
                right: AppSizes.space8.w,
                top: AppSizes.space8.h,
                child: badgeBuilder!(context, rating!),
              ),
            if (titleOnImage && title != null)
              Positioned(
                left: AppSizes.space10.w,
                right: AppSizes.space10.w,
                bottom: AppSizes.space10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onArtwork,
                        fontSize: AppSizes.fontSize16.sp,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: colors.tertiary,
                            size: AppSizes.icon14.sp,
                          ),
                          SizedBox(width: AppSizes.space2.w),
                          Text(
                            rating!,
                            style: TextStyle(
                              color: colors.tertiary,
                              fontSize: AppSizes.fontSize12.sp,
                              fontWeight: FontWeight.w800,
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
