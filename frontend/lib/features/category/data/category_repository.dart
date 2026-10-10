import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'category_model.dart';

/// Repository untuk mengelola operasi data subkoleksi Cloud Firestore `users/{uid}/categories`
class CategoryRepository {
  final FirebaseFirestore? _customFirestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  static CategoryRepository? _instance;

  /// Singleton instance default untuk CategoryRepository
  static CategoryRepository get instance => _instance ??= CategoryRepository();

  /// Setter untuk pengujian unit / dependency injection
  @visibleForTesting
  static set instance(CategoryRepository repo) => _instance = repo;

  /// Mendapatkan referensi subkoleksi categories milik user tertentu
  CollectionReference<Map<String, dynamic>> _categoryCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  /// Inisialisasi otomatis kategori bawaan (14 kategori: 8 pengeluaran, 6 pemasukan)
  /// menggunakan Firestore WriteBatch jika subkoleksi pengguna masih kosong.
  /// Mengembalikan `true` jika seeding berhasil dilakukan, atau `false` jika data sudah ada / UID kosong.
  Future<bool> seedDefaultCategoriesIfEmpty(String uid) async {
    if (uid.trim().isEmpty) return false;

    try {
      final snapshot = await _categoryCollection(uid).limit(1).get();
      if (snapshot.docs.isNotEmpty) return false;

      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      // 1. Seed Expense Categories (8 Kategori)
      final expenses = DefaultCategories.defaultExpenseCategories;
      for (int i = 0; i < expenses.length; i++) {
        final item = expenses[i];
        final docRef = _categoryCollection(uid).doc(item.id);
        batch.set(docRef, {
          ...item.toFirestore(),
          'order': i + 1,
          'createdAt': now,
          'updatedAt': now,
        });
      }

      // 2. Seed Income Categories (6 Kategori)
      final incomes = DefaultCategories.defaultIncomeCategories;
      for (int i = 0; i < incomes.length; i++) {
        final item = incomes[i];
        final docRef = _categoryCollection(uid).doc(item.id);
        batch.set(docRef, {
          ...item.toFirestore(),
          'order': i + 1,
          'createdAt': now,
          'updatedAt': now,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('CategoryRepository seedDefaultCategoriesIfEmpty error: $e');
      return false;
    }
  }

  /// Alias helper untuk seedDefaultCategoriesIfEmpty
  Future<bool> seedDefaultCategories(String uid) => seedDefaultCategoriesIfEmpty(uid);

  /// Stream realtime daftar kategori pengguna dengan opsi filter isExpense.
  /// Mengurutkan kategori berdasarkan field 'order' secara menaik (ascending).
  Stream<List<CategoryItem>> getCategoriesStream(String uid, {bool? isExpense}) {
    if (uid.trim().isEmpty) {
      return Stream.value(<CategoryItem>[]);
    }

    Query<Map<String, dynamic>> query = _categoryCollection(uid);
    if (isExpense != null) {
      query = query.where('isExpense', isEqualTo: isExpense);
    }

    return query
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryItem.fromFirestore(doc))
            .toList());
  }

  /// Stream realtime daftar kategori berdasarkan tipe isExpense spesifik (Pengeluaran / Pemasukan)
  Stream<List<CategoryItem>> watchCategories(String uid, {required bool isExpense}) {
    return getCategoriesStream(uid, isExpense: isExpense);
  }

  /// Mengambil snapshot daftar kategori satu kali (one-shot Future)
  /// Mendukung opsi [source] (Source.serverAndCache, Source.cache, Source.server) untuk offline persistence (CAT-13).
  Future<List<CategoryItem>> getCategories(
    String uid, {
    bool? isExpense,
    Source source = Source.serverAndCache,
  }) async {
    if (uid.trim().isEmpty) return [];

    Query<Map<String, dynamic>> query = _categoryCollection(uid);
    if (isExpense != null) {
      query = query.where('isExpense', isEqualTo: isExpense);
    }

    final snapshot = await query.orderBy('order', descending: false).get(GetOptions(source: source));
    return snapshot.docs.map((doc) => CategoryItem.fromFirestore(doc)).toList();
  }

  /// Mengambil data satu kategori berdasarkan ID dokumen
  /// Mendukung opsi [source] untuk offline persistence (CAT-13).
  Future<CategoryItem?> getCategoryById(
    String uid,
    String categoryId, {
    Source source = Source.serverAndCache,
  }) async {
    if (uid.trim().isEmpty || categoryId.trim().isEmpty) return null;
    final doc = await _categoryCollection(uid).doc(categoryId).get(GetOptions(source: source));
    if (!doc.exists) return null;
    return CategoryItem.fromFirestore(doc);
  }

  /// 3. Menambah kategori kustom baru ke Firestore (CAT-04)
  Future<String> addCategory(String uid, CategoryItem category) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }

    final docId = category.id.isNotEmpty
        ? category.id
        : _categoryCollection(uid).doc().id;
    final docRef = _categoryCollection(uid).doc(docId);
    final categoryToSave = category.id.isEmpty
        ? category.copyWith(id: docId, isCustom: true)
        : category.copyWith(isCustom: true);

    final now = FieldValue.serverTimestamp();
    await docRef.set({
      ...categoryToSave.toFirestore(),
      'createdAt': now,
      'updatedAt': now,
    });

    return docId;
  }

  /// 4. Memperbarui informasi kategori yang ada (nama, ikon, warna, dll.) (CAT-05)
  Future<void> updateCategory(String uid, CategoryItem category) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }
    if (category.id.trim().isEmpty) {
      throw ArgumentError('Category ID tidak boleh kosong');
    }

    final docRef = _categoryCollection(uid).doc(category.id);
    await docRef.update(category.toFirestore());
  }

  /// 5. Menghapus kategori kustom berdasarkan ID (CAT-06)
  /// Melempar Exception jika kategori bertanda isLocked: true (kategori sistem bawaan)
  Future<void> deleteCategory(String uid, String categoryId) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID tidak boleh kosong');
    }

    final docRef = _categoryCollection(uid).doc(categoryId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    if (doc.data()?['isLocked'] == true) {
      throw Exception('Kategori bawaan sistem tidak dapat dihapus');
    }

    await docRef.delete();
  }

  /// 6. Menghitung jumlah transaksi yang menggunakan kategori tertentu (CAT-07)
  Future<int> countTransactionsByCategory(String uid, String categoryId) async {
    if (uid.trim().isEmpty || categoryId.trim().isEmpty) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Memindahkan seluruh catatan transaksi dari kategori lama ke kategori baru/fallback (CAT-07)
  Future<int> migrateTransactionsCategory(
    String uid, {
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    if (uid.trim().isEmpty || fromCategoryId.trim().isEmpty || toCategoryId.trim().isEmpty) {
      return 0;
    }

    final txCollection = _firestore.collection('users').doc(uid).collection('transactions');
    final querySnapshot = await txCollection.where('categoryId', isEqualTo: fromCategoryId).get();

    if (querySnapshot.docs.isEmpty) return 0;

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'categoryId': toCategoryId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return querySnapshot.docs.length;
  }
}
