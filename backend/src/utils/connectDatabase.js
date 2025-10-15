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

		console.log("Kết nối MongoDB thành công");
		return true;
	} catch (error) {
		console.error("Kết nối MongoDB thất bại:", error);
		return false;
	}
};

module.exports = {connectDatabase};
