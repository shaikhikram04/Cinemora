import 'package:flutter/material.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/utils/rating_display_utils.dart';
import 'package:watchary/features/home/widgets/post_rating_bottom_sheet.dart';
import 'package:watchary/features/home/widgets/series_details_content.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kSeriesSeasons = [
  SeriesSeason(
    number: 1,
    year: '2022',
    rating: '8.5',
    episodes: [
      SeriesEpisode(
          number: 1, title: 'The Heirs of the Dragon', runtime: '66m'),
      SeriesEpisode(number: 2, title: 'The Rogue Prince', runtime: '54m'),
      SeriesEpisode(number: 3, title: 'Second of His Name', runtime: '56m'),
      SeriesEpisode(
          number: 4, title: 'King of the Narrow Sea', runtime: '58m'),
      SeriesEpisode(number: 5, title: 'We Light the Way', runtime: '53m'),
      SeriesEpisode(
          number: 6, title: 'The Princess and the Queen', runtime: '58m'),
      SeriesEpisode(number: 7, title: 'Driftmark', runtime: '55m'),
      SeriesEpisode(number: 8, title: 'The Lord of the Tides', runtime: '68m'),
      SeriesEpisode(number: 9, title: 'The Green Council', runtime: '60m'),
      SeriesEpisode(number: 10, title: 'The Black Queen', runtime: '69m'),
    ],
  ),
  SeriesSeason(
    number: 2,
    year: '2024',
    rating: '7.9',
    episodes: [
      SeriesEpisode(number: 1, title: 'A Son for a Son', runtime: '60m'),
      SeriesEpisode(number: 2, title: 'Rhaenyra the Cruel', runtime: '57m'),
      SeriesEpisode(number: 3, title: 'The Burning Mill', runtime: '55m'),
      SeriesEpisode(
          number: 4, title: 'The Red Dragon and the Gold', runtime: '59m'),
      SeriesEpisode(number: 5, title: 'Regent', runtime: '57m'),
      SeriesEpisode(number: 6, title: 'Smallfolk', runtime: '62m'),
      SeriesEpisode(number: 7, title: 'The Red Sowing', runtime: '58m'),
      SeriesEpisode(
          number: 8, title: 'The Meaning of Kings', runtime: '60m'),
    ],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class SeriesDetailsScreen extends StatefulWidget {
  final String seriesTitle;
  final String seriesImage;
  final String rating;
  final List<SeriesSeason> seasons;

  const SeriesDetailsScreen({
    super.key,
    required this.seriesTitle,
    required this.seriesImage,
    required this.rating,
    this.seasons = _kSeriesSeasons,
  });

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  int _selectedSeasonIndex = 0;
  bool _showInWatchlist = false;
  bool _isShowWatched = false;
  final Set<int> _seasonsInWatchlist = {};
  final Set<int> _seasonsWatched = {};
  final Set<String> _episodesWatched = {};
  final Map<int, double> _seasonRatings = {};
  double _showRating = 0.0;
  final Set<int> _expandedSeasons = {};
  bool _showRatingSuccess = false;

  void _toggleShowWatchlist() =>
      setState(() => _showInWatchlist = !_showInWatchlist);

  void _toggleShowWatched() =>
      setState(() => _isShowWatched = !_isShowWatched);

  void _toggleSeasonWatchlist(int seasonNumber) => setState(() {
        if (_seasonsInWatchlist.contains(seasonNumber)) {
          _seasonsInWatchlist.remove(seasonNumber);
        } else {
          _seasonsInWatchlist.add(seasonNumber);
        }
      });

  void _toggleSeasonWatched(int seasonNumber) => setState(() {
        if (_seasonsWatched.contains(seasonNumber)) {
          _seasonsWatched.remove(seasonNumber);
        } else {
          _seasonsWatched.add(seasonNumber);
          final season =
              widget.seasons.firstWhere((s) => s.number == seasonNumber);
          for (final ep in season.episodes) {
            _episodesWatched.add('S${seasonNumber}E${ep.number}');
          }
        }
      });

  void _toggleEpisodeWatched(String key) => setState(() {
        if (_episodesWatched.contains(key)) {
          _episodesWatched.remove(key);
        } else {
          _episodesWatched.add(key);
        }
      });

  void _rateSeason(int seasonNumber, double rating) {
    setState(() => _seasonRatings[seasonNumber] = rating);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPostRatingSheet(
        context,
        movieTitle: '${widget.seriesTitle} – Season $seasonNumber',
        movieImage: widget.seriesImage,
        movieType: 'Series',
        userRating: rating,
        ratingLabel: ratingLabelFor(rating),
        ratingColor: ratingColorFor(rating),
      );
    });
  }

  void _rateShow(double rating) {
    setState(() {
      _showRating = rating;
      _showRatingSuccess = true;
    });
  }

  void _openRankingsSheet() {
    showPostRatingSheet(
      context,
      movieTitle: widget.seriesTitle,
      movieImage: widget.seriesImage,
      movieType: 'Series',
      userRating: _showRating,
      ratingLabel: ratingLabelFor(_showRating),
      ratingColor: ratingColorFor(_showRating),
    );
  }

  void _toggleSeasonExpanded(int seasonNumber) => setState(() {
        if (_expandedSeasons.contains(seasonNumber)) {
          _expandedSeasons.remove(seasonNumber);
        } else {
          _expandedSeasons.add(seasonNumber);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: SeriesDetailsContent(
        seriesTitle: widget.seriesTitle,
        seriesImage: widget.seriesImage,
        rating: widget.rating,
        seasons: widget.seasons,
        selectedSeasonIndex: _selectedSeasonIndex,
        showInWatchlist: _showInWatchlist,
        isShowWatched: _isShowWatched,
        seasonsInWatchlist: _seasonsInWatchlist,
        seasonsWatched: _seasonsWatched,
        episodesWatched: _episodesWatched,
        seasonRatings: _seasonRatings,
        showRating: _showRating,
        expandedSeasons: _expandedSeasons,
        showRatingSuccess: _showRatingSuccess,
        onSeasonSelected: (i) => setState(() => _selectedSeasonIndex = i),
        onToggleShowWatchlist: _toggleShowWatchlist,
        onToggleShowWatched: _toggleShowWatched,
        onToggleSeasonWatchlist: _toggleSeasonWatchlist,
        onToggleSeasonWatched: _toggleSeasonWatched,
        onToggleEpisodeWatched: _toggleEpisodeWatched,
        onRateSeason: _rateSeason,
        onRateShow: _rateShow,
        onToggleSeasonExpanded: _toggleSeasonExpanded,
        onManageRankings: _openRankingsSheet,
      ),
    );
  }
}
