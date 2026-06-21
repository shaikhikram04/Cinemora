import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';

class CastSection extends StatelessWidget {
  final List<CastMember>? cast;
  final bool isLoading;

  const CastSection({super.key, this.cast, this.isLoading = false});

  static final _fallbackColors = [
    const Color(0xFF718096),
    const Color(0xFFEB4B6B),
    const Color(0xFFE0A838),
    const Color(0xFFE84B57),
    const Color(0xFF8C8C97),
  ];

  @override
  Widget build(BuildContext context) {
    final members = cast ?? const [];
    if (!isLoading && members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 130.h,
          child: isLoading && members.isEmpty
              ? _CastSkeletons()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final fallbackColor =
                        _fallbackColors[index % _fallbackColors.length];
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.borderStrong,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: member.profileUrl != null
                                  ? Image.network(
                                      member.profileUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _InitialAvatar(
                                        name: member.name,
                                        color: fallbackColor,
                                      ),
                                    )
                                  : _InitialAvatar(
                                      name: member.name,
                                      color: fallbackColor,
                                    ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: 74.w,
                            child: Text(
                              member.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.foreground,
                                height: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          SizedBox(
                            width: 74.w,
                            child: Text(
                              member.character,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CastSkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Column(
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              _SkeletonLine(width: 60.w),
              SizedBox(height: 4.h),
              _SkeletonLine(width: 44.w),
            ],
          ),
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
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;

  const _SkeletonLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
