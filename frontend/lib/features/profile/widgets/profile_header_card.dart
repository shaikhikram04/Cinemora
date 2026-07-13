import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/router/app_routes.dart';

/// Avatar, name, bio and primary actions for the current user.
class ProfileHeaderCard extends StatelessWidget {
  final UserModel? user;

  const ProfileHeaderCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '—';
    final username = user?.displayUsername ?? '—';
    final bio = user?.bio ?? 'Film • Anime • Series';
    final avatarUrl = user?.avatar;
    final coverUrl = user?.framePoster;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: context.colors.surfaceRaised,
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Stack(
        children: [
          // The user's cover, if they've picked one. It sits behind everything
          // and fades into the card so the name and bio stay legible; the
          // accent glows below stand in for it when unset.
          if (coverUrl != null)
            Positioned(
              top: 0.h,
              left: 0.w,
              right: 0.w,
              child: _CoverBanner(url: coverUrl),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: coverUrl != null ? 0 : null,
            top: coverUrl == null ? 0 : null,
            right: 0,
            child: Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        context.colors.accentPurple.withValues(alpha: 0.8),
                        context.colors.accentRed.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48.r,
                    backgroundColor: context.colors.surfaceRaised2,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person_rounded,
                            size: 40.sp, color: context.colors.mutedSecondary)
                        : null,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  name,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '@$username',
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.mutedSecondarySoft,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.editProfile),
                      child: _ActionButton(
                        label: 'Edit Profile',
                        icon: Icons.edit_rounded,
                        gradient: LinearGradient(
                          colors: [
                            context.colors.accentRed,
                            context.colors.accentRedAlt,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _ActionButton(
                      label: 'Share',
                      icon: Icons.share_rounded,
                      background:
                          context.colors.surfaceRaised.withValues(alpha: 0.2),
                      border: context.colors.borderStrong,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The user's cover image, faded top-to-bottom into the card background so the
/// name, bio and buttons stacked on top of it stay readable.
class _CoverBanner extends StatelessWidget {
  final String url;

  const _CoverBanner({required this.url});

  @override
  Widget build(BuildContext context) {
    final height = 130.h;

    return SizedBox(
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.transparent],
          stops: [0.35, 1.0],
        ).createShader(rect),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Width only: the source is a 1600x600 banner being drawn into a box
          // of a different aspect ratio, so constraining both axes would skew
          // the decode.
          cacheWidth: (1.sw * MediaQuery.devicePixelRatioOf(context)).round(),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? background;
  final Color? border;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.gradient,
    this.background,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: gradient,
        color: background,
        borderRadius: BorderRadius.circular(18.r),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: context.colors.primaryForeground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: context.colors.primaryForeground,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
