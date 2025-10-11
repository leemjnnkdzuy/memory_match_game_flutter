const mongoose = require("mongoose");

const cardSchema = new mongoose.Schema({
	pokemonId: {type: Number, required: true},
	pokemonName: {type: String, required: true},
	isMatched: {type: Boolean, default: false},
	matchedBy: {type: String, default: null},
});

const playerSchema = new mongoose.Schema({
	userId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	username: {type: String, required: true},
	score: {type: Number, default: 0},
	matchedCards: {type: Number, default: 0},
	isReady: {type: Boolean, default: false},
	lastPickTime: {type: Date, default: null},
	isConnected: {type: Boolean, default: true},
	disconnectedAt: {type: Date, default: null},
	socketId: {type: String, default: null},
});

const soloDuelMatchSchema = new mongoose.Schema({
	matchId: {type: String, required: true, unique: true},
	status: {
		type: String,
		enum: ["waiting", "ready", "playing", "completed", "cancelled"],
		default: "waiting",
	},
	players: [playerSchema],
	cards: [cardSchema],
	currentTurn: {type: String, default: null},
	flippedCards: [
		{
			cardIndex: Number,
			flippedBy: String,
			flippedAt: Date,
		},
	],
	lastMatchResult: {
		cardIndices: [Number],
		isMatch: Boolean,
		processedAt: Date,
	},
	winner: {type: mongoose.Schema.Types.ObjectId, ref: "User", default: null},
	startedAt: {type: Date, default: null},
	finishedAt: {type: Date, default: null},
	createdAt: {type: Date, default: Date.now},
	updatedAt: {type: Date, default: Date.now},
});

soloDuelMatchSchema.index({"players.userId": 1});
soloDuelMatchSchema.index({status: 1});

module.exports = mongoose.model("SoloDuelMatch", soloDuelMatchSchema);
