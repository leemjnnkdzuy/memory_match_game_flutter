const matchmakingService = require("../services/matchmakingService");
const gameStateService = require("../services/gameStateService");
const {SoloDuelHistory} = require("../models/soloDuelHistoryModel");
const {User} = require("../models/userModel");
const SoloDuelMatch = require("../models/soloDuelMatchModel");

// Store disconnect timers
const disconnectTimers = new Map();

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

						// Store socket IDs in match
						const updatedMatch = await SoloDuelMatch.findOne({
							matchId: match.matchId,
						});
						updatedMatch.players[0].socketId = player1.socketId;
						updatedMatch.players[1].socketId = player2.socketId;
						await updatedMatch.save();

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

				// Process the flip
				const match = await gameStateService.handleCardFlip(
					matchId,
					socket.userId,
					cardIndex
				);

				// Notify all players about the card flip immediately
				io.to(matchId).emit("solo_duel:card_flipped", {
					matchId,
					cardIndex,
					flippedBy: socket.userId,
					pokemonId: match.cards[cardIndex].pokemonId,
					pokemonName: match.cards[cardIndex].pokemonName,
				});

				// Check if we just completed a pair (flippedCards is now empty after 2nd flip)
				if (
					match.flippedCards.length === 0 &&
					match.lastMatchResult &&
					match.lastMatchResult.cardIndices
				) {
					// Two cards were just processed
					const {cardIndices, isMatch} = match.lastMatchResult;

					console.log(
						`${isMatch ? "✅" : "❌"} Match result: ${
							isMatch ? "MATCH" : "NO MATCH"
						} [${cardIndices[0]}, ${cardIndices[1]}]`
					);

					// Send result after 1 second delay
					setTimeout(async () => {
						const updatedMatch =
							await gameStateService.getMatchState(matchId);

						io.to(matchId).emit("solo_duel:match_result", {
							matchId,
							cardIndices,
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

							// Save match history
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

		socket.on("solo_duel:surrender", async (data) => {
			try {
				const {matchId} = data;
				console.log(
					`🏳️ ${socket.username} surrendering match ${matchId}`
				);

				const match = await gameStateService.surrenderMatch(
					matchId,
					socket.userId
				);

				const winner = match.players.find(
					(p) => p.userId.toString() === match.winner.toString()
				);
				const loser = match.players.find(
					(p) => p.userId.toString() !== match.winner.toString()
				);

				io.to(matchId).emit("solo_duel:game_over", {
					matchId,
					reason: "surrender",
					surrenderedBy: socket.userId,
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
					finishedAt: match.finishedAt.toISOString(),
				});

				const timeTaken = Math.floor(
					(match.finishedAt - match.startedAt) / 1000
				);

				const {
					SoloDuelHistory,
				} = require("../models/soloDuelHistoryModel");
				const history = new SoloDuelHistory({
					player: match.players.map((p) => ({
						playerId: p.userId,
						score: p.score,
						moves: p.matchedCards,
						timeTaken: timeTaken,
					})),
					winner: match.winner,
				});

				await history.save();

				console.log(
					`🏳️ Match surrendered: ${matchId}\n   Surrendered by: ${loser.username}\n   Winner: ${winner.username}`
				);
			} catch (error) {
				console.error("❌ Error surrendering match:", error);
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to surrender",
				});
			}
		});

		socket.on("solo_duel:rejoin_match", async (data) => {
			try {
				const {matchId} = data;
				console.log(
					`🔄 ${socket.username} attempting to rejoin match ${matchId}`
				);

				const match = await gameStateService.handlePlayerReconnect(
					matchId,
					socket.userId,
					socket.id
				);

				if (!match) {
					socket.emit("solo_duel:error", {
						message: "Match not found or already finished",
					});
					return;
				}

				const timerKey = `${matchId}_${socket.userId}`;
				if (disconnectTimers.has(timerKey)) {
					clearTimeout(disconnectTimers.get(timerKey));
					disconnectTimers.delete(timerKey);
					console.log(`⏹️ Cleared disconnect timer for ${timerKey}`);
				}

				socket.join(matchId);

				socket.to(matchId).emit("solo_duel:player_reconnected", {
					userId: socket.userId,
					username: socket.username,
				});

				const playerIds = match.players.map((p) => p.userId);
				const playerUsers = await User.find({
					_id: {$in: playerIds},
				}).select("avatar");
				const avatarMap = {};
				playerUsers.forEach((user) => {
					avatarMap[user._id.toString()] = user.avatar;
				});

				socket.emit("solo_duel:match_state", {
					matchId: match.matchId,
					status: match.status,
					currentTurn: match.currentTurn,
					players: match.players.map((p) => ({
						userId: p.userId.toString(),
						username: p.username,
						score: p.score,
						matchedCards: p.matchedCards,
						isConnected: p.isConnected,
						avatar: avatarMap[p.userId.toString()],
					})),
					cards: match.cards.map((c) => ({
						isMatched: c.isMatched,
						matchedBy: c.matchedBy,
						pokemonId: c.pokemonId,
						pokemonName: c.pokemonName,
					})),
				});
				console.log(`✅ ${socket.username} rejoined match ${matchId}`);
			} catch (error) {
				console.error("❌ Error rejoining match:", error);
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to rejoin match",
				});
			}
		});

		socket.on("disconnect", async () => {
			console.log(`👋 ${socket.username} disconnected`);
			matchmakingService.removeFromQueue(socket.userId);

			// Find active matches for this user
			try {
				const activeMatches = await SoloDuelMatch.find({
					"players.userId": socket.userId,
					status: {$in: ["ready", "playing"]},
				});

				for (const match of activeMatches) {
					const disconnectedMatch =
						await gameStateService.handlePlayerDisconnect(
							match.matchId,
							socket.userId
						);

					if (disconnectedMatch) {
						// Notify opponent
						socket
							.to(match.matchId)
							.emit("solo_duel:player_disconnected", {
								userId: socket.userId,
								username: socket.username,
								disconnectedAt: new Date().toISOString(),
								waitTimeSeconds: 30,
							});

						console.log(
							`⏳ ${socket.username} disconnected from match ${match.matchId}. Starting 30s timer...`
						);

						// Set 30 second timer
						const timerKey = `${match.matchId}_${socket.userId}`;
						const timer = setTimeout(async () => {
							console.log(
								`⏰ 30s timer expired for ${socket.username} in match ${match.matchId}`
							);

							const finalMatch =
								await gameStateService.handleDisconnectTimeout(
									match.matchId,
									socket.userId
								);

							if (finalMatch) {
								const winner = finalMatch.players.find(
									(p) =>
										p.userId.toString() ===
										finalMatch.winner.toString()
								);
								const loser = finalMatch.players.find(
									(p) =>
										p.userId.toString() !==
										finalMatch.winner.toString()
								);

								io.to(match.matchId).emit(
									"solo_duel:game_over",
									{
										matchId: match.matchId,
										reason: "disconnect_timeout",
										disconnectedPlayer: socket.userId,
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
											finalMatch.finishedAt.toISOString(),
									}
								);

								// Save match history
								const timeTaken = Math.floor(
									(finalMatch.finishedAt -
										finalMatch.startedAt) /
										1000
								);

								const history = new SoloDuelHistory({
									player: finalMatch.players.map((p) => ({
										playerId: p.userId,
										score: p.score,
										moves: p.matchedCards,
										timeTaken: timeTaken,
									})),
									winner: finalMatch.winner,
								});

								await history.save();

								console.log(
									`🏆 Match ended due to disconnect: ${match.matchId}\n   Winner: ${winner.username}\n   Disconnected: ${loser.username}`
								);
							}

							disconnectTimers.delete(timerKey);
						}, 30000); // 30 seconds

						disconnectTimers.set(timerKey, timer);
					}
				}
			} catch (error) {
				console.error("❌ Error handling disconnect:", error);
			}
		});
	});
};

module.exports = {setupSoloDuelHandlers};
