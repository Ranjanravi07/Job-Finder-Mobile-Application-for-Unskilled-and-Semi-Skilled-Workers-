require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const {
  isValidNepalPhone,
  normalizePhone,
} = require('./utils/phone');

const DemoOtpService = require('./services/DemoOtpService');
const TwilioOtpService = require('./services/TwilioOtpService');

// Use Demo OTP by default for college demo unless explicitly set to false
const useDemoOtp = process.env.USE_DEMO_OTP !== 'false';
const otpService = useDemoOtp ? new DemoOtpService() : new TwilioOtpService();

const {
  sendOtpRateLimiter,
  verifyOtpRateLimiter
} = require('./middleware/rateLimiter');

// In-memory store for OTP cooldowns
const otpCooldowns = new Map();


// ============================================================
// Firebase Admin Initialization
// ============================================================

try {
  let serviceAccount;

  try {
    serviceAccount = require('./serviceAccountKey.json');
  } catch (error) {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      serviceAccount = JSON.parse(
        process.env.FIREBASE_SERVICE_ACCOUNT
      );
    }
  }

  if (serviceAccount) {
    initializeApp({
      credential: cert(serviceAccount),
    });

    console.log(
      'Firebase Admin initialized successfully with Service Account Key.'
    );
  } else {
    initializeApp();

    console.warn(
      'WARNING: FIREBASE_SERVICE_ACCOUNT not set. Using default credentials.'
    );
  }
} catch (error) {
  console.error(
    'Firebase Admin initialization failed:',
    error.message
  );

  process.exit(1);
}


// ============================================================
// Firebase Services
// ============================================================

const auth = getAuth();
const db = getFirestore();


// ============================================================
// Express
// ============================================================

const app = express();

app.use(helmet());

app.use(
  cors({
    origin: ['http://localhost:5173', 'http://127.0.0.1:5173', 'http://localhost:3000'],
    methods: ['GET', 'POST'],
  })
);

app.use(express.json({ limit: '1mb' }));

app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
});


// ============================================================
// Helper Functions
// ============================================================

function validatePhoneNumber(rawPhone) {
  if (!rawPhone || typeof rawPhone !== 'string') {
    return {
      valid: false,
      message: 'Please enter a valid Nepal mobile number.',
    };
  }

  if (!isValidNepalPhone(rawPhone)) {
    return {
      valid: false,
      message: 'Please enter a valid Nepal mobile number.',
    };
  }

  return {
    valid: true,
    phone: normalizePhone(rawPhone),
  };
}


function normalizePurpose(purpose) {
  if (
    purpose !== 'registration' &&
    purpose !== 'login'
  ) {
    return null;
  }

  return purpose;
}


function normalizeRole(role) {
  if (
    role !== 'worker' &&
    role !== 'employer'
  ) {
    return null;
  }

  return role;
}


// ============================================================
// Health Check
// ============================================================

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Job Finder backend is running.',
  });
});


// ============================================================
// SEND OTP
// ============================================================

app.post(
  '/api/auth/send-otp',
  sendOtpRateLimiter,
  async (req, res) => {

    try {
      const {
        phoneNumber: rawPhone,
        channel = 'sms',
        purpose = 'login',
      } = req.body;

      // --------------------------------------------------------
      // Validate phone
      // --------------------------------------------------------

      const phoneResult = validatePhoneNumber(rawPhone);

      if (!phoneResult.valid) {
        return res.status(400).json({
          success: false,
          message: phoneResult.message,
        });
      }

      const phone = phoneResult.phone;

      // --------------------------------------------------------
      // Check 60-second resend cooldown
      // --------------------------------------------------------
      const now = Date.now();
      const lastSentAt = otpCooldowns.get(phone);
      if (lastSentAt && (now - lastSentAt < 60000)) {
        return res.status(429).json({
          success: false,
          message: 'Please wait before requesting another verification code.',
        });
      }


      // --------------------------------------------------------
      // Validate purpose
      // --------------------------------------------------------

      const normalizedPurpose = normalizePurpose(purpose);

      if (!normalizedPurpose) {
        return res.status(400).json({
          success: false,
          message: 'Invalid OTP purpose.',
        });
      }


      // --------------------------------------------------------
      // Validate channel
      // --------------------------------------------------------

      if (
        channel !== 'sms' &&
        channel !== 'whatsapp'
      ) {
        return res.status(400).json({
          success: false,
          message: 'Invalid OTP delivery method.',
        });
      }


      // --------------------------------------------------------
      // Send OTP via OtpService
      // --------------------------------------------------------

      try {
        const result = await otpService.sendOtp(phone, channel);

        // Update cooldown
        otpCooldowns.set(phone, Date.now());

        return res.json({
          success: true,
          message: result.message,
          channel,
          purpose: normalizedPurpose,
        });

      } catch (error) {
        console.error('Failed to send OTP:', error.message);

        if (error.code === 'rate_limit') {
          return res.status(429).json({
            success: false,
            message: error.message,
          });
        }
        if (error.code === 'unavailable') {
          return res.status(503).json({
            success: false,
            message: error.message,
          });
        }

        return res.status(500).json({
          success: false,
          message: error.message || 'Unable to send OTP right now.',
        });
      }

    } catch (error) {

      console.error(
        'sendOtp error:',
        error.message
      );

      return res.status(500).json({
        success: false,
        message:
          'Server error occurred.',
      });
    }
  }
);


// ============================================================
// VERIFY OTP
// ============================================================

app.post(
  '/api/auth/verify-otp',
  verifyOtpRateLimiter,
  async (req, res) => {

    try {

      const {
        phoneNumber: rawPhone,
        otp,
        purpose = 'login',
      } = req.body;


      // --------------------------------------------------------
      // Validate input
      // --------------------------------------------------------

      if (
        !rawPhone ||
        typeof rawPhone !== 'string'
      ) {

        return res.status(400).json({
          success: false,
          message:
            'Phone number is required.',
        });
      }


      if (
        !otp ||
        typeof otp !== 'string'
      ) {

        return res.status(400).json({
          success: false,
          message:
            'Verification code is required.',
        });
      }


      // --------------------------------------------------------
      // Validate OTP format
      // --------------------------------------------------------

      const cleanOtp = otp.trim();

      if (!/^\d{6}$/.test(cleanOtp)) {

        return res.status(400).json({
          success: false,
          message:
            'Please enter a valid 6-digit verification code.',
        });
      }


      // --------------------------------------------------------
      // Validate phone
      // --------------------------------------------------------

      const phoneResult = validatePhoneNumber(rawPhone);

      if (!phoneResult.valid) {

        return res.status(400).json({
          success: false,
          message:
            phoneResult.message,
        });
      }

      const phone = phoneResult.phone;


      // --------------------------------------------------------
      // Validate purpose
      // --------------------------------------------------------

      const normalizedPurpose =
        normalizePurpose(purpose);

      if (!normalizedPurpose) {

        return res.status(400).json({
          success: false,
          message:
            'Invalid OTP purpose.',
        });
      }


      // --------------------------------------------------------
      // Verify OTP through OtpService
      // --------------------------------------------------------

      try {
        await otpService.verifyOtp(phone, cleanOtp);
      } catch (error) {
        console.error('OTP verification failed:', error.message);

        if (error.code === 'unavailable') {
          return res.status(503).json({
            success: false,
            message: error.message,
          });
        }
        if (error.code === 'rate_limit' || error.code === 'too_many_attempts') {
          return res.status(429).json({
            success: false,
            message: error.message,
          });
        }

        return res.status(400).json({
          success: false,
          message: error.message || 'Incorrect verification code.',
        });
      }


      console.log(
        `Phone verification successful: ${phone}`
      );


      // ========================================================
      // LOGIN FLOW
      // ========================================================

      if (normalizedPurpose === 'login') {

        let userRecord;

        try {
          userRecord = await auth.getUserByPhoneNumber(phone);
        } catch (error) {
          if (error.code === 'auth/user-not-found') {
            try {
              userRecord = await auth.createUser({
                phoneNumber: phone,
              });
            } catch (createErr) {
              console.error('Firebase user creation failed:', createErr.message);
              return res.status(500).json({
                success: false,
                message: 'Unable to complete authentication.',
              });
            }
          } else {
            console.error('Firebase user lookup failed:', error.message);
            return res.status(500).json({
              success: false,
              message: 'Authentication failed.',
            });
          }
        }


        // ------------------------------------------------------
        // Create Firebase Custom Token
        // ------------------------------------------------------

        const customToken =
          await auth.createCustomToken(
            userRecord.uid
          );


        return res.json({
          success: true,
          verified: true,
          isNewUser: false,
          uid: userRecord.uid,
          token: customToken,
        });
      }


      // ========================================================
      // REGISTRATION FLOW
      // ========================================================

      if (
        normalizedPurpose === 'registration'
      ) {

        // ------------------------------------------------------
        // Make sure user still doesn't exist
        // ------------------------------------------------------

        try {

          await auth.getUserByPhoneNumber(phone);

          return res.status(409).json({
            success: false,
            message:
              'An account with this phone number already exists. Please login instead.',
          });

        } catch (error) {

          if (
            error.code !== 'auth/user-not-found'
          ) {

            console.error(
              'Registration verification check failed:',
              error.message
            );

            return res.status(500).json({
              success: false,
              message:
                'Unable to complete registration.',
            });
          }
        }


        // ------------------------------------------------------
        // Phone is verified.
        // Create the Firebase user here and return the custom
        // token so Flutter can sign in immediately and perform
        // its profile writes to Firestore.
        // ------------------------------------------------------

        let userRecord;
        try {
          userRecord = await auth.createUser({
            phoneNumber: phone,
          });
        } catch (error) {
          console.error('Firebase user creation failed:', error.message);
          return res.status(500).json({
            success: false,
            message: 'Unable to create account right now.',
          });
        }

        let customToken;
        try {
          customToken = await auth.createCustomToken(userRecord.uid);
        } catch (error) {
          console.error('Custom token creation failed:', error.message);
          return res.status(500).json({
            success: false,
            message: 'Unable to authenticate account right now.',
          });
        }

        return res.json({
          success: true,
          verified: true,
          isNewUser: true,
          uid: userRecord.uid,
          token: customToken,
          phoneNumber: phone,
          message:
            'Phone number verified successfully. Continue registration.',
        });
      }

    } catch (error) {

      console.error(
        'verifyOtp error:',
        error.message
      );

      return res.status(500).json({
        success: false,
        message:
          'Server error occurred.',
      });
    }
  }
);


// ============================================================
// REGISTER USER
// ============================================================
//
// This endpoint creates the Firebase Authentication account
// AFTER OTP verification and after the user has selected
// Worker or Employer.
//
// Expected request:
//
// {
//   phoneNumber: "98XXXXXXXX",
//   role: "worker",
//   fullName: "...",
//   ...other profile fields
// }
//
// ============================================================

app.post(
  '/api/register',
  verifyOtpRateLimiter,
  async (req, res) => {

    try {

      const {
        phoneNumber: rawPhone,
        role,
        fullName,
        email,
        profileData = {},
      } = req.body;


      // --------------------------------------------------------
      // Validate phone
      // --------------------------------------------------------

      const phoneResult =
        validatePhoneNumber(rawPhone);

      if (!phoneResult.valid) {

        return res.status(400).json({
          success: false,
          message:
            phoneResult.message,
        });
      }

      const phone = phoneResult.phone;


      // --------------------------------------------------------
      // Validate role
      // --------------------------------------------------------

      const normalizedRole =
        normalizeRole(role);

      if (!normalizedRole) {

        return res.status(400).json({
          success: false,
          message:
            'Please select either Worker or Employer.',
        });
      }


      // --------------------------------------------------------
      // Validate name
      // --------------------------------------------------------

      if (
        !fullName ||
        typeof fullName !== 'string' ||
        fullName.trim().length < 2
      ) {

        return res.status(400).json({
          success: false,
          message:
            'Please enter a valid full name.',
        });
      }


      // --------------------------------------------------------
      // IMPORTANT:
      //
      // Registration must only happen AFTER phone verification.
      //
      // We cannot trust a client-supplied "verified": true flag.
      //
      // Your Flutter application should call /api/verifyOtp first.
      //
      // For stronger production security, store a short-lived
      // server-side registration verification record/token.
      //
      // See note below.
      // --------------------------------------------------------


      // --------------------------------------------------------
      // Prevent duplicate Firebase Auth account
      // --------------------------------------------------------

      try {

        await auth.getUserByPhoneNumber(phone);

        return res.status(409).json({
          success: false,
          message:
            'An account with this phone number already exists. Please login instead.',
        });

      } catch (error) {

        if (
          error.code !== 'auth/user-not-found'
        ) {

          console.error(
            'Existing user check failed:',
            error.message
          );

          return res.status(500).json({
            success: false,
            message:
              'Unable to check existing account.',
          });
        }
      }


      // --------------------------------------------------------
      // Create Firebase Authentication user
      // --------------------------------------------------------

      let userRecord;

      try {

        userRecord =
          await auth.createUser({
            phoneNumber: phone,
            displayName: fullName.trim(),
            ...(email
              ? { email: email.trim() }
              : {}),
          });

      } catch (error) {

        console.error(
          'Firebase user creation failed:',
          error.message
        );


        if (
          error.code ===
          'auth/phone-number-already-exists'
        ) {

          return res.status(409).json({
            success: false,
            message:
              'An account with this phone number already exists.',
          });
        }


        return res.status(500).json({
          success: false,
          message:
            'Unable to create your account.',
        });
      }


      const uid = userRecord.uid;


      // --------------------------------------------------------
      // Prepare profile
      // --------------------------------------------------------

      // Sanitize profileData
      const sanitizedProfileData = { ...profileData };
      delete sanitizedProfileData.role;
      delete sanitizedProfileData.adminRole;
      delete sanitizedProfileData.verificationStatus;
      delete sanitizedProfileData.isVerified;
      
      const profile = {
        uid,
        phoneNumber: phone,
        fullName: fullName.trim(),
        role: normalizedRole,
        verifiedPhone: true,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        ...sanitizedProfileData,
      };


      // --------------------------------------------------------
      // Save Worker / Employer profile
      // --------------------------------------------------------

      const collection =
        normalizedRole === 'worker'
          ? 'workers'
          : 'employers';


      try {

        await db
          .collection(collection)
          .doc(uid)
          .set(profile);

      } catch (error) {

        console.error(
          'Profile creation failed:',
          error.message
        );


        // ------------------------------------------------------
        // Roll back Firebase Auth account if profile creation
        // fails. This prevents orphan Firebase users.
        // ------------------------------------------------------

        try {

          await auth.deleteUser(uid);

        } catch (rollbackError) {

          console.error(
            'Failed to rollback Firebase user:',
            rollbackError.message
          );
        }


        return res.status(500).json({
          success: false,
          message:
            'Unable to create your profile. Please try again.',
        });
      }


      // --------------------------------------------------------
      // Create Firebase Custom Token
      // --------------------------------------------------------

      const customToken =
        await auth.createCustomToken(uid);


      return res.status(201).json({
        success: true,
        registered: true,
        uid,
        role: normalizedRole,
        token: customToken,
        message:
          'Registration completed successfully.',
      });

    } catch (error) {

      console.error(
        'register error:',
        error.message
      );

      return res.status(500).json({
        success: false,
        message:
          'Server error occurred.',
      });
    }
  }
);


// ============================================================
// START SERVER
// ============================================================

const PORT =
  process.env.PORT || 3000;

app.listen(PORT, () => {

  console.log(
    `Job Finder Backend Server running on port ${PORT}`
  );

});