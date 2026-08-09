const rateLimit = require('express-rate-limit');

const sendOtpRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 3, // Limit each IP to 3 OTP requests per `window`
  message: { success: false, message: 'Please wait before requesting another verification code.' },
  standardHeaders: true, 
  legacyHeaders: false, 
});

const verifyOtpRateLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // Limit each IP to 10 verification requests per `window`
  message: { success: false, message: 'Too many verification attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  sendOtpRateLimiter,
  verifyOtpRateLimiter
};
