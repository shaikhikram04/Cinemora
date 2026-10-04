import 'package:cinemora/features/home/models/recommended_title.dart';

class HomeRecommendations {
  final List<RecommendedTitle> pickOfWeek;
  final String? becauseYouRankedAnchorTitle;
  final List<RecommendedTitle> becauseYouRanked;
  final List<RecommendedTitle> criticallyAcclaimed;

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
          .map((e) => RecommendedTitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      becauseYouRankedAnchorTitle: anchor?['title'] as String?,
      becauseYouRanked: rankedItems
          .map((e) => RecommendedTitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      criticallyAcclaimed: acclaimedItems
          .map((e) => RecommendedTitle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
