import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cinemora/features/tour/models/tour_step.dart';
import 'package:cinemora/features/tour/viewmodels/tour_cubit.dart';
import 'package:cinemora/features/tour/viewmodels/tour_state.dart';

/// Marks a widget as the spotlight target for one tour step.
///
/// Wrapping is all that's needed — the anchor registers its own key with
/// [TourCubit] on mount and drops it on dispose, so the overlay can find the
/// widget's rect without every screen having to thread a [GlobalKey] up to the
/// app root.
///
/// Outside the tour this is a plain pass-through: no extra layout, no repaint,
/// no state of its own beyond the key.
class TourAnchor extends StatefulWidget {
  final TourStep step;

  /// Scrolls the anchor into view once its step is active.
  ///
  /// Callers whose position depends on an async fetch should pass this as
  /// `false` until the fetch settles — the detail screen's rating section sits
  /// below providers, genres, cast and crew, all of which change height when
  /// TMDB responds, so scrolling early lands on an offset that then moves.
  final bool autoScroll;

  /// Where the anchor lands in the viewport when [autoScroll] runs. 0.35 keeps
  /// it above centre, leaving room for the caption card beneath it.
  final double scrollAlignment;

  final Widget child;

  const TourAnchor({
    super.key,
    required this.step,
    required this.child,
    this.autoScroll = false,
    this.scrollAlignment = 0.35,
  });

  @override
  State<TourAnchor> createState() => _TourAnchorState();
}

class _TourAnchorState extends State<TourAnchor> {
  final _key = GlobalKey();

  /// Held rather than looked up again in [dispose] — by then this subtree is
  /// being torn down and the provider may already be gone.
  late final TourCubit _tour;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _tour = context.read<TourCubit>();
    _tour.registerAnchor(widget.step, _key);
    // The step is often already active by the time the anchor mounts — the
    // detail screen reports itself open before its body has laid out — so a
    // state listener alone would never fire.
    _maybeScroll();
  }

  @override
  void didUpdateWidget(covariant TourAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScroll && !oldWidget.autoScroll) _hasScrolled = false;
    _maybeScroll();
  }

  @override
  void dispose() {
    _tour.unregisterAnchor(widget.step, _key);
    super.dispose();
  }

  void _maybeScroll() {
    if (!widget.autoScroll || _hasScrolled) return;
    if (_tour.state.step != widget.step) return;
    _hasScrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchorContext = _key.currentContext;
      if (!mounted || anchorContext == null) return;
      Scrollable.ensureVisible(
        anchorContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: widget.scrollAlignment,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtree = KeyedSubtree(key: _key, child: widget.child);
    if (!widget.autoScroll) return subtree;

    return BlocListener<TourCubit, TourState>(
      listenWhen: (prev, curr) => prev.step != curr.step,
      listener: (context, state) {
        if (state.step == widget.step) {
          _maybeScroll();
        } else {
          _hasScrolled = false;
        }
      },
      child: subtree,
    );
  }
}
