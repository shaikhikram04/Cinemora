import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/states/w_error_state.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/notifications/models/notification.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_cubit.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_state.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/assets_path.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // Cubit lives at app level (the home badge shares it) — load on open.
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return const _NotificationsContent();
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final grouped = state.grouped;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state, cubit),
                  SizedBox(height: 4.h),
                  Expanded(child: _buildBody(context, state, cubit, grouped)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationsState state,
    NotificationsCubit cubit,
    Map<String, List<AppNotification>> grouped,
  ) {
    if (state.status == NotificationsStatus.loading &&
        state.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.status == NotificationsStatus.failure &&
        state.notifications.isEmpty) {
      return _buildErrorState(context, state, cubit);
    }

    if (grouped.isEmpty) return _buildEmptyState(context);

    return RefreshIndicator(
      onRefresh: cubit.load,
      color: context.colors.primary,
      backgroundColor: context.colors.surfaceMuted,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 48.h),
        children: [
          for (final entry in grouped.entries) ...[
            _buildGroupLabel(context, entry.key),
            ...entry.value.map((n) => _buildNotifCard(context, n, cubit)),
          ],
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    NotificationsState state,
    NotificationsCubit cubit,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 12.h, WSizes.screenPadding.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
                color: context.colors.surfaceMuted,
                border: Border.all(color: context.colors.borderStrong),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colors.foreground,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (state.unreadCount > 0) ...[
                  SizedBox(width: 8.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (state.unreadCount > 0 && state.notifications.isNotEmpty)
            GestureDetector(
              onTap: cubit.markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Group label ─────────────────────────────────────────────────────────────

  Widget _buildGroupLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 22.h, WSizes.screenPadding.w, 8.h),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.colors.mutedSecondaryDeep,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Container(height: 1, color: context.colors.border)),
        ],
      ),
    );
  }

  // ── Notification row ────────────────────────────────────────────────────────
  //
  // One shared row layout for every variant — a flat list with hairline
  // dividers instead of a stack of individually bordered/filled cards, which
  // read as too many nested "boxes" when several sit next to each other.

  static String? _tagFor(AppNotification notif) => switch (notif.type) {
        NotificationType.newRelease => 'NOW AVAILABLE',
        NotificationType.newSeason => 'NEW SEASON',
        NotificationType.system => null,
      };

  static bool _canOpen(AppNotification notif) =>
      notif.tmdbId != null && notif.type != NotificationType.system;

  /// Same route args the library rows use; the detail screen fetches the real
  /// data by id — for anime sequels that id is the *new* season's MAL id.
  void _openTarget(BuildContext context, AppNotification notif) {
    final id = notif.tmdbId;
    if (id == null) return;
    final image = notif.posterUrlLarge ?? '';

    if (notif.cinemaType == 'movie') {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: notif.title,
          image: image,
          rating: '—',
          id: id,
        ),
      );
    } else {
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: notif.title,
          image: image,
          rating: '—',
          id: id,
          source: notif.cinemaType == 'anime' ? 'jikan' : 'tmdb',
          focusSeason: notif.season,
        ),
      );
    }
  }

  Widget _buildNotifCard(
      BuildContext context, AppNotification notif, NotificationsCubit cubit) {
    final isUnread = !notif.isRead;
    final tag = _tagFor(notif);

    return GestureDetector(
      onTap: () {
        cubit.markRead(notif.id);
        if (_canOpen(notif)) _openTarget(context, notif);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isUnread
              ? context.colors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            notif.type == NotificationType.system
                ? _buildCompactIcon(context)
                : _buildPosterThumb(context, notif),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null) ...[
                    Text(
                      tag,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Text(
                    notif.title,
                    style: TextStyle(
                      color: isUnread
                          ? context.colors.foreground
                          : context.colors.mutedSecondarySoft,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    notif.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread
                          ? context.colors.mutedForeground
                          : context.colors.mutedSecondaryDeep,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                  if (_canOpen(notif)) ...[
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View details',
                          style: TextStyle(
                            color: context.colors.primary,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(Icons.arrow_forward_rounded,
                            color: context.colors.primary, size: 12.sp),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notif.timeLabel,
                  style: TextStyle(
                    color: context.colors.mutedSecondaryDeep,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                AnimatedOpacity(
                  opacity: isUnread ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
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

  Widget _buildPosterThumb(BuildContext context, AppNotification notif) {
    final url = notif.posterUrl;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final placeholder = Container(
      color: context.colors.surfaceMuted,
      child: Center(
        child: AppIcon(
          AppIcons.movie,
          color: context.colors.mutedSecondary,
          size: 20.sp,
        ),
      ),
    );

    return SizedBox(
      width: 48.w,
      height: 64.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                // Single dimension only — the decoder keeps the source aspect
                // ratio and the box crops via BoxFit.cover.
                cacheHeight: (64.h * dpr).round(),
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }

  Widget _buildCompactIcon(BuildContext context) {
    final iconColor = context.colors.mutedSecondary;
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_rounded,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  // ── Empty & error states ────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(WSizes.xl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍿', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 20.h),
            Text(
              "You're all caught up",
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We'll let you know when titles you're\nwaiting on release or get new seasons.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.mutedSecondaryDeep,
                fontSize: 13.sp,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationsState state,
      NotificationsCubit cubit) {
    return WErrorState.fullScreen(
      message: state.errorMessage ?? "Couldn't load notifications",
      onRetry: cubit.load,
    );
  }
}
