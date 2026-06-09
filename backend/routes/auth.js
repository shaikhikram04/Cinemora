const router = require("express").Router();
const auth = require("../middlewares/auth");
const { firebaseLogin, refresh, me, deleteAccount } = require("../controllers/authController");

router.post("/firebase", firebaseLogin);
router.post("/refresh", refresh);
router.get("/me", auth, me);
router.delete("/account", auth, deleteAccount);

module.exports = router;
