import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';

class WhereToWatchSection extends StatelessWidget {
  final List<StreamingProvider>? providers;
  final bool isLoading;

  const WhereToWatchSection({
    super.key,
    this.providers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final list = providers ?? const [];
    if (!isLoading && list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WATCH NOW',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.accentRed,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          isLoading
              ? 'Checking platforms…'
              : 'Available on ${list.length} platform${list.length == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: isLoading
              ? _ProviderSkeletons()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, i) => _ProviderCard(provider: list[i]),
                ),
        ),
      ],
    );
  }
}

class _ProviderSkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, __) => Container(
          width: 98.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final StreamingProvider provider;

  const _ProviderCard({required this.provider});

  Future<void> _launch() async {
    final url = provider.webUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        width: 98.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(color: context.colors.borderStrong, width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProviderLogo(provider: provider),
                Icon(Icons.open_in_new_rounded,
                    size: 13.sp, color: context.colors.mutedSecondaryDeep),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    provider.type,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.mutedSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final StreamingProvider provider;

  const _ProviderLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final assetPath = provider.assetPath;
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          assetPath,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackLogo(provider: provider),
        ),
      );
    }
    if (provider.logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          provider.logoUrl!,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.cover,
          // Width only — see poster_image.dart for why passing both dims
          // can distort the decoded image.
          cacheWidth:
              (30.w * MediaQuery.of(context).devicePixelRatio).round(),
          errorBuilder: (_, __, ___) => _FallbackLogo(provider: provider),
        ),
      );
    }
    return _FallbackLogo(provider: provider);
  }
}

class _FallbackLogo extends StatelessWidget {
  final StreamingProvider provider;

  const _FallbackLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        provider.name.isNotEmpty ? provider.name[0] : '?',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
