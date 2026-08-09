const OtpService = require('./OtpService');
const {
  client: twilioClient,
  verifyServiceSid,
} = require('./twilioClient');

class TwilioOtpService extends OtpService {
  async sendOtp(phone, channel) {
    if (!twilioClient || !verifyServiceSid) {
      console.error('Twilio Verify is not configured.');
      const error = new Error('OTP service is temporarily unavailable.');
      error.code = 'unavailable';
      throw error;
    }

    try {
      const verification = await twilioClient.verify.v2
        .services(verifyServiceSid)
        .verifications
        .create({
          to: phone,
          channel: channel,
        });

      console.log(`Twilio verification started: ${phone} | ${channel} | ${verification.status}`);

      return {
        success: true,
        message: 'Verification code sent successfully.',
        channel
      };
    } catch (error) {
      console.error('Failed to send Twilio verification:', error.message);

      // Twilio rate limit
      if (error.code === 60203 || error.code === 20429) {
        const customError = new Error('Please wait before requesting another code.');
        customError.code = 'rate_limit';
        throw customError;
      }

      if (channel === 'whatsapp') {
        const customError = new Error('Unable to send WhatsApp verification right now. Try SMS instead.');
        customError.code = 'whatsapp_failed';
        throw customError;
      }

      const customError = new Error('Unable to send SMS right now. Please try again.');
      customError.code = 'sms_failed';
      throw customError;
    }
  }

  async verifyOtp(phone, code) {
    if (!twilioClient || !verifyServiceSid) {
      console.error('Twilio Verify is not configured.');
      const error = new Error('OTP service is temporarily unavailable.');
      error.code = 'unavailable';
      throw error;
    }

    let verificationCheck;
    try {
      verificationCheck = await twilioClient.verify.v2
        .services(verifyServiceSid)
        .verificationChecks
        .create({
          to: phone,
          code: code,
        });
    } catch (error) {
      console.error('Twilio verification failed:', error.message);

      if (error.code === 20404) {
        const customError = new Error('Your verification code has expired. Please request a new code.');
        customError.code = 'expired';
        throw customError;
      }

      if (error.code === 60202) {
        const customError = new Error('Too many verification attempts. Please request a new code.');
        customError.code = 'too_many_attempts';
        throw customError;
      }

      const customError = new Error('Incorrect verification code.');
      customError.code = 'invalid_code';
      throw customError;
    }

    if (verificationCheck.status !== 'approved') {
      const error = new Error('Incorrect verification code.');
      error.code = 'invalid_code';
      throw error;
    }

    return { success: true };
  }
}

module.exports = TwilioOtpService;
