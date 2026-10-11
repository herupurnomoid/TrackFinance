import 'package:csv/csv.dart';
import '../../category/data/category_model.dart';
import '../../transaction/data/transaction_model.dart';
import 'import_data_model.dart';

/// Parser dan validator cerdas baris berkas CSV transaksi (SYNC-09 & SYNC-10).
/// Memvalidasi skema data per baris, memetakan kategori, mendeteksi duplikasi,
/// serta menghasilkan model pratinjau dan daftar baris bermasalah.
class CsvImportParser {
  const CsvImportParser();

  /// Mengurai string CSV menjadi [ImportFileModel] yang terstruktur.
  ImportFileModel parse({
    required String csvString,
    required String fileName,
    required List<CategoryItem> categories,
    List<TransactionModel> existingTransactions = const [],
  }) {
    // Normalisasi line breaks dan BOM
    final cleanCsv = csvString.startsWith('\uFEFF') ? csvString.substring(1) : csvString;
    final normalizedCsv = cleanCsv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(normalizedCsv);

    if (rows.isEmpty || rows.length == 1) {
      throw const FormatException('Berkas CSV kosong atau tidak memiliki baris transaksi.');
    }

    final List<ImportTransactionPreview> previews = [];
    final List<ImportProblematicRow> errorRows = [];
    final List<TransactionModel> validTransactions = [];
    final Set<String> seenRowSignatures = {};

    int validCount = 0;
    int duplicateCount = 0;
    int totalRows = 0;

    // Deteksi pemetaan indeks kolom secara dinamis dari baris header (baris 0)
    final headerRow = rows[0].map((e) => e.toString().trim().toLowerCase()).toList();

    int dateCol = -1;
    int timeCol = -1;
    int typeCol = -1;
    int categoryCol = -1;
    int amountCol = -1;
    int notesCol = -1;

    for (int col = 0; col < headerRow.length; col++) {
      final h = headerRow[col];
      if (h.contains('tanggal') || h.contains('date')) {
        dateCol = col;
      } else if (h.contains('waktu') || h.contains('time') || h.contains('jam')) {
        timeCol = col;
      } else if (h.contains('tipe') || h.contains('type') || h.contains('jenis')) {
        typeCol = col;
      } else if (h.contains('kategori') || h.contains('category')) {
        categoryCol = col;
      } else if (h.contains('nominal') || h.contains('jumlah') || h.contains('amount')) {
        amountCol = col;
      } else if (h.contains('catatan') || h.contains('notes') || h.contains('keterangan') || h.contains('deskripsi')) {
        notesCol = col;
      }
    }

    // Fallback jika header tidak menyebutkan nama kolom spesifik
    if (dateCol == -1 && headerRow.length > 1) dateCol = 1;
    if (typeCol == -1 && headerRow.length > 2) typeCol = 2;
    if (categoryCol == -1 && headerRow.length > 3) categoryCol = 3;
    if (amountCol == -1 && headerRow.length > 4) amountCol = 4;
    if (notesCol == -1 && headerRow.length > 5) notesCol = 5;

    final maxRequiredIndex = [dateCol, typeCol, categoryCol, amountCol]
        .fold<int>(4, (max, idx) => idx > max ? idx : max);

    // Lewati baris 0 (Header tabel)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Abaikan baris kosong
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue;
      }

      totalRows++;
      final rowNumber = i + 1;
      final rawDataString = row.map((e) => e.toString()).join(', ');

      // 1. Validasi Struktur Kolom
      if (row.length <= maxRequiredIndex) {
        errorRows.add(ImportProblematicRow(
          rowNumber: rowNumber,
          reason: 'Struktur kolom baris tidak lengkap',
          rawData: rawDataString,
        ));
        continue;
      }

      final dateRaw = row[dateCol].toString().trim();
      final typeRaw = row[typeCol].toString().trim().toUpperCase();
      final categoryRaw = row[categoryCol].toString().trim();
      final amountRaw = row[amountCol].toString().trim();
      final notes = (notesCol != -1 && row.length > notesCol)
          ? row[notesCol].toString().trim()
          : '';
      final timeRaw = (timeCol != -1 && row.length > timeCol)
          ? row[timeCol].toString().trim()
          : '';
      final effectiveTime = _parseTime(timeRaw);

      // 2. Validasi Tanggal (Mendukung YYYY-MM-DD atau DD/MM/YYYY)
      final parsedDate = _parseDate(dateRaw);
      if (parsedDate == null) {
        errorRows.add(ImportProblematicRow(
          rowNumber: rowNumber,
          reason: 'Format tanggal tidak sesuai standar YYYY-MM-DD',
          rawData: rawDataString,
        ));
        continue;
      }

      // 3. Validasi Tipe Transaksi
      final isExpense = typeRaw.contains('PENGELUARAN') || typeRaw.contains('EXPENSE');
      final isIncome = typeRaw.contains('PEMASUKAN') || typeRaw.contains('INCOME');
      if (!isExpense && !isIncome) {
        errorRows.add(ImportProblematicRow(
          rowNumber: rowNumber,
          reason: 'Tipe transaksi harus bernilai PENGELUARAN atau PEMASUKAN',
          rawData: rawDataString,
        ));
        continue;
      }

      // 4. Validasi Nominal (Harus berupa bilangan bulat positif > 0)
      final amount = _parseAmount(amountRaw);
      if (amount == null || amount <= 0) {
        errorRows.add(ImportProblematicRow(
          rowNumber: rowNumber,
          reason: 'Nominal tidak valid atau kosong',
          rawData: rawDataString,
        ));
        continue;
      }

      // 5. Pencocokan Kategori (Category Mapping)
      final matchedCategory = _resolveCategory(
        categoryRaw: categoryRaw,
        isExpense: isExpense,
        categories: categories,
      );

      final dateKey = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
      final monthKey = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}';

      // 6. Deteksi Duplikasi (SYNC-10)
      // Cek terhadap data Firestore yang sudah tercatat ATAU duplikasi dalam file CSV itu sendiri
      final signature = '$dateKey|$effectiveTime|${isExpense ? "EXP" : "INC"}|$amount|${matchedCategory.name.toLowerCase()}';
      final isDuplicateInDb = existingTransactions.any((tx) {
        return tx.dateKey == dateKey &&
            tx.amount == amount &&
            tx.isExpense == isExpense &&
            tx.categoryName.toLowerCase() == matchedCategory.name.toLowerCase();
      });

      if (isDuplicateInDb || seenRowSignatures.contains(signature)) {
        duplicateCount++;
        continue;
      }

      seenRowSignatures.add(signature);
      validCount++;

      // Parsing jam dan menit ke objek DateTime
      final timeParts = effectiveTime.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 12;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      // Bangun objek TransactionModel
      final txId = 'tx_imp_${parsedDate.millisecondsSinceEpoch}_$i';
      final tx = TransactionModel(
        id: txId,
        type: isExpense ? 'expense' : 'income',
        amount: amount,
        categoryId: matchedCategory.id,
        categoryName: matchedCategory.name,
        categoryIconCode: matchedCategory.icon.codePoint,
        notes: notes,
        timeStr: effectiveTime,
        date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute),
        dateKey: dateKey,
        monthKey: monthKey,
        year: parsedDate.year,
        month: parsedDate.month - 1, // 0-based month
        day: parsedDate.day,
      );
      validTransactions.add(tx);

      // Tambahkan ke pratinjau (Maksimal 10 item pratinjau)
      if (previews.length < 10) {
        previews.add(ImportTransactionPreview(
          category: matchedCategory.name,
          date: _formatPreviewDate(parsedDate),
          amount: amount.toDouble(),
          isExpense: isExpense,
        ));
      }
    }

    return ImportFileModel(
      fileName: fileName,
      totalRows: totalRows,
      validCount: validCount,
      duplicateCount: duplicateCount,
      errorCount: errorRows.length,
      previews: previews,
      problematicRows: errorRows,
      validTransactions: validTransactions,
    );
  }

  /// Parsing tanggal fleksibel mendukung ISO (YYYY-MM-DD) dan standar lokal (DD/MM/YYYY)
  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final parts = raw.split(RegExp(r'[/.-]'));
    if (parts.length == 3) {
      final p1 = int.tryParse(parts[0]);
      final p2 = int.tryParse(parts[1]);
      final p3 = int.tryParse(parts[2]);
      if (p1 != null && p2 != null && p3 != null) {
        if (p3 > 1000) {
          // Format DD/MM/YYYY
          return DateTime(p3, p2, p1);
        } else if (p1 > 1000) {
          // Format YYYY/MM/DD
          return DateTime(p1, p2, p3);
        }
      }
    }
    return null;
  }

  /// Parsing format waktu transaksi (HH:mm atau HH.mm), default '12:00' jika kosong
  String _parseTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '12:00';
    final match = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(s);
    if (match != null) {
      final h = int.tryParse(match.group(1)!) ?? 12;
      final m = int.tryParse(match.group(2)!) ?? 0;
      if (h >= 0 && h < 24 && m >= 0 && m < 60) {
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }
    }
    return '12:00';
  }

  /// Parsing nominal transaksi cerdas mendukung float (misal 20000.0),
  /// ribuan lokal Indonesia (misal 20.000), internasional (20,000), maupun angka polos.
  int? _parseAmount(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    // Hapus prefix mata uang (Rp, IDR), simbol minus/plus, dan spasi awal/akhir
    s = s.replaceAll(RegExp(r'^(?:Rp\.?|IDR|[+–—-])\s*', caseSensitive: false), '').trim();
    if (s.isEmpty) return null;

    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      final lastDotIndex = s.lastIndexOf('.');
      final lastCommaIndex = s.lastIndexOf(',');

      if (lastDotIndex > lastCommaIndex) {
        // Format internasional: 1,000,000.50 -> koma adalah ribuan, titik adalah desimal
        final cleaned = s.replaceAll(',', '');
        final d = double.tryParse(cleaned);
        return d?.round();
      } else {
        // Format Indonesia: 1.000.000,50 -> titik adalah ribuan, koma adalah desimal
        final cleaned = s.replaceAll('.', '').replaceAll(',', '.');
        final d = double.tryParse(cleaned);
        return d?.round();
      }
    } else if (hasComma) {
      final parts = s.split(',');
      if (parts.length > 2) {
        if (parts.last.length != 3) {
          final thousands = parts.sublist(0, parts.length - 1).join('');
          final d = double.tryParse('$thousands.${parts.last}');
          return d?.round();
        } else {
          final cleaned = s.replaceAll(',', '');
          final d = double.tryParse(cleaned);
          return d?.round();
        }
      } else {
        if (parts[1].length == 3 && parts[0].length <= 3) {
          final cleaned = s.replaceAll(',', '');
          final d = double.tryParse(cleaned);
          return d?.round();
        } else {
          final cleaned = '${parts[0]}.${parts[1]}';
          final d = double.tryParse(cleaned);
          return d?.round();
        }
      }
    } else if (hasDot) {
      final parts = s.split('.');
      if (parts.length > 2) {
        if (parts.last.length != 3) {
          final thousands = parts.sublist(0, parts.length - 1).join('');
          final d = double.tryParse('$thousands.${parts.last}');
          return d?.round();
        } else {
          final cleaned = s.replaceAll('.', '');
          final d = double.tryParse(cleaned);
          return d?.round();
        }
      } else {
        if (parts[1].length == 3 && parts[0].length <= 3) {
          final cleaned = s.replaceAll('.', '');
          final d = double.tryParse(cleaned);
          return d?.round();
        } else {
          final d = double.tryParse(s);
          return d?.round();
        }
      }
    } else {
      final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned);
    }
  }

  /// Mencocokkan nama kategori dengan kategori pengguna secara case-insensitive
  /// dan pencocokan parsial cerdas (misal "Tagihan" -> "Tagihan & Pulsa", "Gaji" -> "Gaji Pokok").
  CategoryItem _resolveCategory({
    required String categoryRaw,
    required bool isExpense,
    required List<CategoryItem> categories,
  }) {
    final lowerTarget = categoryRaw.toLowerCase().trim();

    // Filter kategori yang bertipe sama (pengeluaran / pemasukan)
    final candidateCategories = categories.where((c) => c.isExpense == isExpense).toList();

    // 1. Exact match (case-insensitive)
    for (final cat in candidateCategories) {
      if (cat.name.toLowerCase().trim() == lowerTarget) {
        return cat;
      }
    }

    // 2. Substring match (jika target ada di dalam nama kategori atau sebaliknya)
    if (lowerTarget.isNotEmpty) {
      for (final cat in candidateCategories) {
        final catNameLower = cat.name.toLowerCase().trim();
        if (catNameLower == 'lainnya') continue;
        if (catNameLower.contains(lowerTarget) || lowerTarget.contains(catNameLower)) {
          return cat;
        }
      }

      // 3. Word token matching (misal salah satu kata kunci cocok)
      final targetTokens = lowerTarget.split(RegExp(r'[\s&,/]+')).where((t) => t.length > 2).toSet();
      if (targetTokens.isNotEmpty) {
        for (final cat in candidateCategories) {
          final catNameLower = cat.name.toLowerCase().trim();
          if (catNameLower == 'lainnya') continue;
          final catTokens = catNameLower.split(RegExp(r'[\s&,/]+')).where((t) => t.length > 2).toSet();
          if (targetTokens.intersection(catTokens).isNotEmpty) {
            return cat;
          }
        }
      }
    }

    // 4. Jika tidak ditemukan, fallback ke kategori "Lainnya"
    final fallbackList = isExpense
        ? DefaultCategories.defaultExpenseCategories
        : DefaultCategories.defaultIncomeCategories;

    final targetFallbackId = isExpense ? 'exp-8' : 'inc-6';

    return candidateCategories.firstWhere(
      (c) => c.name.toLowerCase() == 'lainnya' || c.id == targetFallbackId,
      orElse: () => fallbackList.last,
    );
  }

  String _formatPreviewDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[dt.month - 1];
    return '$day $mon ${dt.year}';
  }
}
