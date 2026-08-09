require('dotenv').config();

const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;

if (!accountSid || !authToken) {
  console.error('Missing TWILIO_ACCOUNT_SID or TWILIO_AUTH_TOKEN');
  process.exit(1);
}

const client = twilio(accountSid, authToken);

async function createService() {
  try {
    const service = await client.verify.v2.services.create({
      friendlyName: 'Job Finder OTP',
      codeLength: 6
    });

    console.log('\n================================');
    console.log('VERIFY SERVICE CREATED');
    console.log('================================');
    console.log('Service Name:', service.friendlyName);
    console.log('Service SID:', service.sid);
    console.log('================================\n');

  } catch (error) {
    console.error('Failed to create Verify Service:');
    console.error(error.message);
  }
}

createService();