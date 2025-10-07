# Backend Implementation - Solo Duel Mode

## Tổng quan

Tính năng Solo Duel cho phép hai người chơi thi đấu real-time với nhau trong một trận đấu lật thẻ. Hệ thống sử dụng **WebSocket** để đảm bảo giao tiếp real-time giữa client và server.

---

## Kiến trúc Backend

### Cấu trúc thư mục

```
src/
├── configs/
│   ├── apiConfig.js          # Cấu hình API endpoints
│   ├── corsConfig.js          # Cấu hình CORS
│   └── webSocketConfig.js     # Cấu hình WebSocket (MỚI)
├── controllers/
│   ├── offlineHistoryController.js
│   ├── soloDuelHistoryController.js  # Controller lịch sử Solo Duel
│   ├── soloDuelController.js         # Controller WebSocket Solo Duel (MỚI)
│   └── userController.js
├── middlewares/
│   ├── authMiddleware.js
│   ├── errorHandlerMiddleware.js
│   └── websocketAuthMiddleware.js    # Middleware xác thực WebSocket (MỚI)
├── models/
│   ├── offlineHistoryModel.js
│   ├── soloDuelHistoryModel.js       # Model lịch sử Solo Duel
│   ├── soloDuelMatchModel.js         # Model trận đấu Solo Duel (MỚI)
│   └── userModel.js
├── routes/
│   ├── offlineHistoryRoutes.js
│   ├── soloDuelHistoryRoutes.js
│   └── userRoutes.js
├── services/
│   ├── matchmakingService.js         # Service ghép trận (MỚI)
│   └── gameStateService.js           # Service quản lý trạng thái game (MỚI)
└── utils/
    ├── connectDatabase.js
    ├── errors.js
    ├── jwtService.js
    └── pokemonUtils.js               # Utility chọn Pokemon ngẫu nhiên (MỚI)
```

---

## 1. WebSocket Configuration

### File: `src/configs/websocketConfig.js`

```javascript
const socketIo = require("socket.io");
const {verifyAccessToken} = require("../utils/jwtService");

let io;

const initializeWebSocket = (server) => {
	io = socketIo(server, {
		cors: {
			origin: process.env.CLIENT_URL || "http://localhost:3000",
			methods: ["GET", "POST"],
			credentials: true,
		},
		transports: ["websocket", "polling"],
	});

	// Middleware xác thực
	io.use(async (socket, next) => {
		try {
			const token = socket.handshake.auth.token;
			if (!token) {
				return next(new Error("Authentication error"));
			}

			const decoded = verifyAccessToken(token);
			socket.userId = decoded.userId;
			socket.username = decoded.username;
			next();
		} catch (error) {
			next(new Error("Authentication error"));
		}
	});

	return io;
};

const getIO = () => {
	if (!io) {
		throw new Error("Socket.io not initialized");
	}
	return io;
};

module.exports = {initializeWebSocket, getIO};
```

---

## 2. Models

### File: `src/models/soloDuelMatchModel.js`

```javascript
const mongoose = require("mongoose");

const cardSchema = new mongoose.Schema({
	pokemonId: {type: Number, required: true},
	pokemonName: {type: String, required: true},
	isMatched: {type: Boolean, default: false},
	matchedBy: {type: String, default: null}, // userId của người match
});

const playerSchema = new mongoose.Schema({
	userId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	username: {type: String, required: true},
	score: {type: Number, default: 0},
	matchedCards: {type: Number, default: 0},
	isReady: {type: Boolean, default: false},
	lastPickTime: {type: Date, default: null},
});

const soloDuelMatchSchema = new mongoose.Schema({
	matchId: {type: String, required: true, unique: true},
	status: {
		type: String,
		enum: ["waiting", "ready", "playing", "completed", "cancelled"],
		default: "waiting",
	},
	players: [playerSchema],
	cards: [cardSchema], // 12 cặp thẻ (24 thẻ)
	currentTurn: {type: String, default: null}, // userId của người đang chơi
	flippedCards: [
		{
			cardIndex: Number,
			flippedBy: String,
			flippedAt: Date,
		},
	],
	winner: {type: mongoose.Schema.Types.ObjectId, ref: "User", default: null},
	startedAt: {type: Date, default: null},
	finishedAt: {type: Date, default: null},
	createdAt: {type: Date, default: Date.now},
	updatedAt: {type: Date, default: Date.now},
});

soloDuelMatchSchema.index({matchId: 1});
soloDuelMatchSchema.index({"players.userId": 1});
soloDuelMatchSchema.index({status: 1});

module.exports = mongoose.model("SoloDuelMatch", soloDuelMatchSchema);
```

### File: `src/models/soloDuelHistoryModel.js`

```javascript
const mongoose = require("mongoose");

const soloDuelHistorySchema = new mongoose.Schema({
	matchId: {type: String, required: true},
	userId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	opponentId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},
	score: {type: Number, required: true},
	opponentScore: {type: Number, required: true},
	matchedCards: {type: Number, required: true},
	isWin: {type: Boolean, required: true},
	gameTime: {type: Number, required: true}, // Thời gian chơi (giây)
	datePlayed: {type: Date, default: Date.now},
	createdAt: {type: Date, default: Date.now},
	updatedAt: {type: Date, default: Date.now},
});

soloDuelHistorySchema.index({userId: 1, datePlayed: -1});
soloDuelHistorySchema.index({matchId: 1});

module.exports = mongoose.model("SoloDuelHistory", soloDuelHistorySchema);
```

---

## 3. Utilities

### File: `src/utils/pokemonUtils.js`

```javascript
// Danh sách tất cả Pokemon (151 Pokemon)
const POKEMON_LIST = [
	{id: 1, name: "Abra"},
	{id: 2, name: "Aerodactyl"},
	{id: 3, name: "Alakazam"},
	{id: 4, name: "Arbok"},
	{id: 5, name: "Arcanine"},
	{id: 6, name: "Articuno"},
	{id: 7, name: "Beedrill"},
	{id: 8, name: "Bellsprout"},
	{id: 9, name: "Blastoise"},
	{id: 10, name: "Bulbasaur"},
	// ... thêm tất cả 151 Pokemon
];

/**
 * Chọn ngẫu nhiên n Pokemon từ danh sách
 */
const getRandomPokemon = (count = 12) => {
	const shuffled = [...POKEMON_LIST].sort(() => 0.5 - Math.random());
	return shuffled.slice(0, count);
};

/**
 * Tạo cards cho game (mỗi Pokemon có 2 thẻ)
 */
const generateGameCards = (pokemonList) => {
	const cards = [];
	pokemonList.forEach((pokemon) => {
		cards.push({
			pokemonId: pokemon.id,
			pokemonName: pokemon.name,
			isMatched: false,
			matchedBy: null,
		});
		cards.push({
			pokemonId: pokemon.id,
			pokemonName: pokemon.name,
			isMatched: false,
			matchedBy: null,
		});
	});

	// Shuffle cards
	return cards.sort(() => 0.5 - Math.random());
};

module.exports = {getRandomPokemon, generateGameCards, POKEMON_LIST};
```

---

## 4. Services

### File: `src/services/matchmakingService.js`

```javascript
const SoloDuelMatch = require("../models/soloDuelMatchModel");
const {v4: uuidv4} = require("uuid");
const {getRandomPokemon, generateGameCards} = require("../utils/pokemonUtils");

class MatchmakingService {
	constructor() {
		this.waitingQueue = []; // Hàng đợi người chơi
	}

	/**
	 * Thêm người chơi vào hàng đợi
	 */
	async addToQueue(userId, username, socketId) {
		// Kiểm tra xem người chơi đã trong hàng đợi chưa
		const existingIndex = this.waitingQueue.findIndex(
			(p) => p.userId === userId
		);
		if (existingIndex !== -1) {
			this.waitingQueue[existingIndex].socketId = socketId;
			return null;
		}

		// Thêm vào hàng đợi
		this.waitingQueue.push({
			userId,
			username,
			socketId,
			joinedAt: Date.now(),
		});

		// Nếu có ít nhất 2 người, ghép trận
		if (this.waitingQueue.length >= 2) {
			return await this.createMatch();
		}

		return null;
	}

	/**
	 * Xóa người chơi khỏi hàng đợi
	 */
	removeFromQueue(userId) {
		const index = this.waitingQueue.findIndex((p) => p.userId === userId);
		if (index !== -1) {
			this.waitingQueue.splice(index, 1);
			return true;
		}
		return false;
	}

	/**
	 * Tạo trận đấu mới
	 */
	async createMatch() {
		if (this.waitingQueue.length < 2) {
			return null;
		}

		// Lấy 2 người chơi đầu tiên
		const player1 = this.waitingQueue.shift();
		const player2 = this.waitingQueue.shift();

		// Random 12 Pokemon
		const randomPokemon = getRandomPokemon(12);
		const cards = generateGameCards(randomPokemon);

		// Tạo match trong database
		const match = new SoloDuelMatch({
			matchId: uuidv4(),
			status: "ready",
			players: [
				{
					userId: player1.userId,
					username: player1.username,
					score: 0,
					matchedCards: 0,
					isReady: false,
				},
				{
					userId: player2.userId,
					username: player2.username,
					score: 0,
					matchedCards: 0,
					isReady: false,
				},
			],
			cards: cards,
			currentTurn: player1.userId, // Player 1 đi trước
			createdAt: new Date(),
		});

		await match.save();

		return {
			match,
			player1: {...player1},
			player2: {...player2},
		};
	}

	/**
	 * Lấy thông tin hàng đợi
	 */
	getQueueInfo() {
		return {
			queueLength: this.waitingQueue.length,
			players: this.waitingQueue.map((p) => ({
				userId: p.userId,
				username: p.username,
				waitingTime: Date.now() - p.joinedAt,
			})),
		};
	}
}

module.exports = new MatchmakingService();
```

### File: `src/services/gameStateService.js`

```javascript
const SoloDuelMatch = require("../models/soloDuelMatchModel");

class GameStateService {
	/**
	 * Xử lý lật thẻ
	 */
	async handleCardFlip(matchId, userId, cardIndex) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new Error("Match not found");
		}

		if (match.status !== "playing") {
			throw new Error("Match is not in playing state");
		}

		if (match.currentTurn !== userId) {
			throw new Error("Not your turn");
		}

		const card = match.cards[cardIndex];
		if (card.isMatched) {
			throw new Error("Card already matched");
		}

		// Kiểm tra số thẻ đã lật trong turn này
		const currentTurnFlips = match.flippedCards.filter(
			(fc) =>
				fc.flippedBy === userId && !match.cards[fc.cardIndex].isMatched
		);

		if (currentTurnFlips.length >= 2) {
			throw new Error("Already flipped 2 cards this turn");
		}

		// Thêm thẻ vào danh sách đã lật
		match.flippedCards.push({
			cardIndex,
			flippedBy: userId,
			flippedAt: new Date(),
		});

		// Nếu đã lật 2 thẻ, kiểm tra match
		if (currentTurnFlips.length === 1) {
			const firstCardIndex = currentTurnFlips[0].cardIndex;
			const firstCard = match.cards[firstCardIndex];
			const secondCard = match.cards[cardIndex];

			if (firstCard.pokemonId === secondCard.pokemonId) {
				// Match thành công
				match.cards[firstCardIndex].isMatched = true;
				match.cards[firstCardIndex].matchedBy = userId;
				match.cards[cardIndex].isMatched = true;
				match.cards[cardIndex].matchedBy = userId;

				// Cập nhật điểm
				const player = match.players.find(
					(p) => p.userId.toString() === userId
				);
				player.score += 100;
				player.matchedCards += 1;
				player.lastPickTime = new Date();

				// Kiểm tra kết thúc game
				const allMatched = match.cards.every((c) => c.isMatched);
				if (allMatched) {
					match.status = "completed";
					match.finishedAt = new Date();

					// Xác định người thắng
					const player1 = match.players[0];
					const player2 = match.players[1];
					match.winner =
						player1.score > player2.score
							? player1.userId
							: player2.userId;
				}
			} else {
				// Không match, chuyển lượt
				match.currentTurn = match.players
					.find((p) => p.userId.toString() !== userId)
					.userId.toString();
			}
		}

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	/**
	 * Đánh dấu người chơi sẵn sàng
	 */
	async setPlayerReady(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new Error("Match not found");
		}

		const player = match.players.find(
			(p) => p.userId.toString() === userId
		);
		if (!player) {
			throw new Error("Player not found in match");
		}

		player.isReady = true;

		// Nếu cả 2 người đã sẵn sàng, bắt đầu game
		if (match.players.every((p) => p.isReady)) {
			match.status = "playing";
			match.startedAt = new Date();
		}

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	/**
	 * Lấy trạng thái trận đấu
	 */
	async getMatchState(matchId) {
		return await SoloDuelMatch.findOne({matchId})
			.populate("players.userId", "username avatar")
			.populate("winner", "username avatar");
	}

	/**
	 * Hủy trận đấu
	 */
	async cancelMatch(matchId, reason = "Player disconnected") {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new Error("Match not found");
		}

		match.status = "cancelled";
		match.finishedAt = new Date();
		await match.save();

		return match;
	}
}

module.exports = new GameStateService();
```

---

## 5. Controllers

### File: `src/controllers/soloDuelController.js`

```javascript
const {getIO} = require("../configs/websocketConfig");
const matchmakingService = require("../services/matchmakingService");
const gameStateService = require("../services/gameStateService");
const SoloDuelHistory = require("../models/soloDuelHistoryModel");

class SoloDuelController {
	/**
	 * Khởi tạo WebSocket handlers
	 */
	initializeSocketHandlers(io) {
		io.on("connection", (socket) => {
			console.log(
				`User connected: ${socket.username} (${socket.userId})`
			);

			// Join matchmaking queue
			socket.on("solo_duel:join_queue", async () => {
				try {
					const result = await matchmakingService.addToQueue(
						socket.userId,
						socket.username,
						socket.id
					);

					if (result) {
						// Match found!
						const {match, player1, player2} = result;

						// Emit to both players
						io.to(player1.socketId).emit("solo_duel:match_found", {
							matchId: match.matchId,
							opponent: {
								userId: player2.userId,
								username: player2.username,
							},
							pokemon: match.cards.map((c) => ({
								pokemonId: c.pokemonId,
								pokemonName: c.pokemonName,
							})),
							isFirstPlayer: true,
						});

						io.to(player2.socketId).emit("solo_duel:match_found", {
							matchId: match.matchId,
							opponent: {
								userId: player1.userId,
								username: player1.username,
							},
							pokemon: match.cards.map((c) => ({
								pokemonId: c.pokemonId,
								pokemonName: c.pokemonName,
							})),
							isFirstPlayer: false,
						});
					} else {
						// Added to queue
						socket.emit("solo_duel:queue_joined", {
							position:
								matchmakingService.getQueueInfo().queueLength,
						});
					}
				} catch (error) {
					socket.emit("solo_duel:error", {message: error.message});
				}
			});

			// Leave queue
			socket.on("solo_duel:leave_queue", () => {
				matchmakingService.removeFromQueue(socket.userId);
				socket.emit("solo_duel:queue_left");
			});

			// Player ready
			socket.on("solo_duel:player_ready", async ({matchId}) => {
				try {
					const match = await gameStateService.setPlayerReady(
						matchId,
						socket.userId
					);

					// Broadcast to room
					io.to(matchId).emit("solo_duel:player_ready", {
						userId: socket.userId,
						username: socket.username,
					});

					// If game started
					if (match.status === "playing") {
						io.to(matchId).emit("solo_duel:game_started", {
							currentTurn: match.currentTurn,
							startedAt: match.startedAt,
						});
					}
				} catch (error) {
					socket.emit("solo_duel:error", {message: error.message});
				}
			});

			// Join match room
			socket.on("solo_duel:join_match", ({matchId}) => {
				socket.join(matchId);
				socket.matchId = matchId;
			});

			// Flip card
			socket.on("solo_duel:flip_card", async ({matchId, cardIndex}) => {
				try {
					const match = await gameStateService.handleCardFlip(
						matchId,
						socket.userId,
						cardIndex
					);

					// Broadcast to room
					io.to(matchId).emit("solo_duel:card_flipped", {
						cardIndex,
						flippedBy: socket.userId,
						pokemonId: match.cards[cardIndex].pokemonId,
						pokemonName: match.cards[cardIndex].pokemonName,
					});

					// Check for match result
					const flippedCount = match.flippedCards.filter(
						(fc) =>
							fc.flippedBy === socket.userId &&
							!match.cards[fc.cardIndex].isMatched
					).length;

					if (flippedCount === 2) {
						const lastTwo = match.flippedCards.slice(-2);
						const card1 = match.cards[lastTwo[0].cardIndex];
						const card2 = match.cards[lastTwo[1].cardIndex];
						const isMatch = card1.pokemonId === card2.pokemonId;

						io.to(matchId).emit("solo_duel:match_result", {
							isMatch,
							cardIndices: [
								lastTwo[0].cardIndex,
								lastTwo[1].cardIndex,
							],
							matchedBy: isMatch ? socket.userId : null,
							nextTurn: match.currentTurn,
							players: match.players.map((p) => ({
								userId: p.userId,
								score: p.score,
								matchedCards: p.matchedCards,
							})),
						});

						// Check game over
						if (match.status === "completed") {
							await this.saveMatchHistory(match);

							io.to(matchId).emit("solo_duel:game_over", {
								winner: match.winner,
								players: match.players.map((p) => ({
									userId: p.userId,
									username: p.username,
									score: p.score,
									matchedCards: p.matchedCards,
								})),
								gameTime: Math.floor(
									(match.finishedAt - match.startedAt) / 1000
								),
							});
						}
					}
				} catch (error) {
					socket.emit("solo_duel:error", {message: error.message});
				}
			});

			// Disconnect
			socket.on("disconnect", () => {
				console.log(`User disconnected: ${socket.username}`);
				matchmakingService.removeFromQueue(socket.userId);

				if (socket.matchId) {
					io.to(socket.matchId).emit(
						"solo_duel:player_disconnected",
						{
							userId: socket.userId,
							username: socket.username,
						}
					);
				}
			});
		});
	}

	/**
	 * Lưu lịch sử trận đấu
	 */
	async saveMatchHistory(match) {
		const gameTime = Math.floor(
			(match.finishedAt - match.startedAt) / 1000
		);
		const player1 = match.players[0];
		const player2 = match.players[1];

		const history1 = new SoloDuelHistory({
			matchId: match.matchId,
			userId: player1.userId,
			opponentId: player2.userId,
			score: player1.score,
			opponentScore: player2.score,
			matchedCards: player1.matchedCards,
			isWin: player1.score > player2.score,
			gameTime,
			datePlayed: match.finishedAt,
		});

		const history2 = new SoloDuelHistory({
			matchId: match.matchId,
			userId: player2.userId,
			opponentId: player1.userId,
			score: player2.score,
			opponentScore: player1.score,
			matchedCards: player2.matchedCards,
			isWin: player2.score > player1.score,
			gameTime,
			datePlayed: match.finishedAt,
		});

		await Promise.all([history1.save(), history2.save()]);
	}
}

module.exports = new SoloDuelController();
```

### File: `src/controllers/soloDuelHistoryController.js`

```javascript
const SoloDuelHistory = require("../models/soloDuelHistoryModel");

/**
 * Lấy lịch sử Solo Duel của user
 */
exports.getSoloDuelHistories = async (req, res, next) => {
	try {
		const userId = req.user._id;
		const {
			page = 1,
			limit = 10,
			isWin,
			sortBy = "datePlayed",
			order = "desc",
		} = req.query;

		const query = {userId};
		if (isWin !== undefined) {
			query.isWin = isWin === "true";
		}

		const skip = (page - 1) * limit;
		const sortOrder = order === "asc" ? 1 : -1;

		const [histories, total] = await Promise.all([
			SoloDuelHistory.find(query)
				.populate("opponentId", "username avatar")
				.sort({[sortBy]: sortOrder})
				.skip(skip)
				.limit(parseInt(limit)),
			SoloDuelHistory.countDocuments(query),
		]);

		res.json({
			success: true,
			message: "Lấy lịch sử thành công",
			data: {
				histories,
				pagination: {
					total,
					page: parseInt(page),
					limit: parseInt(limit),
					totalPages: Math.ceil(total / limit),
					hasNextPage: page * limit < total,
					hasPrevPage: page > 1,
				},
			},
		});
	} catch (error) {
		next(error);
	}
};

/**
 * Lấy chi tiết một trận đấu
 */
exports.getSoloDuelHistory = async (req, res, next) => {
	try {
		const {id} = req.params;
		const userId = req.user._id;

		const history = await SoloDuelHistory.findOne({
			_id: id,
			userId,
		}).populate("opponentId", "username avatar");

		if (!history) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy lịch sử",
			});
		}

		res.json({
			success: true,
			message: "Lấy lịch sử thành công",
			data: {history},
		});
	} catch (error) {
		next(error);
	}
};
```

---

## 6. Routes

### File: `src/routes/soloDuelHistoryRoutes.js`

```javascript
const express = require("express");
const router = express.Router();
const {authMiddleware} = require("../middlewares/authMiddleware");
const soloDuelHistoryController = require("../controllers/soloDuelHistoryController");

// Lấy danh sách lịch sử
router.get(
	"/get-solo-duel-histories",
	authMiddleware,
	soloDuelHistoryController.getSoloDuelHistories
);

// Lấy chi tiết một trận
router.get(
	"/get-solo-duel-history/:id",
	authMiddleware,
	soloDuelHistoryController.getSoloDuelHistory
);

module.exports = router;
```

---

## 7. App.js Integration

### File: `app.js`

```javascript
const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const {initializeWebSocket} = require("./src/configs/websocketConfig");
const soloDuelController = require("./src/controllers/soloDuelController");

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/users", require("./src/routes/userRoutes"));
app.use(
	"/api/history-offline-game",
	require("./src/routes/offlineHistoryRoutes")
);
app.use(
	"/api/history-solo-duel",
	require("./src/routes/soloDuelHistoryRoutes")
);

// Initialize WebSocket
const io = initializeWebSocket(server);
soloDuelController.initializeSocketHandlers(io);

// Database connection
mongoose
	.connect(process.env.MONGODB_URI)
	.then(() => console.log("MongoDB connected"))
	.catch((err) => console.error("MongoDB connection error:", err));

// Start server
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
	console.log(`Server is running on port ${PORT}`);
});

module.exports = {app, server};
```

---

## 8. WebSocket Events Protocol

### Client → Server Events

| Event                    | Payload                  | Mô tả                       |
| ------------------------ | ------------------------ | --------------------------- |
| `solo_duel:join_queue`   | -                        | Tham gia hàng đợi ghép trận |
| `solo_duel:leave_queue`  | -                        | Rời hàng đợi                |
| `solo_duel:join_match`   | `{ matchId }`            | Tham gia phòng match        |
| `solo_duel:player_ready` | `{ matchId }`            | Sẵn sàng chơi               |
| `solo_duel:flip_card`    | `{ matchId, cardIndex }` | Lật thẻ                     |

### Server → Client Events

| Event                           | Payload                                                  | Mô tả                 |
| ------------------------------- | -------------------------------------------------------- | --------------------- |
| `solo_duel:queue_joined`        | `{ position }`                                           | Đã vào hàng đợi       |
| `solo_duel:match_found`         | `{ matchId, opponent, pokemon, isFirstPlayer }`          | Tìm thấy trận đấu     |
| `solo_duel:player_ready`        | `{ userId, username }`                                   | Người chơi sẵn sàng   |
| `solo_duel:game_started`        | `{ currentTurn, startedAt }`                             | Game bắt đầu          |
| `solo_duel:card_flipped`        | `{ cardIndex, flippedBy, pokemonId, pokemonName }`       | Thẻ được lật          |
| `solo_duel:match_result`        | `{ isMatch, cardIndices, matchedBy, nextTurn, players }` | Kết quả match         |
| `solo_duel:game_over`           | `{ winner, players, gameTime }`                          | Game kết thúc         |
| `solo_duel:player_disconnected` | `{ userId, username }`                                   | Người chơi disconnect |
| `solo_duel:error`               | `{ message }`                                            | Lỗi xảy ra            |

---

## 9. Package.json Dependencies

```json
{
	"dependencies": {
		"express": "^4.18.2",
		"socket.io": "^4.6.1",
		"mongoose": "^8.0.0",
		"jsonwebtoken": "^9.0.2",
		"bcrypt": "^5.1.1",
		"cors": "^2.8.5",
		"dotenv": "^16.3.1",
		"uuid": "^9.0.1"
	}
}
```

---

## 10. Environment Variables

```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/memory_match_game
JWT_SECRET=your_jwt_secret_key
JWT_REFRESH_SECRET=your_jwt_refresh_secret_key
CLIENT_URL=http://localhost:3000
```

---

## Tổng kết

Backend Solo Duel được thiết kế với:

1. **WebSocket real-time** cho giao tiếp tức thời
2. **Matchmaking service** tự động ghép trận
3. **Game state management** quản lý trạng thái game
4. **History tracking** lưu lịch sử chi tiết
5. **Scalable architecture** dễ mở rộng

Cấu trúc code tuân thủ **Clean Architecture** và **SOLID principles** giống với phần Offline History hiện có.
