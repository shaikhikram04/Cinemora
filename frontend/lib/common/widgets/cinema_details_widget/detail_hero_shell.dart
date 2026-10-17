import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/curved_icon_button.dart';
import 'package:cinemora/common/widgets/images/curved_network_image.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

/// Top scrim painted on the backdrop artwork itself, not on a themed surface,
/// so it stays black in both themes — a theme token would invert in light mode
/// and leave the white back button sitting on near-white.
const Color _backdropTopScrim = Color(0x40000000); // black 25%

// The poster card. 2:3 is the ratio every poster is authored at, so the artwork
// is shown whole and nothing crops the face.
const double _posterWidth = 112.0;
const double _posterHeight = 168.0;

/// Shared hero header for movie and series detail screens.
///
/// Lays the title's poster, whole and uncropped, over a landscape plate, with
/// [bottomContent] (title, chips, meta) beside it.
///
/// The two assets do different jobs and are not interchangeable. [backdropUrl]
/// is a 16:9 still that fills the plate; [posterUrl] is 2:3 and belongs in the
/// card. Most navigations into the detail screens carry only a poster, so when
/// there is no backdrop the plate falls back to the poster *blurred* — stretched
/// across a landscape box it would otherwise lose a third of its height to the
/// crop, taken out of the top and bottom where the faces are.
///
/// Leave [posterUrl] null for a subject that has no poster of its own, such as a
/// collection: the card is dropped and [bottomContent] spans the full width.
class DetailHeroShell extends StatelessWidget {
  /// 16:9 still for the plate. Null or empty falls back to a blurred [posterUrl].
  final String? backdropUrl;

  /// The title's 2:3 poster, shown whole in the card.
  final String? posterUrl;

  final Widget bottomContent;

  const DetailHeroShell({
    super.key,
    required this.bottomContent,
    this.posterUrl,
    this.backdropUrl,
  });

  bool get _hasBackdrop => backdropUrl != null && backdropUrl!.isNotEmpty;
  bool get _hasPoster => posterUrl != null && posterUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: AppSizes.imageDetailsHeroHeight.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Plate(
            url: _hasBackdrop ? backdropUrl! : (_hasPoster ? posterUrl! : null),
            blurred: !_hasBackdrop,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backdropTopScrim,
                  Colors.transparent,
                  colors.background.withValues(alpha: 0.65),
                  colors.background.withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.3, 0.68, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.buttonHorizontalPadding.w,
                  vertical: AppSizes.buttonVerticalPadding.h,
                ),
                child: CurvedIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                  // Sits on the backdrop artwork, so it stays light in both
                  // themes rather than following the theme's foreground.
                  iconColor: colors.primaryForeground,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: AppSizes.space24.w,
            right: AppSizes.space24.w,
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSizes.space20.h),
              child: Row(
                // Both sit on the hero's bottom edge, so a short meta block
                // doesn't float away from the poster it belongs to.
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_hasPoster) ...[
                    _PosterCard(url: posterUrl!),
                    SizedBox(width: AppSizes.space16.w),
                  ],
                  Expanded(child: bottomContent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The landscape image behind the poster — a backdrop at full sharpness, or the
/// poster blurred into a colour wash when that is all we have.
class _Plate extends StatelessWidget {
  final String? url;
  final bool blurred;

  const _Plate({required this.url, required this.blurred});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return ColoredBox(color: context.colors.surfaceMuted);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final decodeWidth = (MediaQuery.sizeOf(context).width * dpr).round();

    final image = CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      // Width only: pinning both axes stretches the decode to that exact box
      // and distorts any source whose real aspect ratio differs.
      memCacheWidth: decodeWidth,
      maxWidthDiskCache: decodeWidth,
      errorWidget: (_, __, ___) =>
          ColoredBox(color: context.colors.surfaceMuted),
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
    );

    if (!blurred) return image;

    // Isolated so the blur doesn't re-run on unrelated repaints in the hero.
    return RepaintBoundary(
      child: image,
    );
  }
}

class _PosterCard extends StatelessWidget {
  final String url;

  const _PosterCard({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius12.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadowStrong,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CurvedNetworkImage(
        url: url,
        width: _posterWidth,
        height: _posterHeight,
        radius: AppSizes.radius12,
        placeholder: Center(
          child: Icon(
            Icons.movie_outlined,
            color: colors.mutedForeground,
            size: AppSizes.icon32.sp,
          ),
        ),
      ),
    );
  }
}
