# 🗄️ Struktur Database & Skema Transaksi (Transactions)

Dokumen ini mendefinisikan struktur database NoSQL Cloud Firestore untuk subkoleksi transaksi (`users/{uid}/transactions`), subkoleksi agregasi bulanan (`users/{uid}/monthly_summaries`), strategi transaksi atomik (*WriteBatch*), kebutuhan pengindeksan (*indexing*), serta aturan keamanan (*Security Rules*).

---

## 📐 Lokasi Path Dokumen

```text
users/{userId}/transactions/{transactionId}
users/{userId}/monthly_summaries/{monthKey}
```

---

## 📊 1. Spesifikasi Field: `transactions`

Subkoleksi ini menyimpan setiap entri transaksi pengeluaran dan pemasukan pengguna.

| Field | Tipe Data | Deskripsi | Wajib? | Contoh / Format |
| :--- | :--- | :--- | :---: | :--- |
| `id` | `string` | ID unik transaksi (Document ID). | Ya | `"tx_1728551234"` |
| `type` | `string` | Jenis transaksi: `"expense"` atau `"income"`. | Ya | `"expense"` |
| `amount` | `number` | Nominal uang dalam Rupiah (selalu bilangan bulat positif). | Ya | `150000` |
| `categoryId` | `string` | ID referensi kategori (*Foreign Key*). | Ya | `"exp-1"` |
| `categoryName`| `string` | Nama kategori saat transaksi dibuat (denormalisasi untuk performa). | Ya | `"Makanan & Minuman"` |
| `categoryIconCode` | `int` | Code point ikon kategori. | Ya | `58737` |
| `notes` | `string` | Catatan atau deskripsi transaksi. | Opsional | `"Makan siang bersama tim"` |
| `timeStr` | `string` | Waktu transaksi format jam.menit. | Ya | `"14.30"` |
| `date` | `timestamp` | Waktu transaksi sebenarnya (digunakan untuk sorting). | Ya | `Timestamp(seconds, nanoseconds)` |
| `dateKey` | `string` | Kunci filter harian format `YYYY-MM-DD`. | Ya | `"2026-10-10"` |
| `monthKey` | `string` | Kunci filter bulanan format `YYYY-MM`. | Ya | `"2026-10"` |
| `year` | `int` | Tahun transaksi. | Ya | `2026` |
| `month` | `int` | Bulan transaksi (0-based: 0 = Jan, 9 = Okt). | Ya | `9` |
| `day` | `int` | Tanggal transaksi. | Ya | `10` |
| `createdAt` | `timestamp` | Waktu transaksi dibuat di sistem. | Ya | `FieldValue.serverTimestamp()` |
| `updatedAt` | `timestamp` | Waktu transaksi terakhir diedit. | Ya | `FieldValue.serverTimestamp()` |

### 📄 Contoh JSON Transaksi Pengeluaran
```json
{
  "id": "tx_20261010_01",
  "type": "expense",
  "amount": 150000,
  "categoryId": "exp-1",
  "categoryName": "Makanan & Minuman",
  "categoryIconCode": 58737,
  "notes": "Makan siang bersama tim",
  "timeStr": "14.30",
  "date": "2026-10-10T07:30:00.000Z",
  "dateKey": "2026-10-10",
  "monthKey": "2026-10",
  "year": 2026,
  "month": 9,
  "day": 10,
  "createdAt": "2026-10-10T07:30:15.000Z",
  "updatedAt": "2026-10-10T07:30:15.000Z"
}
```

### 📄 Contoh JSON Transaksi Pemasukan
```json
{
  "id": "tx_20261010_02",
  "type": "income",
  "amount": 9500000,
  "categoryId": "inc-1",
  "categoryName": "Gaji Pokok",
  "categoryIconCode": 58784,
  "notes": "Gaji Bulanan Oktober",
  "timeStr": "09.00",
  "date": "2026-10-10T02:00:00.000Z",
  "dateKey": "2026-10-10",
  "monthKey": "2026-10",
  "year": 2026,
  "month": 9,
  "day": 10,
  "createdAt": "2026-10-10T02:00:15.000Z",
  "updatedAt": "2026-10-10T02:00:15.000Z"
}
```

---

## 📊 2. Spesifikasi Field: `monthly_summaries`

Subkoleksi ini menyimpan agregasi arus kas bulanan untuk mempercepat rendering Dashboard tanpa biaya baca tinggi.

- **Document ID**: Format `YYYY-MM` (contoh: `2026-10`).

| Field | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `monthKey` | `string` | ID kunci bulan (`"2026-10"`). |
| `year` | `int` | Tahun kalender (`2026`). |
| `month` | `int` | Bulan kalender (`9` untuk Oktober). |
| `totalIncome` | `number` | Akumulasi seluruh pemasukan bulan ini (Rp). |
| `totalExpense` | `number` | Akumulasi seluruh pengeluaran bulan ini (Rp). |
| `netCashflow` | `number` | Arus kas bersih (`totalIncome - totalExpense`). |
| `transactionCount` | `int` | Jumlah total transaksi pada bulan tersebut. |
| `categoryBreakdown`| `map` | Pemetaan akumulasi pengeluaran per kategori. |
| `updatedAt` | `timestamp` | Waktu terakhir ringkasan diperbarui. |

### 📄 Contoh JSON Ringkasan Bulanan
```json
{
  "monthKey": "2026-10",
  "year": 2026,
  "month": 9,
  "totalIncome": 9800000,
  "totalExpense": 4250000,
  "netCashflow": 5550000,
  "transactionCount": 24,
  "categoryBreakdown": {
    "exp-1": {
      "name": "Makanan & Minuman",
      "total": 1750000,
      "count": 14
    },
    "exp-2": {
      "name": "Transportasi",
      "total": 950000,
      "count": 6
    }
  },
  "updatedAt": "2026-10-10T07:30:15.000Z"
}
```

---

## ⚡ Strategi Operasi Atomik (Atomic WriteBatch)

Operasi penambahan, pengubahan, dan penghapusan transaksi **wajib** menggunakan Firestore `WriteBatch` untuk menjamin konsistensi data secara atomik.

### 1. Menambah Transaksi Baru
```dart
final batch = firestore.batch();

// A. Tulis dokumen transaksi
batch.set(txDocRef, tx.toFirestore());

// B. Akumulasi ringkasan bulanan
final isExpense = tx.type == 'expense';
batch.set(summaryDocRef, {
  'monthKey': tx.monthKey,
  'year': tx.year,
  'month': tx.month,
  'totalExpense': FieldValue.increment(isExpense ? tx.amount : 0),
  'totalIncome': FieldValue.increment(!isExpense ? tx.amount : 0),
  'netCashflow': FieldValue.increment(isExpense ? -tx.amount : tx.amount),
  'transactionCount': FieldValue.increment(1),
  'categoryBreakdown.${tx.categoryId}.name': tx.categoryName,
  'categoryBreakdown.${tx.categoryId}.total': FieldValue.increment(tx.amount),
  'categoryBreakdown.${tx.categoryId}.count': FieldValue.increment(1),
  'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

// C. Update saldo akun pengguna
batch.update(userDocRef, {
  'totalBalance': FieldValue.increment(isExpense ? -tx.amount : tx.amount),
});

await batch.commit();
```

### 2. Mengedit Transaksi (Delta Correction)
Jika nominal berubah dari `oldTx` ke `newTx`:
- Hitung selisih nominal (*delta*).
- Terapkan `FieldValue.increment(delta)` pada saldo dan ringkasan bulanan.

### 3. Menghapus Transaksi
- Hapus dokumen `txDocRef`.
- Kurangi nilai pada ringkasan bulanan dengan `FieldValue.increment(-amount)` dan kembalikan saldo akun.

---

## 🔍 Kebutuhan Pengindeksan (Composite Indexes)

Untuk memastikan query pengurutan riwayat transaksi berjalan mulus tanpa error `FAILED_PRECONDITION`, buat composite index berikut:

| Collection ID | Fields yang Diindeks | Kebutuhan Kueri |
| :--- | :--- | :--- |
| `transactions` | `monthKey` (ASC), `date` (DESC) | Menampilkan riwayat transaksi per bulan terurut dari yang terbaru. |
| `transactions` | `type` (ASC), `date` (DESC) | Filter khusus pengeluaran / pemasukan terurut tanggal. |
| `transactions` | `categoryId` (ASC), `date` (DESC) | Filter transaksi berdasarkan kategori tertentu. |
| `transactions` | `dateKey` (ASC), `createdAt` (DESC) | Filter transaksi pada tanggal tertentu. |

---

## 🛡️ Aturan Keamanan (Firestore Security Rules)

Tambahkan aturan berikut pada konfigurasi `firestore.rules`:

```javascript
// Subkoleksi: transactions
match /users/{userId}/transactions/{transactionId} {
  allow read: if request.auth != null && request.auth.uid == userId;

  allow create, update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.amount is number
    && request.resource.data.amount > 0
    && (request.resource.data.type == 'expense' || request.resource.data.type == 'income')
    && request.resource.data.categoryId is string
    && request.resource.data.date is timestamp;

  allow delete: if request.auth != null && request.auth.uid == userId;
}

// Subkoleksi: monthly_summaries
match /users/{userId}/monthly_summaries/{monthKey} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```
