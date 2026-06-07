import 'package:equatable/equatable.dart';

class NotificationSettingsState extends Equatable {
  // Release Alerts
  final bool releaseAlertsEnabled;
  final bool newSeasonAvailable;
  final bool newEpisodeAvailable;
  final bool upcomingMovieRelease;
  final bool streamingChanges;

  // Watchlist Alerts
  final bool watchlistAlertsEnabled;
  final bool watchlistItemReleased;
  final bool watchlistItemTrending;

  // Social
  final bool socialEnabled;
  final bool likesOnRankings;
  final bool comments;
  final bool newFollowers;
  final bool friendActivity;

  // Achievements
  final bool achievementsEnabled;
  final bool badgeUnlocks;
  final bool milestones;
  final bool collectionProgress;

  // System
  final bool systemEnabled;
  final bool appUpdates;
  final bool productAnnouncements;

  const NotificationSettingsState({
    this.releaseAlertsEnabled = true,
    this.newSeasonAvailable = true,
    this.newEpisodeAvailable = true,
    this.upcomingMovieRelease = true,
    this.streamingChanges = false,
    this.watchlistAlertsEnabled = true,
    this.watchlistItemReleased = true,
    this.watchlistItemTrending = false,
    this.socialEnabled = true,
    this.likesOnRankings = true,
    this.comments = true,
    this.newFollowers = true,
    this.friendActivity = false,
    this.achievementsEnabled = true,
    this.badgeUnlocks = true,
    this.milestones = true,
    this.collectionProgress = false,
    this.systemEnabled = false,
    this.appUpdates = false,
    this.productAnnouncements = false,
  });

  NotificationSettingsState copyWith({
    bool? releaseAlertsEnabled,
    bool? newSeasonAvailable,
    bool? newEpisodeAvailable,
    bool? upcomingMovieRelease,
    bool? streamingChanges,
    bool? watchlistAlertsEnabled,
    bool? watchlistItemReleased,
    bool? watchlistItemTrending,
    bool? socialEnabled,
    bool? likesOnRankings,
    bool? comments,
    bool? newFollowers,
    bool? friendActivity,
    bool? achievementsEnabled,
    bool? badgeUnlocks,
    bool? milestones,
    bool? collectionProgress,
    bool? systemEnabled,
    bool? appUpdates,
    bool? productAnnouncements,
  }) {
    return NotificationSettingsState(
      releaseAlertsEnabled: releaseAlertsEnabled ?? this.releaseAlertsEnabled,
      newSeasonAvailable: newSeasonAvailable ?? this.newSeasonAvailable,
      newEpisodeAvailable: newEpisodeAvailable ?? this.newEpisodeAvailable,
      upcomingMovieRelease: upcomingMovieRelease ?? this.upcomingMovieRelease,
      streamingChanges: streamingChanges ?? this.streamingChanges,
      watchlistAlertsEnabled: watchlistAlertsEnabled ?? this.watchlistAlertsEnabled,
      watchlistItemReleased: watchlistItemReleased ?? this.watchlistItemReleased,
      watchlistItemTrending: watchlistItemTrending ?? this.watchlistItemTrending,
      socialEnabled: socialEnabled ?? this.socialEnabled,
      likesOnRankings: likesOnRankings ?? this.likesOnRankings,
      comments: comments ?? this.comments,
      newFollowers: newFollowers ?? this.newFollowers,
      friendActivity: friendActivity ?? this.friendActivity,
      achievementsEnabled: achievementsEnabled ?? this.achievementsEnabled,
      badgeUnlocks: badgeUnlocks ?? this.badgeUnlocks,
      milestones: milestones ?? this.milestones,
      collectionProgress: collectionProgress ?? this.collectionProgress,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      appUpdates: appUpdates ?? this.appUpdates,
      productAnnouncements: productAnnouncements ?? this.productAnnouncements,
    );
  }

  @override
  List<Object> get props => [
        releaseAlertsEnabled,
        newSeasonAvailable,
        newEpisodeAvailable,
        upcomingMovieRelease,
        streamingChanges,
        watchlistAlertsEnabled,
        watchlistItemReleased,
        watchlistItemTrending,
        socialEnabled,
        likesOnRankings,
        comments,
        newFollowers,
        friendActivity,
        achievementsEnabled,
        badgeUnlocks,
        milestones,
        collectionProgress,
        systemEnabled,
        appUpdates,
        productAnnouncements,
      ];
}
