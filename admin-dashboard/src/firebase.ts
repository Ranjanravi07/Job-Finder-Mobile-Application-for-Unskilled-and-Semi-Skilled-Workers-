import { initializeApp, FirebaseApp } from "firebase/app";
import { getAuth, Auth } from "firebase/auth";
import { getFirestore, Firestore } from "firebase/firestore";

// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBAdzifyWIiChQnnsBO5xN_krQipPRcAa0",
  authDomain: "admin-dashboard-of-job-finder.firebaseapp.com",
  projectId: "admin-dashboard-of-job-finder",
  storageBucket: "admin-dashboard-of-job-finder.firebasestorage.app",
  messagingSenderId: "957813668437",
  appId: "1:957813668437:web:8728b0b32413d6c89c72dc",
  measurementId: "G-YJWESGWXTS"
};

const hasValidConfig =
  firebaseConfig.apiKey &&
  typeof firebaseConfig.apiKey === "string" &&
  !firebaseConfig.apiKey.includes("YOUR_") &&
  firebaseConfig.apiKey.length > 10;

let app: FirebaseApp | null = null;
let authInstance: Auth | null = null;
let dbInstance: Firestore | null = null;
let initError: string | null = null;

if (hasValidConfig) {
  try {
    app = initializeApp(firebaseConfig);
    authInstance = getAuth(app);
    dbInstance = getFirestore(app);
  } catch (err: any) {
    initError = err?.message || "Failed to initialize Firebase";
    app = null;
    authInstance = null;
    dbInstance = null;
  }
}

export { app, authInstance as auth, dbInstance as db, initError };

export const isFirebaseConfigured = hasValidConfig && !initError;
