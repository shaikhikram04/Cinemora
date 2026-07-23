import 'package:flutter/material.dart';

/// Renders a custom raster glyph from [AppIcons] the way [Icon] renders a font
/// glyph: tinted to a single colour and sized by a single dimension.
///
/// The assets are single-colour line art on a transparent background, so the
/// tint is applied with the default `BlendMode.srcIn` — colour comes from the
/// caller (or the ambient [IconTheme]), transparency is preserved. Painting one
/// of these with a plain `Image.asset` would leave it near-black and invisible
/// in dark mode.
class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const AppIcon(this.asset, {super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    // Source art is 500px square; decoding at the display size keeps these off
    // the image cache's hot list. Width only — height would distort any glyph
    // whose source aspect ratio isn't exactly square.
    final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: cacheWidth,
      color: color ?? IconTheme.of(context).color,
      filterQuality: FilterQuality.medium,
    );
  }
}
