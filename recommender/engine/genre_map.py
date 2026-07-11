import re

# TMDB and Jikan use different vocabularies for the same concept (TMDB
# "Science Fiction" vs Jikan "Sci-Fi"). Canonicalizing at ingestion time is
# what makes cross-source genre-affinity scoring (Phase 2a) possible at all —
# without this, anime silently falls out of any genre match against
# TMDB-sourced onboarding preferences.
_ALIASES: dict[str, str] = {
    "science fiction": "sci_fi",
    "sci-fi": "sci_fi",
    "tv movie": "tv_movie",
    "slice of life": "slice_of_life",
    "boys love": "boys_love",
    "girls love": "girls_love",
    "award winning": "award_winning",
    "avant garde": "avant_garde",
    "coming of age": "coming_of_age",
}

# TMDB TV genres that bundle two concepts with "&" — split into separate tags
# so they can match single-concept tags from TMDB movies / Jikan.
_SPLIT_ON_AMPERSAND = {"action & adventure", "sci-fi & fantasy", "war & politics"}


def _slugify(label: str) -> str:
    slug = label.strip().lower()
    slug = re.sub(r"[^a-z0-9]+", "_", slug).strip("_")
    return slug


def canonicalize_genre(label: str) -> list[str]:
    if not label:
        return []
    key = label.strip().lower()
    if key in _SPLIT_ON_AMPERSAND:
        tags: list[str] = []
        for part in key.split("&"):
            tags.extend(canonicalize_genre(part))
        return tags
    if key in _ALIASES:
        return [_ALIASES[key]]
    return [_slugify(key)]


def canonicalize_genres(labels: list[str]) -> list[str]:
    seen: list[str] = []
    for label in labels:
        for tag in canonicalize_genre(label):
            if tag and tag not in seen:
                seen.append(tag)
    return seen
