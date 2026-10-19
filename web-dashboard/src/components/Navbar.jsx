import React from "react";
import { Wallet, Calendar, LogOut } from "lucide-react";
import { MONTH_NAMES_ID } from "../services/reportAnalysisEngine";

export default function Navbar({
  user,
  selectedYear,
  selectedMonthIndex,
  onOpenPeriodPicker,
  onOpenLogout
}) {
  const monthName = MONTH_NAMES_ID[selectedMonthIndex] || "";
  const periodLabel = `${monthName} ${selectedYear}`;

  const displayName = user?.displayName || user?.email || "Pengguna";
  const photoUrl = user?.photoURL;
  const initial = displayName.charAt(0).toUpperCase();

  return (
    <header className="dashboard-navbar">
      <div className="nav-container">
        {/* Brand */}
        <div className="nav-brand">
          <div className="nav-logo-icon">
            <Wallet size={20} />
          </div>
          <div className="nav-titles">
            <span className="nav-title-main">TrackFinance</span>
            <span className="nav-title-sub">Dashboard Laporan</span>
          </div>
        </div>

        {/* Actions & Profile */}
        <div className="nav-actions">
          {/* Period Button */}
          <button 
            id="period-picker-trigger"
            className="period-btn" 
            onClick={onOpenPeriodPicker}
            title="Ubah Periode Laporan"
          >
            <Calendar size={16} className="period-btn-calendar" />
            <span>{periodLabel}</span>
          </button>

          {/* User Badge */}
          <div className="user-profile-badge">
            {photoUrl ? (
              <img src={photoUrl} alt={displayName} className="user-avatar-img" />
            ) : (
              <div className="user-avatar-fallback">{initial}</div>
            )}
            <div className="user-info">
              <span className="user-name">{displayName}</span>
            </div>
          </div>

          {/* Logout Button */}
          <button
            id="logout-btn"
            className="btn-logout"
            onClick={onOpenLogout}
            title="Keluar dari Akun"
            aria-label="Logout"
          >
            <LogOut size={18} />
          </button>
        </div>
      </div>
    </header>
  );
}
