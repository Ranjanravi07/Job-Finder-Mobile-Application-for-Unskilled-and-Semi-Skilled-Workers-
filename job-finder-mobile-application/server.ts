/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI, Type } from "@google/genai";
import dotenv from "dotenv";
import crypto from "crypto";

dotenv.config();

const app = express();
const PORT = 3001;

// Parse JSON bodies
app.use(express.json());

// In-memory OTP storage (in production, use a database with proper indexing)
interface OTPData {
  phone: string;
  hashedOtp: string;
  expiresAt: number;
  attempts: number;
}

const otpStore = new Map<string, OTPData>();
const OTP_EXPIRY_MS = 5 * 60 * 1000; // 5 minutes
const MAX_ATTEMPTS = 5;

// Initialize Gemini Client
const apiKey = process.env.GEMINI_API_KEY;
let ai: GoogleGenAI | null = null;

if (apiKey) {
  ai = new GoogleGenAI({
    apiKey: apiKey,
    httpOptions: {
      headers: {
        'User-Agent': 'aistudio-build',
      }
    }
  });
} else {
  console.warn("GEMINI_API_KEY is not defined. Voice extraction will run in simulator mode.");
}

// API Routes
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", geminiEnabled: !!apiKey });
});

// Generate cryptographically secure 6-digit OTP
function generateSecureOTP(): string {
  const otp = crypto.randomInt(0, 1000000).toString().padStart(6, '0');
  return otp;
}

// Hash OTP for secure storage
function hashOTP(otp: string): string {
  return crypto.createHash('sha256').update(otp).digest('hex');
}

// Clean expired OTPs
function cleanExpiredOTPs() {
  const now = Date.now();
  for (const [key, data] of otpStore.entries()) {
    if (data.expiresAt < now) {
      otpStore.delete(key);
    }
  }
}

// OTP Generation endpoint
app.post("/api/otp/send", async (req, res) => {
  const { phone } = req.body;

  if (!phone || phone.length !== 10) {
    return res.status(400).json({ error: "Invalid phone number. Must be 10 digits." });
  }

  // Clean expired OTPs first
  cleanExpiredOTPs();

  // Generate secure OTP
  const otp = generateSecureOTP();
  const hashedOtp = hashOTP(otp);
  const expiresAt = Date.now() + OTP_EXPIRY_MS;

  // Store OTP data (in production, use database)
  otpStore.set(phone, {
    phone,
    hashedOtp,
    expiresAt,
    attempts: 0
  });

  // In production, integrate with SMS gateway here
  // For now, log the OTP (in simulator mode)
  console.log(`[OTP] Generated for +977${phone}: ${otp} (expires in 5 minutes)`);

  // Return success (don't return actual OTP in production)
  res.json({ 
    success: true, 
    message: "OTP sent successfully",
    // For simulator mode only - remove in production
    simulatorOtp: otp 
  });
});

// OTP Verification endpoint
app.post("/api/otp/verify", async (req, res) => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    return res.status(400).json({ error: "Phone number and OTP are required" });
  }

  // Clean expired OTPs
  cleanExpiredOTPs();

  const otpData = otpStore.get(phone);
  if (!otpData) {
    return res.status(400).json({ error: "OTP expired or not found. Please request a new OTP." });
  }

  // Check if expired
  if (Date.now() > otpData.expiresAt) {
    otpStore.delete(phone);
    return res.status(400).json({ error: "OTP has expired. Please request a new OTP." });
  }

  // Check attempt limit
  if (otpData.attempts >= MAX_ATTEMPTS) {
    otpStore.delete(phone);
    return res.status(429).json({ error: "Maximum verification attempts exceeded. Please request a new OTP." });
  }

  // Verify OTP
  const hashedInput = hashOTP(otp);
  if (hashedInput !== otpData.hashedOtp) {
    otpData.attempts += 1;
    otpStore.set(phone, otpData);
    const remainingAttempts = MAX_ATTEMPTS - otpData.attempts;
    return res.status(400).json({ 
      error: "Invalid OTP", 
      remainingAttempts 
    });
  }

  // OTP verified successfully - delete it
  otpStore.delete(phone);

  res.json({ 
    success: true, 
    message: "OTP verified successfully" 
  });
});

// Server-side voice dictation parsing endpoint
app.post("/api/voice-parse", async (req, res) => {
  const { speechText, language } = req.body;

  if (!speechText) {
    return res.status(400).json({ error: "Missing speechText parameter" });
  }

  if (!ai) {
    // Return mock parsed results if API key is not configured
    console.log("No Gemini API key available. Mocking the voice extraction...");
    return res.json({
      name: "Hari Thapa",
      mainSkill: "electrician",
      experience: "3 Years",
      expectedWage: 1200,
      location: "Balkumari, Lalitpur",
      bio: "Parsed via Simulator Mode: " + speechText,
      mode: "simulator"
    });
  }

  try {
    const prompt = `You are an AI assistent designed for unskilled and semi-skilled workers in Nepal.
The worker dictated the following text in ${language === 'ne' ? 'Nepali' : 'English'} to create their job profile:
"${speechText}"

Please parse and extract:
1. Full Name
2. Main Skill/Category (MUST map to one of: mason, carpenter, electrician, plumber, painter, driver, laborer, domestic)
3. Experience level (e.g. "Fresher", "2 Years", "5 Years")
4. Expected Daily Wage (number in Nepali Rupees, e.g. 1000)
5. Location (MUST map to or closest to one of: 'Balkumari, Lalitpur', 'Gwarko, Lalitpur', 'Lagankhel, Lalitpur', 'Koteshwor, Kathmandu', 'Kalanki, Kathmandu', 'Baneshwor, Kathmandu', 'Chabahil, Kathmandu', 'Sanepa, Lalitpur')
6. Bio (A friendly, humble bio written in the worker's language or English summarizing their work)

Please be resilient to spelling errors, colloquial terms, and mixed Nepali-English languages (Romanized Nepali or Devnagari).
Return the result strictly as JSON conforming to the schema.`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            name: { type: Type.STRING, description: "Worker's full name" },
            mainSkill: {
              type: Type.STRING,
              description: "Must be exactly one of: mason, carpenter, electrician, plumber, painter, driver, laborer, domestic"
            },
            experience: { type: Type.STRING, description: "Experience like '3 Years' or 'Fresher'" },
            expectedWage: { type: Type.NUMBER, description: "Expected daily wage as a number" },
            location: { type: Type.STRING, description: "Closer matching Location in Nepal" },
            bio: { type: Type.STRING, description: "Brief humble summary statement" },
          },
          required: ["name", "mainSkill", "experience", "expectedWage", "location"]
        }
      }
    });

    const parsedData = JSON.parse(response.text?.trim() || "{}");
    res.json({ ...parsedData, mode: "gemini" });
  } catch (error: any) {
    console.error("Gemini parse error:", error);
    res.status(500).json({ error: "Failed to parse speech input via Gemini", details: error.message });
  }
});

// Vite middleware for development or Static Asset serving for production
async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
