/// Extracts the poster path segment (e.g. `/abc123.jpg`) from a full TMDB
/// image URL. For non-TMDB external URLs (e.g. anime), returns the URL as-is.
String? extractTmdbPosterPath(String? url) {
  if (url == null || url.isEmpty) return null;
  final match = RegExp(r'/t/p/\w+(/[^?]+)').firstMatch(url);
  return match?.group(1) ?? (url.startsWith('http') ? url : null);
}
