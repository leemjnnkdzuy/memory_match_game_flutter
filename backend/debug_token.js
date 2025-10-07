const jwt = require("jsonwebtoken");

// Sample token from logs (truncated)
const sampleToken =
	"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4ZDQwY2QxM2ZkMjllOTA4YTYxZjE0NSIsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3NTk3MjA4NTIsImV4cCI6MTc1OTgwNzI1MiwgImF1ZCI6Im1lbW9yeS1tYXRjaC1nYW1lLWNsaWVudCIsImlzcyI6Im1lbW9yeS1tYXRjaC1nYW1lIn0";

console.log("Token Analysis:");
console.log("Token length:", sampleToken.length);
console.log("Token parts:", sampleToken.split(".").length);

try {
	const decoded = jwt.decode(sampleToken);
	if (decoded) {
		console.log("- User ID:", decoded.id);
		console.log("- Token Type:", decoded.type);
		console.log("- Issued at:", new Date(decoded.iat * 1000));
		console.log("- Expires at:", new Date(decoded.exp * 1000));
		console.log("- Current time:", new Date());
		console.log(
			"- Time until expiry:",
			Math.round((decoded.exp * 1000 - Date.now()) / 1000 / 60),
			"minutes"
		);
		console.log("- Is expired:", decoded.exp * 1000 < Date.now());
	} else {
		console.log("Failed to decode token");
	}
} catch (e) {
	console.log("Error:", e.message);
}

// Load environment variables
require("dotenv").config();

// Check what the current ACCESS_TOKEN_EXPIRES_IN setting produces
const expiresIn = process.env.ACCESS_TOKEN_EXPIRES_IN || "1d";
console.log("\nCurrent ACCESS_TOKEN_EXPIRES_IN setting:", expiresIn);

// Calculate what 1d means
let ttlMs = 24 * 60 * 60 * 1000; // 1 day default
if (expiresIn.endsWith("m")) {
	ttlMs = parseInt(expiresIn) * 60 * 1000;
} else if (expiresIn.endsWith("h")) {
	ttlMs = parseInt(expiresIn) * 60 * 60 * 1000;
} else if (expiresIn.endsWith("d")) {
	ttlMs = parseInt(expiresIn) * 24 * 60 * 60 * 1000;
}

console.log("Token TTL in hours:", ttlMs / 1000 / 60 / 60);
