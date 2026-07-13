const router = require("express").Router();
const auth = require("../middlewares/auth");
const { singleImage } = require("../middlewares/upload");
const {
  updateProfile, updatePreferences, updateFcmToken, uploadAvatar, uploadCover,
} = require("../controllers/usersController");

router.use(auth);

router.put("/profile", updateProfile);
router.put("/preferences", updatePreferences);
router.put("/fcm-token", updateFcmToken);
router.post("/avatar", singleImage("image"), uploadAvatar);
router.post("/cover", singleImage("image"), uploadCover);

module.exports = router;
