const BattleRoyaleRoom = require("../models/battleRoyaleRoomModel");
const BattleRoyaleMatch = require("../models/battleRoyaleMatchModel");
const AppError = require("../utils/errors");
const {getRandomPokemon} = require("../utils/pokemonUtils");

let io = null;
const roomSockets = new Map();

const createSeededRandom = (seed) => {
	let hash = 2166136261 >>> 0;
	for (let i = 0; i < seed.length; i++) {
		hash ^= seed.charCodeAt(i);
		hash = Math.imul(hash, 16777619);
	}

	return () => {
		hash += hash << 13;
		hash ^= hash >>> 7;
		hash += hash << 3;
		hash ^= hash >>> 17;
		hash += hash << 5;
		return (hash >>> 0) / 4294967296;
	};
};

const shuffleWithSeed = (items, seed) => {
	const array = [...items];
	const random = createSeededRandom(seed);
	for (let i = array.length - 1; i > 0; i--) {
		const j = Math.floor(random() * (i + 1));
		[array[i], array[j]] = [array[j], array[i]];
	}
	return array;
};

const buildMatchCards = (pokemonList, seed) => {
	const duplicated = [];
	pokemonList.forEach((pokemon) => {
		duplicated.push({
			pokemonId: pokemon.pokemonId,
			pokemonName: pokemon.pokemonName,
		});
		duplicated.push({
			pokemonId: pokemon.pokemonId,
			pokemonName: pokemon.pokemonName,
		});
	});

	const shuffled = shuffleWithSeed(duplicated, seed);

	return shuffled.map((card, index) => ({
		...card,
		position: index,
	}));
};

const serializeMatchPlayer = (player) => {
	const raw = typeof player.toObject === "function" ? player.toObject() : player;
	const userId = raw.userId?.toString?.() ?? raw.userId;

	return {
		id: userId,
		userId,
		username: raw.username,
		avatarUrl: raw.avatarUrl,
		borderColor: raw.borderColor,
		pairsFound: raw.pairsFound ?? 0,
		flipCount: raw.flipCount ?? 0,
		completionTime: raw.completionTime ?? 0,
		score: raw.score ?? 0,
		isFinished: raw.isFinished ?? false,
		rank: raw.rank ?? 0,
		finishedAt: raw.finishedAt,
	};
};

const emitLeaderboardSnapshot = (match, roomId) => {
	if (!io || !roomId) return;
	io.to(roomId).emit("br:leaderboard_update", {
		players: match.players.map((p) => serializeMatchPlayer(p)),
	});
};

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
				let pokemonIdsForClient = [];

				const createMatch = async () => {
					const seed = Date.now().toString();
					const pokemonList = getRandomPokemon(room.pairCount);
					const cards = buildMatchCards(pokemonList, seed);

					const newMatch = new BattleRoyaleMatch({
						roomId: room._id,
						seed,
						cards,
						players: room.players.map((p) => ({
							userId: p.userId,
							username: p.username,
							avatarUrl: p.avatarUrl,
							borderColor: p.borderColor,
						})),
						status: "starting",
						startedAt: new Date(),
					});

					await newMatch.save();

					room.matchId = newMatch._id;
					room.seed = seed;
					pokemonIdsForClient = pokemonList.map(
						(pokemon) => pokemon.pokemonId
					);

					return newMatch;
				};

				if (!room.matchId) {
					match = await createMatch();
				} else {
					match = await BattleRoyaleMatch.findById(room.matchId);
					if (!match) {
						match = await createMatch();
					} else {
						pokemonIdsForClient = [
							...new Set(
								match.cards.map((card) => card.pokemonId)
							),
						];

						if (!match.players || match.players.length === 0) {
							match.players = room.players.map((p) => ({
								userId: p.userId,
								username: p.username,
								avatarUrl: p.avatarUrl,
								borderColor: p.borderColor,
							}));
						}
					}
				}

				if (pokemonIdsForClient.length === 0) {
					pokemonIdsForClient = [
						...new Set(match.cards.map((card) => card.pokemonId)),
					];
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
					console.log(`🚀 Emitting br:match_start to room ${roomId}`);
					io.to(roomId).emit("br:match_start", {
						matchId: match._id.toString(),
						seed: match.seed,
						cards: pokemonIdsForClient,
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
					if (room) {
						emitLeaderboardSnapshot(match, room._id.toString());
					}
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
					match.calculateRankings();

					await match.save();

					const room = await BattleRoyaleRoom.findById(match.roomId);
					if (!room) return;

					io.to(room._id.toString()).emit(
						"br:player_finished",
						serializeMatchPlayer(player)
					);
					emitLeaderboardSnapshot(match, room._id.toString());

					if (match.shouldEnd()) {
						match.status = "finished";
						match.finishedAt = new Date();
						await match.save();

						room.status = "finished";
						room.finishedAt = new Date();
						await room.save();

						const leaderboard = match.calculateRankings();

						io.to(room._id.toString()).emit("br:match_finished", {
							leaderboard: leaderboard.map((p) =>
								serializeMatchPlayer(p)
							),
							finishedAt: match.finishedAt,
						});
						emitLeaderboardSnapshot(match, room._id.toString());
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
						await BattleRoyaleRoom.updateOne(
							{_id: roomId, "players.userId": socket.userId},
							{
								$set: {
									"players.$.isConnected": false,
									"players.$.disconnectedAt": new Date(),
								},
							}
						);

						const room = await BattleRoyaleRoom.findById(roomId);
						if (room) {
							io.to(roomId).emit("br:player_disconnected", {
								userId: socket.userId,
								players: room.players,
							});

							setTimeout(async () => {
								try {
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
								} catch (error) {
									console.error(
										"Error removing disconnected player:",
										error
									);
								}
							}, 30000);
						}
					} catch (error) {
						console.error("Error handling disconnect:", error);
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
