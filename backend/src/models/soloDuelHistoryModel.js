const mongoose = require("mongoose");

const soloDuelHistorySchema = new mongoose.Schema({
	player: [
		{
			playerId: {
				type: mongoose.Schema.Types.ObjectId,
				ref: "User",
				required: true,
			},
			score: {type: Number, required: true},
			moves: {type: Number, required: true},
			timeTaken: {type: Number, required: true},
		},
	],
	winner: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},
	createdAt: {type: Date, default: Date.now},
});

exports.SoloDuelHistory = mongoose.model(
	"SoloDuelHistory",
	soloDuelHistorySchema
);
