const anilist = require("../config/anilist");

// GET /api/anilist/anime/:malId
const getAnimeDetail = async (req, res) => {
  const data = await anilist.getAnimeByMalId(req.params.malId);

  if (data?.errors?.length) {
    const first = data.errors[0];
    return res.status(first.status ?? 500).json({ error: first.message });
  }

  const media = data?.data?.Media;
  if (!media?.relations) return res.json(data);

  const edges = media.relations.edges ?? [];
  const title = media.title?.english ?? media.title?.romaji ?? "Unknown";

  // Split direct relations into season prequels/sequels vs everything else
  const directPrequels = edges
    .filter((e) => e.relationType === "PREQUEL" && anilist.isSeasonNode(e.node))
    .map((e) => e.node);
  const directSequels = edges
    .filter((e) => e.relationType === "SEQUEL" && anilist.isSeasonNode(e.node))
    .map((e) => e.node);
  // Drop ALL PREQUEL/SEQUEL edges — we replace them with the full TV-only chain below.
  // Keeping OVA/Movie prequels/sequels here would confuse the frontend into counting them as seasons.
  const otherEdges = edges.filter(
    (e) => e.relationType !== "PREQUEL" && e.relationType !== "SEQUEL"
  );

  console.log(
    `[AniList] "${title}" — ` +
    `${directPrequels.length} direct prequel(s), ${directSequels.length} direct sequel(s)`
  );

  // Traverse the full PREQUEL and SEQUEL chains in parallel
  const [fullPrequels, fullSequels] = await Promise.all([
    anilist.traverseSeasonChain(directPrequels, "PREQUEL"),
    anilist.traverseSeasonChain(directSequels, "SEQUEL"),
  ]);

  console.log(
    `[AniList] "${title}" full chain — ` +
    `${fullPrequels.length} prequel(s), ${fullSequels.length} sequel(s) ` +
    `→ ${1 + fullPrequels.length + fullSequels.length} total season(s)`
  );

  // Rebuild relations.edges with the full season chain
  media.relations.edges = [
    ...otherEdges,
    ...fullPrequels.map((n) => ({ relationType: "PREQUEL", node: n })),
    ...fullSequels.map((n) => ({ relationType: "SEQUEL", node: n })),
  ];

  res.json(data);
};

module.exports = { getAnimeDetail };
