const BattleRoyaleRoom = require("../models/battleRoyaleRoomModel");
const BattleRoyaleMatch = require("../models/battleRoyaleMatchModel");
const AppError = require("../utils/errors");

let io = null;
const roomSockets = new Map();

const setupBattleRoyale = (socketIo) => {
	io = socketIo;

	io.on("connection", (socket) => {
		socket.on("br:join_room", async ({roomId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) {
					socket.emit("br:error", {message: "Room not found"});
					return;
				}

				const player = room.getPlayer(socket.userId);
				if (player) {
					player.socketId = socket.id;
					player.isConnected = true;
					player.disconnectedAt = null;
					if (socket.avatar) player.avatarUrl = socket.avatar;
					if (socket.borderColor)
						player.borderColor = socket.borderColor;
					await room.save();

					socket.join(roomId);

					if (!roomSockets.has(roomId)) {
						roomSockets.set(roomId, new Set());
					}
					roomSockets.get(roomId).add(socket.id);

					socket.emit("br:room_state", {
						room,
					});

					io.to(roomId).emit("br:player_joined", {
						player: {
							userId: player.userId,
							username: player.username,
							avatarUrl: player.avatarUrl,
							borderColor: player.borderColor,
							isHost: player.isHost,
						},
						players: room.players,
					});
				} else {
					socket.emit("br:error", {
						message: "Player not found in room",
					});
				}
			} catch (error) {
				socket.emit("br:error", {message: error.message});
			}
		});

		socket.on("br:toggle_ready", async ({roomId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) return;

				const player = room.getPlayer(socket.userId);
				if (player && !player.isHost) {
					player.isReady = !player.isReady;
					await room.save();

					io.to(roomId).emit("br:player_ready", {
						userId: player.userId,
						isReady: player.isReady,
						players: room.players,
					});
				}
			} catch (error) {
				socket.emit("br:error", {message: error.message});
			}
		});

		socket.on("br:start_match", async ({roomId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) {
					socket.emit("br:error", {message: "Room not found"});
					return;
				}

				if (room.hostId.toString() !== socket.userId.toString()) {
					socket.emit("br:error", {
						message: "Only host can start match",
					});
					return;
				}

				if (!room.canStart()) {
					socket.emit("br:error", {
						message: "All players must be ready",
					});
					return;
				}

				let match;
				if (!room.matchId) {
					const {
						generatePokemonCards,
					} = require("../utils/pokemonUtils");
					const seed = Date.now().toString();
					const cards = generatePokemonCards(room.pairCount, seed);

					match = new BattleRoyaleMatch({
						roomId: room._id,
						seed,
						cards: cards.map((pokemonId, index) => ({
							index,
							pokemonId,
							matchedBy: null,
							matchedAt: null,
						})),
						playerResults: room.players.map((p) => ({
							userId: p.userId,
							username: p.username,
							avatarUrl: p.avatarUrl,
							borderColor: p.borderColor,
						})),
						startedAt: new Date(),
					});

					await match.save();
					room.matchId = match._id;
				} else {
					match = await BattleRoyaleMatch.findById(room.matchId);
				}

				match.status = "inProgress";
				await match.save();

				room.status = "inProgress";
				room.startedAt = new Date();
				await room.save();

				io.to(roomId).emit("br:match_countdown", {
					countdown: 3,
				});

				setTimeout(() => {
					io.to(roomId).emit("br:match_start", {
						matchId: match._id.toString(),
						seed: match.seed,
						cards: match.cards.map((c) => c.pokemonId),
						startAt: new Date(),
					});
				}, 3000);
			} catch (error) {
				socket.emit("br:error", {message: error.message});
			}
		});

		socket.on("br:flip_card", async ({matchId, cardIndex}) => {
			try {
				const match = await BattleRoyaleMatch.findById(matchId);
				if (!match) return;

				const player = match.getPlayerResult(socket.userId);
				if (!player || player.isFinished) return;

				const lastFlip = player.flips[player.flips.length - 1];
				if (lastFlip && Date.now() - lastFlip.timestamp < 250) {
					socket.emit("br:error", {message: "Flip too fast"});
					return;
				}

				socket.emit("br:flip_acknowledged", {
					cardIndex,
					timestamp: Date.now(),
				});
			} catch (error) {
				throw new AppError("Error flipping card:", error);
			}
		});

		socket.on(
			"br:update_progress",
			async ({matchId, pairsFound, flipCount, completionTime}) => {
				try {
					const match = await BattleRoyaleMatch.findById(matchId);
					if (!match) return;

					match.updatePlayerProgress(
						socket.userId,
						pairsFound,
						flipCount,
						completionTime
					);
					await match.save();

					const room = await BattleRoyaleRoom.findById(match.roomId);
					io.to(room._id.toString()).emit("br:leaderboard_update", {
						players: match.players.map((p) => ({
							userId: p.userId,
							username: p.username,
							pairsFound: p.pairsFound,
							flipCount: p.flipCount,
							completionTime: p.completionTime,
							score: p.score,
							isFinished: p.isFinished,
						})),
					});
				} catch (error) {
					throw new AppError("Error updating progress:", error);
				}
			}
		);

		socket.on(
			"br:player_finished",
			async ({matchId, pairsFound, flipCount, completionTime}) => {
				try {
					const match = await BattleRoyaleMatch.findById(matchId);
					if (!match) return;

					const player = match.getPlayerResult(socket.userId);
					if (!player) return;

					player.pairsFound = pairsFound;
					player.flipCount = flipCount;
					player.completionTime = completionTime;
					player.score = match.calculateScore(
						pairsFound,
						flipCount,
						completionTime
					);
					player.isFinished = true;
					player.finishedAt = new Date();

					await match.save();

					const room = await BattleRoyaleRoom.findById(match.roomId);

					io.to(room._id.toString()).emit("br:player_finished", {
						userId: player.userId,
						username: player.username,
						score: player.score,
						rank: player.rank,
					});

					if (match.shouldEnd()) {
						match.status = "finished";
						match.finishedAt = new Date();
						await match.save();

						room.status = "finished";
						room.finishedAt = new Date();
						await room.save();

						const leaderboard = match.calculateRankings();

						io.to(room._id.toString()).emit("br:match_finished", {
							leaderboard,
							finishedAt: match.finishedAt,
						});
					}
				} catch (error) {
					throw new AppError("Error finishing player:", error);
				}
			}
		);

		socket.on("br:kick_player", async ({roomId, playerId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) {
					socket.emit("br:error", {message: "Room not found"});
					return;
				}

				if (room.hostId.toString() !== socket.userId.toString()) {
					socket.emit("br:error", {
						message: "Only host can kick",
					});
					return;
				}

				const kickedPlayer = room.players.find(
					(p) =>
						p._id?.toString() === playerId.toString() ||
						p.userId.toString() === playerId.toString()
				);

				if (!kickedPlayer) {
					socket.emit("br:error", {
						message: "Player not found in room",
					});
					return;
				}

				if (kickedPlayer.socketId) {
					io.to(kickedPlayer.socketId).emit("br:kicked", {
						message: "You have been kicked from the room",
					});
				}

				const playerIndex = room.players.findIndex(
					(p) =>
						p._id?.toString() === playerId.toString() ||
						p.userId.toString() === playerId.toString()
				);

				if (playerIndex !== -1) {
					room.players.splice(playerIndex, 1);
				}

				room.currentPlayers = room.players.length;
				await room.save();

				io.to(roomId).emit("br:player_left", {
					userId: kickedPlayer.userId,
					players: room.players.map((p) => ({
						userId: p.userId,
						username: p.username,
						avatarUrl: p.avatarUrl,
						borderColor: p.borderColor,
						isReady: p.isReady,
						isHost: p.isHost,
						ping: p.ping,
						isConnected: p.isConnected,
					})),
				});
			} catch (error) {
				socket.emit("br:error", {message: error.message});
			}
		});

		socket.on("br:leave_room", async ({roomId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) return;

				room.removePlayer(socket.userId);

				if (room.players.length === 0) {
					await BattleRoyaleRoom.findByIdAndDelete(roomId);
				} else {
					await room.save();

					io.to(roomId).emit("br:player_left", {
						userId: socket.userId,
						players: room.players,
					});

					if (room.hostId.toString() !== socket.userId.toString()) {
						io.to(roomId).emit("br:room_state", {room});
					}
				}

				socket.leave(roomId);
				if (roomSockets.has(roomId)) {
					roomSockets.get(roomId).delete(socket.id);
				}
			} catch (error) {
				throw new AppError("Error leaving room:", error);
			}
		});

		socket.on("br:close_room", async ({roomId}) => {
			try {
				const room = await BattleRoyaleRoom.findById(roomId);
				if (!room) {
					socket.emit("br:error", {message: "Room not found"});
					return;
				}

				if (room.hostId.toString() !== socket.userId.toString()) {
					socket.emit("br:error", {
						message: "Only host can close the room",
					});
					return;
				}

				io.to(roomId).emit("br:room_closed", {
					message: "The room has been closed by the host",
				});

				if (room.matchId) {
					await BattleRoyaleMatch.findByIdAndDelete(room.matchId);
				}

				await BattleRoyaleRoom.findByIdAndDelete(roomId);

				if (roomSockets.has(roomId)) {
					roomSockets.delete(roomId);
				}
			} catch (error) {
				socket.emit("br:error", {message: error.message});
			}
		});

		socket.on("disconnect", async () => {
			for (const [roomId, socketSet] of roomSockets.entries()) {
				if (socketSet.has(socket.id)) {
					try {
						const room = await BattleRoyaleRoom.findById(roomId);
						if (room) {
							const player = room.getPlayer(socket.userId);
							if (player) {
								player.isConnected = false;
								player.disconnectedAt = new Date();
								await room.save();

								io.to(roomId).emit("br:player_disconnected", {
									userId: socket.userId,
									players: room.players,
								});

								setTimeout(async () => {
									const updatedRoom =
										await BattleRoyaleRoom.findById(roomId);
									if (updatedRoom) {
										const p = updatedRoom.getPlayer(
											socket.userId
										);
										if (p && !p.isConnected) {
											updatedRoom.removePlayer(
												socket.userId
											);
											await updatedRoom.save();

											io.to(roomId).emit(
												"br:player_left",
												{
													userId: socket.userId,
													players:
														updatedRoom.players,
												}
											);
										}
									}
								}, 30000);
							}
						}
					} catch (error) {
						throw new AppError("Error handling disconnect:", error);
					}

					socketSet.delete(socket.id);
				}
			}
		});
	});
};

const emitToRoom = (roomId, event, data) => {
	if (io) {
		io.to(roomId).emit(event, data);
	}
};

module.exports = {
	setupBattleRoyale,
	emitToRoom,
};
