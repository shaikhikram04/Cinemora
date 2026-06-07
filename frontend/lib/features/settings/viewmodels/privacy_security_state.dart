import 'package:equatable/equatable.dart';

class PrivacySecurityState extends Equatable {
  final bool publicProfile;
  final bool showRatings;
  final bool showRankings;
  final bool showWatchHistory;

  const PrivacySecurityState({
    this.publicProfile = true,
    this.showRatings = true,
    this.showRankings = true,
    this.showWatchHistory = false,
  });

  PrivacySecurityState copyWith({
    bool? publicProfile,
    bool? showRatings,
    bool? showRankings,
    bool? showWatchHistory,
  }) {
    return PrivacySecurityState(
      publicProfile: publicProfile ?? this.publicProfile,
      showRatings: showRatings ?? this.showRatings,
      showRankings: showRankings ?? this.showRankings,
      showWatchHistory: showWatchHistory ?? this.showWatchHistory,
    );
  }

  @override
  List<Object> get props => [publicProfile, showRatings, showRankings, showWatchHistory];
}
