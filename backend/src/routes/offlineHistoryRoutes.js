const express = require("express");
const router = express.Router();
const {authenticate} = require("../middlewares/authMiddleware");
const {
	saveOfflineHistory,
	getOfflineHistory,
	getOfflineHistorys,
} = require("../controllers/offlineHistoryController");

router.use(authenticate);

router.post("/save-offline-history", saveOfflineHistory);
router.get("/get-offline-history/:id", getOfflineHistory);
router.get("/get-offline-histories", getOfflineHistorys);

module.exports = router;
