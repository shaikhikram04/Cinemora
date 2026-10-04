import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cinemora/common/widgets/shimmer/shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/common/widgets/images/curved_network_image.dart';

// Card geometry shared by the loaded card and its skeleton, so the two cannot
// drift apart. Local because nothing outside this section lays out on them.
const double _cardWidth = 98.0;
const double _rowHeight = 90.0;
const double _logoSize = 30.0;
// The "Subscription"/"Rent" badge is small enough that the 8pt radius step
// would read as a pill rather than a tag.
const double _typeBadgeRadius = 4.0;

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

    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WATCH NOW',
          style: TextStyle(
            fontSize: AppSizes.fontSize12.sp,
            fontWeight: FontWeight.w700,
            color: colors.accentRed,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: AppSizes.space4.h),
        Text(
          isLoading
              ? 'Checking platforms…'
              : 'Available on ${list.length} platform${list.length == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: AppSizes.fontSize14.sp,
            fontWeight: FontWeight.w700,
            color: colors.foreground,
          ),
        ),
        SizedBox(height: AppSizes.space12.h),
        SizedBox(
          height: _rowHeight.h,
          child: isLoading
              ? const _ProviderSkeletons()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: AppSizes.space10.w),
                  itemBuilder: (context, i) => _ProviderCard(provider: list[i]),
                ),
        ),
      ],
    );
  }
}

class _ProviderSkeletons extends StatelessWidget {
  const _ProviderSkeletons();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: AppSizes.space10.w),
        itemBuilder: (_, __) => Container(
          width: _cardWidth.w,
          decoration: BoxDecoration(
            // Shimmer masks its child's shapes with its own colors, so the
            // placeholder stays plain white rather than taking a theme color.
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius12.r),
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
    final colors = context.colors;
    return GestureDetector(
      onTap: _launch,
      child: Container(
        width: _cardWidth.w,
        padding: EdgeInsets.all(AppSizes.space10.w),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSizes.radius12.r),
          border: Border.all(color: colors.borderStrong, width: 0.7),
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
                    size: AppSizes.icon14.sp, color: colors.mutedSecondaryDeep),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: AppSizes.fontSize12.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.space2.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.space6.w,
                    vertical: AppSizes.space2.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(_typeBadgeRadius.r),
                  ),
                  child: Text(
                    provider.type,
                    style: TextStyle(
                      fontSize: AppSizes.fontSize10.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedSecondary,
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
    if (provider.logoUrl != null) {
      return CurvedNetworkImage(
        url: provider.logoUrl,
        width: _logoSize,
        height: _logoSize,
        radius: AppSizes.radius8,
        placeholder: _FallbackLogo(provider: provider),
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
    final colors = context.colors;
    return Container(
      width: _logoSize.w,
      height: _logoSize.h,
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppSizes.radius8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        provider.name.isNotEmpty ? provider.name[0] : '?',
        style: TextStyle(
          fontSize: AppSizes.fontSize14.sp,
          fontWeight: FontWeight.w900,
          color: colors.primaryForeground,
        ),
      ),
    );
  }
}
