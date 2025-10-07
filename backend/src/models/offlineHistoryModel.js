const mongoose = require("mongoose");

const OfflineHistorySchema = new mongoose.Schema(
	{
		userId: {
			type: mongoose.Schema.Types.ObjectId,
			required: true,
			ref: "User",
		},
		score: {
			type: Number,
			required: true,
			min: 0,
		},
		moves: {
			type: Number,
			required: true,
			min: 0,
		},
		timeElapsed: {
			type: Number,
			required: true,
			min: 0,
		},
		difficulty: {
			type: String,
			required: true,
			enum: [
				"veryEasy",
				"easy",
				"normal",
				"medium",
				"hard",
				"superHard",
				"insane",
				"expert",
			],
		},
		isWin: {
			type: Boolean,
			required: true,
		},
		datePlayed: {
			type: Date,
			default: Date.now,
		},
	},
	{
		timestamps: true,
	}
);

exports.OfflineHistory = mongoose.model("OfflineHistory", OfflineHistorySchema);
