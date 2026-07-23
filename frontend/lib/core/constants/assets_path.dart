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

class AppImages {
  AppImages._();

  static const String amazonPrimeVideo =
      'assets/images/streaming_platforms/amazon_prime_video_icon.webp';
  static const String appleTv =
      'assets/images/streaming_platforms/apple_tv_icon.webp';
  static const String crunchyroll =
      'assets/images/streaming_platforms/crunchyroll_icon.webp';
  static const String disneyPlus =
      'assets/images/streaming_platforms/disney_plus_icon.webp';
  static const String jioHotstar =
      'assets/images/streaming_platforms/jio_hotstar_icon.webp';
  static const String mubi = 'assets/images/streaming_platforms/mubi_icon.webp';
  static const String netflix =
      'assets/images/streaming_platforms/netflix_icon.webp';
  static const String sonyLiv =
      'assets/images/streaming_platforms/sony_liv_icon.webp';
  static const String zee5 = 'assets/images/streaming_platforms/zee5_icon.webp';

  static String? forProvider(String name) {
    final l = name.toLowerCase();
    if (l.contains('netflix')) return netflix;
    if (l.contains('prime') || l.contains('amazon')) return amazonPrimeVideo;
    if (l.contains('disney')) return disneyPlus;
    if (l.contains('apple')) return appleTv;
    if (l.contains('hotstar') || l.contains('jio')) return jioHotstar;
    if (l.contains('crunchyroll')) return crunchyroll;
    if (l.contains('mubi')) return mubi;
    if (l.contains('sony')) return sonyLiv;
    if (l.contains('zee5')) return zee5;
    return null;
  }
}

class AppAnimations {
  AppAnimations._();

  static const String confetti = 'assets/animations/confetti.json';
}
