# 🗄️ Struktur Database & Skema Kategori (Categories)

Dokumen ini mendefinisikan struktur database NoSQL Cloud Firestore untuk subkoleksi kategori (`users/{uid}/categories`), pemetaan model Flutter (`CategoryItem`), contoh dokumen JSON, strategi pengindeksan (*indexing*), serta aturan keamanan (*Security Rules*).

---

## 📐 Lokasi Path Dokumen

Setiap pengguna memiliki subkoleksi `categories` mandiri yang terisolasi di bawah dokumen UID mereka:

```text
users/{userId}/categories/{categoryId}
```

---

## 📊 Spesifikasi Field Dokumen Kategori

| Field | Tipe Data | Deskripsi | Wajib? | Contoh / Default |
| :--- | :--- | :--- | :---: | :--- |
| `id` | `string` | ID unik kategori (sama dengan Document ID). | Ya | `"exp-1"`, `"cat_1728551234"` |
| `name` | `string` | Nama kategori (1 - 50 karakter). | Ya | `"Makanan & Minuman"` |
| `iconCode` | `int` | Code point ikon Material Icons Flutter. | Ya | `58737` (`Icons.restaurant_rounded.codePoint`) |
| `color` | `int` | Nilai ARGB32 integer dari warna kartu. | Ya | `4292617766` (`0xFFDC2626`) |
| `isExpense` | `bool` | Indikator jenis kategori (`true` = Pengeluaran, `false` = Pemasukan). | Ya | `true` |
| `isCustom` | `bool` | Indikator kategori buatan user (`true`) atau bawaan sistem (`false`). | Ya | `false` |
| `isLocked` | `bool` | Kategori terkunci sistem yang tidak boleh dihapus. | Ya | `false` (Kecuali kategori "Lainnya" = `true`) |
| `order` | `int` | Urutan tampilan pada grid antarmuka pengguna. | Ya | `1`, `2`, `3` ... |
| `createdAt` | `timestamp` | Waktu saat kategori dibuat di database. | Ya | `FieldValue.serverTimestamp()` |
| `updatedAt` | `timestamp` | Waktu terakhir kategori diperbarui. | Ya | `FieldValue.serverTimestamp()` |

---

## 📄 Contoh Dokumen JSON

### 1. Kategori Pengeluaran Bawaan Sistem (`exp-1`)
```json
{
  "id": "exp-1",
  "name": "Makanan & Minuman",
  "iconCode": 58737,
  "color": 4292617766,
  "isExpense": true,
  "isCustom": false,
  "isLocked": false,
  "order": 1,
  "createdAt": "2026-10-10T10:00:00.000Z",
  "updatedAt": "2026-10-10T10:00:00.000Z"
}
```

### 2. Kategori Terkunci Sistem (`exp-8` - "Lainnya")
```json
{
  "id": "exp-8",
  "name": "Lainnya",
  "iconCode": 58385,
  "color": 4280656875,
  "isExpense": true,
  "isCustom": false,
  "isLocked": true,
  "order": 8,
  "createdAt": "2026-10-10T10:00:00.000Z",
  "updatedAt": "2026-10-10T10:00:00.000Z"
}
```

### 3. Kategori Kustom Buatan Pengguna (`cat_1728559871`)
```json
{
  "id": "cat_1728559871",
  "name": "Kopi & Cafe",
  "iconCode": 58312,
  "color": 4288569888,
  "isExpense": true,
  "isCustom": true,
  "isLocked": false,
  "order": 9,
  "createdAt": "2026-10-10T12:45:00.000Z",
  "updatedAt": "2026-10-10T12:45:00.000Z"
}
```

---

## ⚡ Strategi Inisialisasi Batch (Seeding Default Categories)

Untuk menghemat operasi jaringan dan memastikan konsistensi, penyisipan 14 kategori bawaan dilakukan secara atomik menggunakan Firestore `WriteBatch`:

```dart
Future<void> seedDefaultCategories(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final categoriesRef = firestore.collection('users').doc(uid).collection('categories');
  
  final existing = await categoriesRef.limit(1).get();
  if (existing.docs.isNotEmpty) return; // Sudah terisi sebelumnya

  final batch = firestore.batch();
  final now = FieldValue.serverTimestamp();

  // 1. Seed Expense Categories (8 Kategori)
  final expenses = DefaultCategories.defaultExpenseCategories;
  for (int i = 0; i < expenses.length; i++) {
    final cat = expenses[i];
    final docRef = categoriesRef.doc(cat.id);
    batch.set(docRef, {
      ...cat.toMap(),
      'order': i + 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // 2. Seed Income Categories (6 Kategori)
  final incomes = DefaultCategories.defaultIncomeCategories;
  for (int i = 0; i < incomes.length; i++) {
    final cat = incomes[i];
    final docRef = categoriesRef.doc(cat.id);
    batch.set(docRef, {
      ...cat.toMap(),
      'order': i + 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  await batch.commit();
}
```

---

## 🔍 Kebutuhan Pengindeksan (Composite Indexes)

Untuk menjalankan kueri filter kategori berdasarkan tipe (`isExpense`) dengan pengurutan posisi (`order` ASC), Firestore membutuhkan composite index:

| Collection ID | Fields yang Diindeks | Query Pattern |
| :--- | :--- | :--- |
| `categories` | `isExpense` (ASC), `order` (ASC) | Mengambil semua kategori pengeluaran terurut sesuai urutan prioritas. |
| `categories` | `isExpense` (ASC), `createdAt` (ASC) | Mengambil kategori berdasarkan kronologi penambahan. |

---

## 🛡️ Aturan Keamanan (Firestore Security Rules)

Tambahkan aturan berikut pada konfigurasi `firestore.rules`:

```javascript
match /users/{userId}/categories/{categoryId} {
  // Hanya pemilik akun yang dapat membaca
  allow read: if request.auth != null && request.auth.uid == userId;

  // Validasi pembuatan & pembaruan data
  allow create, update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.name is string
    && request.resource.data.name.size() > 0
    && request.resource.data.name.size() <= 50
    && request.resource.data.isExpense is bool
    && request.resource.data.iconCode is int
    && request.resource.data.color is int;

  // Kategori dengan isLocked == true DILARANG keras dihapus
  allow delete: if request.auth != null && request.auth.uid == userId
    && (!resource.data.keys().hasAll(['isLocked']) || resource.data.isLocked == false);
}
```
