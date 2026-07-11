# Onboarding stores language preferences as display names
# (frontend/lib/features/onboarding/views/taste_setup_view.dart `_kLanguages`),
# not ISO codes — map to ISO 639-1 so they compare against TMDB's
# `original_language`. "Other" has no single code and is intentionally
# dropped rather than guessed.
_DISPLAY_TO_ISO = {
    "english": "en",
    "hindi": "hi",
    "japanese": "ja",
    "korean": "ko",
    "tamil": "ta",
    "telugu": "te",
    "malayalam": "ml",
    "marathi": "mr",
}


def to_iso_codes(display_names: list[str]) -> set[str]:
    codes = set()
    for name in display_names:
        code = _DISPLAY_TO_ISO.get(name.strip().lower())
        if code:
            codes.add(code)
    return codes
