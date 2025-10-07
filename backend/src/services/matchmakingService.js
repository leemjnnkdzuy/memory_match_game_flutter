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
