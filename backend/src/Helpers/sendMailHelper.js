const nodemailer = require("nodemailer");

const sendMailHelper = async (options) => {
	try {
		const transporter = nodemailer.createTransport({
			service: "gmail",
			auth: {
				user: process.env.MAILUSERTOSEND,
				pass: process.env.MAILPASSWORDTOSEND,
			},
		});

		const mailOptions = {
			from: `"Account Verification" <${process.env.MAILUSERTOSEND}>`,
			to: options.email,
			subject: options.subject,
			html: options.html,
		};

		const info = await transporter.sendMail(mailOptions);
		console.log("Email sent:", info.response);
		return true;
	} catch (error) {
		console.error("Error sending email:", error);
		return false;
	}
};

sendMailHelper.sendChangeEmailVerification = async (email, pin, firstName) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Xác nhận thay đổi email</h2>
			<p>Xin chào ${firstName},</p>
			<p>Bạn đã yêu cầu thay đổi địa chỉ email. Để tiếp tục, vui lòng sử dụng mã PIN sau:</p>
			<div style="background-color: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
				${pin}
			</div>
			<p>Mã PIN này có hiệu lực trong 10 phút.</p>
			<p>Nếu bạn không yêu cầu thay đổi email, vui lòng bỏ qua email này và đảm bảo tài khoản của bạn an toàn.</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email,
		subject: "Xác nhận thay đổi email",
		html,
	});
};

sendMailHelper.sendNewEmailVerification = async (email, pin, firstName) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Xác minh địa chỉ email mới</h2>
			<p>Xin chào ${firstName},</p>
			<p>Bạn đang trong quá trình thay đổi địa chỉ email cho tài khoản của mình. Để hoàn tất, vui lòng sử dụng mã PIN sau:</p>
			<div style="background-color: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
				${pin}
			</div>
			<p>Mã PIN này có hiệu lực trong 10 phút.</p>
			<p>Nếu bạn không yêu cầu thay đổi này, vui lòng liên hệ với chúng tôi ngay lập tức.</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email,
		subject: "Xác minh email mới",
		html,
	});
};

sendMailHelper.sendEmailChangeNotification = async (
	oldEmail,
	newEmail,
	firstName
) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Thông báo thay đổi email</h2>
			<p>Xin chào ${firstName},</p>
			<p>Email đăng nhập cho tài khoản của bạn đã được thay đổi thành công.</p>
			<div style="background-color: #f9f9f9; border-left: 4px solid #4CAF50; padding: 15px; margin: 20px 0;">
				<p style="margin: 5px 0;"><strong>Email cũ:</strong> ${oldEmail}</p>
				<p style="margin: 5px 0;"><strong>Email mới:</strong> ${newEmail}</p>
			</div>
			<p>Từ giờ trở đi, vui lòng sử dụng email mới để đăng nhập.</p>
			<p style="color: #d32f2f; font-weight: bold;">Nếu bạn không thực hiện thay đổi này, tài khoản của bạn có thể đã bị xâm nhập. Vui lòng liên hệ với chúng tôi ngay lập tức!</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email: oldEmail,
		subject: "Thông báo: Email tài khoản đã được thay đổi",
		html,
	});
};

sendMailHelper.sendAccountVerification = async (
	email,
	verificationCode,
	firstName
) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Xác minh tài khoản Memory Match Game</h2>
			<p>Xin chào ${firstName},</p>
			<p>Cảm ơn bạn đã đăng ký tài khoản Memory Match Game. Để hoàn tất quá trình đăng ký, vui lòng sử dụng mã xác minh sau:</p>
			<div style="background-color: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
				${verificationCode}
			</div>
			<p>Mã này sẽ hết hạn sau 15 phút.</p>
			<p>Nếu bạn không thực hiện đăng ký này, vui lòng bỏ qua email này.</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email,
		subject: "Xác minh tài khoản Memory Match Game",
		html,
	});
};

sendMailHelper.sendPasswordResetPin = async (email, resetPin, firstName) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Khôi phục mật khẩu</h2>
			<p>Xin chào ${firstName},</p>
			<p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Memory Match Game của mình. Để tiếp tục, vui lòng sử dụng mã xác thực sau:</p>
			<div style="background-color: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
				${resetPin}
			</div>
			<p>Mã này sẽ hết hạn sau 10 phút.</p>
			<p style="color: #d32f2f; font-weight: bold;">Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này và đảm bảo tài khoản của bạn an toàn.</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email,
		subject: "Khôi phục mật khẩu Memory Match Game",
		html,
	});
};

sendMailHelper.resendAccountVerification = async (
	email,
	verificationCode,
	firstName
) => {
	const html = `
		<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
			<h2 style="color: #333;">Gửi lại mã xác minh</h2>
			<p>Xin chào ${firstName},</p>
			<p>Theo yêu cầu của bạn, đây là mã xác minh mới để hoàn tất quá trình đăng ký tài khoản Memory Match Game:</p>
			<div style="background-color: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
				${verificationCode}
			</div>
			<p>Mã này sẽ hết hạn sau 15 phút.</p>
			<p>Nếu bạn không yêu cầu gửi lại mã xác minh, vui lòng bỏ qua email này.</p>
			<p style="color: #888; font-size: 12px; margin-top: 30px;">Email này được gửi tự động, vui lòng không trả lời.</p>
		</div>
	`;

	return sendMailHelper({
		email,
		subject: "Gửi lại mã xác minh - Memory Match Game",
		html,
	});
};

module.exports = sendMailHelper;
