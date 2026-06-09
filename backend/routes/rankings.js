const router = require("express").Router();
const auth = require("../middlewares/auth");
const {
  getLists, createList, getList, updateList, deleteList,
  addEntry, reorderEntries, removeEntry,
} = require("../controllers/rankingsController");

router.use(auth);

router.get("/", getLists);
router.post("/", createList);
router.get("/:id", getList);
router.put("/:id", updateList);
router.delete("/:id", deleteList);
router.post("/:id/entries", addEntry);
router.put("/:id/entries", reorderEntries);
router.delete("/:id/entries/:tmdbId", removeEntry);

module.exports = router;
