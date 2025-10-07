const express = require("express");
const userRoutes = require("../routes/userRoutes");
const offlineHistoryRoutes = require("../routes/offlineHistoryRoutes");

const router = express.Router();

router.use("/users", userRoutes);
router.use("/history-offline-game", offlineHistoryRoutes);

module.exports = router;
