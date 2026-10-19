import React from "react";
import { ChevronLeft, ChevronRight, X } from "lucide-react";
import { MONTH_NAMES_SHORT } from "../services/reportAnalysisEngine";

export default function PeriodSelector({
  isOpen,
  onClose,
  selectedYear,
  selectedMonthIndex,
  onSelectPeriod
}) {
  if (!isOpen) return null;

  const handlePrevYear = () => {
    onSelectPeriod(selectedYear - 1, selectedMonthIndex);
  };

  const handleNextYear = () => {
    onSelectPeriod(selectedYear + 1, selectedMonthIndex);
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="picker-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="picker-dialog-header">
          <h3 className="picker-dialog-title">Pilih Periode Laporan</h3>
          <button className="stepper-btn" onClick={onClose} aria-label="Tutup modal">
            <X size={18} />
          </button>
        </div>

        {/* Year Stepper */}
        <div className="year-stepper">
          <button 
            id="prev-year-btn"
            className="stepper-btn" 
            onClick={handlePrevYear}
            aria-label="Tahun Sebelumnya"
          >
            <ChevronLeft size={18} />
          </button>
          <span className="year-title">{selectedYear}</span>
          <button 
            id="next-year-btn"
            className="stepper-btn" 
            onClick={handleNextYear}
            aria-label="Tahun Berikutnya"
          >
            <ChevronRight size={18} />
          </button>
        </div>

        {/* Months Grid */}
        <div className="months-grid">
          {MONTH_NAMES_SHORT.map((name, index) => {
            const isSelected = index === selectedMonthIndex;
            return (
              <button
                key={name}
                id={`month-btn-${index}`}
                className={`month-cell ${isSelected ? "selected" : ""}`}
                onClick={() => {
                  onSelectPeriod(selectedYear, index);
                  onClose();
                }}
              >
                {name}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
