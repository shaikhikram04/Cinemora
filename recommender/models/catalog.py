from datetime import datetime, timezone
from typing import Literal

from pydantic import BaseModel, Field

Source = Literal["tmdb", "anilist"]
CinemaType = Literal["movie", "tv", "anime"]


class CatalogItem(BaseModel):
    source: Source
    sourceId: int
    cinemaType: CinemaType
    title: str
    posterPath: str | None = None
    year: str | None = None
    genres: list[str] = Field(default_factory=list)
    rawRating: float = 0.0
    voteCount: int = 0
    normalizedRating: float = 0.0
    bayesianScore: float = 0.0
    originalLanguage: str | None = None
    similarIds: list[int] = Field(default_factory=list)
    updatedAt: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    def public(self) -> dict:
        return {
            "source": self.source,
            "sourceId": self.sourceId,
            "cinemaType": self.cinemaType,
            "title": self.title,
            "posterPath": self.posterPath,
            "year": self.year,
            "rating": round(self.normalizedRating, 1),
            "genres": self.genres,
        }
