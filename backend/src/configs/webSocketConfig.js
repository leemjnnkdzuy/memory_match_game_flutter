const socketIo = require("socket.io");
const {verifyAccessToken} = require("../utils/jwtService");
const {User} = require("../models/userModel");

let io;

const initializeWebSocket = (server) => {
	io = socketIo(server, {
		cors: {
			origin: process.env.CLIENT_URL || "http://localhost:3000",
			methods: ["GET", "POST"],
			credentials: true,
		},
		transports: ["websocket", "polling"],
	});

	io.use(async (socket, next) => {
		try {
			const token = socket.handshake.auth.token;
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

			console.log(
				`✅ User connected: ${socket.username} (${socket.userId})`
			);
			next();
		} catch (error) {
			if (error.message.includes("expired")) {
				console.log(`❌ Token expired for connection attempt`);
				return next(new Error("TOKEN_EXPIRED"));
			} else if (
				error.message.includes("invalid") ||
				error.message.includes("malformed")
			) {
				console.log(`❌ Invalid token format for connection attempt`);
				return next(new Error("TOKEN_INVALID"));
			} else {
				console.error(`❌ Auth error:`, error.message);
				return next(new Error("AUTHENTICATION_FAILED"));
			}
		}
	});

	return io;
};

const getIO = () => {
	if (!io) {
		throw new Error("Socket.io not initialized");
	}
	return io;
};

module.exports = {initializeWebSocket, getIO};
