const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  updateProfile, updatePreferences, updateFcmToken,
} = require("../controllers/usersController");

router.use(auth);

router.put("/profile", updateProfile);
router.put("/preferences", updatePreferences);
router.put("/fcm-token", updateFcmToken);

module.exports = router;
