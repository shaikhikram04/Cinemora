import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/era_insight.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final LibraryStatsModel? stats;
  final List<LibraryEntryModel> entries;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.stats,
    this.entries = const [],
    this.error,
  });

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

  List<LibraryEntryModel> get topFavorites {
    final rated = entries
        .where((e) => e.status == WatchStatus.watched && (e.userRating ?? 0) > 0)
        .toList()
      ..sort((a, b) => (b.userRating ?? 0).compareTo(a.userRating ?? 0));
    return rated.take(5).toList();
  }

  int get watchedCount =>
      entries.where((e) => e.status == WatchStatus.watched).length;

  /// Null until the library carries enough dated titles to make a claim.
  EraInsight? get favoriteEra => deriveFavoriteEra(entries);

  List<LibraryEntryModel> get recentActivity {
    final sorted = [...entries]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  @override
  List<Object?> get props => [status, stats, entries, error];
}
