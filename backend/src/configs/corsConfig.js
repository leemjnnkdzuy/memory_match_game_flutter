const cors = require("cors");

const setupCorsConfig = (enableCors) => {
	const whitelist = [/^.*$/];

	let corsOptions;

	if (enableCors) {
		corsOptions = {
			origin(origin, cb) {
				if (!origin) return cb(null, true);
				if (origin === "null") return cb(null, true);
				const ok = whitelist.some((re) => re.test(origin));
				cb(
					ok
						? null
						: new Error(`CORS policy: Origin ${origin} not allowed`),
					ok
				);
			},
			credentials: true,
			methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
			allowedHeaders: ["Content-Type", "Authorization", "X-API-Key"],
			preflightContinue: false,
			optionsSuccessStatus: 204,
		};
	} else {
		corsOptions = {
			origin: "*",
			methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
			allowedHeaders: ["Content-Type", "Authorization", "X-API-Key"],
			preflightContinue: false,
			optionsSuccessStatus: 204,
		};
	}

	return cors(corsOptions);
};

module.exports = setupCorsConfig;
