const socketIo = require("socket.io");
const {verifyAccessToken} = require("../utils/jwtService");
const {User} = require("../models/userModel");
const AppError = require("../utils/errors");

let io;

const initializeWebSocket = (server) => {
	io = socketIo(server, {
		cors: {
			origin: true,
			methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
			credentials: true,
			allowedHeaders: ["Content-Type", "Authorization"],
		},
		transports: ["polling", "websocket"],
		allowUpgrades: true,
		pingTimeout: 60000,
		pingInterval: 25000,
		upgradeTimeout: 30000,
		maxHttpBufferSize: 1e6,
		allowEIO3: true,
	});

	io.use(async (socket, next) => {
		try {
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
				"username email is_active isVerified avatar borderColor"
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
			socket.avatar = user.avatar || null;
			socket.borderColor = user.borderColor || "#4CAF50";
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
