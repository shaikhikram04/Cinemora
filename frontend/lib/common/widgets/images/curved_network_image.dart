import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

/// A network image clipped to a rounded rectangle, with the app's decode-size
/// capping and failure handling built in.
///
/// Replaces the hand-rolled `ClipRRect` → sized box → [Image.network] stack that
/// every poster thumbnail, provider logo and ranking tile used to repeat, along
/// with the `cacheWidth` arithmetic each one carried.
///
/// [width] and [height] are **unscaled design values** — this widget applies
/// ScreenUtil itself (`.w` across, `.h` down, `.r` on the radius), so call sites
/// must not pre-scale them.
///
/// An empty or null [url] and a load failure both render [placeholder], so a
/// caller only describes the empty state once.
class CurvedNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  /// Painted behind the image, so a slow or transparent source doesn't flash
  /// whatever is underneath. Defaults to `surfaceMuted`.
  final Color? backgroundColor;

  /// Shown when [url] is missing or the fetch fails. Left null, the background
  /// shows through on its own.
  final Widget? placeholder;

  /// Keeps the previous frame on screen while a new [url] loads, instead of
  /// blanking. Worth it where the url changes in place (a shuffling poster).
  final bool gaplessPlayback;

  const CurvedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = AppSizes.radius10,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.placeholder,
    this.gaplessPlayback = false,
  });

  @override
  Widget build(BuildContext context) {
    final renderedWidth = width?.w;
    final renderedHeight = height?.h;
    final fallback = placeholder ?? const SizedBox.shrink();

    final decodeWidth = _decodePixels(context, renderedWidth);
    // Width wins when it is a real number; a fill-parent width has no size of
    // its own, so the height caps the decode in its place.
    final decodeHeight =
        decodeWidth != null ? null : _decodePixels(context, renderedHeight);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: SizedBox(
        width: renderedWidth,
        height: renderedHeight,
        child: ColoredBox(
          color: backgroundColor ?? context.colors.surfaceMuted,
          child: url == null || url!.isEmpty
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: fit,
                  useOldImageOnUrlChange: gaplessPlayback,
                  // Cap the decode at the rendered size — TMDB artwork arrives
                  // far larger than the boxes we draw it in, and decoding at
                  // source resolution is a scroll-jank source.
                  //
                  // One axis only: constraining both stretches the decode to
                  // that exact box, distorting any source whose real aspect
                  // ratio differs. Width wins when both are given; height
                  // covers the boxes that only pin their height.
                  memCacheWidth: decodeWidth,
                  memCacheHeight: decodeHeight,
                  // Keep the bytes on disk at the same cap, so a cold start
                  // re-reads a thumbnail rather than the full-size original.
                  maxWidthDiskCache: decodeWidth,
                  maxHeightDiskCache: decodeHeight,
                  // The background shows through while the fetch is in flight;
                  // a spinner per thumbnail would be noisier than the gap.
                  errorWidget: (_, __, ___) => fallback,
                  // Appear on decode, as Image.network did. The package's
                  // default half-second cross-fade would otherwise animate
                  // every thumbnail in a scrolling list.
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                ),
        ),
      ),
    );
  }

  /// The rendered extent in device pixels, or null when there is nothing finite
  /// to cap against — a `double.infinity` width (an image told to fill its
  /// parent) has no decode size of its own, so the other axis caps it instead.
  int? _decodePixels(BuildContext context, double? rendered) =>
      rendered == null || !rendered.isFinite
          ? null
          : (rendered * MediaQuery.devicePixelRatioOf(context)).round();
}
