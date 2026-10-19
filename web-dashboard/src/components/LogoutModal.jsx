import React from "react";
import { LogOut } from "lucide-react";

export default function LogoutModal({ isOpen, onClose, onConfirm }) {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="logout-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="logout-icon-circle">
          <LogOut size={26} />
        </div>
        <h3 className="logout-dialog-title">Keluar dari Akun?</h3>
        <p className="logout-dialog-desc">
          Anda akan keluar dari sesi web TrackFinance saat ini. Anda dapat masuk kembali kapan saja.
        </p>

        <div className="logout-btn-row">
          <button id="cancel-logout-btn" className="btn-cancel" onClick={onClose}>
            Batal
          </button>
          <button id="confirm-logout-btn" className="btn-confirm-logout" onClick={onConfirm}>
            Keluar
          </button>
        </div>
      </div>
    </div>
  );
}
