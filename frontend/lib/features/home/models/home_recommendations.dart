import 'package:cinemora/features/home/models/similar_item.dart';

class HomeRecommendations {
  final List<SimilarItem> pickOfWeek;
  final String? becauseYouRankedAnchorTitle;
  final List<SimilarItem> becauseYouRanked;
  final List<SimilarItem> criticallyAcclaimed;

  const HomeRecommendations({
    this.pickOfWeek = const [],
    this.becauseYouRankedAnchorTitle,
    this.becauseYouRanked = const [],
    this.criticallyAcclaimed = const [],
  });

  factory HomeRecommendations.fromJson(Map<String, dynamic> json) {
    final ranked = json['becauseYouRanked'] as Map<String, dynamic>?;
    final anchor = ranked?['anchor'] as Map<String, dynamic>?;
    final rankedItems = (ranked?['items'] as List?) ?? const [];
    final acclaimedItems = (json['criticallyAcclaimed'] as List?) ?? const [];
    final pickItems = (json['pickOfWeek'] as List?) ?? const [];

    return HomeRecommendations(
      pickOfWeek: pickItems
          .map((e) => SimilarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      becauseYouRankedAnchorTitle: anchor?['title'] as String?,
      becauseYouRanked: rankedItems
          .map((e) => SimilarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      criticallyAcclaimed: acclaimedItems
          .map((e) => SimilarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
