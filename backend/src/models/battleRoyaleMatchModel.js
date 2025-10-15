const mongoose = require("mongoose");

const cardSchema = new mongoose.Schema({
	pokemonId: {type: Number, required: true},
	pokemonName: {type: String, required: true},
	position: {type: Number, required: true},
});

const playerResultSchema = new mongoose.Schema({
	userId: {type: mongoose.Schema.Types.ObjectId, ref: "User", required: true},
	username: {type: String, required: true},
	pairsFound: {type: Number, default: 0},
	flipCount: {type: Number, default: 0},
	completionTime: {type: Number, default: 0},
	score: {type: Number, default: 0},
	rank: {type: Number, default: 0},
	isFinished: {type: Boolean, default: false},
	finishedAt: {type: Date, default: null},
	flips: [
		{
			cardIndex: Number,
			timestamp: Date,
			wasMatch: Boolean,
		},
	],
});

const battleRoyaleMatchSchema = new mongoose.Schema({
	roomId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "BattleRoyaleRoom",
		required: true,
	},
	seed: {type: String, required: true},
	cards: [cardSchema],
	players: [playerResultSchema],
	status: {
		type: String,
		enum: ["starting", "inProgress", "finished"],
		default: "starting",
	},
	startedAt: {type: Date, default: Date.now},
	finishedAt: {type: Date, default: null},
	createdAt: {type: Date, default: Date.now},
});

battleRoyaleMatchSchema.index({roomId: 1});
battleRoyaleMatchSchema.index({"players.userId": 1});
battleRoyaleMatchSchema.index({status: 1});
battleRoyaleMatchSchema.index({createdAt: -1});

battleRoyaleMatchSchema.methods.calculateScore = function (
	pairsFound,
	flipCount,
	completionTime
) {
	if (completionTime === 0) return 0;
	return Math.round(
		10000 / completionTime + pairsFound * 150 - flipCount * 5
	);
};

battleRoyaleMatchSchema.methods.calculateRankings = function () {
	const finishedPlayers = this.players
		.filter((p) => p.isFinished)
		.sort((a, b) => {
			if (a.score !== b.score) return b.score - a.score;
			if (a.completionTime !== b.completionTime)
				return a.completionTime - b.completionTime;
			if (a.flipCount !== b.flipCount) return a.flipCount - b.flipCount;
			return 0;
		});

	let currentRank = 1;
	for (let i = 0; i < finishedPlayers.length; i++) {
		if (i > 0) {
			const prev = finishedPlayers[i - 1];
			const curr = finishedPlayers[i];
			if (
				prev.score !== curr.score ||
				prev.completionTime !== curr.completionTime ||
				prev.flipCount !== curr.flipCount
			) {
				currentRank = i + 1;
			}
		}
		finishedPlayers[i].rank = currentRank;
	}

	return finishedPlayers;
};

battleRoyaleMatchSchema.methods.getPlayerResult = function (userId) {
	return this.players.find((p) => p.userId.toString() === userId.toString());
};

battleRoyaleMatchSchema.methods.updatePlayerProgress = function (
	userId,
	pairsFound,
	flipCount,
	completionTime
) {
	const player = this.getPlayerResult(userId);
	if (player) {
		player.pairsFound = pairsFound;
		player.flipCount = flipCount;
		player.completionTime = completionTime;
		player.score = this.calculateScore(
			pairsFound,
			flipCount,
			completionTime
		);

		if (pairsFound >= this.cards.length / 2 && !player.isFinished) {
			player.isFinished = true;
			player.finishedAt = new Date();
		}
	}
};

battleRoyaleMatchSchema.methods.recordFlip = function (
	userId,
	cardIndex,
	wasMatch
) {
	const player = this.getPlayerResult(userId);
	if (player) {
		player.flips.push({
			cardIndex,
			timestamp: new Date(),
			wasMatch,
		});
	}
};

battleRoyaleMatchSchema.methods.shouldEnd = function () {
	const allFinished = this.players.every((p) => p.isFinished);
	return allFinished || this.status === "finished";
};

module.exports = mongoose.model("BattleRoyaleMatch", battleRoyaleMatchSchema);
