import React, { useState } from "react";
import { PieChart, Inbox } from "lucide-react";
import { formatCurrency } from "../services/reportAnalysisEngine";

export default function CategoryStructureCard({
  expenseCategories = [],
  incomeCategories = [],
  totalExpense = 0,
  totalIncome = 0
}) {
  const [isExpenseTab, setIsExpenseTab] = useState(true);

  const categories = isExpenseTab ? expenseCategories : incomeCategories;
  const currentTotal = isExpenseTab ? totalExpense : totalIncome;
  const hasData = categories && categories.length > 0;

  // SVG Donut calculation
  const size = 160;
  const strokeWidth = 24;
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  let cumulativeOffset = 0;

  return (
    <div className="chart-card" id="category-structure-card">
      <div className="chart-card-header">
        <h3 className="chart-card-title">Struktur & Alokasi</h3>

        {/* Dynamic Segmented Pill */}
        <div className="segmented-pill">
          <button
            id="tab-expense-btn"
            className={`segment-btn ${isExpenseTab ? "active expense" : ""}`}
            onClick={() => setIsExpenseTab(true)}
          >
            Pengeluaran
          </button>
          <button
            id="tab-income-btn"
            className={`segment-btn ${!isExpenseTab ? "active income" : ""}`}
            onClick={() => setIsExpenseTab(false)}
          >
            Pemasukan
          </button>
        </div>
      </div>

      {!hasData ? (
        <div className="empty-chart-box">
          <div className="empty-chart-icon">
            <Inbox size={24} />
          </div>
          <p>Belum ada data {isExpenseTab ? "pengeluaran" : "pemasukan"} di bulan ini</p>
        </div>
      ) : (
        <div className="structure-content">
          {/* Donut Chart */}
          <div className="donut-wrapper">
            <svg width={size} height={size} className="donut-svg" viewBox={`0 0 ${size} ${size}`}>
              {/* Background ring */}
              <circle
                cx={size / 2}
                cy={size / 2}
                r={radius}
                fill="none"
                stroke="#F1F5F9"
                strokeWidth={strokeWidth}
              />

              {/* Slices */}
              {categories.map((cat, i) => {
                const strokeDasharray = `${(cat.percentage / 100) * circumference} ${circumference}`;
                const strokeDashoffset = -cumulativeOffset;
                cumulativeOffset += (cat.percentage / 100) * circumference;

                return (
                  <circle
                    key={cat.name + i}
                    cx={size / 2}
                    cy={size / 2}
                    r={radius}
                    fill="none"
                    stroke={cat.sliceColor}
                    strokeWidth={strokeWidth}
                    strokeDasharray={strokeDasharray}
                    strokeDashoffset={strokeDashoffset}
                    style={{ transition: "stroke-dasharray 0.5s ease" }}
                  />
                );
              })}
            </svg>

            {/* Center Summary */}
            <div className="donut-center-info">
              <span className="donut-center-label">Total</span>
              <span className="donut-center-total" title={formatCurrency(currentTotal)}>
                {formatCurrency(currentTotal)}
              </span>
            </div>
          </div>

          {/* Category List */}
          <div className="category-list">
            {categories.map((cat) => (
              <div key={cat.name} className="category-row">
                <div className="cat-left">
                  <span
                    className="cat-color-dot"
                    style={{ backgroundColor: cat.sliceColor }}
                  ></span>
                  <div>
                    <div className="cat-name">{cat.name}</div>
                    {cat.count > 0 && (
                      <span className="cat-count">{cat.count} transaksi</span>
                    )}
                  </div>
                </div>

                <div className="cat-right">
                  <span className="cat-amount">{formatCurrency(cat.amount)}</span>
                  <span className="cat-percent-badge">{cat.percentage}%</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
