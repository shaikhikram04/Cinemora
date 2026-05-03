import 'package:flutter/material.dart';
import 'package:watchary/common/widgets/cards/media_poster_card.dart';

class MovieCard extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final String? title;
  final String? rating;
  final double radius;

  const MovieCard({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.title,
    this.rating,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return WMediaPosterCard(
      image: image,
      width: width,
      imageHeight: height,
      title: title,
      rating: rating,
      radius: radius,
    );
  }
}
