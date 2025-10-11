const asyncHandle = require("express-async-handler");
const AppError = require("../utils/errors");
const {OfflineHistory} = require("../models/offlineHistoryModel");
const {SoloDuelHistory} = require("../models/soloDuelHistoryModel");

const saveOfflineHistory = asyncHandle(async (req, res) => {
	const {score, moves, timeElapsed, difficulty, isWin} = req.body;

	if (
		score === undefined ||
		moves === undefined ||
		timeElapsed === undefined ||
		!difficulty ||
		isWin === undefined
	) {
		throw new AppError(
			"Vui lòng cung cấp đầy đủ thông tin: score, moves, timeElapsed, difficulty, isWin",
			400
		);
	}

	if (typeof score !== "number" || score < 0) {
		throw new AppError("Score phải là số và không được âm", 400);
	}

	if (typeof moves !== "number" || moves < 0) {
		throw new AppError("Moves phải là số và không được âm", 400);
	}

	if (typeof timeElapsed !== "number" || timeElapsed < 0) {
		throw new AppError("TimeElapsed phải là số và không được âm", 400);
	}

	const validDifficulties = [
		"veryEasy",
		"easy",
		"normal",
		"medium",
		"hard",
		"superHard",
		"insane",
		"expert",
	];
	if (!validDifficulties.includes(difficulty)) {
		throw new AppError(
			`Difficulty phải là một trong các giá trị: ${validDifficulties.join(
				", "
			)}`,
			400
		);
	}

	if (typeof isWin !== "boolean") {
		throw new AppError("isWin phải là boolean (true/false)", 400);
	}

	const offlineHistory = new OfflineHistory({
		userId: req.user.id,
		score,
		moves,
		timeElapsed,
		difficulty,
		isWin,
		datePlayed: new Date(),
	});

	await offlineHistory.save();

	return res.status(201).json({
		success: true,
		message: "Lưu lịch sử chơi offline thành công",
		data: {
			history: {
				id: offlineHistory._id,
				userId: offlineHistory.userId,
				score: offlineHistory.score,
				moves: offlineHistory.moves,
				timeElapsed: offlineHistory.timeElapsed,
				difficulty: offlineHistory.difficulty,
				isWin: offlineHistory.isWin,
				datePlayed: offlineHistory.datePlayed,
			},
		},
	});
});

const getHistory = asyncHandle(async (req, res) => {
	const {id} = req.params;

	if (!id.match(/^[0-9a-fA-F]{24}$/)) {
		throw new AppError("ID không hợp lệ", 400);
	}

	let history = await OfflineHistory.findById(id).populate(
		"userId",
		"username email first_name last_name avatar"
	);

	if (history) {
		if (history.userId._id.toString() !== req.user.id) {
			throw new AppError("Bạn không có quyền xem lịch sử này", 403);
		}

		return res.status(200).json({
			success: true,
			message: "Lấy lịch sử chơi thành công",
			data: {
				history: {
					id: history._id,
					type: "offline",
					userId: history.userId,
					score: history.score,
					moves: history.moves,
					timeElapsed: history.timeElapsed,
					difficulty: history.difficulty,
					isWin: history.isWin,
					datePlayed: history.datePlayed,
					createdAt: history.createdAt,
					updatedAt: history.updatedAt,
				},
			},
		});
	}

	history = await SoloDuelHistory.findById(id)
		.populate("userId", "username email first_name last_name avatar")
		.populate("opponentId", "username email first_name last_name avatar");

	if (!history) {
		throw new AppError("Không tìm thấy lịch sử chơi", 404);
	}

	if (history.userId._id.toString() !== req.user.id) {
		throw new AppError("Bạn không có quyền xem lịch sử này", 403);
	}

	return res.status(200).json({
		success: true,
		message: "Lấy lịch sử chơi thành công",
		data: {
			history: {
				id: history._id,
				type: "online",
				matchId: history.matchId,
				userId: history.userId,
				opponentId: history.opponentId,
				score: history.score,
				opponentScore: history.opponentScore,
				matchedCards: history.matchedCards,
				isWin: history.isWin,
				gameTime: history.gameTime,
				datePlayed: history.datePlayed,
				opponent: history.opponentId,
				createdAt: history.createdAt,
				updatedAt: history.updatedAt,
			},
		},
	});
});

const getHistories = asyncHandle(async (req, res) => {
	const {
		page = 1,
		limit = 10,
		difficulty,
		isWin,
		type,
		sortBy = "datePlayed",
		order = "desc",
	} = req.query;

	const pageNum = parseInt(page, 10);
	const limitNum = parseInt(limit, 10);
	const skip = (pageNum - 1) * limitNum;
	const sortOrder = order === "asc" ? 1 : -1;

	let offlineHistories = [];
	let onlineHistories = [];
	let totalOffline = 0;
	let totalOnline = 0;

	if (!type || type === "offline") {
		const offlineFilter = {userId: req.user.id};

		if (difficulty) {
			const validDifficulties = [
				"veryEasy",
				"easy",
				"normal",
				"medium",
				"hard",
				"superHard",
				"insane",
				"expert",
			];
			if (validDifficulties.includes(difficulty)) {
				offlineFilter.difficulty = difficulty;
			}
		}

		if (isWin !== undefined) {
			if (isWin === "true" || isWin === true) {
				offlineFilter.isWin = true;
			} else if (isWin === "false" || isWin === false) {
				offlineFilter.isWin = false;
			}
		}

		totalOffline = await OfflineHistory.countDocuments(offlineFilter);

		const offlineDocs = await OfflineHistory.find(offlineFilter)
			.sort({[sortBy]: sortOrder})
			.populate("userId", "username email first_name last_name avatar");

		offlineHistories = offlineDocs.map((history) => ({
			id: history._id,
			type: "offline",
			userId: history.userId,
			score: history.score,
			moves: history.moves,
			timeElapsed: history.timeElapsed,
			difficulty: history.difficulty,
			isWin: history.isWin,
			datePlayed: history.datePlayed,
			createdAt: history.createdAt,
			updatedAt: history.updatedAt,
		}));
	}

	if (!type || type === "online") {
		const onlineFilter = {
			userId: req.user.id,
		};

		totalOnline = await SoloDuelHistory.countDocuments(onlineFilter);

		const onlineDocs = await SoloDuelHistory.find(onlineFilter)
			.sort({datePlayed: sortOrder})
			.populate("userId", "username email first_name last_name avatar")
			.populate(
				"opponentId",
				"username email first_name last_name avatar"
			);

		onlineHistories = onlineDocs.map((history) => ({
			id: history._id,
			type: "online",
			matchId: history.matchId,
			userId: history.userId._id,
			opponentId: history.opponentId._id,
			score: history.score,
			opponentScore: history.opponentScore,
			matchedCards: history.matchedCards,
			isWin: history.isWin,
			gameTime: history.gameTime,
			datePlayed: history.datePlayed,
			opponent: history.opponentId,
			createdAt: history.createdAt,
			updatedAt: history.updatedAt,
		}));
	}

	let allHistories = [...offlineHistories, ...onlineHistories];

	allHistories.sort((a, b) => {
		const dateA = a.datePlayed || a.createdAt;
		const dateB = b.datePlayed || b.createdAt;
		return sortOrder === 1
			? new Date(dateA) - new Date(dateB)
			: new Date(dateB) - new Date(dateA);
	});

	const total = totalOffline + totalOnline;
	const paginatedHistories = allHistories.slice(skip, skip + limitNum);
	const totalPages = Math.ceil(total / limitNum);
	const hasNextPage = pageNum < totalPages;
	const hasPrevPage = pageNum > 1;

	return res.status(200).json({
		success: true,
		message: "Lấy danh sách lịch sử chơi thành công",
		data: {
			histories: paginatedHistories,
			pagination: {
				total,
				totalOffline,
				totalOnline,
				page: pageNum,
				limit: limitNum,
				totalPages,
				hasNextPage,
				hasPrevPage,
			},
		},
	});
});

module.exports = {
	saveOfflineHistory,
	getHistory,
	getHistories,
};
