import 'package:flutter/material.dart';

import 'package:cinemora/core/constants/app_colors.dart';

/// Darkens artwork so a caption, badge or control stays legible on top of it.
///
/// Drop it into the [Stack] above an image, usually inside the same clip:
///
/// ```dart
/// Stack(fit: StackFit.expand, children: [
///   CurvedNetworkImage(url: poster, width: 130, height: 180),
///   ArtworkScrim.bottom(),
///   Positioned(bottom: 8, left: 8, child: Text(title)),
/// ])
/// ```
///
/// The black is deliberately **theme-independent**: these sit on photographs,
/// not on a themed surface, so a theme color would invert in light mode and
/// strand white text on near-white. [ArtworkScrim.toBackground] is the one
/// exception — its job is to dissolve artwork into the page beneath it, so it
/// follows the theme by design.
class ArtworkScrim extends StatelessWidget {
  /// Opacities from [begin] to [end]; 0 is fully transparent.
  final List<double> opacities;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  /// Tints toward the theme background instead of black.
  final bool towardBackground;

  /// Vertical fade, clear at the top and dark at the bottom — the shape for a
  /// title or rating sitting on the lower edge of a poster or backdrop.
  ///
  /// [midOpacity] adds a third stop at [midStop], for artwork that needs its
  /// middle held down too rather than one sweep to the bottom. [topOpacity]
  /// darkens the top edge as well, where a control sits up there.
  ArtworkScrim.bottom({
    super.key,
    double opacity = 0.78,
    double? midOpacity,
    double midStop = 0.5,
    double topOpacity = 0.0,
  })  : opacities = midOpacity == null
            ? [topOpacity, opacity]
            : [topOpacity, midOpacity, opacity],
        stops = midOpacity == null ? null : [0.0, midStop, 1.0],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter,
        towardBackground = false;

  /// Fade in from one edge or corner, for a label hugging that side.
  ArtworkScrim.edge({
    super.key,
    required AlignmentGeometry from,
    required AlignmentGeometry to,
    double opacity = 0.45,
  })  : opacities = [0.0, opacity],
        stops = null,
        begin = from,
        end = to,
        towardBackground = false;

  /// Fade from clear artwork into the page background, so a hero header merges
  /// with the content scrolling beneath it rather than ending on a hard edge.
  ArtworkScrim.toBackground({
    super.key,
    double opacity = 0.7,
  })  : opacities = [0.0, opacity],
        stops = null,
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter,
        towardBackground = true;

  @override
  Widget build(BuildContext context) {
    final base =
        towardBackground ? context.colors.background : const Color(0xFF000000);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          stops: stops,
          colors: [
            for (final opacity in opacities) base.withValues(alpha: opacity),
          ],
        ),
      ),
    );
  }
}
