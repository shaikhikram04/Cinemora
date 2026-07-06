import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/shimmer/w_shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/features/franchise/viewmodels/franchise_list_state.dart';
import 'package:cinemora/features/franchise/widgets/franchise_card.dart';

class FranchiseResultsSection extends StatelessWidget {
  final FranchiseStatus status;
  final List<FranchiseSummary> items;
  final ValueChanged<FranchiseSummary> onTap;
  final String? query;
  final String emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const FranchiseResultsSection({
    super.key,
    required this.status,
    required this.items,
    required this.onTap,
    this.query,
    this.emptyMessage = 'Nothing here yet',
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: switch (status) {
        FranchiseStatus.loading => const _ShimmerList(),
        FranchiseStatus.success => _ResultsList(
            items: items,
            query: query,
            onTap: onTap,
          ),
        FranchiseStatus.empty => _EmptyState(message: emptyMessage),
        FranchiseStatus.failure => _ErrorState(
            message: errorMessage,
            onRetry: onRetry,
          ),
        FranchiseStatus.idle => const SizedBox.shrink(),
      },
    );
  }
}

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

class _ResultsList extends StatelessWidget {
  final List<FranchiseSummary> items;
  final String? query;
  final ValueChanged<FranchiseSummary> onTap;

  const _ResultsList({required this.items, required this.onTap, this.query});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (query != null && query!.isNotEmpty)
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
                    text:
                        '${items.length} result${items.length == 1 ? '' : 's'} for ',
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
        Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              FranchiseCard(
                franchise: items[i],
                onTap: () => onTap(items[i]),
              ),
            ],
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
