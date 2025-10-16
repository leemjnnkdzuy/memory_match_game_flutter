const mongoose = require("mongoose");

const playerSchema = new mongoose.Schema({
	userId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	username: {type: String, required: true},
	avatarUrl: {type: String, default: null},
	borderColor: {type: String, default: "#4CAF50"},
	isReady: {type: Boolean, default: false},
	isHost: {type: Boolean, default: false},
	ping: {type: Number, default: null},
	isConnected: {type: Boolean, default: true},
	disconnectedAt: {type: Date, default: null},
	socketId: {type: String, default: null},
	joinedAt: {type: Date, default: Date.now},
});

const battleRoyaleRoomSchema = new mongoose.Schema({
	code: {type: String, required: true, unique: true, index: true},
	name: {type: String, required: true},
	password: {type: String, default: null},
	maxPlayers: {type: Number, default: 8, min: 2, max: 8},
	currentPlayers: {type: Number, default: 0},
	hostId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	pairCount: {type: Number, default: 8},
	softCapTime: {type: Number, default: 120},
	hardCapTime: {type: Number, default: null},
	flipLimit: {type: Number, default: 2},
	seed: {type: String, default: null},
	region: {type: String, default: "auto"},
	status: {
		type: String,
		enum: ["waiting", "starting", "inProgress", "finished"],
		default: "waiting",
	},
	players: [playerSchema],
	matchId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "BattleRoyaleMatch",
		default: null,
	},
	createdAt: {type: Date, default: Date.now},
	startedAt: {type: Date, default: null},
	finishedAt: {type: Date, default: null},
	updatedAt: {type: Date, default: Date.now},
});

battleRoyaleRoomSchema.index({status: 1});
battleRoyaleRoomSchema.index({hostId: 1});
battleRoyaleRoomSchema.index({createdAt: -1});
battleRoyaleRoomSchema.index({"players.userId": 1});

battleRoyaleRoomSchema.pre("save", function (next) {
	this.currentPlayers = this.players.filter((p) => p.isConnected).length;
	this.updatedAt = Date.now();
	next();
});

battleRoyaleRoomSchema.methods.isFull = function () {
	return this.currentPlayers >= this.maxPlayers;
};

battleRoyaleRoomSchema.methods.canStart = function () {
	const nonHostPlayers = this.players.filter(
		(p) => !p.isHost && p.isConnected
	);
	const allNonHostReady = nonHostPlayers.every((p) => p.isReady);
	return this.currentPlayers >= 2 && allNonHostReady;
};

battleRoyaleRoomSchema.methods.getPlayer = function (userId) {
	return this.players.find((p) => p.userId.toString() === userId.toString());
};

battleRoyaleRoomSchema.methods.addPlayer = function (
	userId,
	username,
	socketId,
	avatarUrl = null,
	borderColor = "#4CAF50"
) {
	const existingPlayer = this.getPlayer(userId);
	if (existingPlayer) {
		existingPlayer.isConnected = true;
		existingPlayer.socketId = socketId;
		existingPlayer.disconnectedAt = null;
		if (avatarUrl) existingPlayer.avatarUrl = avatarUrl;
		if (borderColor) existingPlayer.borderColor = borderColor;
	} else {
		this.players.push({
			userId,
			username,
			socketId,
			avatarUrl,
			borderColor,
			isHost: this.players.length === 0,
			isConnected: true,
		});
	}
};

battleRoyaleRoomSchema.methods.removePlayer = function (userId) {
	const playerIndex = this.players.findIndex(
		(p) => p.userId.toString() === userId.toString()
	);
	if (playerIndex !== -1) {
		const wasHost = this.players[playerIndex].isHost;
		this.players.splice(playerIndex, 1);

		if (wasHost && this.players.length > 0) {
			const newHost = this.players
				.filter((p) => p.isConnected)
				.sort((a, b) => a.joinedAt - b.joinedAt)[0];
			if (newHost) {
				newHost.isHost = true;
				this.hostId = newHost.userId;
			}
		}
	}
};

module.exports = mongoose.model("BattleRoyaleRoom", battleRoyaleRoomSchema);
