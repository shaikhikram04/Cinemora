require("dotenv").config();
const express = require("express");
const connectDB = require("./config/database");
require("./config/firebase"); // initialize firebase-admin
const rateLimiter = require("./middlewares/rateLimiter");

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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
app.use("/api/watch-together", require("./routes/watchTogether"));
app.use("/api/notifications", require("./routes/notifications"));

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
});
