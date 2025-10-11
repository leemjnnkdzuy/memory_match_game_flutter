const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const AppError = require("./errors");

class JWTService {
	static generateAccessToken(userId) {
		return jwt.sign(
			{
				id: userId,
				type: "access",
			},
			process.env.JWT_SECRET,
			{
				expiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || "1d",
				issuer: "memory-match-game",
				audience: "memory-match-game-client",
			}
		);
	}

	static generateRefreshToken() {
		return crypto.randomBytes(64).toString("hex");
	}

	static generateTokens(userId) {
		const accessToken = this.generateAccessToken(userId);
		const refreshToken = this.generateRefreshToken();

		return {
			accessToken,
			refreshToken,
			accessTokenExpiresAt: new Date(
				Date.now() + this.getAccessTokenTTL()
			),
			refreshTokenExpiresAt: new Date(
				Date.now() + this.getRefreshTokenTTL()
			),
		};
	}

	static getAccessTokenTTL() {
		const expiry = process.env.ACCESS_TOKEN_EXPIRES_IN || "1d";
		if (expiry.endsWith("m")) {
			return parseInt(expiry) * 60 * 1000;
		}
		if (expiry.endsWith("h")) {
			return parseInt(expiry) * 60 * 60 * 1000;
		}
		if (expiry.endsWith("d")) {
			return parseInt(expiry) * 24 * 60 * 60 * 1000;
		}
		return 15 * 60 * 1000;
	}

	static getRefreshTokenTTL() {
		const expiry = process.env.REFRESH_TOKEN_EXPIRES_IN || "30d";
		if (expiry.endsWith("m")) {
			return parseInt(expiry) * 60 * 1000;
		}
		if (expiry.endsWith("h")) {
			return parseInt(expiry) * 60 * 60 * 1000;
		}
		if (expiry.endsWith("d")) {
			return parseInt(expiry) * 24 * 60 * 60 * 1000;
		}
		return 30 * 24 * 60 * 60 * 1000;
	}

	static verifyAccessToken(token) {
		try {
			const decoded = jwt.verify(token, process.env.JWT_SECRET, {
				issuer: "memory-match-game",
				audience: "memory-match-game-client",
			});

			if (decoded.type !== "access") {
				throw new AppError("Invalid token type", 401);
			}

			return decoded;
		} catch (error) {
			if (error.name === "TokenExpiredError") {
				throw new AppError("Token expired", 401);
			} else if (error.name === "JsonWebTokenError") {
				throw new AppError("Token invalid", 401);
			} else if (error.name === "NotBeforeError") {
				throw new AppError("Token not active", 401);
			} else {
				throw new AppError("Token verification failed", 401);
			}
		}
	}

	static isValidTokenFormat(token) {
		if (!token || typeof token !== "string") {
			return false;
		}

		const parts = token.split(".");
		return parts.length === 3;
	}

	static extractTokenFromHeader(authHeader) {
		if (!authHeader || !authHeader.startsWith("Bearer ")) {
			return null;
		}
		return authHeader.split(" ")[1];
	}

	static generatePasswordResetToken(userId) {
		return jwt.sign(
			{
				id: userId,
				type: "reset",
			},
			process.env.JWT_SECRET,
			{
				expiresIn: "15m",
				issuer: "memory-match-game",
				audience: "memory-match-game-client",
			}
		);
	}

	static verifyPasswordResetToken(token) {
		try {
			const decoded = jwt.verify(token, process.env.JWT_SECRET, {
				issuer: "memory-match-game",
				audience: "memory-match-game-client",
			});

			if (decoded.type !== "reset") {
				throw new AppError("Invalid token type", 401);
			}

			return decoded;
		} catch (error) {
			throw new AppError("Invalid or expired reset token", 401);
		}
	}

	static getDeviceInfo(req) {
		const userAgent = req.get("User-Agent") || "Unknown";
		const platform = req.get("X-Platform") || "Unknown";
		const version = req.get("X-App-Version") || "Unknown";

		return `${platform} ${version} (${userAgent})`.substring(0, 255);
	}

	static getClientIP(req) {
		return (
			req.ip ||
			req.connection.remoteAddress ||
			req.socket.remoteAddress ||
			(req.connection.socket
				? req.connection.socket.remoteAddress
				: null) ||
			req.get("X-Forwarded-For") ||
			req.get("X-Real-IP") ||
			"Unknown"
		);
	}

	static isRefreshTokenExpired(token) {
		return new Date() > new Date(token.expiresAt);
	}
}

module.exports = JWTService;
