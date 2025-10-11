const express = require("express");
const router = express.Router();
const {authenticate} = require("../middlewares/authMiddleware");
const {
	saveOfflineHistory,
	getHistory,
	getHistories,
} = require("../controllers/historyController");

router.use(authenticate);

router.post("/save-offline-history", saveOfflineHistory);
router.get("/get-history/:id", getHistory);
router.get("/get-histories", getHistories);

module.exports = router;
