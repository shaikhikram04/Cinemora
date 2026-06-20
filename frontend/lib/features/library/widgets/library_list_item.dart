import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/core/utils/rating_display_utils.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';

class LibraryListItem extends StatelessWidget {
  final LibraryEntryModel entry;

  const LibraryListItem({
    super.key,
    required this.entry,
  });

  // If only one season was added, focus that season when opening series details.
  int? get _focusSeason =>
      entry.cinemaType != 'movie' && entry.seasons.length == 1
          ? entry.seasons.first.seasonNumber
          : null;

  void _openDetail(BuildContext context) {
    if (entry.cinemaType == 'movie') {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: entry.title,
          image: entry.posterUrl,
          rating: entry.tmdbRating?.toStringAsFixed(1) ?? '—',
          id: entry.tmdbId,
        ),
      );
    } else {
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: entry.title,
          image: entry.posterUrl,
          rating: entry.tmdbRating?.toStringAsFixed(1) ?? '—',
          id: entry.tmdbId,
          source: entry.cinemaType == 'anime' ? 'jikan' : 'tmdb',
          focusSeason: _focusSeason,
        ),
      );
    }
  }

  void _openActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _ActionsSheet(
        entry: entry,
        cubit: context.read<LibraryCubit>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProgress = entry.cinemaType != 'movie' &&
        entry.progress != null &&
        entry.progress!.progressFraction > 0;

    final rewatchCount = entry.watchedAt.length;
    final focusSeason = _focusSeason;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90.w,
                      height: 110.h,
                      child: entry.posterUrl.isNotEmpty
                          ? Image.network(
                              entry.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _PosterPlaceholder(
                                type: entry.cinemaType,
                              ),
                            )
                          : _PosterPlaceholder(type: entry.cinemaType),
                    ),
                    // Fade overlay on left edge
                    Container(
                      width: 90.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 6.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + menu button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(
                              color: context.colors.foreground,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openActionsSheet(context),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.w, top: 2.h),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 16.sp,
                                color: context.colors.mutedSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Year · season badge · type · TMDb rating
                    Row(
                      children: [
                        if (entry.releaseYear != null) ...[
                          Text(
                            entry.releaseYear!,
                            style: TextStyle(
                              color: context.colors.mutedSecondary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _dot(context),
                        ],
                        // Season badge when only one season is tracked
                        if (focusSeason != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _typeColor(context, entry.cinemaType)
                                    .withValues(alpha: 0.6),
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'S$focusSeason',
                              style: TextStyle(
                                color: _typeColor(context, entry.cinemaType),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                        ],
                        Text(
                          entry.displayType.toUpperCase(),
                          style: TextStyle(
                            color: _typeColor(context, entry.cinemaType),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (entry.tmdbRating != null) ...[
                          _dot(context),
                          Icon(Icons.star_rounded,
                              color: context.colors.tertiary, size: 13.sp),
                          SizedBox(width: 3.w),
                          Text(
                            entry.tmdbRating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: context.colors.tertiary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' TMDb',
                            style: TextStyle(
                              color: context.colors.mutedSecondaryDeep,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // User rating stars + optional rewatch badge
                    if (entry.userRating != null && entry.userRating! > 0) ...[
                      SizedBox(height: 7.h),
                      Row(
                        children: [
                          Text(
                            entry.userRating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: ratingColorFor(entry.userRating!),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _StarRow(rating: entry.userRating!),
                          if (rewatchCount > 1) ...[
                            SizedBox(width: 8.w),
                            _RewatchBadge(count: rewatchCount),
                          ],
                        ],
                      ),
                    ] else if (rewatchCount > 1) ...[
                      SizedBox(height: 7.h),
                      _RewatchBadge(count: rewatchCount),
                    ],

                    // Progress bar + episode label
                    if (hasProgress) ...[
                      SizedBox(height: 8.h),
                      _ProgressRow(entry: entry),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text(
          '•',
          style: TextStyle(
            color: context.colors.mutedSecondaryDeep,
            fontSize: 11.sp,
          ),
        ),
      );

  Color _typeColor(BuildContext context, String cinemaType) {
    switch (cinemaType) {
      case 'anime':
        return context.colors.warning;
      case 'tv':
        return context.colors.accentPurple;
      default:
        return context.colors.accentRed;
    }
  }
}

// ── Rewatch Badge ─────────────────────────────────────────────────────────────

class _RewatchBadge extends StatelessWidget {
  final int count;

  const _RewatchBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.colors.accentRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.replay_rounded,
            size: 10.sp,
            color: context.colors.accentRed.withValues(alpha: 0.8),
          ),
          SizedBox(width: 2.w),
          Text(
            '$count×',
            style: TextStyle(
              color: context.colors.accentRed.withValues(alpha: 0.8),
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Row ──────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  final LibraryEntryModel entry;

  const _ProgressRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final fraction = entry.progress!.progressFraction;
    final label = entry.progress!.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 3.h,
            backgroundColor: context.colors.borderStrong,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.accentRed.withValues(alpha: 0.8),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Star Row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && i < rating;
        return Icon(
          half ? Icons.star_half_rounded : Icons.star_rounded,
          size: 14.sp,
          color: full || half
              ? ratingColorFor(rating)
              : context.colors.mutedSecondaryHeader,
        );
      }),
    );
  }
}

// ── Poster Placeholder ────────────────────────────────────────────────────────

class _PosterPlaceholder extends StatelessWidget {
  final String type;

  const _PosterPlaceholder({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = type == 'anime'
        ? Icons.auto_awesome_outlined
        : type == 'tv'
            ? Icons.tv_outlined
            : Icons.movie_outlined;

    return Container(
      color: context.colors.surfaceMuted,
      child: Center(
        child: Icon(icon, color: context.colors.mutedSecondary, size: 28.sp),
      ),
    );
  }
}

// ── Actions Bottom Sheet ──────────────────────────────────────────────────────

class _ActionsSheet extends StatelessWidget {
  final LibraryEntryModel entry;
  final LibraryCubit cubit;

  const _ActionsSheet({
    required this.entry,
    required this.cubit,
  });

  static const _moveStatuses = [
    ('Watchlist', Icons.bookmark_rounded),
    ('Watched', Icons.check_circle_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isWatched = entry.status == 'watched';
    final isDropped = entry.status == 'dropped';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: context.colors.borderStrong),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colors.mutedSecondaryDeep,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title + current status pill
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _statusColor(context, entry.status)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99.r),
                      border: Border.all(
                        color: _statusColor(context, entry.status)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      entry.displayStatus,
                      style: TextStyle(
                        color: _statusColor(context, entry.status),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Move to',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Watchlist / Watched ──────────────────────────────────
              Row(
                children: _moveStatuses.map((s) {
                  final (label, icon) = s;
                  final isCurrent = entry.displayStatus == label;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: s == _moveStatuses.last ? 0 : 8.w),
                      child: GestureDetector(
                        onTap: isCurrent
                            ? null
                            : () {
                                Navigator.pop(context);
                                cubit.updateEntryStatus(
                                    entry.tmdbId, entry.cinemaType, label);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? context.colors.accentRed
                                    .withValues(alpha: 0.12)
                                : context.colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isCurrent
                                  ? context.colors.accentRed
                                      .withValues(alpha: 0.5)
                                  : context.colors.borderStrong,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                icon,
                                size: 20.sp,
                                color: isCurrent
                                    ? context.colors.accentRed
                                    : context.colors.mutedSecondary,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isCurrent
                                      ? context.colors.foreground
                                      : context.colors.mutedSecondary,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10.h),

              // ── Rewatch — only when already watched ─────────────────
              if (isWatched) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    cubit.markAsRewatch(entry.tmdbId, entry.cinemaType);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    decoration: BoxDecoration(
                      color: context.colors.accentRed.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: context.colors.accentRed.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 17.sp,
                          color: context.colors.accentRed,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Watch again',
                          style: TextStyle(
                            color: context.colors.accentRed,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // ── Divider ──────────────────────────────────────────────
              Divider(
                color: context.colors.borderStrong,
                height: 1,
                thickness: 1,
              ),
              SizedBox(height: 10.h),

              // ── Drop — only when not already dropped ─────────────────
              if (!isDropped) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    cubit.updateEntryStatus(
                        entry.tmdbId, entry.cinemaType, 'Dropped');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: context.colors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 17.sp,
                          color: context.colors.warning,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Drop it',
                          style: TextStyle(
                            color: context.colors.warning,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // ── Remove from library ───────────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  cubit.removeEntry(entry.tmdbId, entry.cinemaType);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: context.colors.accentRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: context.colors.accentRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18.sp,
                        color: context.colors.accentRed,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Remove from library',
                        style: TextStyle(
                          color: context.colors.accentRed,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'watched':
        return context.colors.success;
      case 'dropped':
        return context.colors.warning;
      default:
        return context.colors.accentRed;
    }
  }
}
