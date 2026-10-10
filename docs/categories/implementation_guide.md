# 🛠️ Panduan Implementasi Teknis: Fitur Kategori (Category)

Dokumen ini memandu langkah-demi-langkah implementasi kode Flutter untuk mengintegrasikan **Fitur Manajemen Kategori** dengan **Cloud Firestore SDK**.

---

## 🎯 Target Implementasi
1. Menambahkan fungsi serialisasi Cloud Firestore pada model `CategoryItem`.
2. Membuat service layer `CategoryRepository` yang menangani operasi CRUD dan realtime streaming.
3. Menghubungkan antarmuka `CategoryScreen`, `AddCategoryModal`, dan `CategoryDeleteDialog` dengan database.
4. Menambahkan pengecekan integritas data transaksi sebelum kategori dihapus.

---

## 📂 Langkah 1: Perbarui Model `CategoryItem`

Buka file [frontend/lib/features/category/data/category_model.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/category/data/category_model.dart) dan tambahkan metode serialisasi Firestore:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final bool isExpense;
  final bool isCustom;
  final Color color;
  final bool isLocked;
  final int order;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
    this.isCustom = false,
    this.color = const Color(0xFF2563EB),
    this.isLocked = false,
    this.order = 0,
  });

  // Konversi dokumen Firestore ke Model CategoryItem
  factory CategoryItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final iconCode = data['iconCode'] as int? ?? Icons.category_rounded.codePoint;
    final colorInt = data['color'] as int? ?? 0xFF2563EB;

    return CategoryItem(
      id: doc.id,
      name: data['name'] as String? ?? 'Kategori',
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      isExpense: data['isExpense'] as bool? ?? true,
      isCustom: data['isCustom'] as bool? ?? false,
      color: Color(colorInt),
      isLocked: data['isLocked'] as bool? ?? false,
      order: data['order'] as int? ?? 0,
    );
  }

  // Konversi Model ke format Map Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconCode': icon.codePoint,
      'color': color.toARGB32(),
      'isExpense': isExpense,
      'isCustom': isCustom,
      'isLocked': isLocked,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CategoryItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isExpense,
    bool? isCustom,
    Color? color,
    bool? isLocked,
    int? order,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isExpense: isExpense ?? this.isExpense,
      isCustom: isCustom ?? this.isCustom,
      color: color ?? this.color,
      isLocked: isLocked ?? this.isLocked,
      order: order ?? this.order,
    );
  }
}
```

---

## 📂 Langkah 2: Buat `CategoryRepository`

Buat file baru di [frontend/lib/features/category/data/category_repository.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/category/data/category_repository.dart):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final CategoryRepository instance = CategoryRepository();

  CollectionReference<Map<String, dynamic>> _categoryCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  /// 1. Stream realtime daftar kategori pengguna berdasarkan tipe (Pengeluaran / Pemasukan)
  Stream<List<CategoryItem>> watchCategories(String uid, {required bool isExpense}) {
    return _categoryCollection(uid)
        .where('isExpense', isEqualTo: isExpense)
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryItem.fromFirestore(doc)).toList());
  }

  /// 2. Inisialisasi otomatis kategori bawaan jika subkoleksi masih kosong
  Future<void> seedDefaultCategoriesIfEmpty(String uid) async {
    final snapshot = await _categoryCollection(uid).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // Seed Expense (8 Kategori)
    final expenses = DefaultCategories.defaultExpenseCategories;
    for (int i = 0; i < expenses.length; i++) {
      final item = expenses[i];
      final docRef = _categoryCollection(uid).doc(item.id);
      batch.set(docRef, {
        ...item.toFirestore(),
        'order': i + 1,
        'createdAt': now,
      });
    }

    // Seed Income (6 Kategori)
    final incomes = DefaultCategories.defaultIncomeCategories;
    for (int i = 0; i < incomes.length; i++) {
      final item = incomes[i];
      final docRef = _categoryCollection(uid).doc(item.id);
      batch.set(docRef, {
        ...item.toFirestore(),
        'order': i + 1,
        'createdAt': now,
      });
    }

    await batch.commit();
  }

  /// 3. Menambah kategori kustom baru
  Future<void> addCategory(String uid, CategoryItem category) async {
    final docRef = _categoryCollection(uid).doc(category.id);
    await docRef.set({
      ...category.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 4. Memperbarui kategori yang ada
  Future<void> updateCategory(String uid, CategoryItem category) async {
    final docRef = _categoryCollection(uid).doc(category.id);
    await docRef.update(category.toFirestore());
  }

  /// 5. Menghapus kategori kustom (Validasi isLocked)
  Future<void> deleteCategory(String uid, String categoryId) async {
    final docRef = _categoryCollection(uid).doc(categoryId);
    final doc = await docRef.get();
    
    if (doc.exists && (doc.data()?['isLocked'] == true)) {
      throw Exception('Kategori bawaan sistem tidak dapat dihapus');
    }

    await docRef.delete();
  }

  /// 6. Menghitung jumlah transaksi yang menggunakan kategori tertentu
  Future<int> countTransactionsByCategory(String uid, String categoryId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
```

---

## 📂 Langkah 3: Integrasi ke `CategoryScreen`

Di file [frontend/lib/features/category/presentation/screens/category_screen.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/category/presentation/screens/category_screen.dart):

1. **Panggil Seeding Otomatis pada `initState`**:
```dart
@override
void initState() {
  super.initState();
  final uid = widget.user?.uid;
  if (uid != null) {
    CategoryRepository.instance.seedDefaultCategoriesIfEmpty(uid);
  }
}
```

2. **Ganti List Lokal dengan `StreamBuilder`**:
```dart
StreamBuilder<List<CategoryItem>>(
  stream: CategoryRepository.instance.watchCategories(
    widget.user?.uid ?? '',
    isExpense: _isExpenseTab,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CategorySkeleton();
    }
    
    final categories = snapshot.data ?? [];
    if (categories.isEmpty) {
      return CategoryEmptyState(
        isExpense: _isExpenseTab,
        onAddPressed: _openAddModal,
      );
    }

    return GridView.builder(
      // Render CategoryGridItem dari Firestore stream
      itemCount: categories.length,
      itemBuilder: (context, index) => CategoryGridItem(
        category: categories[index],
        onTap: () => _handleCategoryClick(categories[index]),
      ),
    );
  },
)
```

3. **Operasi Simpan di `AddCategoryModal`**:
```dart
onSave: (name, icon, color, isExpense) async {
  final uid = widget.user?.uid;
  if (uid == null) return;

  final newCategory = CategoryItem(
    id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
    name: name,
    icon: icon,
    color: color,
    isExpense: isExpense,
    isCustom: true,
  );

  await CategoryRepository.instance.addCategory(uid, newCategory);
  _showToast('Kategori "$name" berhasil disimpan');
}
```

4. **Operasi Hapus dengan Pengecekan Transaksi**:
```dart
void _showDeleteDialog(CategoryItem category) async {
  final uid = widget.user?.uid;
  if (uid == null) return;

  final txCount = await CategoryRepository.instance.countTransactionsByCategory(uid, category.id);

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (context) => CategoryDeleteDialog(
      categoryName: category.name,
      transactionCount: txCount,
      onConfirmDelete: () async {
        await CategoryRepository.instance.deleteCategory(uid, category.id);
        _showToast('Kategori "${category.name}" berhasil dihapus');
      },
    ),
  );
}
```

---

## 🧪 Langkah 4: Pengujian & Validasi

Jalankan pengujian test suite:
```bash
cd frontend
flutter test test/category_model_test.dart
flutter test
```
Pastikan seluruh interaksi tambah, ubah, dan hapus berjalan mulus baik saat online maupun saat berada dalam mode cache luring (*offline persistence*).
