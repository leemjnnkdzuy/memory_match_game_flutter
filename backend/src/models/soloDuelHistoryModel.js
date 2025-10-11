const mongoose = require("mongoose");

const soloDuelHistorySchema = new mongoose.Schema({
	matchId: {type: String, required: true},
	userId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},
	opponentId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},
	score: {type: Number, required: true},
	opponentScore: {type: Number, required: true},
	matchedCards: {type: Number, required: true},
	isWin: {type: Boolean, required: true},
	gameTime: {type: Number, required: true},
	datePlayed: {type: Date, required: true},
	createdAt: {type: Date, default: Date.now},
	updatedAt: {type: Date, default: Date.now},
});

soloDuelHistorySchema.pre("save", function (next) {
	this.updatedAt = Date.now();
	next();
});

exports.SoloDuelHistory = mongoose.model(
	"SoloDuelHistory",
	soloDuelHistorySchema
);
