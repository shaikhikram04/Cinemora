import 'package:equatable/equatable.dart';

import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/features/tour/models/tour_step.dart';

/// The title the tour walks the user through. Captured once when the tour
/// starts, from whatever the home feed happens to be showing in its hero slot,
/// and carried across all seven steps so every screen spotlights the same item.
class TourTarget extends Equatable {
  final int tmdbId;

  /// Always paired with [tmdbId] — anime entries store AniList/Jikan ids in
  /// the same field, so the id alone does not identify a title.
  final CinemaType cinemaType;
  final String title;

  const TourTarget({
    required this.tmdbId,
    required this.cinemaType,
    required this.title,
  });

  @override
  List<Object?> get props => [tmdbId, cinemaType, title];
}

class TourState extends Equatable {
  final TourStep step;
  final TourTarget? target;

  /// True once the user has picked a list in the post-rating sheet. That sheet
  /// keeps its selection in local State rather than a cubit, so it reports the
  /// change here instead of the tour observing it.
  final bool hasRankingSelection;

  const TourState({
    this.step = TourStep.inactive,
    this.target,
    this.hasRankingSelection = false,
  });

  TourState copyWith({
    TourStep? step,
    TourTarget? target,
    bool? hasRankingSelection,
  }) =>
      TourState(
        step: step ?? this.step,
        target: target ?? this.target,
        hasRankingSelection: hasRankingSelection ?? this.hasRankingSelection,
      );

  @override
  List<Object?> get props => [step, target, hasRankingSelection];
}
