const {getIO} = require("../configs/webSocketConfig");
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
