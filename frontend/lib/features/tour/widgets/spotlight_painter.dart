import 'package:flutter/material.dart';

/// Paints the dimmed scrim with a rounded hole punched out of it, plus the
/// pulsing ring that draws the eye to the hole.
///
/// The hole is a path difference rather than a `saveLayer` + [BlendMode.clear]
/// composite: no offscreen buffer, and no faint seam along the cut-out edge
/// that the blend-mode approach leaves behind on some devices.
class SpotlightPainter extends CustomPainter {
  /// Hole in global (screen) coordinates.
  final Rect hole;
  final double holeRadius;

  /// Scrim opacity, 0→1, so the overlay can fade in on the first step.
  final double scrimOpacity;

  /// Pulse phase, 0→1, repeating. Drives the ring's radius and its fade-out.
  final double pulse;

  final Color ringColor;

  /// When false only the highlight is drawn — no dimming. Used by steps that
  /// mark a control without hiding the screen behind it.
  final bool drawScrim;

  const SpotlightPainter({
    required this.hole,
    required this.holeRadius,
    required this.scrimOpacity,
    required this.pulse,
    required this.ringColor,
    this.drawScrim = true,
  });

  /// Deliberately light. The app is already dark, so a heavy scrim turns the
  /// surrounding UI into an unreadable black slab — the user loses the context
  /// the coach mark is supposed to be teaching them to navigate. Focus is
  /// carried by the ring and the outline below instead of by sheer darkness.
  static const _maxScrimAlpha = 0.45;
  static const _ringMaxSpread = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Rect.fromLTWH(0, 0, size.width, size.height);
    final cutout = RRect.fromRectAndRadius(hole, Radius.circular(holeRadius));

    if (drawScrim) {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(screen),
          Path()..addRRect(cutout),
        ),
        Paint()
          ..color =
              Colors.black.withValues(alpha: _maxScrimAlpha * scrimOpacity),
      );
    }

    // Steady outline on the hole itself. With a light scrim the brightness
    // difference alone is too subtle to mark the target, so the edge is drawn
    // rather than merely implied.
    canvas.drawRRect(
      cutout,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ringColor.withValues(alpha: 0.9 * scrimOpacity),
    );

    // Ring expands out of the hole edge and fades as it goes, so it reads as
    // emanating from the control rather than framing it.
    final spread = _ringMaxSpread * pulse;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        hole.inflate(spread),
        Radius.circular(holeRadius + spread),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ringColor.withValues(alpha: 0.7 * (1 - pulse) * scrimOpacity),
    );
  }

  @override
  bool shouldRepaint(SpotlightPainter old) =>
      old.hole != hole ||
      old.holeRadius != holeRadius ||
      old.scrimOpacity != scrimOpacity ||
      old.pulse != pulse ||
      old.ringColor != ringColor ||
      old.drawScrim != drawScrim;
}
