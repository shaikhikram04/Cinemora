import 'package:flutter/material.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/features/home/widgets/movie_details_content.dart';
import 'package:watchary/features/home/widgets/post_rating_bottom_sheet.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieTitle;
  final String movieImage;
  final String rating;

  const MovieDetailsScreen({
    super.key,
    required this.movieTitle,
    required this.movieImage,
    required this.rating,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isInWatchlist = false;
  bool _isWatched = false;
  double _userRating = 5.0;
  bool _showAllTags = false;

  void _toggleWatchlist() {
    setState(() => _isInWatchlist = !_isInWatchlist);
  }

  void _toggleWatched() {
    setState(() => _isWatched = !_isWatched);
  }

  void _updateRating(double value) {
    setState(() => _userRating = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPostRatingSheet(
        context,
        movieTitle: widget.movieTitle,
        movieImage: widget.movieImage,
        movieType: 'Movie',
        userRating: value,
        ratingLabel: _labelFor(value),
        ratingColor: _colorFor(value),
      );
    });
  }

  Color _colorFor(double v) {
    if (v == 5.0) return Colors.tealAccent;
    if (v >= 4.5) return Colors.greenAccent;
    if (v >= 4.0) return Colors.green;
    if (v >= 3.5) return Colors.lightGreen;
    if (v >= 3.0) return Colors.amberAccent;
    if (v >= 2.5) return Colors.amberAccent;
    if (v >= 2.0) return Colors.orangeAccent;
    if (v >= 1.5) return Colors.deepOrangeAccent;
    return WColors.accentRed;
  }

  String _labelFor(double v) {
    if (v == 5.0) return 'Masterpiece';
    if (v >= 4.5) return 'Excellent';
    if (v >= 4.0) return 'Great';
    if (v >= 3.5) return 'Good';
    if (v >= 3.0) return 'Decent';
    if (v >= 2.5) return 'Below Average';
    if (v >= 2.0) return 'Bad';
    if (v >= 1.5) return 'Very Bad';
    if (v >= 1.0) return 'Terrible';
    return 'Avoid it';
  }

  void _toggleTags() {
    setState(() => _showAllTags = !_showAllTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: MovieDetailsContent(
        movieTitle: widget.movieTitle,
        movieImage: widget.movieImage,
        rating: widget.rating,
        isInWatchlist: _isInWatchlist,
        isWatched: _isWatched,
        userRating: _userRating,
        showAllTags: _showAllTags,
        onToggleWatchlist: _toggleWatchlist,
        onToggleWatched: _toggleWatched,
        onRate: _updateRating,
        onToggleTags: _toggleTags,
      ),
    );
  }
}
