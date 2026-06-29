import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/api_constants.dart';

class RankingList {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final int count;
  final Color accent;
  final List<String> images;
  final List<RankingEntry> entries;

  const RankingList({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.accent,
    required this.images,
    required this.entries,
  });

  // Sends only list-level metadata (no entries) — used for POST /rankings
  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'description': subtitle,
        'emoji': emoji,
        'accentColor':
            '#${(accent.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
      };

  factory RankingList.fromJson(Map<String, dynamic> json) {
    final entries = (json['entries'] as List? ?? [])
        .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return RankingList(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      emoji: json['emoji'] as String? ?? '🏆',
      title: json['title'] as String,
      subtitle: json['description'] as String? ?? '',
      count: entries.length,
      accent: _colorFromHex(json['accentColor'] as String?),
      images: entries
          .take(3)
          .map((e) => e.image)
          .where((i) => i.isNotEmpty)
          .toList(),
      entries: entries,
    );
  }

  static Color _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFE84B57);
    final clean = hex.replaceAll('#', '');
    return Color(int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16));
  }
}

class RankingEntry {
  final int? tmdbId;
  final String cinemaType; // backend value: 'movie', 'tv', 'anime'
  final String title;
  final String year;
  final String type;   // display: 'Movie', 'Series', 'Anime'
  final String rating; // display: user rating string
  final String image;  // full URL for display
  final String? posterPath; // raw path for API serialisation

  const RankingEntry({
    this.tmdbId,
    required this.cinemaType,
    required this.title,
    required this.year,
    required this.type,
    required this.rating,
    required this.image,
    this.posterPath,
  });

  Map<String, dynamic> toJson() => {
        if (tmdbId != null) 'tmdbId': tmdbId,
        'cinemaType': cinemaType,
        'title': title,
        'posterPath': posterPath,
        'year': year,
        'userRating': double.tryParse(rating),
      };

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    final posterPath = json['posterPath'] as String?;
    final cinemaType = json['cinemaType'] as String? ?? 'movie';
    return RankingEntry(
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
      cinemaType: cinemaType,
      title: json['title'] as String,
      year: json['year'] as String? ?? '',
      type: _displayType(cinemaType),
      rating: (json['userRating'] as num?)?.toStringAsFixed(1) ?? '—',
      image: _resolveImageUrl(posterPath),
      posterPath: posterPath,
    );
  }

  static String _displayType(String cinemaType) => switch (cinemaType) {
        'movie' => 'Movie',
        'tv' => 'Series',
        'anime' => 'Anime',
        _ => cinemaType,
      };

  static String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiConstants.tmdbImageBase}/w200$path';
  }
}
