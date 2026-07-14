import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/era_insight.dart';
import 'package:cinemora/core/utils/language_insight.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final LibraryStatsModel? stats;

  /// Mirrored from LibraryCubit, which owns the library. The profile does not
  /// fetch its own copy: it used to, and that snapshot went stale the moment
  /// the user added a title from a detail page, freezing every derived value
  /// below until a pull-to-refresh.
  final List<LibraryEntryModel> entries;

  final String? error;

  // Precomputed on construction — derived from entries, computed once per state
  // emit rather than once per widget rebuild. The profile sits under three
  // nested BlocBuilders, so getters here would re-walk the library on every
  // unrelated rankings or auth emission.
  final List<LibraryEntryModel> topFavorites;
  final List<LibraryEntryModel> recentActivity;
  final int watchedCount;

  /// Null until the library carries enough dated titles to make a claim.
  final EraInsight? favoriteEra;

  /// Null until the library carries enough language-tagged titles to make a
  /// claim. Entries added before the app recorded `originalLanguage` carry no
  /// language, so a long-standing library stays null until its entries are
  /// touched again.
  final LanguageInsight? favoriteLanguage;

  ProfileState({
    this.status = ProfileStatus.initial,
    this.stats,
    this.entries = const [],
    this.error,
  })  : topFavorites = _buildTopFavorites(entries),
        recentActivity = _buildRecentActivity(entries),
        watchedCount =
            entries.where((e) => e.status == WatchStatus.watched).length,
        favoriteEra = deriveFavoriteEra(entries),
        favoriteLanguage = deriveFavoriteLanguage(entries);

  ProfileState copyWith({
    ProfileStatus? status,
    LibraryStatsModel? stats,
    List<LibraryEntryModel>? entries,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      entries: entries ?? this.entries,
      error: error ?? this.error,
    );
  }

  static List<LibraryEntryModel> _buildTopFavorites(
      List<LibraryEntryModel> entries) {
    final rated = entries
        .where((e) => e.status == WatchStatus.watched && (e.userRating ?? 0) > 0)
        .toList()
      ..sort((a, b) => (b.userRating ?? 0).compareTo(a.userRating ?? 0));
    return rated.take(5).toList();
  }

  static List<LibraryEntryModel> _buildRecentActivity(
      List<LibraryEntryModel> entries) {
    final sorted = [...entries]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  @override
  List<Object?> get props => [status, stats, entries, error];
}
