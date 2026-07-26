/// Latched for the duration of the first-run coach-mark tour.
///
/// The tour drives the app's real screens through their real cubits — that's
/// what makes it feel like using the app rather than watching a slideshow. What
/// it must not do is leave anything behind on the server. Nothing the user does
/// while being *shown* how the app works is a statement about their taste, and
/// a title they've never seen has no business seeding their recommendations,
/// their stats, or their release notifications.
///
/// So the writes stop at the repository layer: while this is active, library
/// and rankings mutations are answered from memory with a plausible response
/// instead of going to the network. Every screen the tour visits reads from the
/// cubits, so they all show the right thing, and none of it survives the
/// reload that runs when the tour ends.
///
/// Deliberately a bare mutable flag rather than a cubit:
///
/// * the write path shouldn't have to know the tour exists, let alone depend
///   on it, and
/// * [TourCubit] already watches [LibraryCubit] to decide when its first step
///   is satisfied, so a repository depending on TourCubit would close a cycle.
class TourMode {
  bool _active = false;

  bool get isActive => _active;

  set active(bool value) => _active = value;
}
