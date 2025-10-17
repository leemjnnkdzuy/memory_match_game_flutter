const SoloDuelMatch = require("../models/soloDuelMatchModel");
const {v4: uuidv4} = require("uuid");
const {getRandomPokemon, generateGameCards} = require("../utils/pokemonUtils");

class MatchmakingService {
	constructor() {
		this.waitingQueue = [];
	}

	async addToQueue(userId, username, socketId) {
		const existingIndex = this.waitingQueue.findIndex(
			(p) => p.userId === userId
		);
		if (existingIndex !== -1) {
			this.waitingQueue[existingIndex].socketId = socketId;
			return null;
		}

		this.waitingQueue.push({
			userId,
			username,
			socketId,
			joinedAt: Date.now(),
		});

		if (this.waitingQueue.length >= 2) {
			return await this.createMatch();
		}

		return null;
	}

	removeFromQueue(userId) {
		const index = this.waitingQueue.findIndex((p) => p.userId === userId);
		if (index !== -1) {
			this.waitingQueue.splice(index, 1);
			return true;
		}
		return false;
	}

	async createMatch() {
		if (this.waitingQueue.length < 2) {
			return null;
		}

		const player1 = this.waitingQueue.shift();
		const player2 = this.waitingQueue.shift();

		const randomPokemon = getRandomPokemon(12);
		const cards = generateGameCards(randomPokemon);

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
			currentTurn: player1.userId,
			createdAt: new Date(),
		});

		await match.save();

		return {
			match,
			player1: {...player1},
			player2: {...player2},
		};
	}

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
