import 'package:flutter/material.dart';

enum NotifCardVariant { media, recommendation, compact }

class WNotif {
  final String id;
  final NotifCardVariant variant;
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

  const WNotif({
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

  WNotif copyWith({bool? isRead}) => WNotif(
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

const kInitialNotifications = [
  WNotif(
    id: '1',
    variant: NotifCardVariant.media,
    title: 'Season 3 Available',
    seriesTitle: 'The Bear',
    body: 'New episodes are waiting. Chef Carmen is back.',
    timeLabel: '2m ago',
    ctaLabel: 'Continue Watching',
    tag: 'NEW SEASON',
    posterColor: Color(0xFF1E3A5F),
    posterColorAlt: Color(0xFF0D2137),
  ),
  WNotif(
    id: '2',
    variant: NotifCardVariant.media,
    title: 'Episode 7 Dropped',
    seriesTitle: 'House of the Dragon',
    body: 'The latest episode is now available to stream.',
    timeLabel: '1h ago',
    ctaLabel: 'Watch Now',
    tag: 'NEW EPISODE',
    posterColor: Color(0xFF4A1515),
    posterColorAlt: Color(0xFF2A0A0A),
  ),
  WNotif(
    id: '3',
    variant: NotifCardVariant.compact,
    title: 'Cinephile Badge Unlocked',
    body: "100 movies watched. You've earned it.",
    timeLabel: '3h ago',
    compactIcon: Icons.military_tech_rounded,
    compactIconColor: Color(0xFFFFBB00),
  ),
  WNotif(
    id: '4',
    variant: NotifCardVariant.compact,
    title: 'Update your Sci-Fi rankings',
    body: 'You watched something new in this genre.',
    timeLabel: '5h ago',
    isRead: true,
    compactIcon: Icons.bar_chart_rounded,
    compactIconColor: Color(0xFF8F83FF),
  ),
  WNotif(
    id: '5',
    variant: NotifCardVariant.recommendation,
    title: 'Arrival',
    body: '1h 56m  ·  Sci-Fi  ·  Denis Villeneuve',
    timeLabel: '2d ago',
    isRead: true,
    becauseOf: 'Because you liked Interstellar',
    posterColor: Color(0xFF162540),
    posterColorAlt: Color(0xFF0A1520),
  ),
  WNotif(
    id: '6',
    variant: NotifCardVariant.compact,
    title: 'Long time, no watch',
    body: '2 weeks since your last film. Your library misses you.',
    timeLabel: '3d ago',
    isRead: true,
    compactIcon: Icons.local_movies_outlined,
    compactIconColor: Color(0xFF6E6E7D),
  ),
  WNotif(
    id: '7',
    variant: NotifCardVariant.recommendation,
    title: '3 Comedies Picked for You',
    body: 'Curated from your taste profile.',
    timeLabel: '1w ago',
    becauseOf: 'Feeling light today?',
    posterColor: Color(0xFF2A1540),
    posterColorAlt: Color(0xFF180D28),
  ),
];
