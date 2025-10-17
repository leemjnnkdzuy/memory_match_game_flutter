const express = require("express");
const router = express.Router();
const {
	createRoom,
	getPublicRooms,
	getRoomByCode,
	joinRoom,
	setReady,
	kickPlayer,
	startMatch,
	getRoomDetails,
	getMatchLeaderboard,
	closeRoom,
} = require("../controllers/battleRoyaleController");
const {authenticate} = require("../middlewares/authMiddleware");

router.use(authenticate);

router.post("/rooms", createRoom);
router.get("/rooms", getPublicRooms);
router.get("/rooms/code/:code", getRoomByCode);
router.get("/rooms/:roomId", getRoomDetails);
router.post("/rooms/:roomId/join", joinRoom);
router.post("/rooms/:roomId/ready", setReady);
router.post("/rooms/:roomId/kick", kickPlayer);
router.post("/rooms/:roomId/start", startMatch);
router.delete("/rooms/:roomId", closeRoom);

router.get("/matches/:matchId/leaderboard", getMatchLeaderboard);

module.exports = router;
