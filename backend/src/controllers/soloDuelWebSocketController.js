const matchmakingService = require("../services/matchmakingService");
const gameStateService = require("../services/gameStateService");
const {SoloDuelHistory} = require("../models/soloDuelHistoryModel");
const {User} = require("../models/userModel");

/**
 * Setup Solo Duel WebSocket handlers
 */
const setupSoloDuelHandlers = (io) => {
	io.on("connection", (socket) => {
		console.log(
			`🎮 Solo Duel: User ${socket.username} (${socket.userId}) connected`
		);

		// ==================== JOIN QUEUE ====================
		socket.on("solo_duel:join_queue", async () => {
			try {
				console.log(`📥 ${socket.username} joining queue...`);

				const result = await matchmakingService.addToQueue(
					socket.userId,
					socket.username,
					socket.id
				);

				if (result) {
					const {match, player1, player2} = result;

					const [player1User, player2User] = await Promise.all([
						User.findById(player1.userId).select("avatar username"),
						User.findById(player2.userId).select("avatar username"),
					]);

					const player1Socket = io.sockets.sockets.get(
						player1.socketId
					);
					const player2Socket = io.sockets.sockets.get(
						player2.socketId
					);

					if (player1Socket && player2Socket) {
						player1Socket.join(match.matchId);
						player2Socket.join(match.matchId);

						// Notify player 1
						player1Socket.emit("solo_duel:match_found", {
							matchId: match.matchId,
							player: {
								userId: player1.userId,
								username: player1User.username,
								avatar: player1User.avatar,
							},
							opponent: {
								userId: player2.userId,
								username: player2User.username,
								avatar: player2User.avatar,
							},
							pokemon: match.cards.map((card) => ({
								pokemonId: card.pokemonId,
								pokemonName: card.pokemonName,
							})),
							isFirstPlayer: true,
						});

						// Notify player 2
						player2Socket.emit("solo_duel:match_found", {
							matchId: match.matchId,
							player: {
								userId: player2.userId,
								username: player2User.username,
								avatar: player2User.avatar,
							},
							opponent: {
								userId: player1.userId,
								username: player1User.username,
								avatar: player1User.avatar,
							},
							pokemon: match.cards.map((card) => ({
								pokemonId: card.pokemonId,
								pokemonName: card.pokemonName,
							})),
							isFirstPlayer: false,
						});

						console.log(
							`✅ Match created: ${match.matchId}\n   Player 1: ${player1.username}\n   Player 2: ${player2.username}`
						);
					}
				} else {
					// Added to queue, waiting for opponent
					const queueInfo = matchmakingService.getQueueInfo();
					socket.emit("solo_duel:queue_joined", {
						position: queueInfo.queueLength,
						queueLength: queueInfo.queueLength,
					});
					console.log(
						`⏳ ${socket.username} added to queue (position: ${queueInfo.queueLength})`
					);
				}
			} catch (error) {
				console.error("❌ Error joining queue:", error);
				socket.emit("solo_duel:error", {
					message: "Failed to join queue",
					error: error.message,
				});
			}
		});

		// ==================== LEAVE QUEUE ====================
		socket.on("solo_duel:leave_queue", () => {
			try {
				const removed = matchmakingService.removeFromQueue(
					socket.userId
				);
				socket.emit("solo_duel:queue_left", {});
				console.log(
					`👋 ${socket.username} left queue ${
						removed ? "(removed)" : "(not in queue)"
					}`
				);
			} catch (error) {
				console.error("❌ Error leaving queue:", error);
			}
		});

		// ==================== PLAYER READY ====================
		socket.on("solo_duel:player_ready", async (data) => {
			try {
				const {matchId} = data;
				console.log(`✋ ${socket.username} ready for match ${matchId}`);

				const match = await gameStateService.setPlayerReady(
					matchId,
					socket.userId
				);

				// Notify all players in the match
				io.to(matchId).emit("solo_duel:player_ready", {
					userId: socket.userId,
					username: socket.username,
				});

				// If both players are ready, start the game
				if (match.status === "playing") {
					io.to(matchId).emit("solo_duel:game_started", {
						matchId: match.matchId,
						currentTurn: match.currentTurn,
						startedAt: match.startedAt.toISOString(),
						players: match.players.map((p) => ({
							userId: p.userId.toString(),
							username: p.username,
							score: p.score,
							matchedCards: p.matchedCards,
						})),
					});

					console.log(
						`🎮 Game started: ${matchId}\n   Current turn: ${match.currentTurn}`
					);
				}
			} catch (error) {
				console.error("❌ Error setting player ready:", error);
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to ready up",
				});
			}
		});

		// ==================== FLIP CARD ====================
		socket.on("solo_duel:flip_card", async (data) => {
			try {
				const {matchId, cardIndex} = data;
				console.log(
					`🃏 ${socket.username} flipping card ${cardIndex} in match ${matchId}`
				);

				const match = await gameStateService.handleCardFlip(
					matchId,
					socket.userId,
					cardIndex
				);

				// Notify all players about the card flip
				io.to(matchId).emit("solo_duel:card_flipped", {
					matchId,
					cardIndex,
					flippedBy: socket.userId,
					pokemonId: match.cards[cardIndex].pokemonId,
					pokemonName: match.cards[cardIndex].pokemonName,
				});

				// Get current turn flips (cards not yet matched)
				const currentTurnFlips = match.flippedCards.filter(
					(fc) =>
						fc.flippedBy === socket.userId &&
						!match.cards[fc.cardIndex].isMatched
				);

				// If 2 cards flipped, send match result after a delay
				if (currentTurnFlips.length === 2) {
					const firstCardIndex = currentTurnFlips[0].cardIndex;
					const secondCardIndex = currentTurnFlips[1].cardIndex;
					const firstCard = match.cards[firstCardIndex];
					const secondCard = match.cards[secondCardIndex];
					const isMatch =
						firstCard.pokemonId === secondCard.pokemonId;

					// Wait 1 second to show both cards before revealing result
					setTimeout(async () => {
						// Re-fetch match to get latest state
						const updatedMatch =
							await gameStateService.getMatchState(matchId);

						io.to(matchId).emit("solo_duel:match_result", {
							matchId,
							cardIndices: [firstCardIndex, secondCardIndex],
							isMatch,
							matchedBy: isMatch ? socket.userId : null,
							nextTurn: updatedMatch.currentTurn,
							players: updatedMatch.players.map((p) => ({
								userId: p.userId.toString(),
								username: p.username,
								score: p.score,
								matchedCards: p.matchedCards,
							})),
						});

						console.log(
							`${isMatch ? "✅" : "❌"} Match result: ${
								isMatch ? "MATCH" : "NO MATCH"
							}`
						);

						// Check if game is over
						if (updatedMatch.status === "completed") {
							const winner = updatedMatch.players.find(
								(p) =>
									p.userId.toString() ===
									updatedMatch.winner.toString()
							);
							const loser = updatedMatch.players.find(
								(p) =>
									p.userId.toString() !==
									updatedMatch.winner.toString()
							);

							io.to(matchId).emit("solo_duel:game_over", {
								matchId,
								winner: {
									userId: winner.userId.toString(),
									username: winner.username,
									score: winner.score,
									matchedCards: winner.matchedCards,
								},
								loser: {
									userId: loser.userId.toString(),
									username: loser.username,
									score: loser.score,
									matchedCards: loser.matchedCards,
								},
								finishedAt:
									updatedMatch.finishedAt.toISOString(),
							});

							// Save match history to database
							const timeTaken = Math.floor(
								(updatedMatch.finishedAt -
									updatedMatch.startedAt) /
									1000
							);

							const history = new SoloDuelHistory({
								player: updatedMatch.players.map((p) => ({
									playerId: p.userId,
									score: p.score,
									moves: p.matchedCards,
									timeTaken: timeTaken,
								})),
								winner: updatedMatch.winner,
							});

							await history.save();

							console.log(
								`🏆 Game over: ${matchId}\n   Winner: ${winner.username} (${winner.score} points)\n   Loser: ${loser.username} (${loser.score} points)`
							);
						}
					}, 1000);
				}
			} catch (error) {
				console.error("❌ Error flipping card:", error);
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to flip card",
				});
			}
		});

		// ==================== DISCONNECT ====================
		socket.on("disconnect", async () => {
			console.log(
				`👋 User disconnected: ${socket.username} (${socket.userId})`
			);

			// Remove from queue if still waiting
			matchmakingService.removeFromQueue(socket.userId);

			// TODO: Handle disconnection during active match
			// Find active matches and notify other player
			// Mark match as cancelled/abandoned
		});
	});
};

module.exports = {setupSoloDuelHandlers};
