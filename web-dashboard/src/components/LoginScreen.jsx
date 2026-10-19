import React, { useState } from "react";
import { ShieldCheck, Wallet, AlertCircle, Loader2 } from "lucide-react";
import { signInWithGoogle } from "../services/firebase";
import "../styles/login.css";

export default function LoginScreen({ onLoginSuccess }) {
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const handleGoogleSignIn = async () => {
    setLoading(true);
    setErrorMsg("");
    try {
      const user = await signInWithGoogle();
      if (user) {
        onLoginSuccess(user);
      }
    } catch (err) {
      console.error(err);
      if (err.code === "auth/popup-blocked") {
        setErrorMsg("Jendela popup Google diblokir oleh browser. Harap izinkan popup di pengaturan browser Anda.");
      } else if (err.code === "auth/cancelled-popup-request" || err.code === "auth/popup-closed-by-user") {
        setErrorMsg("Proses login dibatalkan.");
      } else {
        setErrorMsg(`Login gagal: ${err.message || "Periksa koneksi internet atau konfigurasi akun Google."}`);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="login-viewport" id="login-screen">
      <div className="login-glow-1"></div>
      <div className="login-glow-2"></div>

      <div className="login-card">
        {/* Left Hero Section with 3D Illustration */}
        <div className="login-hero">
          <div className="hero-badge-pill">
            <span className="hero-badge-dot"></span>
            Fintech Web Portal
          </div>

          <div className="hero-art-wrapper">
            <img 
              src="/tactile_vault_3d.jpg" 
              alt="TrackFinance 3D Vault Illustration" 
              className="hero-artwork-img"
            />
          </div>

          <h2 className="hero-title">Dashboard Laporan</h2>
          <p className="hero-desc">
            Visualisasi arus kas bulanan, grafik tren harian, dan ringkasan alokasi keuangan real-time.
          </p>
        </div>

        {/* Right Form / Action Section */}
        <div className="login-form-area">
          <div className="brand-badge">
            <div className="brand-icon-sq">
              <Wallet size={22} />
            </div>
            <div className="brand-name">
              Track<span>Finance</span>
            </div>
          </div>

          <h1 className="welcome-title">
            Selamat datang di TrackFinance
          </h1>
          <p className="welcome-subtitle">
            Catat dan pantau keuanganmu dengan tenang, transparan, dan rapi dari layar browser desktop.
          </p>

          {errorMsg && (
            <div className="error-pill" role="alert">
              <AlertCircle size={18} />
              <span>{errorMsg}</span>
            </div>
          )}

          {/* Authentic Google Button */}
          <button
            id="google-signin-btn"
            className="btn-google"
            onClick={handleGoogleSignIn}
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader2 size={20} className="animate-spin" />
                <span>Menghubungkan ke Google...</span>
              </>
            ) : (
              <>
                {/* Authentic Google 4-Color G SVG Logo */}
                <svg width="20" height="20" viewBox="0 0 24 24">
                  <path
                    fill="#4285F4"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                  />
                  <path
                    fill="#34A853"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                  />
                  <path
                    fill="#FBBC05"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                  />
                  <path
                    fill="#EA4335"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                  />
                </svg>
                <span>Lanjutkan dengan Google</span>
              </>
            )}
          </button>

          {/* Security Badge */}
          <div className="security-badge">
            <ShieldCheck size={20} />
            <div className="security-text">
              Dilindungi dengan enkripsi AES-256 & Firebase Authentication. Data terisolasi aman per pengguna.
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
