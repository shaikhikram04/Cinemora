class MoviePoster {
  final int? id;
  final String title;
  final String rating;
  final String image;
  final String? backdropImage;
  final String year;
  final String? tag;
  final bool actionAdded;

  const MoviePoster({
    this.id,
    required this.title,
    required this.rating,
    required this.image,
    this.backdropImage,
    this.year = '',
    this.tag,
    this.actionAdded = false,
  });
}
