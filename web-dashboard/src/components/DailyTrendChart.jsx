import React, { useState } from "react";
import { BarChart3, Inbox } from "lucide-react";
import { formatCurrency } from "../services/reportAnalysisEngine";

export default function DailyTrendChart({ dailyTrends = [] }) {
  const [hoveredDay, setHoveredDay] = useState(null);

  const hasData = dailyTrends && dailyTrends.length > 0;

  // Find max value to scale bars relative to height
  const maxVal = hasData
    ? Math.max(
        ...dailyTrends.map((d) => Math.max(d.income, d.expense)),
        100000
      )
    : 1;

  return (
    <div className="chart-card" id="daily-trend-chart-card">
      <div className="chart-card-header">
        <h3 className="chart-card-title">Tren Arus Kas Harian</h3>
        <div className="trend-legend">
          <div className="legend-item">
            <span className="legend-dot-income"></span>
            <span>Masuk</span>
          </div>
          <div className="legend-item">
            <span className="legend-dot-expense"></span>
            <span>Keluar</span>
          </div>
        </div>
      </div>

      {!hasData ? (
        <div className="empty-chart-box">
          <div className="empty-chart-icon">
            <Inbox size={24} />
          </div>
          <p>Belum ada data transaksi harian di bulan ini</p>
        </div>
      ) : (
        <div className="bars-container">
          {dailyTrends.map((item, idx) => {
            const incomeHeight = Math.max((item.income / maxVal) * 160, item.income > 0 ? 6 : 0);
            const expenseHeight = Math.max((item.expense / maxVal) * 160, item.expense > 0 ? 6 : 0);
            const isHovered = hoveredDay === idx;

            return (
              <div
                key={item.dayStr}
                className="day-bar-group"
                onMouseEnter={() => setHoveredDay(idx)}
                onMouseLeave={() => setHoveredDay(null)}
              >
                {/* Floating Tooltip */}
                {isHovered && (
                  <div className="chart-tooltip">
                    <strong>{item.fullDateStr}</strong>
                    <div style={{ color: "#34D399" }}>
                      Masuk: {formatCurrency(item.income)}
                    </div>
                    <div style={{ color: "#FB7185" }}>
                      Keluar: {formatCurrency(item.expense)}
                    </div>
                  </div>
                )}

                {/* Bars Pair */}
                <div className="bars-pair">
                  <div
                    className="bar bar-income"
                    style={{ height: `${incomeHeight}px` }}
                    title={`Masuk: ${formatCurrency(item.income)}`}
                  ></div>
                  <div
                    className="bar bar-expense"
                    style={{ height: `${expenseHeight}px` }}
                    title={`Keluar: ${formatCurrency(item.expense)}`}
                  ></div>
                </div>

                <span className="day-label">{item.dayStr}</span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
