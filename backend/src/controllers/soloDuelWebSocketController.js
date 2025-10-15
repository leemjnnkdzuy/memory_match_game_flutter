const matchmakingService = require("../services/matchmakingService");
const gameStateService = require("../services/gameStateService");
const {SoloDuelHistory} = require("../models/soloDuelHistoryModel");
const {User} = require("../models/userModel");
const SoloDuelMatch = require("../models/soloDuelMatchModel");

const disconnectTimers = new Map();

const setupSoloDuelHandlers = (io) => {
	io.on("connection", (socket) => {
		socket.on("solo_duel:join_queue", async () => {
			try {
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

						const updatedMatch = await SoloDuelMatch.findOne({
							matchId: match.matchId,
						});
						updatedMatch.players[0].socketId = player1.socketId;
						updatedMatch.players[1].socketId = player2.socketId;
						await updatedMatch.save();

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
					}
				} else {
					const queueInfo = matchmakingService.getQueueInfo();
					socket.emit("solo_duel:queue_joined", {
						position: queueInfo.queueLength,
						queueLength: queueInfo.queueLength,
					});
				}
			} catch (error) {
				socket.emit("solo_duel:error", {
					message: "Failed to join queue",
					error: error.message,
				});
			}
		});

		socket.on("solo_duel:leave_queue", () => {
			try {
				const removed = matchmakingService.removeFromQueue(
					socket.userId
				);
				socket.emit("solo_duel:queue_left", {});
			} catch (error) {
				console.error("Error leaving queue:", error);
			}
		});

		socket.on("solo_duel:player_ready", async (data) => {
			try {
				const {matchId} = data;
				const match = await gameStateService.setPlayerReady(
					matchId,
					socket.userId
				);

				io.to(matchId).emit("solo_duel:player_ready", {
					userId: socket.userId,
					username: socket.username,
				});

				if (match.status === "playing") {
					const gameStartedData = {
						matchId: match.matchId,
						currentTurn: match.currentTurn,
						startedAt: match.startedAt.toISOString(),
						players: match.players.map((p) => ({
							userId: p.userId.toString(),
							username: p.username,
							score: p.score,
							matchedCards: p.matchedCards,
						})),
					};

					io.to(matchId).emit(
						"solo_duel:game_started",
						gameStartedData
					);
				}
			} catch (error) {
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to ready up",
				});
			}
		});

		socket.on("solo_duel:flip_card", async (data) => {
			try {
				const {matchId, cardIndex} = data;

				const match = await gameStateService.handleCardFlip(
					matchId,
					socket.userId,
					cardIndex
				);

				io.to(matchId).emit("solo_duel:card_flipped", {
					matchId,
					cardIndex,
					flippedBy: socket.userId,
					pokemonId: match.cards[cardIndex].pokemonId,
					pokemonName: match.cards[cardIndex].pokemonName,
				});

				if (
					match.flippedCards.length === 0 &&
					match.lastMatchResult &&
					match.lastMatchResult.cardIndices
				) {
					const {cardIndices, isMatch} = match.lastMatchResult;

					setTimeout(async () => {
						const updatedMatch =
							await gameStateService.getMatchState(matchId);

						const resultData = {
							matchId,
							cardIndices,
							isMatch,
							matchedBy: isMatch ? socket.userId : null,
							nextTurn: updatedMatch.currentTurn,
							players: updatedMatch.players.map((p) => ({
								userId:
									typeof p.userId === "string"
										? p.userId
										: p.userId._id.toString(),
								username: p.username,
								score: p.score,
								matchedCards: p.matchedCards,
							})),
						};

						io.to(matchId).emit(
							"solo_duel:match_result",
							resultData
						);
						if (updatedMatch.status === "completed") {
							const getIdString = (obj) =>
								typeof obj === "string"
									? obj
									: obj._id.toString();

							const winnerId = getIdString(updatedMatch.winner);
							const winner = updatedMatch.players.find(
								(p) => getIdString(p.userId) === winnerId
							);
							const loser = updatedMatch.players.find(
								(p) => getIdString(p.userId) !== winnerId
							);

							io.to(matchId).emit("solo_duel:game_over", {
								matchId,
								winner: {
									userId: getIdString(winner.userId),
									username: winner.username,
									score: winner.score,
									matchedCards: winner.matchedCards,
								},
								loser: {
									userId: getIdString(loser.userId),
									username: loser.username,
									score: loser.score,
									matchedCards: loser.matchedCards,
								},
								finishedAt:
									updatedMatch.finishedAt.toISOString(),
							});
							const gameTime = Math.floor(
								(updatedMatch.finishedAt -
									updatedMatch.startedAt) /
									1000
							);

							const winnerPlayer = updatedMatch.players.find(
								(p) => getIdString(p.userId) === winnerId
							);
							const loserPlayer = updatedMatch.players.find(
								(p) => getIdString(p.userId) !== winnerId
							);

							const winnerHistory = new SoloDuelHistory({
								matchId: updatedMatch.matchId,
								userId: getIdString(winnerPlayer.userId),
								opponentId: getIdString(loserPlayer.userId),
								score: winnerPlayer.score,
								opponentScore: loserPlayer.score,
								matchedCards: winnerPlayer.matchedCards,
								isWin: true,
								gameTime: gameTime,
								datePlayed: updatedMatch.finishedAt,
							});

							const loserHistory = new SoloDuelHistory({
								matchId: updatedMatch.matchId,
								userId: getIdString(loserPlayer.userId),
								opponentId: getIdString(winnerPlayer.userId),
								score: loserPlayer.score,
								opponentScore: winnerPlayer.score,
								matchedCards: loserPlayer.matchedCards,
								isWin: false,
								gameTime: gameTime,
								datePlayed: updatedMatch.finishedAt,
							});

							await Promise.all([
								winnerHistory.save(),
								loserHistory.save(),
							]);
						}
					}, 1000);
				}
			} catch (error) {
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to flip card",
				});
			}
		});

		socket.on("solo_duel:surrender", async (data) => {
			try {
				const {matchId} = data;
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

				const winnerHistory = new SoloDuelHistory({
					matchId: match.matchId,
					userId: winner.userId.toString(),
					opponentId: loser.userId.toString(),
					score: winner.score,
					opponentScore: loser.score,
					matchedCards: winner.matchedCards,
					isWin: true,
					gameTime: timeTaken,
					datePlayed: match.finishedAt,
				});

				const loserHistory = new SoloDuelHistory({
					matchId: match.matchId,
					userId: loser.userId.toString(),
					opponentId: winner.userId.toString(),
					score: loser.score,
					opponentScore: winner.score,
					matchedCards: loser.matchedCards,
					isWin: false,
					gameTime: timeTaken,
					datePlayed: match.finishedAt,
				});

				await Promise.all([winnerHistory.save(), loserHistory.save()]);
			} catch (error) {
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to surrender",
				});
			}
		});

		socket.on("solo_duel:rejoin_match", async (data) => {
			try {
				const {matchId} = data;

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
			} catch (error) {
				socket.emit("solo_duel:error", {
					message: error.message || "Failed to rejoin match",
				});
			}
		});

		socket.on("disconnect", async () => {
			matchmakingService.removeFromQueue(socket.userId);

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
						socket
							.to(match.matchId)
							.emit("solo_duel:player_disconnected", {
								userId: socket.userId,
								username: socket.username,
								disconnectedAt: new Date().toISOString(),
								waitTimeSeconds: 30,
							});

						const timerKey = `${match.matchId}_${socket.userId}`;
						const timer = setTimeout(async () => {
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

								const timeTaken = Math.floor(
									(finalMatch.finishedAt -
										finalMatch.startedAt) /
										1000
								);

								const winnerHistory = new SoloDuelHistory({
									matchId: finalMatch.matchId,
									userId: winner.userId.toString(),
									opponentId: loser.userId.toString(),
									score: winner.score,
									opponentScore: loser.score,
									matchedCards: winner.matchedCards,
									isWin: true,
									gameTime: timeTaken,
									datePlayed: finalMatch.finishedAt,
								});

								const loserHistory = new SoloDuelHistory({
									matchId: finalMatch.matchId,
									userId: loser.userId.toString(),
									opponentId: winner.userId.toString(),
									score: loser.score,
									opponentScore: winner.score,
									matchedCards: loser.matchedCards,
									isWin: false,
									gameTime: timeTaken,
									datePlayed: finalMatch.finishedAt,
								});

								await Promise.all([
									winnerHistory.save(),
									loserHistory.save(),
								]);
							}

							disconnectTimers.delete(timerKey);
						}, 30000);

						disconnectTimers.set(timerKey, timer);
					}
				}
			} catch (error) {
				console.error("Error handling disconnect:", error);
			}
		});
	});
};

module.exports = {setupSoloDuelHandlers};
