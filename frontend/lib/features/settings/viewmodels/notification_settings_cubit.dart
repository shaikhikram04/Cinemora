import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_settings_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit() : super(const NotificationSettingsState());

  void setReleaseAlerts(bool v) => emit(state.copyWith(
        releaseAlertsEnabled: v,
        newSeasonAvailable: v ? state.newSeasonAvailable : false,
        newEpisodeAvailable: v ? state.newEpisodeAvailable : false,
        upcomingMovieRelease: v ? state.upcomingMovieRelease : false,
        streamingChanges: v ? state.streamingChanges : false,
      ));

  void setWatchlistAlerts(bool v) => emit(state.copyWith(
        watchlistAlertsEnabled: v,
        watchlistItemReleased: v ? state.watchlistItemReleased : false,
        watchlistItemTrending: v ? state.watchlistItemTrending : false,
      ));

  void setSocial(bool v) => emit(state.copyWith(
        socialEnabled: v,
        likesOnRankings: v ? state.likesOnRankings : false,
        comments: v ? state.comments : false,
        newFollowers: v ? state.newFollowers : false,
        friendActivity: v ? state.friendActivity : false,
      ));

  void setAchievements(bool v) => emit(state.copyWith(
        achievementsEnabled: v,
        badgeUnlocks: v ? state.badgeUnlocks : false,
        milestones: v ? state.milestones : false,
        collectionProgress: v ? state.collectionProgress : false,
      ));

  void setSystem(bool v) => emit(state.copyWith(
        systemEnabled: v,
        appUpdates: v ? state.appUpdates : false,
        productAnnouncements: v ? state.productAnnouncements : false,
      ));

  void setNewSeasonAvailable(bool v) => emit(state.copyWith(newSeasonAvailable: v));
  void setNewEpisodeAvailable(bool v) => emit(state.copyWith(newEpisodeAvailable: v));
  void setUpcomingMovieRelease(bool v) => emit(state.copyWith(upcomingMovieRelease: v));
  void setStreamingChanges(bool v) => emit(state.copyWith(streamingChanges: v));
  void setWatchlistItemReleased(bool v) => emit(state.copyWith(watchlistItemReleased: v));
  void setWatchlistItemTrending(bool v) => emit(state.copyWith(watchlistItemTrending: v));
  void setLikesOnRankings(bool v) => emit(state.copyWith(likesOnRankings: v));
  void setComments(bool v) => emit(state.copyWith(comments: v));
  void setNewFollowers(bool v) => emit(state.copyWith(newFollowers: v));
  void setFriendActivity(bool v) => emit(state.copyWith(friendActivity: v));
  void setBadgeUnlocks(bool v) => emit(state.copyWith(badgeUnlocks: v));
  void setMilestones(bool v) => emit(state.copyWith(milestones: v));
  void setCollectionProgress(bool v) => emit(state.copyWith(collectionProgress: v));
  void setAppUpdates(bool v) => emit(state.copyWith(appUpdates: v));
  void setProductAnnouncements(bool v) => emit(state.copyWith(productAnnouncements: v));
}
