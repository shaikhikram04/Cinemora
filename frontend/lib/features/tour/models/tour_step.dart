/// The first-run coach-mark tour, one step per control the user has to tap.
///
/// Each step doubles as the id of the anchor it spotlights — every step has
/// exactly one target, so a separate anchor enum would only be two names for
/// the same thing.
enum TourStep {
  /// No tour running. Either never started, skipped, or finished.
  inactive,

  /// Home feed → the hero card's "Watchlist" button.
  bookmarkHero,

  /// Bottom nav → Library tab.
  openLibraryTab,

  /// Library → the row for the title just saved.
  openLibraryEntry,

  /// Detail screen → the star bar, after an animated scroll down to it.
  rateTitle,

  /// Post-rating sheet → the first suggested ranking list.
  pickRankingList,

  /// Post-rating sheet → the "Place in ranking" CTA.
  confirmPlacement,

  /// Placement screen → "View Full Ranking".
  viewFullRanking,

  /// Ranking detail → back out to the home tab.
  backHome,

  /// Centred sign-off card. No anchor.
  celebrate;

  /// Steps that carry a spotlight. [celebrate] is a centred card with nothing
  /// to point at, and [inactive] draws nothing at all.
  bool get hasAnchor => this != TourStep.inactive && this != TourStep.celebrate;

  bool get isRunning => this != TourStep.inactive;

  /// Whether the step dims the screen and swallows taps outside the spotlight.
  ///
  /// [backHome] doesn't. It lands on the ranking the user has just built, and
  /// the whole point of the step before it was "have a look at the list" —
  /// greying that list out and refusing to scroll it hides the one thing they
  /// were sent there to see. It highlights the way out and otherwise stays out
  /// of the way. Nothing on that screen can navigate away, so there's no
  /// wandering to guard against either.
  bool get isBlocking => this != TourStep.backHome;

  /// Ordered list of steps the user actually walks through, used for the
  /// "3 of 8" counter and for rewinding when they go off-script.
  static const sequence = [
    bookmarkHero,
    openLibraryTab,
    openLibraryEntry,
    rateTitle,
    pickRankingList,
    confirmPlacement,
    viewFullRanking,
    backHome,
  ];

  /// 1-based position in [sequence], or null for steps outside it.
  int? get position {
    final i = sequence.indexOf(this);
    return i == -1 ? null : i + 1;
  }

  /// The step before this one, for rewinding when the user navigates away
  /// from the screen the current step lives on.
  TourStep? get previous {
    final i = sequence.indexOf(this);
    return i <= 0 ? null : sequence[i - 1];
  }

  /// The step after this one. [backHome] rolls into [celebrate], which is not
  /// part of [sequence].
  TourStep get next {
    if (this == backHome) return celebrate;
    final i = sequence.indexOf(this);
    if (i == -1 || i == sequence.length - 1) return inactive;
    return sequence[i + 1];
  }
}

/// Caption shown next to the spotlight.
class TourCopy {
  final String title;
  final String body;

  const TourCopy(this.title, this.body);
}

/// Written second-person and short — the caption sits over a dimmed screen and
/// competes with the control it is pointing at, so anything longer than two
/// lines gets skipped.
const tourCopy = <TourStep, TourCopy>{
  TourStep.bookmarkHero: TourCopy(
    'Start with a watchlist',
    'Tap Watchlist to save this one. Everything in Cinemora starts here.',
  ),
  TourStep.openLibraryTab: TourCopy(
    'Your Library',
    'Every title you save lands in here. Open it up.',
  ),
  TourStep.openLibraryEntry: TourCopy(
    'Open the title',
    'There it is. Tap it to see the full details.',
  ),
  TourStep.rateTitle: TourCopy(
    'Give it a rating',
    'Tap the stars — pick anything for now, you can change it whenever.',
  ),
  TourStep.pickRankingList: TourCopy(
    'Ratings become rankings',
    'Choose a list to drop this title into.',
  ),
  TourStep.confirmPlacement: TourCopy(
    'Place it',
    'Add it to that list.',
  ),
  TourStep.viewFullRanking: TourCopy(
    "It's ranked",
    "First one in, so it takes #1. Have a look at the list.",
  ),
  TourStep.backHome: TourCopy(
    "That's the whole loop",
    'Have a proper look — then head back with the arrow up top.',
  ),
  TourStep.celebrate: TourCopy(
    "You're all set",
    'Your home feed sharpens up with every title you rank.',
  ),
};
