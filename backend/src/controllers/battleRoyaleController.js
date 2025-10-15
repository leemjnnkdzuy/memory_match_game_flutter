const BattleRoyaleRoom = require("../models/battleRoyaleRoomModel");
const BattleRoyaleMatch = require("../models/battleRoyaleMatchModel");
const {generatePokemonCards} = require("../utils/pokemonUtils");
const {emitToRoom} = require("./battleRoyaleWebSocketController");
const crypto = require("crypto");

function generateRoomCode() {
	return crypto.randomBytes(4).toString("hex").toUpperCase();
}

const createRoom = async (req, res) => {
	try {
		const userId = req.user._id;
		const username = req.user.username;

		const {
			name,
			password,
			maxPlayers = 8,
			pairCount = 8,
			softCapTime = 120,
			hardCapTime,
			seed,
			region = "auto",
		} = req.body;

		if (!name || name.trim() === "") {
			return res.status(400).json({
				success: false,
				message: "Room name is required",
			});
		}

		if (maxPlayers < 2 || maxPlayers > 8) {
			return res.status(400).json({
				success: false,
				message: "Max players must be between 2 and 8",
			});
		}

		let code;
		let isUnique = false;
		while (!isUnique) {
			code = generateRoomCode();
			const existing = await BattleRoyaleRoom.findOne({code});
			if (!existing) isUnique = true;
		}

		const room = new BattleRoyaleRoom({
			code,
			name: name.trim(),
			password: password || null,
			maxPlayers,
			pairCount,
			softCapTime,
			hardCapTime,
			seed: seed || crypto.randomBytes(16).toString("hex"),
			region,
			hostId: userId,
			players: [
				{
					userId,
					username,
					isHost: true,
					isReady: false,
					isConnected: true,
				},
			],
		});

		await room.save();

		return res.status(201).json({
			success: true,
			message: "Room created successfully",
			data: room,
		});
	} catch (error) {
		console.error("Error creating room:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to create room",
			error: error.message,
		});
	}
};

const getPublicRooms = async (req, res) => {
	try {
		const {minPlayers, maxPlayers, maxPing} = req.query;

		const query = {
			status: "waiting",
			password: null,
		};

		if (minPlayers) {
			query.currentPlayers = {$gte: parseInt(minPlayers)};
		}

		const rooms = await BattleRoyaleRoom.find(query)
			.sort({createdAt: -1})
			.limit(50)
			.select("-players.socketId")
			.lean();

		let filteredRooms = rooms;
		if (maxPlayers) {
			filteredRooms = rooms.filter(
				(room) => room.currentPlayers <= parseInt(maxPlayers)
			);
		}

		return res.status(200).json({
			success: true,
			data: {rooms: filteredRooms},
		});
	} catch (error) {
		console.error("Error getting rooms:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to get rooms",
			error: error.message,
		});
	}
};

const joinRoom = async (req, res) => {
	try {
		const {roomId} = req.params;
		const {password} = req.body;
		const userId = req.user._id;
		const username = req.user.username;

		const room = await BattleRoyaleRoom.findById(roomId);

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		if (room.status !== "waiting") {
			return res.status(400).json({
				success: false,
				message: "Room is not accepting new players",
			});
		}

		if (room.isFull()) {
			return res.status(400).json({
				success: false,
				message: "Room is full",
			});
		}

		if (room.password && room.password !== password) {
			return res.status(401).json({
				success: false,
				message: "Incorrect password",
			});
		}

		const existingPlayer = room.getPlayer(userId);
		if (!existingPlayer) {
			room.players.push({
				userId,
				username,
				isHost: false,
				isReady: false,
				isConnected: true,
			});
		} else {
			existingPlayer.isConnected = true;
			existingPlayer.disconnectedAt = null;
		}

		await room.save();

		// Thông báo cho tất cả người chơi trong phòng về người chơi mới
		emitToRoom(roomId, "br:player_joined", {
			player: {
				userId,
				username,
				isHost: false,
			},
			players: room.players,
		});

		return res.status(200).json({
			success: true,
			message: "Joined room successfully",
			data: room,
		});
	} catch (error) {
		console.error("Error joining room:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to join room",
			error: error.message,
		});
	}
};

const setReady = async (req, res) => {
	try {
		const {roomId} = req.params;
		const {ready} = req.body;
		const userId = req.user._id;

		const room = await BattleRoyaleRoom.findById(roomId);

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		const player = room.getPlayer(userId);
		if (!player) {
			return res.status(404).json({
				success: false,
				message: "Player not in room",
			});
		}

		player.isReady = ready;
		await room.save();

		// Thông báo cho tất cả người chơi trong phòng
		emitToRoom(roomId, "br:player_ready", {
			userId: player.userId,
			isReady: player.isReady,
			players: room.players,
		});

		return res.status(200).json({
			success: true,
			message: "Ready status updated",
			data: {ready: player.isReady},
		});
	} catch (error) {
		console.error("Error setting ready:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to set ready status",
			error: error.message,
		});
	}
};

const kickPlayer = async (req, res) => {
	try {
		const {roomId} = req.params;
		const {playerId} = req.body;
		const userId = req.user._id;

		const room = await BattleRoyaleRoom.findById(roomId);

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		if (room.hostId.toString() !== userId.toString()) {
			return res.status(403).json({
				success: false,
				message: "Only host can kick players",
			});
		}

		room.removePlayer(playerId);
		await room.save();

		// Thông báo cho tất cả người chơi trong phòng
		emitToRoom(roomId, "br:player_left", {
			userId: playerId,
			players: room.players,
		});

		return res.status(200).json({
			success: true,
			message: "Player kicked",
		});
	} catch (error) {
		console.error("Error kicking player:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to kick player",
			error: error.message,
		});
	}
};

const startMatch = async (req, res) => {
	try {
		const {roomId} = req.params;
		const userId = req.user._id;

		const room = await BattleRoyaleRoom.findById(roomId);

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		if (room.hostId.toString() !== userId.toString()) {
			return res.status(403).json({
				success: false,
				message: "Only host can start match",
			});
		}

		if (!room.canStart()) {
			return res.status(400).json({
				success: false,
				message: "Not enough ready players to start",
			});
		}

		const cards = generatePokemonCards(room.pairCount, room.seed);

		const match = new BattleRoyaleMatch({
			roomId: room._id,
			seed: room.seed,
			cards: cards.map((card, index) => ({
				pokemonId: card.id,
				pokemonName: card.name,
				position: index,
			})),
			players: room.players.map((p) => ({
				userId: p.userId,
				username: p.username,
			})),
			status: "starting",
		});

		await match.save();

		room.status = "starting";
		room.matchId = match._id;
		room.startedAt = new Date();
		await room.save();

		return res.status(200).json({
			success: true,
			message: "Match starting",
			data: {
				matchId: match._id,
				seed: match.seed,
				cards: match.cards,
			},
		});
	} catch (error) {
		console.error("Error starting match:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to start match",
			error: error.message,
		});
	}
};

const getRoomDetails = async (req, res) => {
	try {
		const {roomId} = req.params;

		const room = await BattleRoyaleRoom.findById(roomId)
			.select("-players.socketId")
			.lean();

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		return res.status(200).json({
			success: true,
			data: room,
		});
	} catch (error) {
		console.error("Error getting room details:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to get room details",
			error: error.message,
		});
	}
};

const getMatchLeaderboard = async (req, res) => {
	try {
		const {matchId} = req.params;

		const match = await BattleRoyaleMatch.findById(matchId).lean();

		if (!match) {
			return res.status(404).json({
				success: false,
				message: "Match not found",
			});
		}

		const matchDoc = await BattleRoyaleMatch.findById(matchId);
		const leaderboard = matchDoc.calculateRankings();

		return res.status(200).json({
			success: true,
			data: {
				leaderboard,
				status: match.status,
			},
		});
	} catch (error) {
		console.error("Error getting leaderboard:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to get leaderboard",
			error: error.message,
		});
	}
};

const closeRoom = async (req, res) => {
	try {
		const {roomId} = req.params;
		const userId = req.user._id;

		const room = await BattleRoyaleRoom.findById(roomId);

		if (!room) {
			return res.status(404).json({
				success: false,
				message: "Room not found",
			});
		}

		if (room.hostId.toString() !== userId.toString()) {
			return res.status(403).json({
				success: false,
				message: "Only host can close the room",
			});
		}

		// Nếu có match đang diễn ra, xóa luôn match
		if (room.matchId) {
			await BattleRoyaleMatch.findByIdAndDelete(room.matchId);
		}

		// Xóa phòng
		await BattleRoyaleRoom.findByIdAndDelete(roomId);

		return res.status(200).json({
			success: true,
			message: "Room closed successfully",
		});
	} catch (error) {
		console.error("Error closing room:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to close room",
			error: error.message,
		});
	}
};

module.exports = {
	createRoom,
	getPublicRooms,
	joinRoom,
	setReady,
	kickPlayer,
	startMatch,
	getRoomDetails,
	getMatchLeaderboard,
	closeRoom,
};
