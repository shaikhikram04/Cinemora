const admin = require("../config/firebase");
const User = require("../models/User");

// Which per-type opt-out gates each notification type. In-app inbox rows are
// always created; prefs only silence the push channel.
const PREF_BY_TYPE = {
  new_release: "pushNewRelease",
  new_season: "pushNewSeason",
};

// Token errors that mean "this device is gone" — prune so the sweep stops
// paying for a dead send every day. Anything else is transient: log and keep.
const DEAD_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

/**
 * Sends the FCM push for one notification document. Best effort by design:
 * failures are logged, never thrown — the inbox row already exists, push is
 * just the doorbell.
 */
const sendPushForNotification = async (notif) => {
  const user = await User.findById(notif.userId).select(
    "fcmToken notificationPrefs",
  );
  if (!user?.fcmToken) return;

  const prefKey = PREF_BY_TYPE[notif.type];
  if (prefKey && user.notificationPrefs?.[prefKey] === false) return;

  // The device downloads this itself, so TMDB/AniList URLs work directly.
  // Expanding the notification shows the poster under the text.
  const posterPath = notif.data?.posterPath;
  const imageUrl = !posterPath
    ? null
    : posterPath.startsWith("http")
      ? posterPath
      : `https://image.tmdb.org/t/p/w500${posterPath}`;

  try {
    await admin.messaging().send({
      token: user.fcmToken,
      notification: { title: notif.title, body: notif.body },
      // Data values must be strings; the app uses these to route the tap.
      data: {
        type: notif.type,
        tmdbId: String(notif.data?.tmdbId ?? ""),
        cinemaType: notif.data?.cinemaType ?? "",
        season: notif.data?.season != null ? String(notif.data.season) : "",
      },
      android: {
        priority: "high",
        ...(imageUrl && { notification: { imageUrl } }),
      },
    });
  } catch (err) {
    if (DEAD_TOKEN_CODES.has(err.code)) {
      await User.updateOne({ _id: notif.userId }, { $unset: { fcmToken: 1 } });
    } else {
      console.error(
        `[push] send failed for user ${notif.userId}: ${err.message}`,
      );
    }
  }
};

module.exports = { sendPushForNotification };
