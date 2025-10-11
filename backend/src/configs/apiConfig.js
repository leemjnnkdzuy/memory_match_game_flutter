const express = require("express");
const userRoutes = require("../routes/userRoutes");
const historyRoutes = require("../routes/historyRoutes");

const router = express.Router();

router.use("/users", userRoutes);
router.use("/history", historyRoutes);

module.exports = router;
