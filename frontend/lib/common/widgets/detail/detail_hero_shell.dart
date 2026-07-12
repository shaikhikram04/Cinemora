import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/buttons/circle_icon_button.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

/// Shared backdrop shell for movie and series detail hero headers.
/// Renders the full-bleed image, the gradient overlay, and the top nav row
/// (back + share). Caller provides [bottomContent] for the title/meta area.
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
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenW = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: WSizes.imageDetailsHeroHeight.h,
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  context.colors.background.withValues(alpha: 0.65),
                  context.colors.background.withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.3, 0.68, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w,
                vertical: 12.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WCircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    iconColor: Colors.white,
                  ),
                  WCircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared!')),
                    ),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    iconColor: Colors.white,
                    iconSize: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 24.w,
          right: 24.w,
          child: bottomContent,
        ),
      ],
    );
  }
}
