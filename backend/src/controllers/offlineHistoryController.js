const asyncHandle = require("express-async-handler");
const AppError = require("../utils/errors");
const {OfflineHistory} = require("../models/offlineHistoryModel");

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

const getOfflineHistory = asyncHandle(async (req, res) => {
	const {id} = req.params;

	if (!id.match(/^[0-9a-fA-F]{24}$/)) {
		throw new AppError("ID không hợp lệ", 400);
	}

	const history = await OfflineHistory.findById(id).populate(
		"userId",
		"username email first_name last_name avatar"
	);

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
});

const getOfflineHistorys = asyncHandle(async (req, res) => {
	const {
		page = 1,
		limit = 10,
		difficulty,
		isWin,
		sortBy = "datePlayed",
		order = "desc",
	} = req.query;

	const filter = {userId: req.user.id};

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
			filter.difficulty = difficulty;
		}
	}

	if (isWin !== undefined) {
		if (isWin === "true" || isWin === true) {
			filter.isWin = true;
		} else if (isWin === "false" || isWin === false) {
			filter.isWin = false;
		}
	}

	const sortOrder = order === "asc" ? 1 : -1;
	const sortQuery = {};
	sortQuery[sortBy] = sortOrder;

	const pageNum = parseInt(page, 10);
	const limitNum = parseInt(limit, 10);
	const skip = (pageNum - 1) * limitNum;

	const total = await OfflineHistory.countDocuments(filter);

	const histories = await OfflineHistory.find(filter)
		.sort(sortQuery)
		.skip(skip)
		.limit(limitNum)
		.populate("userId", "username email first_name last_name avatar");

	const totalPages = Math.ceil(total / limitNum);
	const hasNextPage = pageNum < totalPages;
	const hasPrevPage = pageNum > 1;

	return res.status(200).json({
		success: true,
		message: "Lấy danh sách lịch sử chơi thành công",
		data: {
			histories: histories.map((history) => ({
				id: history._id,
				userId: history.userId,
				score: history.score,
				moves: history.moves,
				timeElapsed: history.timeElapsed,
				difficulty: history.difficulty,
				isWin: history.isWin,
				datePlayed: history.datePlayed,
				createdAt: history.createdAt,
				updatedAt: history.updatedAt,
			})),
			pagination: {
				total,
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
	getOfflineHistory,
	getOfflineHistorys,
};
