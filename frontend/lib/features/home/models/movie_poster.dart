class MoviePoster {
  final String title;
  final String rating;
  final String image;
  final String? tag;
  final bool actionAdded;

  const MoviePoster({
    required this.title,
    required this.rating,
    required this.image,
    this.tag,
    this.actionAdded = false,
  });
}
