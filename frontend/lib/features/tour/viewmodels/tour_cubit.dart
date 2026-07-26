import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/features/tour/models/tour_step.dart';
import 'package:cinemora/features/tour/tour_mode.dart';
import 'tour_state.dart';

/// Drives the one-time first-run coach-mark tour.
///
/// Two things make this more than a step counter:
///
/// 1. **Steps advance on observed app state, never on the tap itself.** Step 1
///    only moves on once the watchlist entry actually lands in [LibraryCubit];
///    a failed write leaves the coach mark where it is instead of marching past
///    a no-op the user can't see.
/// 2. **Going off-script rewinds rather than breaks.** Wandering to the wrong
///    tab, or backing out of the detail screen, re-points the coach mark at
///    whatever gets the user back on track.
class TourCubit extends Cubit<TourState> {
  final SharedPreferences _prefs;

  /// Flipped alongside every step change, so the repositories know to keep the
  /// tour's writes off the server. Owned here rather than read from here: the
  /// write path must not depend on this cubit, which already watches the
  /// library and would otherwise form a cycle.
  final TourMode _tourMode;

  /// Bumped if the tour's shape ever changes enough that people who saw the
  /// old one should see the new one.
  static const _completedKey = 'tour_v1_done';

  /// Set the moment taste setup succeeds — the one point in the app that only
  /// a brand-new account passes through.
  ///
  /// The completion flag alone isn't a sufficient gate: it's per-device, so a
  /// long-standing user reinstalling or signing in on a second phone would
  /// arrive with it unset and get walked through a tour they don't need. This
  /// flag says *this account was created here*, which is the actual condition.
  static const _armedKey = 'tour_v1_armed';

  /// Live spotlight targets, registered by [TourAnchor] as those widgets mount.
  ///
  /// A stack per step rather than one key, because a step can legitimately
  /// have more than one anchor alive at once: [TourStep.backHome] is marked on
  /// both the Home tab and the ranking detail screen's back arrow, and while
  /// that screen is pushed the shell below it is still mounted. Most recent
  /// wins, and removing it falls back to the one underneath instead of leaving
  /// the step with no target at all.
  final Map<TourStep, List<GlobalKey>> _anchors = {};

  TourCubit(this._prefs, this._tourMode) : super(const TourState());

  /// Single funnel for state changes, so [TourMode] can never fall out of step
  /// with whether a tour is actually running. A missed `false` here would mean
  /// the app silently stops persisting real user data.
  @override
  void emit(TourState state) {
    _tourMode.active = state.step.isRunning;
    super.emit(state);
  }

  bool get hasCompleted => _prefs.getBool(_completedKey) ?? false;

  /// Topmost anchor for [step] that is actually in the tree.
  GlobalKey? anchorFor(TourStep step) {
    final keys = _anchors[step];
    if (keys == null) return null;
    for (final key in keys.reversed) {
      if (key.currentContext != null) return key;
    }
    return null;
  }

  // ── Anchor registry ────────────────────────────────────────────────────────

  void registerAnchor(TourStep step, GlobalKey key) =>
      (_anchors[step] ??= []).add(key);

  /// Called from [TourAnchor.dispose]. If the *last* anchor for the current
  /// step just went away, rewind a step so the tour points at the control that
  /// gets the user back rather than at a rect that no longer exists — that's
  /// what turns backing out of the detail screen into a re-prompt instead of a
  /// dead end.
  void unregisterAnchor(TourStep step, GlobalKey key) {
    final keys = _anchors[step];
    if (keys == null) return;
    keys.remove(key);
    if (keys.isNotEmpty) return;
    _anchors.remove(step);
    if (state.step != step) return;
    final previous = step.previous;
    if (previous != null) emit(state.copyWith(step: previous));
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Marks this device as having created an account. Called from taste setup
  /// the moment it submits successfully.
  Future<void> arm() => _prefs.setBool(_armedKey, true);

  /// Starts the tour on [target], for a first-time account that hasn't been
  /// through it yet. Safe to call on every home-feed load — it no-ops once
  /// running, once completed, or for an account that was created elsewhere.
  void maybeStart(TourTarget target) {
    if (state.step.isRunning) return;
    if (hasCompleted) return;
    if (!(_prefs.getBool(_armedKey) ?? false)) return;
    emit(TourState(step: TourStep.bookmarkHero, target: target));
  }

  void skip() => _finish();

  void _finish() {
    _prefs.setBool(_completedKey, true);
    emit(const TourState());
  }

  /// Dismisses the closing card. The completion flag is written here rather
  /// than at [TourStep.celebrate] so a crash mid-tour doesn't burn the run.
  void dismissCelebration() {
    if (state.step != TourStep.celebrate) return;
    _finish();
  }

  // ── Advance conditions, observed from real app state ───────────────────────

  void _advanceFrom(TourStep expected) {
    if (state.step != expected) return;
    emit(state.copyWith(step: expected.next));
  }

  /// Step 1 → 2. Driven by the library itself, so the step only clears once the
  /// write has actually landed.
  void onLibraryChanged(List<LibraryEntryModel> entries) {
    if (state.step != TourStep.bookmarkHero) return;
    final target = state.target;
    if (target == null) return;
    final saved = entries.any(
        (e) => e.tmdbId == target.tmdbId && e.cinemaType == target.cinemaType);
    if (saved) _advanceFrom(TourStep.bookmarkHero);
  }

  /// Steps 2 → 3 and 8 → done, plus the rewind when the user wanders off the
  /// Library tab mid-tour.
  void onTabChanged(int index) {
    switch (state.step) {
      case TourStep.openLibraryTab:
        if (index == _libraryTabIndex) _advanceFrom(TourStep.openLibraryTab);
      case TourStep.openLibraryEntry:
        // The Library branch stays mounted once visited, so its anchor is
        // still registered while the user is on another tab — without this the
        // spotlight would sit over an off-screen row.
        if (index != _libraryTabIndex) {
          emit(state.copyWith(step: TourStep.openLibraryTab));
        }
      case TourStep.backHome:
        if (index == _homeTabIndex) _advanceFrom(TourStep.backHome);
      default:
        break;
    }
  }

  /// Step 3 → 4.
  void onDetailOpened(int tmdbId, CinemaType cinemaType) {
    final target = state.target;
    if (target == null) return;
    if (tmdbId != target.tmdbId || cinemaType != target.cinemaType) return;
    _advanceFrom(TourStep.openLibraryEntry);
  }

  /// Step 4 → 5.
  void onRated() => _advanceFrom(TourStep.rateTitle);

  /// Steps 5 ↔ 6. Deselecting sends the spotlight back to the list cards.
  void onRankingListSelected(bool selected) {
    emit(state.copyWith(hasRankingSelection: selected));
    if (selected) {
      _advanceFrom(TourStep.pickRankingList);
    } else if (state.step == TourStep.confirmPlacement) {
      emit(state.copyWith(step: TourStep.pickRankingList));
    }
  }

  /// Step 6 → 7.
  void onPlacementOpened() => _advanceFrom(TourStep.confirmPlacement);

  /// Step 7 → 8.
  void onRankingDetailOpened() => _advanceFrom(TourStep.viewFullRanking);

  static const _homeTabIndex = 0;
  static const _libraryTabIndex = 2;
}
