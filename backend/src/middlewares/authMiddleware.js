const jwt = require("jsonwebtoken");
const {User} = require("../models/userModel");
const AppError = require("../utils/errors");
const asyncHandle = require("express-async-handler");
const JWTService = require("../utils/jwtService");

const authenticate = asyncHandle(async (req, res, next) => {
	const authHeader = req.headers.authorization || req.header("Authorization");
	const token = JWTService.extractTokenFromHeader(authHeader);

	if (!token) {
		throw new AppError("Không có token xác thực, truy cập bị từ chối", 401);
	}

	if (!JWTService.isValidTokenFormat(token)) {
		throw new AppError(
			"Định dạng token không hợp lệ, truy cập bị từ chối",
			401
		);
	}

	try {
		const decoded = JWTService.verifyAccessToken(token);

		const user = await User.findById(decoded.id);
		if (!user) {
			throw new AppError(
				"Không tìm thấy người dùng, truy cập bị từ chối",
				401
			);
		}

		if (!user.is_active) {
			throw new AppError(
				"Tài khoản đã bị vô hiệu hóa, truy cập bị từ chối",
				401
			);
		}

		if (!user.isVerified) {
			throw new AppError(
				"Tài khoản chưa được xác minh, truy cập bị từ chối",
				401
			);
		}

		req.user = {
			id: user._id.toString(),
			_id: user._id,
			email: user.email,
			username: user.username,
			first_name: user.first_name,
			last_name: user.last_name,
			avatar: user.avatar,
		};

		next();
	} catch (error) {
		if (
			error.message.includes("expired") ||
			error.message.includes("invalid")
		) {
			throw new AppError("Token đã hết hạn hoặc không hợp lệ", 401);
		}
		throw new AppError("Xác thực token thất bại, truy cập bị từ chối", 401);
	}
});

const requireAdmin = asyncHandle(async (req, res, next) => {
	if (!req.user) {
		throw new AppError("Yêu cầu xác thực", 401);
	}

	const user = await User.findById(req.user.id);
	if (!user || user.role !== "admin") {
		throw new AppError("Yêu cầu quyền admin", 403);
	}

	next();
});

const optionalAuth = asyncHandle(async (req, res, next) => {
	const authHeader = req.headers.authorization || req.header("Authorization");
	const token = JWTService.extractTokenFromHeader(authHeader);

	if (!token) {
		return next();
	}

	try {
		if (!JWTService.isValidTokenFormat(token)) {
			return next();
		}

		const decoded = JWTService.verifyAccessToken(token);

		const user = await User.findById(decoded.id);
		if (!user || !user.is_active || !user.isVerified) {
			return next();
		}

		req.user = {
			id: user._id.toString(),
			_id: user._id,
			email: user.email,
			username: user.username,
			first_name: user.first_name,
			last_name: user.last_name,
			avatar: user.avatar,
		};

		next();
	} catch (error) {
		next();
	}
});

module.exports = {authenticate, requireAdmin, optionalAuth};
