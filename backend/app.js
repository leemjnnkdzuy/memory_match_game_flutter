const express = require("express");
const http = require("http");
const dotenv = require("dotenv");
const connectDatabase = require("./src/utils/connectDatabase");
const corsConfig = require("./src/configs/corsConfig");
const apiRoutes = require("./src/configs/apiConfig");
const errorHandler = require("./src/middlewares/errorHandlerMiddleware");
const {initializeWebSocket} = require("./src/configs/webSocketConfig");
const {
	setupSoloDuelHandlers,
} = require("./src/controllers/soloDuelWebSocketController");

dotenv.config();
connectDatabase();

const app = express();
const server = http.createServer(app);

app.use(express.json({limit: "10mb"}));
app.use(corsConfig(false));

app.use("/api", apiRoutes);
app.get("/", (req, res) => {
	res.send("SERVER GAME MEMORY MATCH IS RUNNING");
});

app.use(errorHandler);

// Initialize WebSocket
const io = initializeWebSocket(server);

// Setup Solo Duel handlers
setupSoloDuelHandlers(io);

console.log("✅ Solo Duel WebSocket handlers initialized");

const PORT = process.env.PORT;

try {
	console.log(`Server is running on port ${PORT}`);
	server.listen(PORT);
} catch (error) {
	console.error("Server startup error:", error);
	process.exit(1);
}

module.exports = {app, server};
