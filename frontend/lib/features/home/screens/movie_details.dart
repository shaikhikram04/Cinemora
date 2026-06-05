import 'package:flutter/material.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';
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
  bool _showRatingSuccess = false;

  void _toggleWatchlist() {
    setState(() => _isInWatchlist = !_isInWatchlist);
  }

  void _toggleWatched() {
    setState(() => _isWatched = !_isWatched);
  }

  void _updateRating(double value) {
    setState(() {
      _userRating = value;
      _showRatingSuccess = true;
    });
  }

  void _openRankingsSheet() {
    showPostRatingSheet(
      context,
      movieTitle: widget.movieTitle,
      movieImage: widget.movieImage,
      movieType: 'Movie',
      userRating: _userRating,
      ratingLabel: ratingLabelFor(_userRating),
      ratingColor: ratingColorFor(_userRating),
    );
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
        showRatingSuccess: _showRatingSuccess,
        onToggleWatchlist: _toggleWatchlist,
        onToggleWatched: _toggleWatched,
        onRate: _updateRating,
        onToggleTags: _toggleTags,
        onManageRankings: _openRankingsSheet,
      ),
    );
  }
}
