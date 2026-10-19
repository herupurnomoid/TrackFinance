import React, { useState, useEffect } from "react";
import {
  subscribeToAuth,
  logOut,
  db
} from "./services/firebase";
import {
  doc,
  collection,
  query,
  where,
  onSnapshot
} from "firebase/firestore";
import {
  MONTH_NAMES_ID,
  calculateFinancialHealth,
  generateDailyTrends,
  generateCategoryBreakdown
} from "./services/reportAnalysisEngine";

import LoginScreen from "./components/LoginScreen";
import Navbar from "./components/Navbar";
import PeriodSelector from "./components/PeriodSelector";
import CashflowSummary from "./components/CashflowSummary";
import FinancialHealthCard from "./components/FinancialHealthCard";
import DailyTrendChart from "./components/DailyTrendChart";
import CategoryStructureCard from "./components/CategoryStructureCard";
import LogoutModal from "./components/LogoutModal";

import "./styles/index.css";
import "./styles/dashboard.css";

export default function App() {
  const [currentUser, setCurrentUser] = useState(null);
  const [authChecking, setAuthChecking] = useState(true);

  // Period state: default to current year and month
  const now = new Date();
  const [selectedYear, setSelectedYear] = useState(now.getFullYear());
  const [selectedMonthIndex, setSelectedMonthIndex] = useState(now.getMonth());

  // Report Data State
  const [reportData, setReportData] = useState({
    monthKey: `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, "0")}`,
    year: now.getFullYear(),
    monthIndex: now.getMonth(),
    totalIncome: 0,
    totalExpense: 0,
    netCashflow: 0,
    savingsRate: 0.0,
    healthScore: 0,
    healthStatus: "Belum Ada Data",
    healthRecommendation: "Belum ada transaksi tercatat pada bulan ini.",
    dailyTrends: [],
    expenseCategories: [],
    incomeCategories: []
  });
  
  const [isPeriodPickerOpen, setIsPeriodPickerOpen] = useState(false);
  const [isLogoutModalOpen, setIsLogoutModalOpen] = useState(false);

  // 1. Listen to Firebase Auth
  useEffect(() => {
    const unsubscribe = subscribeToAuth((user) => {
      setCurrentUser(user);
      setAuthChecking(false);
    });
    return () => unsubscribe();
  }, []);

  // 2. Subscribe to Live Firestore Report Data for the selected user & period
  useEffect(() => {
    if (!currentUser || !currentUser.uid || !db) return;

    const monthKey = `${selectedYear}-${(selectedMonthIndex + 1).toString().padStart(2, "0")}`;

    const summaryRef = doc(db, "users", currentUser.uid, "monthly_summaries", monthKey);
    const txQuery = query(
      collection(db, "users", currentUser.uid, "transactions"),
      where("monthKey", "==", monthKey)
    );

    let currentSummary = null;
    let currentTransactions = [];

    const updateReport = () => {
      const totalIncome = currentSummary?.totalIncome ?? 
        currentTransactions.filter(t => t.type === "income" || t.isExpense === false).reduce((s, t) => s + (t.amount || 0), 0);
      
      const totalExpense = currentSummary?.totalExpense ?? 
        currentTransactions.filter(t => t.type === "expense" || t.isExpense === true).reduce((s, t) => s + (t.amount || 0), 0);
      
      const netCashflow = totalIncome - totalExpense;
      const health = calculateFinancialHealth(totalIncome, totalExpense);
      const dailyTrends = generateDailyTrends(currentTransactions, selectedMonthIndex);
      const expenseCategories = generateCategoryBreakdown(currentTransactions, true, totalExpense);
      const incomeCategories = generateCategoryBreakdown(currentTransactions, false, totalIncome);

      setReportData({
        monthKey,
        year: selectedYear,
        monthIndex: selectedMonthIndex,
        totalIncome,
        totalExpense,
        netCashflow,
        savingsRate: health.savingsRate,
        healthScore: health.healthScore,
        healthStatus: health.healthStatus,
        healthRecommendation: health.healthRecommendation,
        dailyTrends,
        expenseCategories,
        incomeCategories
      });
    };

    const unsubSummary = onSnapshot(summaryRef, (snap) => {
      if (snap.exists()) {
        currentSummary = snap.data();
      } else {
        currentSummary = null;
      }
      updateReport();
    }, (err) => {
      console.warn("Summary snapshot note:", err);
    });

    const unsubTx = onSnapshot(txQuery, (snap) => {
      currentTransactions = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      updateReport();
    }, (err) => {
      console.warn("Transactions snapshot note:", err);
    });

    return () => {
      unsubSummary();
      unsubTx();
    };
  }, [currentUser, selectedYear, selectedMonthIndex]);

  const handleLogout = async () => {
    setIsLogoutModalOpen(false);
    await logOut();
    setCurrentUser(null);
  };

  // Auth checking screen
  if (authChecking) {
    return (
      <div style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "#0F172A",
        color: "#FFFFFF",
        fontFamily: "Plus Jakarta Sans, sans-serif"
      }}>
        <div style={{ textAlign: "center" }}>
          <div style={{
            width: 48,
            height: 48,
            border: "3px solid rgba(255, 255, 255, 0.2)",
            borderTopColor: "#38BDF8",
            borderRadius: "50%",
            animation: "spin 1s linear infinite",
            margin: "0 auto 16px"
          }}></div>
          <p style={{ fontSize: 15, color: "#94A3B8" }}>Memuat TrackFinance...</p>
          <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </div>
      </div>
    );
  }

  // Not logged in -> Show Clean Production LoginScreen
  if (!currentUser) {
    return <LoginScreen onLoginSuccess={(user) => setCurrentUser(user)} />;
  }

  const isEmpty = (reportData.totalIncome === 0 && reportData.totalExpense === 0);
  const currentMonthName = MONTH_NAMES_ID[selectedMonthIndex] || "";

  return (
    <div className="dashboard-layout" id="app-dashboard">
      {/* Navbar with Period Selector & User Logout */}
      <Navbar
        user={currentUser}
        selectedYear={selectedYear}
        selectedMonthIndex={selectedMonthIndex}
        onOpenPeriodPicker={() => setIsPeriodPickerOpen(true)}
        onOpenLogout={() => setIsLogoutModalOpen(true)}
      />

      {/* Main Content Dashboard */}
      <main className="dashboard-main animate-fade-in">
        {/* Hero Row */}
        <div className="dashboard-hero-row">
          <div>
            <h1 className="dashboard-page-title">
              Laporan Keuangan
            </h1>
            <p className="dashboard-page-subtitle">
              Ringkasan performa finansial dan analisis alokasi dana periode {currentMonthName} {selectedYear}.
            </p>
          </div>
        </div>

        {/* 1. Cashflow Summary (3 Cards) */}
        <CashflowSummary
          totalIncome={reportData.totalIncome}
          totalExpense={reportData.totalExpense}
          netCashflow={reportData.netCashflow}
        />

        {/* 2. Financial Health Indicator Card */}
        <FinancialHealthCard
          healthScore={reportData.healthScore}
          healthStatus={reportData.healthStatus}
          savingsRate={reportData.savingsRate}
          healthRecommendation={reportData.healthRecommendation}
          isEmpty={isEmpty}
        />

        {/* 3. Daily Cashflow Trend & Structure Allocation Grid */}
        <div className="analytics-grid">
          {/* Daily Trend Bar Chart */}
          <DailyTrendChart dailyTrends={reportData.dailyTrends} />

          {/* Category Allocation Donut Chart & Ranked List */}
          <CategoryStructureCard
            expenseCategories={reportData.expenseCategories}
            incomeCategories={reportData.incomeCategories}
            totalExpense={reportData.totalExpense}
            totalIncome={reportData.totalIncome}
          />
        </div>
      </main>

      {/* Month & Year Picker Modal */}
      <PeriodSelector
        isOpen={isPeriodPickerOpen}
        onClose={() => setIsPeriodPickerOpen(false)}
        selectedYear={selectedYear}
        selectedMonthIndex={selectedMonthIndex}
        onSelectPeriod={(year, monthIdx) => {
          setSelectedYear(year);
          setSelectedMonthIndex(monthIdx);
        }}
      />

      {/* Logout Confirmation Modal */}
      <LogoutModal
        isOpen={isLogoutModalOpen}
        onClose={() => setIsLogoutModalOpen(false)}
        onConfirm={handleLogout}
      />
    </div>
  );
}
