import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/features/settings/viewmodels/data_library_cubit.dart';
import 'package:watchary/features/settings/viewmodels/data_library_state.dart';
import 'package:watchary/features/settings/widgets/settings_top_bar.dart';

class DataLibraryView extends StatelessWidget {
  const DataLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DataLibraryCubit(),
      child: const _DataLibraryContent(),
    );
  }
}

class _DataLibraryContent extends StatelessWidget {
  const _DataLibraryContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataLibraryCubit, DataLibraryState>(
      builder: (context, state) {
        final cubit = context.read<DataLibraryCubit>();
        return Scaffold(
      backgroundColor: WColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(title: 'Data & Library'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  WSizes.screenPadding.w,
                  16.h,
                  WSizes.screenPadding.w,
                  100.h,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Collection Stats
                  _CollectionStatsCard(),
                  SizedBox(height: 24.h),

                  // Export
                  _SectionLabel(label: 'EXPORT DATA'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: WColors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: WColors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _ExportRow(
                            icon: Icons.movie_filter_rounded,
                            iconColor: WColors.accentRed,
                            title: 'Export Collection',
                            subtitle: '523 titles • CSV or JSON',
                            onTap: () =>
                                _showExportDialog(context, 'Collection'),
                          ),
                          _Divider(),
                          _ExportRow(
                            icon: Icons.format_list_numbered_rounded,
                            iconColor: WColors.chartBlue,
                            title: 'Export Rankings',
                            subtitle: '4 lists • 55 total titles',
                            onTap: () => _showExportDialog(context, 'Rankings'),
                          ),
                          _Divider(),
                          _ExportRow(
                            icon: Icons.history_rounded,
                            iconColor: WColors.chartGreen,
                            title: 'Export Watch History',
                            subtitle: 'Activity log • CSV format',
                            isLast: true,
                            onTap: () =>
                                _showExportDialog(context, 'Watch History'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Storage
                  _SectionLabel(label: 'STORAGE'),
                  SizedBox(height: 10.h),
                  _StorageCard(
                    cacheCleared: state.cacheCleared,
                    onClearCache: () {
                      cubit.clearCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cache cleared',
                              style: TextStyle(fontSize: 14.sp)),
                          backgroundColor: WColors.chartGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  void _showExportDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WColors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Export $type',
          style: TextStyle(
            color: WColors.foreground,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose export format:',
              style: TextStyle(
                color: WColors.mutedSecondarySoft,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _FormatButton(label: 'CSV', onTap: () => Navigator.pop(ctx)),
                SizedBox(width: 10.w),
                _FormatButton(label: 'JSON', onTap: () => Navigator.pop(ctx)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: WColors.mutedSecondarySoft)),
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FormatButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: WColors.chartGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: WColors.chartGreen.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: WColors.chartGreen,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        label,
        style: TextStyle(
          color: WColors.mutedSecondaryDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 64.w),
      height: 0.5,
      color: WColors.borderStrong,
    );
  }
}

// ── Collection stats card ────────────────────────────────────────────────────

class _CollectionStatsCard extends StatelessWidget {
  const _CollectionStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: WColors.chartGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.library_books_outlined,
                    size: 19.sp, color: WColors.chartGreen),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Collection',
                    style: TextStyle(
                      color: WColors.foreground,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Complete overview',
                    style: TextStyle(
                      color: WColors.mutedSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _StatPill(
                  value: '523', label: 'Total', color: WColors.foreground),
              SizedBox(width: 10.w),
              _StatPill(
                  value: '325', label: 'Movies', color: WColors.accentRed),
              SizedBox(width: 10.w),
              _StatPill(
                  value: '132', label: 'Series', color: WColors.chartPurple),
              SizedBox(width: 10.w),
              _StatPill(
                  value: '66', label: 'Anime', color: WColors.chartYellow),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 0.5, color: WColors.borderStrong),
          SizedBox(height: 14.h),
          Row(
            children: [
              _StatPill(
                  value: '4', label: 'Rankings', color: WColors.chartBlue),
              SizedBox(width: 10.w),
              _StatPill(value: '6', label: 'Badges', color: WColors.warning),
              SizedBox(width: 10.w),
              _StatPill(
                  value: '4.3★',
                  label: 'Avg Rating',
                  color: WColors.chartYellow),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: WColors.surfaceRaised2,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: WColors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                color: WColors.mutedSecondaryDeep,
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Export row ───────────────────────────────────────────────────────────────

class _ExportRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLast;

  const _ExportRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 19.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: WColors.foreground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.file_download_outlined,
                  size: 18.sp, color: WColors.mutedSecondaryHeader),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Storage card ─────────────────────────────────────────────────────────────

class _StorageCard extends StatelessWidget {
  final bool cacheCleared;
  final VoidCallback onClearCache;

  const _StorageCard({
    required this.cacheCleared,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    final usedMB = cacheCleared ? 0 : 124;
    final totalMB = 1024;
    final fraction = usedMB / totalMB;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.storage_outlined,
                      size: 16.sp, color: WColors.chartGreen),
                  SizedBox(width: 6.w),
                  Text(
                    'Cache',
                    style: TextStyle(
                      color: WColors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                cacheCleared ? '0 MB / 1 GB' : '124 MB / 1 GB',
                style: TextStyle(
                  color: WColors.mutedSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6.h,
              backgroundColor: WColors.surfaceTint.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(
                cacheCleared ? WColors.chartGreen : WColors.warning,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: cacheCleared ? null : onClearCache,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: cacheCleared
                    ? WColors.surfaceRaised2
                    : WColors.chartGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: cacheCleared
                      ? WColors.borderStrong
                      : WColors.chartGreen.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cacheCleared
                        ? Icons.check_circle_outline_rounded
                        : Icons.cleaning_services_rounded,
                    size: 16.sp,
                    color: cacheCleared
                        ? WColors.mutedSecondary
                        : WColors.chartGreen,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    cacheCleared ? 'Cache Cleared' : 'Clear Cache',
                    style: TextStyle(
                      color: cacheCleared
                          ? WColors.mutedSecondary
                          : WColors.chartGreen,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
