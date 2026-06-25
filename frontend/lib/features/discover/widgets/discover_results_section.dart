import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/discover/models/search_result_item.dart';
import 'package:cinemora/features/discover/viewmodels/discover_state.dart';
import 'package:cinemora/features/discover/widgets/discover_result_card.dart';

class DiscoverResultsSection extends StatelessWidget {
  final DiscoverSearchStatus status;
  final List<SearchResultItem> results;
  final String query;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const DiscoverResultsSection({
    super.key,
    required this.status,
    required this.results,
    required this.query,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: switch (status) {
        DiscoverSearchStatus.loading => const _ShimmerList(),
        DiscoverSearchStatus.success => _ResultsList(
            results: results,
            query: query,
          ),
        DiscoverSearchStatus.empty => _EmptyState(query: query),
        DiscoverSearchStatus.failure => _ErrorState(
            message: errorMessage,
            onRetry: onRetry,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: WShimmer(
            child: Container(
              height: 96.h,
              decoration: BoxDecoration(
                color: context.colors.surfaceChip,
                borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<SearchResultItem> results;
  final String query;

  const _ResultsList({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count header
        if (query.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colors.mutedForeground,
                ),
                children: [
                  TextSpan(
                    text: '${results.length} result${results.length == 1 ? '' : 's'} for ',
                  ),
                  TextSpan(
                    text: '"$query"',
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => DiscoverResultCard(item: results[i]),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52.sp,
              color: context.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text(
              query.isNotEmpty ? 'No results for "$query"' : 'Nothing here yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try a different title, genre, or director',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.mutedForeground,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const _ErrorState({this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48.sp,
              color: context.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
