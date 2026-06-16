import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/notifications/models/notification.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_cubit.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_state.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: const _NotificationsContent(),
    );
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
                  Expanded(
                    child: grouped.isEmpty
                        ? _buildEmptyState(context)
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 48.h),
                            children: [
                              for (final entry in grouped.entries) ...[
                                _buildGroupLabel(context, entry.key),
                                ...entry.value.map(
                                  (n) => _buildNotifCard(context, n, cubit),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                      borderRadius:
                          BorderRadius.circular(WSizes.radiusFull.r),
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
          if (state.unreadCount > 0)
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

  // ── Card dispatcher ─────────────────────────────────────────────────────────

  Widget _buildNotifCard(BuildContext context, WNotif notif, NotificationsCubit cubit) {
    return switch (notif.variant) {
      NotifCardVariant.media => _buildMediaCard(context, notif, cubit),
      NotifCardVariant.recommendation =>
        _buildRecommendationCard(context, notif, cubit),
      NotifCardVariant.compact => _buildCompactCard(context, notif, cubit),
    };
  }

  // ── Media card ──────────────────────────────────────────────────────────────

  Widget _buildMediaCard(BuildContext context, WNotif notif, NotificationsCubit cubit) {
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () => cubit.markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isUnread
              ? context.colors.surfaceRaised
              : context.colors.surfaceBorderAlt.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
          border: Border.all(
            color: isUnread
                ? context.colors.primary.withValues(alpha: 0.35)
                : context.colors.border,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      notif.posterColor,
                      notif.posterColorAlt ??
                          notif.posterColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.22),
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (notif.tag != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              notif.tag!,
                              style: TextStyle(
                                color: context.colors.primary,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          notif.timeLabel,
                          style: TextStyle(
                            color: context.colors.mutedSecondaryDeep,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (notif.seriesTitle != null)
                      Text(
                        notif.seriesTitle!,
                        style: TextStyle(
                          color: isUnread
                              ? context.colors.foreground
                              : context.colors.mutedSecondarySoft,
                          fontSize: 15.sp,
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
                        fontSize: 11.sp,
                        height: 1.4,
                      ),
                    ),
                    if (notif.ctaLabel != null) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Text(
                            notif.ctaLabel!,
                            style: TextStyle(
                              color: context.colors.primary,
                              fontSize: 11.sp,
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Recommendation card ─────────────────────────────────────────────────────

  Widget _buildRecommendationCard(BuildContext context, WNotif notif, NotificationsCubit cubit) {
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () => cubit.markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isUnread
              ? context.colors.surfaceRaised
              : context.colors.surfaceBorderAlt.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
          border: Border.all(
            color: isUnread ? context.colors.borderStrong : context.colors.border,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notif.becauseOf != null)
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: context.colors.mutedSecondaryHighlight,
                      size: 11.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      notif.becauseOf!,
                      style: TextStyle(
                        color: context.colors.mutedSecondaryHighlight,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            color: isUnread
                                ? context.colors.foreground
                                : context.colors.mutedSecondarySoft,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notif.body,
                          style: TextStyle(
                            color: isUnread
                                ? context.colors.mutedForeground
                                : context.colors.mutedSecondaryDeep,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          notif.timeLabel,
                          style: TextStyle(
                            color: context.colors.mutedSecondaryDeep,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Container(
                    width: 50.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          notif.posterColor,
                          notif.posterColorAlt ??
                              notif.posterColor.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie_rounded,
                        color: Colors.white.withValues(alpha: 0.18),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact card ────────────────────────────────────────────────────────────

  Widget _buildCompactCard(BuildContext context, WNotif notif, NotificationsCubit cubit) {
    final isUnread = !notif.isRead;
    final iconColor = notif.compactIconColor ?? context.colors.mutedSecondary;

    return GestureDetector(
      onTap: () => cubit.markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isUnread
              ? context.colors.surfaceRaised
              : context.colors.surfaceBorderAlt.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: isUnread ? context.colors.borderStrong : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
              ),
              child: Icon(
                notif.compactIcon ?? Icons.notifications_rounded,
                color: iconColor,
                size: 17.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      color: isUnread
                          ? context.colors.foreground
                          : context.colors.mutedSecondarySoft,
                      fontSize: 13.sp,
                      fontWeight:
                          isUnread ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    notif.body,
                    style: TextStyle(
                      color: context.colors.mutedSecondaryDeep,
                      fontSize: 11.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                SizedBox(height: 4.h),
                Text(
                  notif.timeLabel,
                  style: TextStyle(
                    color: context.colors.mutedSecondaryDeep,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

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
              "We'll let you know when new episodes,\nseasons, and recommendations arrive.",
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
}
