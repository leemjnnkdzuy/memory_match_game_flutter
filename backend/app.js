const express = require("express");
const cors = require("cors");
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
const io = initializeWebSocket(server);
const PORT = process.env.PORT;

app.use(express.json({limit: "20mb"}));
app.use(corsConfig(false));

app.use("/api", apiRoutes);
app.get("/", (req, res) => {
	res.send("Máy chủ đang hoạt động!");
});

app.use(errorHandler);

setupSoloDuelHandlers(io);

try {
	server.listen(PORT);
	console.log(`Server đang chạy trên cổng ${PORT}`);
} catch (error) {
	console.error("Lỗi khởi động máy chủ:", error);
	process.exit(1);
}

module.exports = {app, server};
