enum WatchStatus {
  watchlist,
  watched,
  dropped;

  String get apiValue => name; // 'watchlist', 'watched', 'dropped'

  static WatchStatus fromJson(String value) => switch (value) {
        'watchlist' => WatchStatus.watchlist,
        'watched' => WatchStatus.watched,
        'dropped' => WatchStatus.dropped,
        _ => WatchStatus.watchlist,
      };

  // Maps UI filter display labels to enum values.
  static WatchStatus fromDisplayName(String display) =>
      switch (display.toLowerCase()) {
        'watchlist' => WatchStatus.watchlist,
        'watched' => WatchStatus.watched,
        'dropped' => WatchStatus.dropped,
        _ => WatchStatus.watchlist,
      };

  String get displayName => switch (this) {
        WatchStatus.watchlist => 'Watchlist',
        WatchStatus.watched => 'Watched',
        WatchStatus.dropped => 'Dropped',
      };
}
