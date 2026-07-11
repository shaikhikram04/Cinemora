import 'package:cinemora/features/home/models/similar_item.dart';

/// One assistant response from the mood chat: a text reply plus the concrete
/// catalog items Claude chose to recommend (rendered as cards).
class MoodReply {
  final String sessionId;
  final String reply;
  final List<SimilarItem> recommendations;
  final int turnsRemaining;

  const MoodReply({
    required this.sessionId,
    required this.reply,
    this.recommendations = const [],
    this.turnsRemaining = 0,
  });

  factory MoodReply.fromJson(Map<String, dynamic> json) {
    final recs = (json['recommendations'] as List?) ?? const [];
    return MoodReply(
      sessionId: json['sessionId'] as String? ?? '',
      reply: json['reply'] as String? ?? '',
      recommendations: recs
          .map((e) => SimilarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      turnsRemaining: json['turnsRemaining'] as int? ?? 0,
    );
  }
}
