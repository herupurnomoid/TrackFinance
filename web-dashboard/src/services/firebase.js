import { initializeApp } from "firebase/app";
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged
} from "firebase/auth";
import {
  getFirestore,
  doc,
  collection,
  query,
  where,
  orderBy,
  onSnapshot,
  getDoc,
  setDoc,
  updateDoc,
  serverTimestamp
} from "firebase/firestore";

// Konfigurasi Firebase TrackFinance
const firebaseConfig = {
  apiKey: "AIzaSyDWzaHD0C-kmPKYA4OjKRH2rOx9blcLKpM",
  authDomain: "trackfinance-6ccfd.firebaseapp.com",
  projectId: "trackfinance-6ccfd",
  storageBucket: "trackfinance-6ccfd.firebasestorage.app",
  messagingSenderId: "24704467613",
  appId: "1:24704467613:web:trackfinanceweb"
};

let app;
let auth;
let db;

try {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  db = getFirestore(app);
} catch (e) {
  console.warn("Firebase initialization note:", e);
}

const googleProvider = new GoogleAuthProvider();
googleProvider.setCustomParameters({
  prompt: 'select_account'
});

export { auth, db };



/**
 * Sign in dengan Google OAuth Popup
 */
export async function signInWithGoogle() {
  if (!auth) throw new Error("Firebase Auth tidak terinisialisasi.");
  try {
    const result = await signInWithPopup(auth, googleProvider);
    const user = result.user;
    
    // Sinkronisasi data ke Cloud Firestore users/{uid}
    try {
      const userRef = doc(db, "users", user.uid);
      const userSnap = await getDoc(userRef);
      if (!userSnap.exists()) {
        await setDoc(userRef, {
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: serverTimestamp(),
          lastLoginAt: serverTimestamp(),
          currency: "IDR",
          financialHealthScore: 85
        });
      } else {
        await updateDoc(userRef, {
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          lastLoginAt: serverTimestamp()
        });
      }
    } catch (firestoreErr) {
      console.warn("Firestore sync warning:", firestoreErr);
    }
    
    return user;
  } catch (error) {
    console.error("Google Sign-In Error:", error);
    throw error;
  }
}

/**
 * Logout
 */
export async function logOut() {
  if (auth) {
    await signOut(auth);
  }
}

/**
 * Subscribe ke status Autentikasi Firebase
 */
export function subscribeToAuth(callback) {
  if (!auth) {
    callback(null);
    return () => {};
  }

  return onAuthStateChanged(auth, (user) => {
    callback(user);
  });
}

