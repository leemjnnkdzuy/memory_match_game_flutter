const express = require("express");
const userRoutes = require("../routes/userRoutes");
const historyRoutes = require("../routes/historyRoutes");
const battleRoyaleRoutes = require("../routes/battleRoyaleRoutes");

const router = express.Router();

router.use("/users", userRoutes);
router.use("/history", historyRoutes);
router.use("/battle-royale", battleRoyaleRoutes);

module.exports = router;
