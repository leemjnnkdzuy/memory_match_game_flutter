const mongoose = require("mongoose");

const connectDatabase = async () => {
	try {
		const username = encodeURIComponent(process.env.MONGODB_USER);
		const password = encodeURIComponent(process.env.MONGODB_PASSWORD);
		const cluster = encodeURIComponent(process.env.MONGODB_CLUSTER);
		const database = encodeURIComponent(process.env.MONGODB_DATABASE);

		const uri = `mongodb+srv://${username}:${password}@${cluster}/${database}?retryWrites=true&w=majority`;

		await mongoose.connect(uri, {
			serverSelectionTimeoutMS: 5000,
			socketTimeoutMS: 45000,
		});

		console.log("MongoDB connected successfully");
	} catch (error) {
		console.error("MongoDB connection error:", error);
		process.exit(1);
	}
};

module.exports = connectDatabase;
