const socketIo = require("socket.io");
const {verifyAccessToken} = require("../utils/jwtService");
const {User} = require("../models/userModel");
const AppError = require("../utils/errors");

let io;

const initializeWebSocket = (server) => {
	io = socketIo(server, {
		cors: {
			origin: process.env.CLIENT_URL,
			methods: ["GET", "POST"],
			credentials: true,
		},
		transports: ["websocket", "polling"],
	});

	io.use(async (socket, next) => {
		try {
			// Lấy token từ auth hoặc query
			const token =
				socket.handshake.auth.token || socket.handshake.query.token;
			if (!token) {
				return next(new Error("No authentication token provided"));
			}

			const decoded = verifyAccessToken(token);
			socket.userId =
				decoded.userId || decoded.id || decoded._id || decoded.sub;

			if (!socket.userId) {
				return next(new Error("Invalid token payload - no user ID"));
			}

			const user = await User.findById(socket.userId).select(
				"username email is_active isVerified"
			);

			if (!user) {
				return next(new Error("User not found"));
			}

			if (!user.is_active || !user.isVerified) {
				return next(
					new Error("User account is inactive or not verified")
				);
			}

			socket.userId = socket.userId;
			socket.username = user.username;
			socket.email = user.email;
			next();
		} catch (error) {
			if (error.message.includes("expired")) {
				return next(new Error("TOKEN_EXPIRED"));
			} else if (
				error.message.includes("invalid") ||
				error.message.includes("malformed")
			) {
				return next(new Error("TOKEN_INVALID"));
			} else {
				return next(new Error("AUTHENTICATION_FAILED"));
			}
		}
	});

	return io;
};

const getIO = () => {
	if (!io) {
		throw new AppError("Socket.io not initialized", 500);
	}
	return io;
};

module.exports = {initializeWebSocket, getIO};
