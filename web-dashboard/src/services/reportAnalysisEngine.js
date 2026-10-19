/**
 * TrackFinance Report Analysis Engine
 * Ported directly from mobile Flutter business logic (REP-02, REP-03, REP-04)
 */

export const MONTH_NAMES_ID = [
  "Januari", "Februari", "Maret", "April", "Mei", "Juni",
  "Juli", "Agustus", "September", "Oktober", "November", "Desember"
];

export const MONTH_NAMES_SHORT = [
  "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
  "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
];

/**
 * Format IDR currency
 */
export function formatCurrency(amount, { showSign = false, isIncome = false } = {}) {
  if (amount === undefined || amount === null || isNaN(amount)) return "Rp 0";
  const absAmount = Math.abs(Math.round(amount));
  const formatted = absAmount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  
  if (!showSign) {
    return `Rp ${formatted}`;
  }
  return isIncome ? `+Rp ${formatted}` : `-Rp ${formatted}`;
}

/**
 * Engine Kalkulasi Kesehatan Finansial (REP-02)
 */
export function calculateFinancialHealth(totalIncome = 0, totalExpense = 0) {
  // 1. Kondisi Kosong (Tidak ada transaksi)
  if (totalIncome === 0 && totalExpense === 0) {
    return {
      savingsRate: 0.0,
      healthScore: 0,
      healthStatus: "Belum Ada Data",
      healthRecommendation: "Belum ada transaksi tercatat pada bulan ini."
    };
  }

  const netCashflow = totalIncome - totalExpense;

  // 2. Kondisi Defisit Tanpa Pemasukan
  if (totalIncome <= 0 && totalExpense > 0) {
    return {
      savingsRate: -100.0,
      healthScore: 35,
      healthStatus: "Minus Kritis",
      healthRecommendation: "Pengeluaran melebihi pemasukan bulan ini. Tinjau kembali anggaran belanja dan tunda pengeluaran non-primer."
    };
  }

  // 3. Normal Berdasarkan Rasio Tabungan
  const rawSavingsRate = (netCashflow / totalIncome) * 100;
  const savingsRate = parseFloat(rawSavingsRate.toFixed(1));

  if (savingsRate >= 40.0) {
    return {
      savingsRate,
      healthScore: 95,
      healthStatus: "Sangat Sehat",
      healthRecommendation: "Kondisi keuangan sangat prima. Pertahankan rasio tabungan dan alokasikan ke instrumen investasi."
    };
  } else if (savingsRate >= 20.0) {
    return {
      savingsRate,
      healthScore: 82,
      healthStatus: "Sehat",
      healthRecommendation: "Pengeluaran terkendali dengan baik. Anda menyisihkan lebih dari 20% pemasukan bulan ini."
    };
  } else if (savingsRate >= 0.0) {
    return {
      savingsRate,
      healthScore: 65,
      healthStatus: "Waspada",
      healthRecommendation: "Arus kas tipis. Kurangi pos pengeluaran hiburan dan belanja harian untuk memperbesar dana darurat."
    };
  } else {
    return {
      savingsRate,
      healthScore: 35,
      healthStatus: "Minus Kritis",
      healthRecommendation: "Pengeluaran melebihi pemasukan bulan ini. Tinjau kembali anggaran belanja dan tunda pengeluaran non-primer."
    };
  }
}

/**
 * Generator Tren Arus Kas Harian (REP-03)
 */
export function generateDailyTrends(transactions = [], monthIndex = 9) {
  if (!transactions || transactions.length === 0) return [];

  const safeMonthIndex = Math.min(Math.max(monthIndex, 0), MONTH_NAMES_SHORT.length - 1);
  const monthLabel = MONTH_NAMES_SHORT[safeMonthIndex];
  const dailyAggregates = {};

  transactions.forEach((tx) => {
    let day = tx.day;
    if (!day && tx.date) {
      const d = tx.date.toDate ? tx.date.toDate() : new Date(tx.date);
      day = d.getDate();
    }
    if (!day) day = 1;

    if (!dailyAggregates[day]) {
      dailyAggregates[day] = { expense: 0, income: 0 };
    }

    const amount = Math.abs(tx.amount || 0);
    const isExpense = tx.type === "expense" || tx.isExpense === true;

    if (isExpense) {
      dailyAggregates[day].expense += amount;
    } else {
      dailyAggregates[day].income += amount;
    }
  });

  const sortedDays = Object.keys(dailyAggregates)
    .map(Number)
    .sort((a, b) => a - b);

  return sortedDays.map((d) => {
    const dayStr = d.toString().padStart(2, "0");
    const entry = dailyAggregates[d];
    return {
      dayStr,
      fullDateStr: `${dayStr} ${monthLabel}`,
      expense: entry.expense,
      income: entry.income
    };
  });
}

/**
 * Generator Proporsi Donut Chart & List Kategori (REP-04)
 */
export const EXPENSE_COLORS = [
  "#DC2626", // Merah pekat
  "#EF4444", // Merah standar
  "#F87171", // Merah sedang
  "#FCA5A5", // Merah pastel
  "#B91C1C", // Merah marun
  "#991B1B"  // Merah tua
];

export const INCOME_COLORS = [
  "#15803D", // Hijau emerald tua
  "#16A34A", // Hijau daun
  "#22C55E", // Hijau terang
  "#4ADE80", // Hijau mint muda
  "#86EFAC", // Hijau pastel
  "#166534"  // Hijau pekat
];

export function generateCategoryBreakdown(transactions = [], isExpense = true, totalAmount = 0) {
  const filtered = transactions.filter((t) => {
    const exp = t.type === "expense" || t.isExpense === true;
    return exp === isExpense;
  });

  if (filtered.length === 0) return [];

  const catMap = {};
  filtered.forEach((tx) => {
    const name = tx.categoryName || tx.name || "Lainnya";
    const amount = Math.abs(tx.amount || 0);
    if (!catMap[name]) {
      catMap[name] = { name, amount: 0, count: 0 };
    }
    catMap[name].amount += amount;
    catMap[name].count += 1;
  });

  const list = Object.values(catMap).sort((a, b) => b.amount - a.amount);
  const effectiveTotal = totalAmount > 0 
    ? totalAmount 
    : list.reduce((sum, item) => sum + item.amount, 0);

  const colors = isExpense ? EXPENSE_COLORS : INCOME_COLORS;

  return list.map((item, index) => {
    const percentage = effectiveTotal > 0 
      ? parseFloat(((item.amount / effectiveTotal) * 100).toFixed(1))
      : 0;
    
    return {
      name: item.name,
      amount: item.amount,
      count: item.count,
      percentage,
      sliceColor: colors[index % colors.length]
    };
  });
}

/**
 * Mock October 2026 Data (Exact Replica of Mobile Prototype)
 */
export const MOCK_OCTOBER_DATA = {
  monthKey: "2026-10",
  year: 2026,
  monthIndex: 9, // Oktober
  totalIncome: 5000000,
  totalExpense: 248466,
  netCashflow: 4751534,
  savingsRate: 95.0,
  healthScore: 95,
  healthStatus: "Sangat Sehat",
  healthRecommendation: "Kondisi keuangan sangat prima. Pertahankan rasio tabungan dan alokasikan ke instrumen investasi.",
  dailyTrends: [
    { dayStr: "01", fullDateStr: "01 Okt", expense: 21000, income: 4500000 },
    { dayStr: "02", fullDateStr: "02 Okt", expense: 97000, income: 0 },
    { dayStr: "05", fullDateStr: "05 Okt", expense: 11466, income: 400000 },
    { dayStr: "06", fullDateStr: "06 Okt", expense: 102000, income: 0 },
    { dayStr: "07", fullDateStr: "07 Okt", expense: 17000, income: 100000 }
  ],
  expenseCategories: [
    { name: "Makanan & Minuman", percentage: 39.0, amount: 97000, sliceColor: "#DC2626", count: 5 },
    { name: "Transportasi", percentage: 29.3, amount: 72666, sliceColor: "#EF4444", count: 3 },
    { name: "Belanja", percentage: 27.7, amount: 68800, sliceColor: "#F87171", count: 4 },
    { name: "Tagihan", percentage: 4.0, amount: 10000, sliceColor: "#FCA5A5", count: 1 }
  ],
  incomeCategories: [
    { name: "Gaji", percentage: 90.0, amount: 4500000, sliceColor: "#15803D", count: 1 },
    { name: "Freelance", percentage: 8.0, amount: 400000, sliceColor: "#16A34A", count: 1 },
    { name: "Hadiah", percentage: 2.0, amount: 100000, sliceColor: "#4ADE80", count: 1 }
  ]
};
