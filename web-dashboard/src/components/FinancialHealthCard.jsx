import React from "react";
import { Sparkles, Activity, Lightbulb } from "lucide-react";

export default function FinancialHealthCard({
  healthScore = 0,
  healthStatus = "Belum Ada Data",
  savingsRate = 0,
  healthRecommendation = "",
  isEmpty = false
}) {
  const getStatusClass = () => {
    if (isEmpty || healthStatus === "Belum Ada Data") return "status-empty";
    if (healthStatus === "Sangat Sehat" || healthStatus === "Sehat") return "status-sehat";
    if (healthStatus === "Waspada") return "status-waspada";
    return "status-kritis";
  };

  const isSavingsPositive = savingsRate >= 0;

  return (
    <section className="health-card" id="financial-health-card" aria-label="Indikator Kesehatan Finansial">
      <div className="health-header">
        <div className="health-title-group">
          <div className="health-icon-box">
            <Activity size={20} />
          </div>
          <h2 className="health-title">Indikator Kesehatan Finansial</h2>
        </div>

        <div className={`health-status-badge ${getStatusClass()}`}>
          <Sparkles size={14} />
          <span>{healthStatus}</span>
        </div>
      </div>

      <div className="health-metrics-row">
        {/* Score & Savings Rate Gauge Box */}
        <div className="health-gauge-box">
          <span className="health-gauge-number">
            {isEmpty ? "-" : healthScore}
          </span>
          <span className="health-gauge-sub">Skor Finansial (0-100)</span>
          {!isEmpty && (
            <div className={`health-savings-rate ${isSavingsPositive ? "savings-positive" : "savings-negative"}`}>
              {isSavingsPositive ? `+${savingsRate}%` : `${savingsRate}%`} Tabungan
            </div>
          )}
        </div>

        {/* Dynamic Smart Recommendation */}
        <div className="health-rec-box">
          <div className="health-rec-header">
            <Lightbulb size={16} />
            <span>Rekomendasi Cerdas</span>
          </div>
          <p className="health-rec-text">
            {healthRecommendation || "Pertahankan pencatatan transaksi secara rutin untuk memantau tren arus kas Anda."}
          </p>
        </div>
      </div>
    </section>
  );
}
