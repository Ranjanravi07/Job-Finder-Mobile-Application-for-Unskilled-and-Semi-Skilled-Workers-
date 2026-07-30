import { initializeApp } from "firebase/app";
import { getAuth, setPersistence, browserLocalPersistence, Auth } from "firebase/auth";
import { getFirestore, Firestore } from "firebase/firestore";

// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBAdzifyWIiChQnnsBO5xN_krQipPRcAa0",
  authDomain: "admin-dashboard-of-job-finder.firebaseapp.com",
  databaseURL: "https://admin-dashboard-of-job-finder-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "admin-dashboard-of-job-finder",
  storageBucket: "admin-dashboard-of-job-finder.firebasestorage.app",
  messagingSenderId: "957813668437",
  appId: "1:957813668437:web:8728b0b32413d6c89c72dc",
  measurementId: "G-YJWESGWXTS"
};

let app: any;
let auth: Auth | null = null;
let db: Firestore | null = null;

try {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  db = getFirestore(app);

  // Set auth persistence to LOCAL to ensure auth state survives page refreshes
  setPersistence(auth, browserLocalPersistence).catch((err) => {
    console.error("Failed to set auth persistence:", err);
  });
} catch (err) {
  console.error("Firebase initialization error:", err);
}

export { auth, db };
export const isFirebaseConfigured = !!auth && !!db;