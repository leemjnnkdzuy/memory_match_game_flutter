const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const sendMailHelper = require("../Helpers/sendMailHelper");
const crypto = require("crypto");
const AppError = require("../utils/errors");
const asyncHandle = require("express-async-handler");
const {User} = require("../models/userModel");
const JWTService = require("../utils/jwtService");

const register = asyncHandle(async (req, res) => {
	const {username, email, password, confirmPassword, first_name, last_name} =
		req.body;

	if (
		!username ||
		!email ||
		!password ||
		!confirmPassword ||
		!first_name ||
		!last_name
	) {
		throw new AppError("Tất cả các trường thông tin đều bắt buộc", 400);
	}

	if (password !== confirmPassword) {
		throw new AppError("Mật khẩu xác nhận không khớp", 400);
	}

	const existingEmail = await User.findOne({email});
	if (existingEmail) {
		throw new AppError("Email đã tồn tại", 400);
	}

	const existingUsername = await User.findOne({username});
	if (existingUsername) {
		throw new AppError("Tên người dùng đã tồn tại", 400);
	}

	const hashedPassword = await bcrypt.hash(password, 10);

	const verificationCode = Math.floor(
		100000 + Math.random() * 900000
	).toString();
	const verificationCodeExpires = new Date(Date.now() + 15 * 60 * 1000);

	const user = new User({
		username,
		email,
		password: hashedPassword,
		first_name,
		last_name,
		isVerified: false,
		verificationCode,
		verificationCodeExpires,
	});

	await user.save();

	try {
		await sendMailHelper.sendAccountVerification(
			email,
			verificationCode,
			first_name
		);
	} catch (error) {
		console.log("Email sending failed:", error);
	}

	return res.status(201).json({
		success: true,
		message:
			"Đăng ký thành công! Vui lòng kiểm tra email để xác minh tài khoản.",
		data: {
			userId: user._id,
			username: user.username,
			email: user.email,
		},
	});
});

const verify = asyncHandle(async (req, res) => {
	const {code} = req.body;

	if (!code) {
		throw new AppError("Mã xác minh là bắt buộc", 400);
	}

	const user = await User.findOne({
		verificationCode: code,
		verificationCodeExpires: {$gt: new Date()},
	});

	if (!user) {
		throw new AppError("Mã xác minh không hợp lệ hoặc đã hết hạn", 400);
	}

	user.isVerified = true;
	user.verificationCode = undefined;
	user.verificationCodeExpires = undefined;
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Xác minh email thành công!",
	});
});

const login = asyncHandle(async (req, res) => {
	const {username, email, password} = req.body;

	if ((!username && !email) || !password) {
		throw new AppError("Vui lòng cung cấp username/email và mật khẩu", 400);
	}

	let user = null;
	if (username && email) {
		throw new AppError(
			"Chỉ cung cấp username hoặc email, không phải cả hai",
			400
		);
	} else if (username) {
		user = await User.findOne({username});
	} else {
		user = await User.findOne({email});
	}

	if (!user) {
		throw new AppError("Thông tin đăng nhập không hợp lệ", 401);
	}

	if (!user.isVerified) {
		throw new AppError("Vui lòng xác minh email trước khi đăng nhập", 401);
	}

	if (!user.is_active) {
		throw new AppError("Tài khoản đã bị vô hiệu hóa", 401);
	}

	const isMatch = await bcrypt.compare(password, user.password);
	if (!isMatch) {
		throw new AppError("Thông tin đăng nhập không hợp lệ", 401);
	}

	const tokens = JWTService.generateTokens(user._id);

	const deviceInfo = JWTService.getDeviceInfo(req);
	const ipAddress = JWTService.getClientIP(req);

	user.refreshTokens = user.refreshTokens.filter(
		(token) => !JWTService.isRefreshTokenExpired(token)
	);

	user.refreshTokens.push({
		token: tokens.refreshToken,
		expiresAt: tokens.refreshTokenExpiresAt,
		deviceInfo,
		ipAddress,
	});

	if (user.refreshTokens.length > 5) {
		user.refreshTokens = user.refreshTokens.slice(-5);
	}

	await user.save();

	return res.status(200).json({
		success: true,
		message: "Đăng nhập thành công",
		data: {
			accessToken: tokens.accessToken,
			refreshToken: tokens.refreshToken,
			accessTokenExpiresAt: tokens.accessTokenExpiresAt,
			refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
			user: {
				id: user._id,
				username: user.username,
				email: user.email,
				first_name: user.first_name,
				last_name: user.last_name,
				avatar: user.avatar,
				language: user.language,
				bio: user.bio,
				is_active: user.is_active,
			},
		},
	});
});

const getProfile = asyncHandle(async (req, res) => {
	const user = await User.findById(req.user.id).select(
		"-password -verificationCode -resetPin -tempAuthHashCode -changeEmailPin -newEmailPin"
	);

	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	return res.status(200).json({
		success: true,
		message: "Lấy thông tin người dùng thành công",
		data: {
			user: user,
		},
	});
});

const updateProfile = asyncHandle(async (req, res) => {
	const {
		first_name,
		last_name,
		bio,
		avatar,
		github_url,
		linkedin_url,
		website_url,
		youtube_url,
		facebook_url,
		instagram_url,
	} = req.body;

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (first_name !== undefined) user.first_name = first_name;
	if (last_name !== undefined) user.last_name = last_name;
	if (bio !== undefined) user.bio = bio;
	if (avatar !== undefined) user.avatar = avatar;
	if (github_url !== undefined) user.github_url = github_url;
	if (linkedin_url !== undefined) user.linkedin_url = linkedin_url;
	if (website_url !== undefined) user.website_url = website_url;
	if (youtube_url !== undefined) user.youtube_url = youtube_url;
	if (facebook_url !== undefined) user.facebook_url = facebook_url;
	if (instagram_url !== undefined) user.instagram_url = instagram_url;

	await user.save();

	return res.status(200).json({
		success: true,
		message: "Cập nhật hồ sơ thành công",
		data: {
			user: {
				id: user._id,
				username: user.username,
				email: user.email,
				first_name: user.first_name,
				last_name: user.last_name,
				bio: user.bio,
				language: user.language,
				avatar: user.avatar,
				github_url: user.github_url,
				linkedin_url: user.linkedin_url,
				website_url: user.website_url,
				youtube_url: user.youtube_url,
				facebook_url: user.facebook_url,
				instagram_url: user.instagram_url,
			},
		},
	});
});

const getUserData = asyncHandle(async (req, res) => {
	const {idOrUserName} = req.params;

	let user;
	if (isNaN(idOrUserName)) {
		user = await User.findOne({username: idOrUserName}).select(
			"-password -email -verificationCode -resetPin -tempAuthHashCode -changeEmailPin -newEmailPin -resetPasswordToken -changeEmailPinExpires -changeMailAuthHashCode -changeMailAuthHashCodeExpires -newEmail -newEmailPinExpires -resetPasswordExpires -resetPinExpires -tempAuthHashCodeExpires -verificationCodeExpires"
		);
	} else {
		user = await User.findById(idOrUserName).select(
			"-password -email -verificationCode -resetPin -tempAuthHashCode -changeEmailPin -newEmailPin -resetPasswordToken -changeEmailPinExpires -changeMailAuthHashCode -changeMailAuthHashCodeExpires -newEmail -newEmailPinExpires -resetPasswordExpires -resetPinExpires -tempAuthHashCodeExpires -verificationCodeExpires"
		);
	}

	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	return res.status(200).json({
		success: true,
		message: "Lấy thông tin người dùng thành công",
		data: {
			user: {
				id: user._id,
				first_name: user.first_name,
				last_name: user.last_name,
				username: user.username,
				avatar: user.avatar,
				bio: user.bio,
				github_url: user.github_url,
				linkedin_url: user.linkedin_url,
				website_url: user.website_url,
				youtube_url: user.youtube_url,
				facebook_url: user.facebook_url,
				instagram_url: user.instagram_url,
				history_match: user.history_match,
				created_at: user.created_at,
			},
		},
	});
});

const checkUsernameExist = asyncHandle(async (req, res) => {
	const {username} = req.body;

	if (!username) {
		throw new AppError("Tên người dùng là bắt buộc", 400);
	}

	const user = await User.findOne({username});

	return res.status(200).json({
		success: true,
		data: {
			exists: !!user,
		},
	});
});

const forgotPassword = asyncHandle(async (req, res) => {
	const {email} = req.body;

	if (!email) {
		throw new AppError("Email là bắt buộc", 400);
	}

	const user = await User.findOne({email});
	if (!user) {
		throw new AppError("Không tìm thấy người dùng với email này", 404);
	}

	const resetPin = Math.floor(100000 + Math.random() * 900000).toString();
	const resetPinExpires = new Date(Date.now() + 10 * 60 * 1000);

	user.resetPasswordToken = undefined;
	user.resetPasswordExpires = undefined;
	user.resetPin = resetPin;
	user.resetPinExpires = resetPinExpires;
	await user.save();

	try {
		await sendMailHelper.sendPasswordResetPin(
			email,
			resetPin,
			user.first_name
		);
	} catch (error) {
		console.log("Email sending failed:", error);
	}

	return res.status(200).json({
		success: true,
		message: "Mã xác thực đã được gửi về email!",
	});
});

const verifyResetPin = asyncHandle(async (req, res) => {
	const {email, code} = req.body;

	if (!email || !code) {
		throw new AppError("Email và mã xác thực là bắt buộc", 400);
	}

	const user = await User.findOne({
		email,
		resetPin: code,
		resetPinExpires: {$gt: new Date()},
	});

	if (!user) {
		throw new AppError("Mã xác thực không hợp lệ hoặc đã hết hạn", 400);
	}

	const resetToken = JWTService.generatePasswordResetToken(user._id);

	user.resetPin = undefined;
	user.resetPinExpires = undefined;
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Xác thực thành công!",
		data: {
			resetToken,
		},
	});
});

const resetPassword = asyncHandle(async (req, res) => {
	const {password, confirmPassword, resetToken} = req.body;

	if (!password || !confirmPassword || !resetToken) {
		throw new AppError("Tất cả các trường là bắt buộc", 400);
	}

	if (password !== confirmPassword) {
		throw new AppError("Mật khẩu xác nhận không khớp", 400);
	}

	let payload;
	try {
		payload = JWTService.verifyPasswordResetToken(resetToken);
	} catch (e) {
		throw new AppError("Token không hợp lệ hoặc đã hết hạn", 400);
	}

	const user = await User.findById(payload.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	user.password = await bcrypt.hash(password, 10);
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Đặt lại mật khẩu thành công!",
	});
});

const changePassword = asyncHandle(async (req, res) => {
	const {currentPassword, newPassword, confirmNewPassword} = req.body;

	if (!currentPassword || !newPassword || !confirmNewPassword) {
		throw new AppError("Tất cả các trường mật khẩu là bắt buộc", 400);
	}

	if (newPassword !== confirmNewPassword) {
		throw new AppError("Mật khẩu mới và xác nhận không khớp", 400);
	}

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	const isMatch = await bcrypt.compare(currentPassword, user.password);
	if (!isMatch) {
		throw new AppError("Mật khẩu hiện tại không đúng", 400);
	}

	user.password = await bcrypt.hash(newPassword, 10);
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Đổi mật khẩu thành công!",
	});
});

const resendVerificationEmail = asyncHandle(async (req, res) => {
	const {email} = req.body;

	if (!email) {
		throw new AppError("Email là bắt buộc", 400);
	}

	const user = await User.findOne({email});
	if (!user) {
		throw new AppError("Không tìm thấy người dùng với email này", 404);
	}

	if (user.isVerified) {
		throw new AppError("Tài khoản đã được xác minh", 400);
	}

	const verificationCode = Math.floor(
		100000 + Math.random() * 900000
	).toString();
	const verificationCodeExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

	user.verificationCode = verificationCode;
	user.verificationCodeExpires = verificationCodeExpires;
	await user.save();

	try {
		await sendMailHelper.resendAccountVerification(
			email,
			verificationCode,
			user.first_name
		);
	} catch (error) {
		console.log("Email sending failed:", error);
	}

	return res.status(200).json({
		success: true,
		message: "Mã xác minh mới đã được gửi về email!",
	});
});

const deactivateAccount = asyncHandle(async (req, res) => {
	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	user.is_active = false;
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Tài khoản đã được vô hiệu hóa thành công",
	});
});

const reactivateAccount = asyncHandle(async (req, res) => {
	const {email, password} = req.body;

	if (!email || !password) {
		throw new AppError("Email và mật khẩu là bắt buộc", 400);
	}

	const user = await User.findOne({email});
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (user.is_active) {
		throw new AppError("Tài khoản đã hoạt động", 400);
	}

	const isMatch = await bcrypt.compare(password, user.password);
	if (!isMatch) {
		throw new AppError("Mật khẩu không đúng", 401);
	}

	user.is_active = true;
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Tài khoản đã được kích hoạt lại thành công",
	});
});

const refreshToken = asyncHandle(async (req, res) => {
	const {refreshToken} = req.body;

	if (!refreshToken) {
		throw new AppError("Refresh token là bắt buộc", 400);
	}

	const user = await User.findOne({
		"refreshTokens.token": refreshToken,
	});

	if (!user) {
		throw new AppError("Refresh token không hợp lệ", 401);
	}

	const tokenRecord = user.refreshTokens.find(
		(t) => t.token === refreshToken
	);

	if (!tokenRecord) {
		throw new AppError("Refresh token không hợp lệ", 401);
	}

	if (JWTService.isRefreshTokenExpired(tokenRecord)) {
		user.refreshTokens = user.refreshTokens.filter(
			(t) => t.token !== refreshToken
		);
		await user.save();
		throw new AppError("Refresh token đã hết hạn", 401);
	}

	if (!user.is_active) {
		throw new AppError("Tài khoản đã bị vô hiệu hóa", 401);
	}

	if (!user.isVerified) {
		throw new AppError("Tài khoản chưa được xác minh", 401);
	}

	const newAccessToken = JWTService.generateAccessToken(user._id);
	const accessTokenExpiresAt = new Date(
		Date.now() + JWTService.getAccessTokenTTL()
	);

	let newRefreshToken = refreshToken;
	let refreshTokenExpiresAt = tokenRecord.expiresAt;

	const shouldRotateRefreshToken =
		process.env.ROTATE_REFRESH_TOKEN === "true";

	if (shouldRotateRefreshToken) {
		const tokens = JWTService.generateTokens(user._id);
		newRefreshToken = tokens.refreshToken;
		refreshTokenExpiresAt = tokens.refreshTokenExpiresAt;

		user.refreshTokens = user.refreshTokens.filter(
			(t) => t.token !== refreshToken
		);
		user.refreshTokens.push({
			token: newRefreshToken,
			expiresAt: refreshTokenExpiresAt,
			deviceInfo: tokenRecord.deviceInfo,
			ipAddress: tokenRecord.ipAddress,
		});

		await user.save();
	}

	return res.status(200).json({
		success: true,
		message: "Token đã được làm mới",
		data: {
			accessToken: newAccessToken,
			refreshToken: newRefreshToken,
			accessTokenExpiresAt,
			refreshTokenExpiresAt,
		},
	});
});

const logout = asyncHandle(async (req, res) => {
	const {refreshToken} = req.body;

	if (!refreshToken) {
		throw new AppError("Refresh token là bắt buộc", 400);
	}

	const user = await User.findOne({
		"refreshTokens.token": refreshToken,
	});

	if (user) {
		user.refreshTokens = user.refreshTokens.filter(
			(t) => t.token !== refreshToken
		);
		await user.save();
	}

	return res.status(200).json({
		success: true,
		message: "Đăng xuất thành công",
	});
});

const logoutAll = asyncHandle(async (req, res) => {
	const user = await User.findById(req.user.id);

	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	user.refreshTokens = [];
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Đăng xuất khỏi tất cả thiết bị thành công",
	});
});

const getActiveSessions = asyncHandle(async (req, res) => {
	const user = await User.findById(req.user.id).select("refreshTokens");

	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	const activeSessions = user.refreshTokens.filter(
		(token) => !JWTService.isRefreshTokenExpired(token)
	);

	if (activeSessions.length !== user.refreshTokens.length) {
		user.refreshTokens = activeSessions;
		await user.save();
	}

	const sessions = activeSessions.map((token) => ({
		id: token._id,
		deviceInfo: token.deviceInfo,
		ipAddress: token.ipAddress,
		createdAt: token.createdAt,
		expiresAt: token.expiresAt,
		isExpired: JWTService.isRefreshTokenExpired(token),
	}));

	return res.status(200).json({
		success: true,
		message: "Lấy danh sách phiên hoạt động thành công",
		data: {
			sessions,
			totalActiveSessions: sessions.length,
		},
	});
});

const revokeSession = asyncHandle(async (req, res) => {
	const {sessionId} = req.params;

	const user = await User.findById(req.user.id);

	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	const initialLength = user.refreshTokens.length;
	user.refreshTokens = user.refreshTokens.filter(
		(token) => token._id.toString() !== sessionId
	);

	if (user.refreshTokens.length === initialLength) {
		throw new AppError("Không tìm thấy phiên làm việc", 404);
	}

	await user.save();

	return res.status(200).json({
		success: true,
		message: "Thu hồi phiên làm việc thành công",
	});
});

const changeUsername = asyncHandle(async (req, res) => {
	const {newUsername} = req.body;

	if (!newUsername) {
		throw new AppError("Tên người dùng mới là bắt buộc", 400);
	}

	const usernameRegex = /^[a-zA-Z0-9_]{3,50}$/;
	if (!usernameRegex.test(newUsername)) {
		throw new AppError(
			"Tên người dùng phải có 3-50 ký tự và chỉ chứa chữ cái, số và dấu gạch dưới",
			400
		);
	}

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (user.username === newUsername) {
		throw new AppError("Tên người dùng mới giống với tên hiện tại", 400);
	}

	const existingUser = await User.findOne({username: newUsername});
	if (existingUser) {
		throw new AppError("Tên người dùng đã tồn tại", 400);
	}

	const oldUsername = user.username;
	user.username = newUsername;
	await user.save();

	return res.status(200).json({
		success: true,
		message: "Thay đổi tên người dùng thành công",
		data: {
			oldUsername,
			newUsername,
			user: {
				id: user._id,
				username: user.username,
				email: user.email,
				first_name: user.first_name,
				last_name: user.last_name,
				avatar: user.avatar,
			},
		},
	});
});

const changeEmail = asyncHandle(async (req, res) => {
	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	const changeEmailPin = Math.floor(
		100000 + Math.random() * 900000
	).toString();
	const changeEmailPinExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

	user.changeEmailPin = changeEmailPin;
	user.changeEmailPinExpires = changeEmailPinExpires;
	user.changeMailAuthHashCode = undefined;
	user.changeMailAuthHashCodeExpires = undefined;
	user.newEmail = undefined;
	user.newEmailPin = undefined;
	user.newEmailPinExpires = undefined;

	await user.save();

	try {
		await sendMailHelper.sendChangeEmailVerification(
			user.email,
			changeEmailPin,
			user.first_name
		);
	} catch (error) {
		throw new AppError("Không thể gửi email xác minh", 500);
	}

	return res.status(200).json({
		success: true,
		message: "Mã PIN đã được gửi đến email hiện tại của bạn",
		data: {
			email: user.email,
			expiresAt: changeEmailPinExpires,
		},
	});
});

const confirmChangeEmail = asyncHandle(async (req, res) => {
	const {pin} = req.body;

	if (!pin) {
		throw new AppError("Vui lòng nhập mã PIN", 400);
	}

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (
		user.changeEmailPin !== pin ||
		!user.changeEmailPinExpires ||
		user.changeEmailPinExpires < new Date()
	) {
		throw new AppError("Mã PIN không hợp lệ hoặc đã hết hạn", 400);
	}

	const changeMailAuthHashCode = crypto.randomBytes(32).toString("hex");
	const changeMailAuthHashCodeExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

	user.changeMailAuthHashCode = changeMailAuthHashCode;
	user.changeMailAuthHashCodeExpires = changeMailAuthHashCodeExpires;
	user.changeEmailPin = undefined;
	user.changeEmailPinExpires = undefined;

	await user.save();

	return res.status(200).json({
		success: true,
		message: "Xác minh thành công. Bạn có thể tiếp tục đổi email",
		data: {
			changeMailAuthHashCode,
			expiresAt: changeMailAuthHashCodeExpires,
		},
	});
});

const changeNewEmail = asyncHandle(async (req, res) => {
	const {newEmail, changeMailAuthHashCode} = req.body;

	if (!newEmail || !changeMailAuthHashCode) {
		throw new AppError("Vui lòng cung cấp email mới và mã xác thực", 400);
	}

	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (!emailRegex.test(newEmail)) {
		throw new AppError("Định dạng email không hợp lệ", 400);
	}

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (
		user.changeMailAuthHashCode !== changeMailAuthHashCode ||
		!user.changeMailAuthHashCodeExpires ||
		user.changeMailAuthHashCodeExpires < new Date()
	) {
		throw new AppError("Mã xác thực không hợp lệ hoặc đã hết hạn", 400);
	}

	if (user.email === newEmail) {
		throw new AppError(
			"Email mới không được trùng với email hiện tại",
			400
		);
	}

	const existingUser = await User.findOne({email: newEmail});
	if (existingUser) {
		throw new AppError("Email này đã được sử dụng bởi tài khoản khác", 400);
	}

	const newEmailPin = Math.floor(100000 + Math.random() * 900000).toString();
	const newEmailPinExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

	user.newEmail = newEmail;
	user.newEmailPin = newEmailPin;
	user.newEmailPinExpires = newEmailPinExpires;

	await user.save();

	try {
		await sendMailHelper.sendNewEmailVerification(
			newEmail,
			newEmailPin,
			user.first_name
		);
	} catch (error) {
		throw new AppError("Không thể gửi email xác minh đến địa chỉ mới", 500);
	}

	return res.status(200).json({
		success: true,
		message: "Mã PIN đã được gửi đến email mới",
		data: {
			newEmail: newEmail,
			expiresAt: newEmailPinExpires,
		},
	});
});

const completeChangeEmail = asyncHandle(async (req, res) => {
	const {pin} = req.body;

	if (!pin) {
		throw new AppError("Vui lòng nhập mã PIN", 400);
	}

	const user = await User.findById(req.user.id);
	if (!user) {
		throw new AppError("Không tìm thấy người dùng", 404);
	}

	if (
		user.newEmailPin !== pin ||
		!user.newEmailPinExpires ||
		user.newEmailPinExpires < new Date() ||
		!user.newEmail
	) {
		throw new AppError("Mã PIN không hợp lệ hoặc đã hết hạn", 400);
	}

	const oldEmail = user.email;
	const newEmail = user.newEmail;

	user.email = newEmail;

	user.changeEmailPin = undefined;
	user.changeEmailPinExpires = undefined;
	user.changeMailAuthHashCode = undefined;
	user.changeMailAuthHashCodeExpires = undefined;
	user.newEmail = undefined;
	user.newEmailPin = undefined;
	user.newEmailPinExpires = undefined;

	await user.save();

	try {
		await sendMailHelper.sendEmailChangeNotification(
			oldEmail,
			newEmail,
			user.first_name
		);
	} catch (error) {
		console.error("Failed to send email change notification:", error);
	}

	return res.status(200).json({
		success: true,
		message: "Đổi email thành công",
		data: {
			oldEmail,
			newEmail,
			user: {
				id: user._id,
				username: user.username,
				email: user.email,
				first_name: user.first_name,
				last_name: user.last_name,
			},
		},
	});
});

module.exports = {
	register,
	verify,
	login,
	getProfile,
	updateProfile,
	getUserData,
	checkUsernameExist,
	forgotPassword,
	verifyResetPin,
	resetPassword,
	changePassword,
	resendVerificationEmail,
	deactivateAccount,
	reactivateAccount,
	refreshToken,
	logout,
	logoutAll,
	getActiveSessions,
	revokeSession,
	changeUsername,
	changeEmail,
	confirmChangeEmail,
	changeNewEmail,
	completeChangeEmail,
};
