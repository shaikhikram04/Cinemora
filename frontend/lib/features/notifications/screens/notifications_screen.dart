import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

// Three distinct card templates:
//   media        → season / episode releases with poster + series title + inline CTA
//   recommendation → "Because you liked X" cards with accent label + artwork
//   compact      → achievements, system nudges, milestones — single-row density
enum _CardVariant { media, recommendation, compact }

class _Notif {
  final String id;
  final _CardVariant variant;
  final String title;
  final String? seriesTitle;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String? ctaLabel;
  final Color posterColor;
  final Color? posterColorAlt;
  final String? tag;
  final String? becauseOf;
  final IconData? compactIcon;
  final Color? compactIconColor;

  const _Notif({
    required this.id,
    required this.variant,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.seriesTitle,
    this.isRead = false,
    this.ctaLabel,
    this.posterColor = const Color(0xFF3A3A4A),
    this.posterColorAlt,
    this.tag,
    this.becauseOf,
    this.compactIcon,
    this.compactIconColor,
  });

  _Notif copyWith({bool? isRead}) => _Notif(
        id: id,
        variant: variant,
        title: title,
        seriesTitle: seriesTitle,
        body: body,
        timeLabel: timeLabel,
        isRead: isRead ?? this.isRead,
        ctaLabel: ctaLabel,
        posterColor: posterColor,
        posterColorAlt: posterColorAlt,
        tag: tag,
        becauseOf: becauseOf,
        compactIcon: compactIcon,
        compactIconColor: compactIconColor,
      );
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_Notif> _notifications = const [
    // ── Media cards ──────────────────────────────────────────────────────────
    _Notif(
      id: '1',
      variant: _CardVariant.media,
      title: 'Season 3 Available',
      seriesTitle: 'The Bear',
      body: 'New episodes are waiting. Chef Carmen is back.',
      timeLabel: '2m ago',
      ctaLabel: 'Continue Watching',
      tag: 'NEW SEASON',
      posterColor: Color(0xFF1E3A5F),
      posterColorAlt: Color(0xFF0D2137),
    ),
    _Notif(
      id: '2',
      variant: _CardVariant.media,
      title: 'Episode 7 Dropped',
      seriesTitle: 'House of the Dragon',
      body: 'The latest episode is now available to stream.',
      timeLabel: '1h ago',
      ctaLabel: 'Watch Now',
      tag: 'NEW EPISODE',
      posterColor: Color(0xFF4A1515),
      posterColorAlt: Color(0xFF2A0A0A),
    ),
    // ── Compact cards (achievements / system) ────────────────────────────────
    _Notif(
      id: '3',
      variant: _CardVariant.compact,
      title: 'Cinephile Badge Unlocked',
      body: "100 movies watched. You've earned it.",
      timeLabel: '3h ago',
      compactIcon: Icons.military_tech_rounded,
      compactIconColor: Color(0xFFFFBB00),
    ),
    _Notif(
      id: '4',
      variant: _CardVariant.compact,
      title: 'Update your Sci-Fi rankings',
      body: 'You watched something new in this genre.',
      timeLabel: '5h ago',
      isRead: true,
      compactIcon: Icons.bar_chart_rounded,
      compactIconColor: Color(0xFF8F83FF),
    ),
    // ── Recommendation cards ─────────────────────────────────────────────────
    _Notif(
      id: '5',
      variant: _CardVariant.recommendation,
      title: 'Arrival',
      body: '1h 56m  ·  Sci-Fi  ·  Denis Villeneuve',
      timeLabel: '2d ago',
      isRead: true,
      becauseOf: 'Because you liked Interstellar',
      posterColor: Color(0xFF162540),
      posterColorAlt: Color(0xFF0A1520),
    ),
    _Notif(
      id: '6',
      variant: _CardVariant.compact,
      title: 'Long time, no watch',
      body: '2 weeks since your last film. Your library misses you.',
      timeLabel: '3d ago',
      isRead: true,
      compactIcon: Icons.local_movies_outlined,
      compactIconColor: Color(0xFF6E6E7D),
    ),
    _Notif(
      id: '7',
      variant: _CardVariant.recommendation,
      title: '3 Comedies Picked for You',
      body: 'Curated from your taste profile.',
      timeLabel: '1w ago',
      becauseOf: 'Feeling light today?',
      posterColor: Color(0xFF2A1540),
      posterColorAlt: Color(0xFF180D28),
    ),
  ];

  Map<String, List<_Notif>> get _grouped {
    final today = <_Notif>[];
    final thisWeek = <_Notif>[];
    final earlier = <_Notif>[];

    for (final n in _notifications) {
      final t = n.timeLabel;
      if (t.contains('m ago') || t.contains('h ago')) {
        today.add(n);
      } else if (t.contains('d ago')) {
        thisWeek.add(n);
      } else {
        earlier.add(n);
      }
    }

    return {
      if (today.isNotEmpty) 'Today': today,
      if (thisWeek.isNotEmpty) 'This Week': thisWeek,
      if (earlier.isNotEmpty) 'Earlier': earlier,
    };
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _markRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: WColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 4.h),
              Expanded(
                child: grouped.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 48.h),
                        children: [
                          for (final entry in grouped.entries) ...[
                            _buildGroupLabel(entry.key),
                            ...entry.value.map(_buildNotifCard),
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
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
                color: WColors.surfaceMuted,
                border: Border.all(color: WColors.borderStrong),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: WColors.foreground,
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
                    color: WColors.foreground,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_unreadCount > 0) ...[
                  SizedBox(width: 8.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: WColors.primary,
                      borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                    ),
                    child: Text(
                      '$_unreadCount',
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
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: WColors.mutedSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Group label ────────────────────────────────────────────────────────────

  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 22.h, WSizes.screenPadding.w, 8.h),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: WColors.mutedSecondaryDeep,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(height: 1, color: WColors.border),
          ),
        ],
      ),
    );
  }

  // ── Card dispatcher ────────────────────────────────────────────────────────

  Widget _buildNotifCard(_Notif notif) {
    return switch (notif.variant) {
      _CardVariant.media => _buildMediaCard(notif),
      _CardVariant.recommendation => _buildRecommendationCard(notif),
      _CardVariant.compact => _buildCompactCard(notif),
    };
  }

  // ── Media card (season / episode / release) ────────────────────────────────
  //
  // Large card. Poster artwork left, series info right.
  // Unread state: primary-tinted border + full-opacity title.
  // CTA rendered as inline text + arrow so the card reads as content, not a
  // form control.

  Widget _buildMediaCard(_Notif notif) {
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () => _markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isUnread
              ? WColors.surfaceRaised
              : WColors.surfaceBorderAlt.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
          border: Border.all(
            color: isUnread
                ? WColors.primary.withValues(alpha: 0.35)
                : WColors.border,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster placeholder — gradient block simulates artwork tint
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
              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag pill + timestamp
                    Row(
                      children: [
                        if (notif.tag != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: WColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              notif.tag!,
                              style: TextStyle(
                                color: WColors.primary,
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
                            color: WColors.mutedSecondaryDeep,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Series title — this is the primary content anchor
                    if (notif.seriesTitle != null)
                      Text(
                        notif.seriesTitle!,
                        style: TextStyle(
                          color: isUnread
                              ? WColors.foreground
                              : WColors.mutedSecondarySoft,
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
                            ? WColors.mutedForeground
                            : WColors.mutedSecondaryDeep,
                        fontSize: 11.sp,
                        height: 1.4,
                      ),
                    ),
                    if (notif.ctaLabel != null) ...[
                      SizedBox(height: 12.h),
                      // Inline text CTA — feels native, not like a button
                      Row(
                        children: [
                          Text(
                            notif.ctaLabel!,
                            style: TextStyle(
                              color: WColors.primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(Icons.arrow_forward_rounded,
                              color: WColors.primary, size: 12.sp),
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

  // ── Recommendation card ("Because you liked X…") ──────────────────────────
  //
  // Medium card. Accent label at the top signals personalization.
  // Poster right-anchored to break the left-heavy visual pattern of media cards.
  // No CTA button — tapping the entire card navigates.

  Widget _buildRecommendationCard(_Notif notif) {
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () => _markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isUnread
              ? WColors.surfaceRaised
              : WColors.surfaceBorderAlt.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
          border: Border.all(
            color: isUnread ? WColors.borderStrong : WColors.border,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalization label — the key differentiator from media cards
              if (notif.becauseOf != null)
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: WColors.mutedSecondaryHighlight,
                      size: 11.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      notif.becauseOf!,
                      style: TextStyle(
                        color: WColors.mutedSecondaryHighlight,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 10.h),
              // Poster anchored RIGHT + content left — breaks visual rhythm
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            color: isUnread
                                ? WColors.foreground
                                : WColors.mutedSecondarySoft,
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
                                ? WColors.mutedForeground
                                : WColors.mutedSecondaryDeep,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          notif.timeLabel,
                          style: TextStyle(
                            color: WColors.mutedSecondaryDeep,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Poster placeholder — right side intentionally
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

  // ── Compact card (achievement / milestone / system nudge) ──────────────────
  //
  // Single dense row. Icon in a 36×36 surface chip. Unread dot top-right.
  // No poster, no CTA — purpose is acknowledgement, not navigation.

  Widget _buildCompactCard(_Notif notif) {
    final isUnread = !notif.isRead;
    final iconColor = notif.compactIconColor ?? WColors.mutedSecondary;

    return GestureDetector(
      onTap: () => _markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
            horizontal: WSizes.screenPadding.w, vertical: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isUnread
              ? WColors.surfaceRaised
              : WColors.surfaceBorderAlt.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: isUnread ? WColors.borderStrong : WColors.border,
          ),
        ),
        child: Row(
          children: [
            // Type icon in surface chip
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
            // Title + body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      color: isUnread
                          ? WColors.foreground
                          : WColors.mutedSecondarySoft,
                      fontSize: 13.sp,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    notif.body,
                    style: TextStyle(
                      color: WColors.mutedSecondaryDeep,
                      fontSize: 11.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Unread dot stacked above timestamp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  opacity: isUnread ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: WColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notif.timeLabel,
                  style: TextStyle(
                    color: WColors.mutedSecondaryDeep,
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

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
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
                color: WColors.foreground,
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
                color: WColors.mutedSecondaryDeep,
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
