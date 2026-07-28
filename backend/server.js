require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/database");
require("./config/firebase"); // initialize firebase-admin
const rateLimiter = require("./middlewares/rateLimiter");
const AppError = require("./utils/AppError");

const app = express();

// Behind a managed host (Render/Railway/Fly/nginx) every request arrives from
// the proxy, so req.ip is the proxy's address unless we opt in to
// X-Forwarded-For. Without this the rate limiter below buckets the entire
// userbase into one counter: 300 req/min becomes a global cap, and the 10/min
// auth limit locks everyone out after ten sign-ins.
//
// The value is the number of proxies in front of us — trusting only that many
// hops means a client can't forge its own IP by sending X-Forwarded-For. Set
// TRUST_PROXY_HOPS to match the deployment; 0 disables it for a direct bind.
const trustProxyHops = Number(process.env.TRUST_PROXY_HOPS ?? 1);
if (trustProxyHops > 0) app.set("trust proxy", trustProxyHops);

// The clients are native apps, which don't send an Origin header and aren't
// subject to CORS at all — so the default is to grant no browser origin.
// CORS_ORIGINS (comma-separated) exists for a future web client or dashboard.
const corsOrigins = (process.env.CORS_ORIGINS || "")
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);
app.use(cors({ origin: corsOrigins.length > 0 ? corsOrigins : false }));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Reachability probe for the app's offline detection. Deliberately mounted
// above the logger and the rate limiter: the client polls this while it thinks
// it's offline, and those probes should neither flood the log nor eat the
// per-IP budget. Touches nothing — answering at all is the whole signal.
app.get("/api/health", (req, res) => res.json({ ok: true }));

// Request logger — prints method, path, status, and latency for every request
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const ms = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} → ${res.statusCode} (${ms}ms)`);
  });
  next();
});

// Broad limit: 300 req/min per IP across all API routes.
app.use("/api", rateLimiter(300, 60_000));

// Tighter limit on auth endpoints to slow brute-force attempts.
const authLimiter = rateLimiter(10, 60_000);

// Routes (added as features are built)
app.use("/api/auth", authLimiter, require("./routes/auth"));
app.use("/api/library", require("./routes/library"));
app.use("/api/rankings", require("./routes/rankings"));
app.use("/api/tmdb", require("./routes/tmdb"));
app.use("/api/jikan", require("./routes/jikan"));
app.use("/api/anilist", require("./routes/anilist"));
app.use("/api/users", require("./routes/users"));
app.use("/api/notifications", require("./routes/notifications"));
app.use("/api/recommendations", require("./routes/recommendations"));

// Only an AppError carries a message written to be read by a user. Anything
// else reaching here is an internal failure — a Mongoose cast error, an axios
// timeout, a bug — and its message describes our internals, so it stays in the
// log and the client gets a generic one.
app.use((err, req, res, next) => {
  console.error(err);
  const isPublic = err instanceof AppError;
  const status = isPublic ? err.status : 500;
  res.status(status).json({
    error: {
      code: isPublic ? err.code : "INTERNAL_ERROR",
      message: isPublic ? err.message : "Something went wrong. Please try again.",
    },
  });
});

const PORT = process.env.PORT || 3000;

connectDB().then(() => {
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

  // Daily push sweep. The inbox is compute-on-read and needs no schedule; this
  // exists only so push notifications reach phones that haven't opened the
  // app. Default 13:30 UTC = 7pm IST — an evening push, never a 3am one.
  //
  // The schedule is in-process, so every instance that runs it repeats the
  // whole pass. The atomic claim in sealRelease stops that from double-sending,
  // but it is still duplicated work against Mongo and the release APIs — so
  // when running more than one instance, set PUSH_SWEEP_ENABLED=false on all
  // but one.
  if (process.env.PUSH_SWEEP_ENABLED === "false") {
    console.log("[sweep] not scheduled on this instance");
  } else {
    const cron = require("node-cron");
    const { sweepAllUsers } = require("./services/releaseNotifications");
    const schedule = process.env.PUSH_SWEEP_CRON || "30 13 * * *";
    cron.schedule(schedule, () =>
      sweepAllUsers().catch((err) =>
        console.error(`[sweep] failed: ${err.message}`),
      ),
    );
    console.log(`[sweep] scheduled (${schedule})`);
  }
});
