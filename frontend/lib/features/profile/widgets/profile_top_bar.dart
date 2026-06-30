import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/router/app_routes.dart';

/// Profile screen title row with the settings shortcut.
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.settings),
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: context.colors.surfaceRaised.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 20.sp,
              color: context.colors.mutedSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
