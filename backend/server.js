require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/database");
require("./config/firebase"); // initialize firebase-admin
const rateLimiter = require("./middlewares/rateLimiter");

const app = express();

app.use(cors());
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

app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({
    error: {
      code: err.code || "INTERNAL_ERROR",
      message: err.message || "Server error",
    },
  });
});

const PORT = process.env.PORT || 3000;

connectDB().then(() => {
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

  // Daily push sweep. The inbox is compute-on-read and needs no schedule; this
  // exists only so push notifications reach phones that haven't opened the
  // app. Default 13:30 UTC = 7pm IST — an evening push, never a 3am one.
  const cron = require("node-cron");
  const { sweepAllUsers } = require("./services/releaseNotifications");
  cron.schedule(process.env.PUSH_SWEEP_CRON || "30 13 * * *", () =>
    sweepAllUsers().catch((err) =>
      console.error(`[sweep] failed: ${err.message}`),
    ),
  );
});
