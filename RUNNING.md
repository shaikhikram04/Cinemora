# Running Watchary

Watchary is a Flutter cinema-companion app backed by two services. Bring them up in this order:

```
MongoDB + Redis  →  recommender (Python)  →  backend (Node)  →  frontend (Flutter)
```

| Service | Stack | Default port | Talks to |
|---|---|---|---|
| **recommender** | Python 3.14 · FastAPI · Uvicorn | `8000` (internal only) | Mongo, Redis, TMDB, Jikan, Gemini |
| **backend** | Node · Express 5 · Mongoose 8 | `3000` (public API) | Mongo, TMDB, Jikan, AniList, Firebase, recommender |
| **frontend** | Flutter 3.41 (Dart 3.11) via FVM | — | backend |

The Flutter app only ever calls the **backend**. The backend proxies recommendation/mood calls to the **recommender** over an internal secret-protected hop.

---

## 0. Prerequisites

- **MongoDB** and **Redis** running locally (both services default to `localhost`).
- **Flutter via FVM** — the pinned toolchain lives at `~/fvm/versions/stable/bin/flutter` (Flutter 3.41.4 / Dart 3.11.1).
- **Node** 18+ and **Python** 3.14 (a `.venv` already exists in `recommender/`).
- API keys: a **TMDB** key (shared by both services) and, for mood chat, a **Gemini** key (free from [AI Studio](https://aistudio.google.com/apikey)).
- **Firebase** service account JSON for the backend (auth), plus `google-services.json` already in `frontend/android/app/`.

Start Mongo + Redis first, e.g.:

```bash
# however you run them locally — examples:
mongod --dbpath /your/db/path        # or: systemctl start mongod
redis-server                         # or: systemctl start redis
```

---

## 1. Recommender (Python / FastAPI) — port 8000

```bash
cd recommender
cp .env.example .env          # first time only — then fill in the values below
source .venv/bin/activate     # venv already provisioned
# if deps are missing: pip install -r requirements.txt

uvicorn main:app --reload --port 8000
```

Fill in `recommender/.env`:

| Var | Notes |
|---|---|
| `MONGO_URI` | Same Mongo instance as the backend (`mongodb://localhost:27017/watchary`). |
| `REDIS_URL` | `redis://localhost:6379/0` |
| `TMDB_API_KEY` | Same key as `backend/.env`. |
| `INTERNAL_SERVICE_SECRET` | **Must match** the backend's value — the shared handshake. |
| `GEMINI_API_KEY` | Required for mood chat; without it the mood endpoint returns `503` (rest of the app still works). Free tier: ~10 req/min, 1500 req/day. |
| `INGESTION_HOUR_UTC` / `CATALOG_PAGE_LIMIT` | Daily sweep hour and pages pulled per list. |

**Health check:**

```bash
curl http://localhost:8000/internal/health
# expects Mongo + Redis connectivity to report ok
```

**Seed the content catalog** (first run — the DB starts empty; recommendations need it):

```bash
curl -X POST http://localhost:8000/internal/ingest/run \
  -H "X-Internal-Secret: <your INTERNAL_SERVICE_SECRET>"
```

This pulls TMDB (movies/tv) + Jikan (anime) and can take a few minutes under Jikan's rate limit. After the first run, APScheduler re-ingests daily at `INGESTION_HOUR_UTC`.

---

## 2. Backend (Node / Express) — port 3000

```bash
cd backend
cp .env.example .env          # first time only
npm install                   # first time only
npm run dev                   # nodemon; use `npm start` for plain node
```

Fill in `backend/.env`:

| Var | Notes |
|---|---|
| `MONGO_URI` | `mongodb://localhost:27017/watchary` |
| `JWT_SECRET` / `JWT_REFRESH_SECRET` | Any strong secrets. |
| `TMDB_API_KEY` | Same key as the recommender. |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full service-account JSON on a single line. |
| `RECOMMENDER_URL` | `http://localhost:8000` |
| `INTERNAL_SERVICE_SECRET` | **Must match** the recommender's value. |

Recommendation routes exposed to the app (all behind JWT auth):

- `GET  /api/recommendations/home?type=all|movie|tv|anime`
- `GET  /api/recommendations/similar/:cinemaType/:tmdbId`
- `POST /api/recommendations/mood/message`

---

## 3. Frontend (Flutter) — via FVM

```bash
cd frontend
~/fvm/versions/stable/bin/flutter pub get
~/fvm/versions/stable/bin/flutter run          # pick a connected device / emulator
```

> Tip: alias it — `alias fflutter='~/fvm/versions/stable/bin/flutter'` — then just `fflutter run`.

### Configuring the API base URL

The app talks only to the Node backend, at the URL in
[`frontend/lib/core/constants/api_constants.dart`](frontend/lib/core/constants/api_constants.dart)
(`ApiConstants.baseUrl`). `baseUrl` is a compile-time `const`, so after changing it you must **fully restart** the app (`flutter run` again, or a hot **restart** — a hot reload won't pick it up).

Pick the value for how you're running:

| Where the app runs | `baseUrl` |
|---|---|
| Desktop / web on the laptop itself | `http://localhost:3000/api` |
| Android emulator | `http://10.0.2.2:3000/api` |
| Physical device on the same Wi-Fi | `http://<laptop-LAN-IP>:3000/api` |
| Physical device over USB (recommended) | `http://localhost:3000/api` + `adb reverse` (below) |

Find the laptop's LAN IP:

```bash
ip -4 addr show | grep -oP '(?<=inet\s)(?!127\.)[0-9.]+'
```

### Recommended for a physical phone: `adb reverse` (network-independent)

Editing `baseUrl` every time you switch networks (home Wi-Fi → phone hotspot → mobile data) gets old fast, and some networks block phone↔laptop traffic outright (Wi-Fi AP isolation, hotspot client isolation). `adb reverse` sidesteps all of it by tunneling over the USB cable:

```bash
# phone plugged in via USB, USB debugging enabled
adb devices                      # confirm the phone is listed
adb reverse tcp:3000 tcp:3000    # phone's localhost:3000 → laptop's localhost:3000
```

Then keep `baseUrl = 'http://localhost:3000/api'`. This works identically on home Wi-Fi, the phone's hotspot, mobile data, or with Wi-Fi off entirely — the traffic never touches the network. Re-run `adb reverse tcp:3000 tcp:3000` after replugging the phone or restarting adb (it isn't persistent).

### Phone hotspot (Wi-Fi down, laptop on the phone's hotspot)

The phone assigns the laptop a new IP (often `192.168.43.x`). Find it with the `ip` command above, then set `baseUrl` to `http://<that-ip>:3000/api`. If the phone isolates its hotspot clients, this won't work — use `adb reverse` instead.

> **Note:** the laptop's LAN IP is a DHCP lease and can change after a router/phone reboot — if you suddenly get "No route to host", re-check the IP. Prefer `adb reverse` to avoid this entirely.

Useful checks:

```bash
~/fvm/versions/stable/bin/flutter analyze
~/fvm/versions/stable/bin/flutter test
```

---

## Quick start (all services)

Three terminals:

```bash
# terminal 1 — recommender
cd recommender && source .venv/bin/activate && uvicorn main:app --reload --port 8000

# terminal 2 — backend
cd backend && npm run dev

# terminal 3 — frontend
cd frontend && ~/fvm/versions/stable/bin/flutter run
```

Then, on first run only, seed the catalog (step 1's ingest curl).

---

## Troubleshooting

- **Home recommendations are empty / no "Critically Acclaimed"** → the catalog hasn't been ingested. Run the `/internal/ingest/run` curl (step 1).
- **Mood chat returns 503** → `GEMINI_API_KEY` is blank in `recommender/.env`. Add a key and restart the recommender.
- **Mood chat returns 429 "busy"** → either the Gemini free tier's ~10 req/min ceiling, or *both* `GEMINI_MODEL` and `GEMINI_FALLBACK_MODEL` are shedding load (free-tier traffic is dropped first when a model is saturated — a `503 high demand` can persist for minutes). Wait and retry.
- **Backend `502`/`connection refused` on `/api/recommendations/*`** → the recommender isn't running, or `RECOMMENDER_URL` / `INTERNAL_SERVICE_SECRET` don't match between the two `.env` files.
- **`/internal/*` returns 401/403** → the `X-Internal-Secret` doesn't match the recommender's `INTERNAL_SERVICE_SECRET`.
- **App can't reach the backend from a device/emulator** (`No route to host` / `connectionError`) → the `baseUrl` doesn't match how you're running. See [Configuring the API base URL](#configuring-the-api-base-url) — use `10.0.2.2` on the emulator, the laptop LAN IP on Wi-Fi, or `adb reverse` over USB (works on any network). A bare `:` with no port (e.g. `http://192.168.1.108:/api`) also causes this — make sure the port is present.
- **Mongo/Redis connection errors at startup** → make sure both are running before the recommender/backend; verify `/internal/health` reports both ok.

---

## Architecture at a glance

```
Flutter app
   │  (JWT, HTTPS)
   ▼
Node backend  ──────────────►  Python recommender   (X-Internal-Secret + X-User-Id)
   │  TMDB / Jikan / AniList        │  TMDB / Jikan (ingestion + similar)
   │  Firebase auth                 │  Gemini API (mood chat)
   ▼                                ▼
MongoDB  ◄──────────────────────  MongoDB (own collections) + Redis (caches)
```

- The recommender **reads** `users`, `libraryentries`, `rankinglists` and **owns** `content_catalog`, `recommendation_cache`, `ingestion_locks`, `mood_sessions`.
- "Trending Now" is served directly by the Node backend (raw TMDB/Jikan); everything personalized (Pick of the Week, Because You Ranked, Critically Acclaimed, Similar, Mood) comes from the recommender.
