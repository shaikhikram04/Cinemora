import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/curved_icon_button.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

/// Top scrim painted on the backdrop artwork itself, not on a themed surface,
/// so it stays black in both themes — a theme token would invert in light mode
/// and leave the white back button sitting on near-white.
const Color _backdropTopScrim = Color(0x40000000); // black 25%

/// Shared backdrop shell for movie and series detail hero headers.
/// Renders the full-bleed image, the gradient overlay, and the back button.
/// Caller provides [bottomContent] for the title/meta area.
class DetailHeroShell extends StatelessWidget {
  final String imageUrl;
  final Widget bottomContent;

  const DetailHeroShell({
    super.key,
    required this.imageUrl,
    required this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenW = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: AppSizes.imageDetailsHeroHeight.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              // DecorationImage has no cacheWidth/cacheHeight of its own —
              // ResizeImage caps the decode size the same way, avoiding a
              // full-resolution TMDB backdrop decode on every details page.
              // Width only: passing both dims stretches the decode to that
              // exact box, distorting the image if its real aspect ratio
              // doesn't match.
              image: ResizeImage(
                NetworkImage(imageUrl),
                width: (screenW * dpr).round(),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
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
          child: bottomContent,
        ),
      ],
    );
  }
}
