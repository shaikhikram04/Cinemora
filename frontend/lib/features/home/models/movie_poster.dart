import 'package:cinemora/core/models/catalog_source.dart';
import 'package:cinemora/core/models/cinema_type.dart';

class MoviePoster {
  final int? id;
  final String title;
  final String rating;
  final String image;
  final String? backdropImage;
  final String year;
  final String? tag;
  final bool actionAdded;
  // Set on mixed-type carousels (e.g. Critically Acclaimed) where each item
  // may be a different cinema type — null means the carousel's own fixed
  // type (passed by the call site) should be used instead.
  final CinemaType? cinemaType;
  final CatalogSource? source;

  const MoviePoster({
    this.id,
    required this.title,
    required this.rating,
    required this.image,
    this.backdropImage,
    this.year = '',
    this.tag,
    this.actionAdded = false,
    this.cinemaType,
    this.source,
  });
}
