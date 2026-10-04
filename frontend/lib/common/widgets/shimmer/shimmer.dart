import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceMuted,
      highlightColor: context.colors.surfaceRaised2,
      child: child,
    );
  }
}
