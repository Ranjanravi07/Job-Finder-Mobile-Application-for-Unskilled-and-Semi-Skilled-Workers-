class OtpService {
  /**
   * Send an OTP to the specified phone number.
   * @param {string} phone - Normalized phone number.
   * @param {string} channel - 'sms' or 'whatsapp'.
   * @returns {Promise<{success: boolean, message: string, channel: string}>}
   */
  async sendOtp(phone, channel) {
    throw new Error('Not implemented');
  }

  /**
   * Verify an OTP for the specified phone number.
   * @param {string} phone - Normalized phone number.
   * @param {string} code - The 6-digit code.
   * @returns {Promise<{success: boolean, message?: string}>} - Throws on failure.
   */
  async verifyOtp(phone, code) {
    throw new Error('Not implemented');
  }
}

module.exports = OtpService;
