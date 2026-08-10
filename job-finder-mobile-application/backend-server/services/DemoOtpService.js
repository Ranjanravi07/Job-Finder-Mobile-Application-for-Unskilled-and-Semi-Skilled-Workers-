const OtpService = require('./OtpService');

class DemoOtpService extends OtpService {
  constructor() {
    super();
    // In-memory map: { phone: { code: "123456", expiresAt: Date, attempts: number } }
    this.otpStore = new Map();
  }

  generateCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async sendOtp(phone, channel) {
    const code = this.generateCode();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes expiration
    
    this.otpStore.set(phone, {
      code,
      expiresAt,
      attempts: 0
    });

    console.log('\n=============================================');
    console.log(`🚀 [DEMO OTP SYSTEM]`);
    console.log(`📱 Phone: ${phone}`);
    console.log(`🔑 Code:  ${code}`);
    console.log(`⏱️ Expires in: 5 minutes`);
    console.log('=============================================\n');

    return {
      success: true,
      message: 'Demo OTP generated successfully.',
      channel
    };
  }

  async verifyOtp(phone, code) {
    const record = this.otpStore.get(phone);

    if (!record) {
      const error = new Error('Verification code is invalid or has already been used.');
      error.code = 'invalid_code';
      throw error;
    }

    if (Date.now() > record.expiresAt) {
      this.otpStore.delete(phone);
      const error = new Error('Your verification code has expired. Please request a new code.');
      error.code = 'expired';
      throw error;
    }

    if (record.attempts >= 3) {
      this.otpStore.delete(phone);
      const error = new Error('Too many verification attempts. Please request a new code.');
      error.code = 'too_many_attempts';
      throw error;
    }

    record.attempts += 1;

    if (record.code !== code) {
      const error = new Error('Incorrect verification code.');
      error.code = 'invalid_code';
      throw error;
    }

    // Success! Clean up the used OTP.
    this.otpStore.delete(phone);
    return { success: true };
  }
}

module.exports = DemoOtpService;
