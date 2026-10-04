import 'package:flutter/widgets.dart';

/// Warms [ImageCache] so a screen's artwork is already fetched and decoded by
/// the time the user reaches it, instead of popping in card by card once it
/// mounts.
///
/// Fire-and-forget. A failed warm-up isn't an error anyone needs to hear
/// about — every one of these images renders through a widget with its own
/// error builder, which will simply fetch it again at display time.
///
/// **The providers passed in have to be built exactly the way the rendering
/// widget builds them.** The cache is keyed on the provider, so two mismatches
/// fill a key nothing ever reads and cost a second download rather than saving
/// the first:
///
///  * the wrong kind — every network image in the app renders through
///    `CachedNetworkImageProvider` (directly, or inside [CurvedNetworkImage]),
///    so a bare `NetworkImage` never matches;
///  * the wrong size — a provider that renders wrapped in a [ResizeImage] is a
///    different key from the unwrapped one.
///
/// Use [PosterImage.providerFor] for posters rather than reconstructing the
/// resize arithmetic at the call site.
void precacheImages(BuildContext context, Iterable<ImageProvider> providers) {
  for (final provider in providers) {
    precacheImage(provider, context, onError: (_, __) {});
  }
}
