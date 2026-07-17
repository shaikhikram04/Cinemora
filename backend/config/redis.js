const { createClient } = require("redis");

// Shared with the recommender service, so every key here is namespaced by
// source (tmdb: / jikan: / anilist:) — the recommender owns similar:* and
// acclaimed:* on the same instance.
const url = process.env.REDIS_URL || "redis://localhost:6379/0";

// How long to stop attempting connections after a failure. Without this, every
// request would pay a fresh connect attempt while Redis is down.
const DOWN_BACKOFF_MS = 30_000;

let client = null;
let connecting = null;
let downUntil = 0;
let errorLogged = false;

// Callers must await this — connecting is async, and issuing a command before
// the socket is ready throws, which fail-open would silently turn into a
// permanent cache miss on every request.
const getClient = async () => {
  if (client?.isReady) return client;
  // Circuit open: Redis was just seen down, so don't even try — fail open now.
  if (Date.now() < downUntil) throw new Error("redis circuit open");
  if (connecting) return connecting;

  const c = createClient({
    url,
    socket: {
      // Give up quickly rather than retrying forever: an unbounded strategy
      // means connect() never settles and every caller hangs on it.
      reconnectStrategy: (retries) =>
        retries > 2 ? new Error("redis unreachable") : 200,
      connectTimeout: 1000,
    },
    // Fail fast instead of queueing commands while disconnected — a cache read
    // must never hold a request open waiting for Redis to come back.
    disableOfflineQueue: true,
  });

  // The cache is optional; an unhandled 'error' event would crash the process.
  // Log once so a dead Redis is visible without spamming on every retry.
  c.on("error", (err) => {
    if (!errorLogged) {
      errorLogged = true;
      console.error(`[redis] unavailable, falling back to live API calls: ${err.message}`);
    }
  });
  c.on("ready", () => {
    errorLogged = false;
  });

  connecting = c
    .connect()
    .then(() => {
      client = c;
      connecting = null;
      return c;
    })
    .catch((err) => {
      // Open the circuit and drop the dead client so a later request can retry
      // with a fresh one once the backoff expires.
      connecting = null;
      client = null;
      downUntil = Date.now() + DOWN_BACKOFF_MS;
      c.destroy?.();
      throw err;
    });

  return connecting;
};

// Every helper below fails open: if Redis is down we behave exactly as if the
// key were missing. Slower and more upstream calls, but never a broken request.
const cacheGet = async (key) => {
  try {
    const raw = await (await getClient()).get(key);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
};

const cacheSet = async (key, value, ttlSeconds) => {
  try {
    await (await getClient()).set(key, JSON.stringify(value), { EX: ttlSeconds });
  } catch {
    // A cache write failure must not fail the request that produced the data.
  }
};

const closeRedis = async () => {
  if (!client) return;
  try {
    await client.quit();
  } catch {
    // already gone
  }
  client = null;
};

module.exports = { cacheGet, cacheSet, closeRedis };
