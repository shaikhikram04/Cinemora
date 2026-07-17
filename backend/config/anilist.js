const axios = require("axios");
const { cacheGet, cacheSet } = require("./redis");

// AniList GraphQL — no API key; rate limit: 90 req/min per IP
const anilist = axios.create({
  baseURL: "https://graphql.anilist.co",
  timeout: 15000,
  headers: { "Content-Type": "application/json" },
});

const TTL = {
  details: 60 * 60 * 24, // 24 hours
  // Short — search was the only uncached path against the 90 req/min budget we
  // share with the recommender. Dedupes popular/repeated queries; a typing burst
  // still costs one call per prefix, so debounce on the client too.
  search: 60 * 5,
};

// Shared fields for every relation node — includes format so we can filter out OVAs/Movies
const RELATION_NODE_FIELDS = `
  id
  idMal
  type
  format
  title { english romaji }
  episodes
  averageScore
  startDate { year }
  status
`;

const ANIME_DETAIL_QUERY = `
  query ($malId: Int) {
    Media(idMal: $malId, type: ANIME) {
      id
      idMal
      title { english romaji }
      description(asHtml: false)
      genres
      averageScore
      episodes
      status
      countryOfOrigin
      startDate { year }
      endDate { year }
      coverImage { extraLarge large }
      trailer { id site }
      studios(isMain: true) { nodes { name } }
      characters(role: MAIN, perPage: 10, sort: [ROLE, RELEVANCE]) {
        edges {
          role
          node {
            name { full }
            image { medium }
          }
        }
      }
      relations {
        edges {
          relationType(version: 2)
          node { ${RELATION_NODE_FIELDS} }
        }
      }
    }
  }
`;

// Lightweight query used only for chain traversal — avoids fetching full detail repeatedly
const RELATIONS_ONLY_QUERY = `
  query ($id: Int) {
    Media(id: $id, type: ANIME) {
      relations {
        edges {
          relationType(version: 2)
          node { ${RELATION_NODE_FIELDS} }
        }
      }
    }
  }
`;

const getAnimeByMalId = async (malId) => {
  const key = `anilist:detail:${malId}`;
  const cached = await cacheGet(key);
  if (cached) return cached;

  const { data } = await anilist.post("", {
    query: ANIME_DETAIL_QUERY,
    variables: { malId: parseInt(malId, 10) },
  });

  await cacheSet(key, data, TTL.details);
  return data;
};

// Fetches only the relations for a given AniList ID — cached independently
const getRelationsById = async (anilistId) => {
  const key = `anilist:rel:${anilistId}`;
  const cached = await cacheGet(key);
  if (cached) return cached;

  const { data } = await anilist.post("", {
    query: RELATIONS_ONLY_QUERY,
    variables: { id: anilistId },
  });

  const edges = data?.data?.Media?.relations?.edges ?? [];
  await cacheSet(key, edges, TTL.details);
  return edges;
};

// A node is a "season" if it's a TV anime — filters out OVAs, Movies, Specials
const isSeasonNode = (node) =>
  node?.type === "ANIME" &&
  (node?.format === "TV" ||
    node?.format === "TV_SHORT" ||
    node?.format == null);

// Iteratively follows PREQUEL or SEQUEL links until the chain ends.
// AniList only exposes direct relations, so we must hop node-by-node.
const traverseSeasonChain = async (directNodes, direction) => {
  const allNodes = [...directNodes];
  const visited = new Set(directNodes.map((n) => n.id));
  let frontier = [...directNodes];

  while (frontier.length > 0 && allNodes.length < 20) {
    const nextFrontier = [];

    for (const node of frontier) {
      const edges = await getRelationsById(node.id);
      const nextNodes = edges
        .filter(
          (e) =>
            e.relationType === direction &&
            isSeasonNode(e.node) &&
            !visited.has(e.node.id),
        )
        .map((e) => e.node);

      for (const n of nextNodes) {
        visited.add(n.id);
        allNodes.push(n);
        nextFrontier.push(n);
      }
    }

    frontier = nextFrontier;
  }

  return allNodes;
};

const SEARCH_QUERY = `
  query ($search: String, $perPage: Int) {
    Page(page: 1, perPage: $perPage) {
      media(
        search: $search
        type: ANIME
        format_in: [TV, TV_SHORT]
        sort: [SEARCH_MATCH, POPULARITY_DESC]
      ) {
        id
        idMal
        title { english romaji }
        coverImage { large }
        averageScore
        startDate { year }
      }
    }
  }
`;

const searchAnime = async (query, perPage = 20) => {
  // Normalized so "Naruto", "naruto" and "naruto " share one entry
  const key = `anilist:search:${query.trim().toLowerCase()}:${perPage}`;
  const cached = await cacheGet(key);
  if (cached) return cached;

  const { data } = await anilist.post("", {
    query: SEARCH_QUERY,
    variables: { search: query, perPage },
  });
  const media = data?.data?.Page?.media ?? [];
  // Drop entries with no MAL ID — they can't be opened in the detail screen
  const results = media.filter((m) => m.idMal != null);

  await cacheSet(key, results, TTL.search);
  return results;
};

module.exports = {
  getAnimeByMalId,
  searchAnime,
  isSeasonNode,
  traverseSeasonChain,
};
