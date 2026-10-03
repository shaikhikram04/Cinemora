class AppIcons {
  AppIcons._();

  static const String cinemora = 'assets/icons/cinemora_icon.png';
  static const String cinemoraTransparent =
      'assets/icons/cinemora_transparent_icon.png';

  // Custom line-art glyphs. Single-color art on transparent background, so
  // they tint like a font icon — render them through `AppIcon`, never a bare
  // Image.asset (which would paint them near-black in both themes).
  static const String movie = 'assets/icons/movie_icon.webp';
  static const String tvShow = 'assets/icons/tv_show_icon.webp';
  static const String anime = 'assets/icons/anime_icon.webp';
  static const String ranking = 'assets/icons/ranking_icon.webp';
  static const String randomPick = 'assets/icons/shuffle_icon.webp';
}

class AppAnimations {
  AppAnimations._();

  static const String confetti = 'assets/animations/confetti.json';
}
