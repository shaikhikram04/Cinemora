import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/app_colors.dart';

class TopGradientBackgroundContainer extends StatelessWidget {
  const TopGradientBackgroundContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.primary.withAlpha(38),
            context.colors.background,
            context.colors.background,
          ],
        ),
      ),
      child: child,
    );
  }
}
