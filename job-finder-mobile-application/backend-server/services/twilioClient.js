const twilio = require('twilio');

const accountSid =
  process.env.TWILIO_ACCOUNT_SID || '';

const authToken =
  process.env.TWILIO_AUTH_TOKEN || '';

const verifyServiceSid =
  process.env.TWILIO_VERIFY_SERVICE_SID || '';

let client = null;

if (accountSid && authToken) {

  client = twilio(
    accountSid,
    authToken
  );

  console.log(
    'Twilio client initialized successfully.'
  );

} else {

  console.error(
    'Twilio credentials missing. Check TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN.'
  );
}

module.exports = {
  client,
  verifyServiceSid,
};