// Manually triggers the daily push sweep (normally cron-scheduled in
// server.js). For testing push delivery without waiting for the schedule:
//
//   cd backend && node scripts/runPushSweep.js
require("dotenv").config();
const mongoose = require("mongoose");
const { sweepAllUsers } = require("../services/releaseNotifications");

(async () => {
  await mongoose.connect(process.env.MONGO_URI);
  await sweepAllUsers();
  await mongoose.disconnect();
  process.exit(0);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
