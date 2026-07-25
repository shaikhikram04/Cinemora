/// The taste vocabulary, shared by onboarding and Edit Profile.
///
/// These two screens must offer the same set. When they drifted apart, a genre
/// picked during onboarding (Comedy, Adventure) was absent from Edit Profile —
/// still stored on the user and still sent on save, but invisible and therefore
/// impossible to remove. Keeping one list here is what prevents that.
class TasteOptions {
  const TasteOptions._();

  /// Genre keys in display order. The order is the one onboarding already
  /// used — roughly by popularity — with the two Edit-Profile-only genres
  /// folded in rather than appended, so neither screen reorders on the user.
  static const genres = <String>[
    'Action',
    'Thriller',
    'Sci-Fi',
    'Comedy',
    'Romance',
    'Horror',
    'Drama',
    'Mystery',
    'Psychological',
    'Fantasy',
    'Crime',
    'Adventure',
    'Documentary',
    'Animation',
  ];

  /// Decoration for onboarding's genre chips. Edit Profile renders text only,
  /// so a missing entry here is harmless — [genres] stays the source of truth.
  static const genreEmoji = <String, String>{
    'Action': '💥',
    'Thriller': '🔪',
    'Sci-Fi': '🚀',
    'Comedy': '😂',
    'Romance': '❤️',
    'Horror': '👻',
    'Drama': '🎭',
    'Mystery': '🔍',
    'Psychological': '🧠',
    'Fantasy': '🧙',
    'Crime': '🦹',
    'Adventure': '🌍',
    'Documentary': '📽️',
    'Animation': '✨',
  };

  /// Quick picks shown inline on Edit Profile.
  static const languages = <String>[
    'English',
    'Japanese',
    'Korean',
    'French',
    'Spanish',
    'German',
    'Hindi',
  ];

  /// The full set behind "Others". Leads with the quick picks so the sheet
  /// doubles as a complete picker, then the languages onboarding offers, then
  /// a broader predefined set.
  static const moreLanguages = <String>[
    ...languages,
    'Tamil',
    'Telugu',
    'Malayalam',
    'Marathi',
    'Mandarin',
    'Cantonese',
    'Italian',
    'Portuguese',
    'Russian',
    'Arabic',
    'Turkish',
    'Thai',
    'Vietnamese',
    'Bengali',
    'Punjabi',
    'Gujarati',
    'Kannada',
    'Urdu',
    'Dutch',
    'Swedish',
    'Polish',
    'Indonesian',
  ];
}
