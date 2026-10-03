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

  /// True while the invitation card is up — the tour has been offered but not
  /// accepted.
  ///
  /// Deliberately not a [TourStep]. Steps mean "spotlight this control, and
  /// hold the app's writes back while the user taps it"; the invitation points
  /// at nothing and changes nothing, and folding it into the enum would make
  /// [TourStep.isRunning] true for a state where no tour is running — which is
  /// what gates both the write suppression and the re-entry guard.
  final bool isInviting;

  const TourState({
    this.step = TourStep.inactive,
    this.target,
    this.hasRankingSelection = false,
    this.isInviting = false,
  });

  /// True when the tour has any claim on the screen — walking through a step,
  /// or waiting on an answer to the invitation.
  ///
  /// Screens that have to hold still for the tour want this rather than
  /// `step.isRunning`: the invitation is a period where no step is running but
  /// the tour is one tap away from needing the layout exactly as it is.
  bool get isEngaged => step.isRunning || isInviting;

  TourState copyWith({
    TourStep? step,
    TourTarget? target,
    bool? hasRankingSelection,
    bool? isInviting,
  }) =>
      TourState(
        step: step ?? this.step,
        target: target ?? this.target,
        hasRankingSelection: hasRankingSelection ?? this.hasRankingSelection,
        isInviting: isInviting ?? this.isInviting,
      );

  @override
  List<Object?> get props => [step, target, hasRankingSelection, isInviting];
}
