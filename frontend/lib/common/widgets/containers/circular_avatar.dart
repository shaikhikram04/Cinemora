import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCircularAvatar extends StatelessWidget {
  const AppCircularAvatar({
    super.key,
    required this.imageUrl,
    required this.initial,
    required this.fallbackColor,
    this.size = AppSizes.avatarSize,
  });

  final String? imageUrl;
  final String initial;
  final Color fallbackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.borderStrong,
          width: AppSizes.borderWidth,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                // Width only — profile photos are
                // portrait, not square; passing both
                // dims would squish them into the
                // circle instead of letting cover
                // crop them correctly.
                cacheWidth:
                    (size.w * MediaQuery.of(context).devicePixelRatio).round(),
                errorBuilder: (_, __, ___) => _InitialAvatar(
                  name: initial,
                  color: fallbackColor,
                ),
              )
            : _InitialAvatar(
                name: initial,
                color: fallbackColor,
              ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _InitialAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return ColoredBox(
      color: color,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: AppSizes.fontSize16.sp,
            fontWeight: FontWeight.bold,
            // Sits on the caller's fallbackColor, not a themed surface.
            color: context.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
