import { initializeApp, FirebaseApp } from "firebase/app";
import { getAuth, Auth } from "firebase/auth";
import { getFirestore, Firestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
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
