import React from "react";
import { ArrowUpRight, ArrowDownRight, Scale } from "lucide-react";
import { formatCurrency } from "../services/reportAnalysisEngine";

export default function CashflowSummary({ totalIncome = 0, totalExpense = 0, netCashflow = 0 }) {
  const isSurplus = netCashflow >= 0;

  return (
    <section className="cashflow-grid" aria-label="Ringkasan Arus Kas">
      {/* Pemasukan */}
      <div className="cashflow-card" id="card-total-income">
        <div className="cashflow-header">
          <span className="cashflow-label">Total Pemasukan</span>
          <div className="cashflow-icon-pill pill-income">
            <ArrowUpRight size={18} />
          </div>
        </div>
        <div className="cashflow-amount amount-income">
          {formatCurrency(totalIncome)}
        </div>
        <div className="cashflow-subtext">Akumulasi pemasukan bulan ini</div>
      </div>

      {/* Pengeluaran */}
      <div className="cashflow-card" id="card-total-expense">
        <div className="cashflow-header">
          <span className="cashflow-label">Total Pengeluaran</span>
          <div className="cashflow-icon-pill pill-expense">
            <ArrowDownRight size={18} />
          </div>
        </div>
        <div className="cashflow-amount amount-expense">
          {formatCurrency(totalExpense)}
        </div>
        <div className="cashflow-subtext">Akumulasi pengeluaran bulan ini</div>
      </div>

      {/* Arus Kas Bersih */}
      <div className="cashflow-card" id="card-net-cashflow">
        <div className="cashflow-header">
          <span className="cashflow-label">Arus Kas Bersih</span>
          <div className="cashflow-icon-pill pill-net">
            <Scale size={18} />
          </div>
        </div>
        <div className={`cashflow-amount ${isSurplus ? "amount-net-surplus" : "amount-net-deficit"}`}>
          {formatCurrency(netCashflow, { showSign: true, isIncome: isSurplus })}
        </div>
        <div className="cashflow-subtext">
          {isSurplus ? "Surplus kas positif" : "Defisit kas operasional"}
        </div>
      </div>
    </section>
  );
}
