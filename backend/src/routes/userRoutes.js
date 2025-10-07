const express = require("express");
const router = express.Router();
const {authenticate} = require("../middlewares/authMiddleware");
const {
	register,
	verify,
	login,
	getProfile,
	updateProfile,
	getUserData,
	checkUsernameExist,
	forgotPassword,
	verifyResetPin,
	resetPassword,
	changePassword,
	resendVerificationEmail,
	deactivateAccount,
	reactivateAccount,
	refreshToken,
	logout,
	logoutAll,
	getActiveSessions,
	revokeSession,
	changeUsername,
	changeEmail,
	confirmChangeEmail,
	changeNewEmail,
	completeChangeEmail,
} = require("../controllers/userController");

router.post("/register", register);
router.post("/verify", verify);
router.post("/login", login);

router.post("/check-username-exist", checkUsernameExist);

router.post("/forgot-password", forgotPassword);
router.post("/verify-reset-pin", verifyResetPin);
router.post("/reset-password", resetPassword);
router.post("/resend-verification-email", resendVerificationEmail);

router.post("/reactivate-account", reactivateAccount);

router.post("/refresh-token", refreshToken);
router.post("/logout", logout);
router.get("/user/:idOrUserName", getUserData);

router.use(authenticate);

router.put("/change-username", changeUsername);
router.get("/profile", getProfile);
router.put("/profile", updateProfile);
router.post("/change-password", changePassword);
router.post("/deactivate-account", deactivateAccount);
router.post("/logout-all", logoutAll);
router.get("/sessions", getActiveSessions);
router.delete("/sessions/:sessionId", revokeSession);
router.get("/change-email", changeEmail);
router.post("/confirm-change-email", confirmChangeEmail);
router.post("/change-new-email", changeNewEmail);
router.put("/complete-change-email", completeChangeEmail);

module.exports = router;
