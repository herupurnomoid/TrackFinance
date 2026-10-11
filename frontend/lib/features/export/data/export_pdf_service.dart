import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../transaction/data/transaction_model.dart';
import 'trackfinance_logo_data.dart';

/// Service untuk menghasilkan dokumen laporan PDF resmi TrackFinance (SYNC-03)
/// dengan gaya visual modern terinspirasi GoPay E-statement.
class ExportPdfService {
  const ExportPdfService();

  /// Menghasilkan berkas PDF dalam bentuk [Uint8List] siap simpan/bagikan.
  Future<Uint8List> generatePdfBytes({
    required List<TransactionModel> transactions,
    String? userName,
    String? periodLabel,
    DateTime? startDate,
    DateTime? endDate,
    String? logoSvg,
  }) async {
    final pdf = pw.Document();

    // Muat logo SVG TrackFinance
    final effectiveLogoSvg = (logoSvg != null && logoSvg.trim().isNotEmpty)
        ? logoSvg
        : TrackFinanceLogoData.loadSvg();

    // Hitung agregasi data ringkasan
    int totalIncome = 0;
    int totalExpense = 0;
    for (final tx in transactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }
    final int netBalance = totalIncome - totalExpense;
    final int txCount = transactions.length;

    // Palet warna resmi terinspirasi GoPay E-statement & TrackFinance
    const pageBgColor = PdfColor.fromInt(0xFFECEFF6); // Soft lavender-gray page background
    const brandBlue = PdfColor.fromInt(0xFF0284C7); // TrackFinance sky cyan/blue
    const textDark = PdfColor.fromInt(0xFF0F172A); // Slate 900
    const textMuted = PdfColor.fromInt(0xFF64748B); // Slate 500
    const borderColor = PdfColor.fromInt(0xFFE2E8F0); // Slate 200
    const summaryBoxBg = PdfColor.fromInt(0xFFF1F5F9); // Light Gray for summary metrics
    const rowDivider = PdfColor.fromInt(0xFFF1F5F9); // Very light row border
    const incomeGreen = PdfColor.fromInt(0xFF059669); // Emerald 600
    const expenseRed = PdfColor.fromInt(0xFFDC2626); // Rose 600

    // Label periode
    final resolvedPeriod = periodLabel ??
        ((startDate != null && endDate != null)
            ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
            : 'Semua Periode');

    final effectiveUserName = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim().toUpperCase()
        : 'PENGGUNA TRACKFINANCE';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 42),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  // 1. Warna latar belakang halaman penuh (GoPay soft background)
                  pw.Container(color: pageBgColor),

                  // 2. Banner dekorasi melengkung di bagian bawah halaman
                  pw.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: pw.Container(
                      height: 34,
                      decoration: const pw.BoxDecoration(
                        color: brandBlue,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(20),
                          topRight: pw.Radius.circular(20),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'TrackFinance | Aplikasi Manajemen Keuangan Pribadi yang Aman & Terpercaya',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 7.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Logo SVG TrackFinance + Brand Text + Badge E-statement
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 18,
                      height: 18,
                      child: pw.ClipRRect(
                        horizontalRadius: 4,
                        verticalRadius: 4,
                        child: pw.SvgImage(
                          svg: effectiveLogoSvg,
                          width: 18,
                          height: 18,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'TrackFinance',
                      style: pw.TextStyle(
                        color: textDark,
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: borderColor, width: 0.6),
                      ),
                      child: pw.Text(
                        'E-statement',
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Pill indikator halaman
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor, width: 0.6),
                  ),
                  child: pw.Text(
                    'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                    style: pw.TextStyle(
                      color: textMuted,
                      fontSize: 8,
                    ),
                  ),
                ),
                // Periode transaksi
                pw.Row(
                  children: [
                    pw.Text(
                      'Periode transaksi : ',
                      style: pw.TextStyle(color: textMuted, fontSize: 8),
                    ),
                    pw.Text(
                      resolvedPeriod,
                      style: pw.TextStyle(
                        color: textDark,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            alignment: pw.Alignment.center,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 14,
                  height: 14,
                  child: pw.ClipRRect(
                    horizontalRadius: 3,
                    verticalRadius: 3,
                    child: pw.SvgImage(
                      svg: effectiveLogoSvg,
                      width: 14,
                      height: 14,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  'TrackFinance',
                  style: pw.TextStyle(
                    color: textDark,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // 1. BAGIAN PROFIL & RINGKASAN METRIK (Kartu Putih Atas)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: borderColor, width: 0.6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Info Pemilik Akun
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        effectiveUserName,
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Tanggal unduh : ${_formatDate(DateTime.now())}',
                        style: pw.TextStyle(color: textMuted, fontSize: 8),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'Laporan Riwayat Transaksi Resmi',
                        style: pw.TextStyle(color: textMuted, fontSize: 7.5),
                      ),
                    ],
                  ),
                  // Box Ringkasan Metrik Horizontal (Style GoPay)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: summaryBoxBg,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: borderColor, width: 0.5),
                    ),
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        _buildMetricItem('Total pemasukan', '+${_formatRupiah(totalIncome)}', incomeGreen),
                        _buildVerticalDivider(borderColor),
                        _buildMetricItem('Total pengeluaran', '-${_formatRupiah(totalExpense)}', textDark),
                        _buildVerticalDivider(borderColor),
                        _buildMetricItem(
                          'Arus kas bersih',
                          _formatRupiah(netBalance),
                          netBalance >= 0 ? incomeGreen : expenseRed,
                        ),
                        _buildVerticalDivider(borderColor),
                        _buildMetricItem('Total transaksi', '$txCount data', textDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. TABEL RINCIAN TRANSAKSI (Sesuai Struktur Row & Kolom Resmi)
            if (transactions.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor, width: 0.8),
                ),
                child: pw.Text(
                  'Tidak ada data transaksi yang tercatat pada rentang periode ini.',
                  style: pw.TextStyle(color: textMuted, fontSize: 9.5),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: rowDivider, width: 0.6),
                  top: pw.BorderSide(color: borderColor, width: 0.8),
                  bottom: pw.BorderSide(color: borderColor, width: 0.8),
                ),
                headerHeight: 24,
                headerStyle: pw.TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                headers: <String>[
                  'No',
                  'Tanggal',
                  'Waktu',
                  'Tipe',
                  'Kategori',
                  'Catatan',
                  'Nominal (Rp)',
                ],
                columnWidths: const {
                  0: pw.FixedColumnWidth(22),
                  1: pw.FixedColumnWidth(58),
                  2: pw.FixedColumnWidth(36),
                  3: pw.FixedColumnWidth(84),
                  4: pw.FixedColumnWidth(92),
                  5: pw.FlexColumnWidth(),
                  6: pw.FixedColumnWidth(88),
                },
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                cellStyle: pw.TextStyle(
                  color: textDark,
                  fontSize: 8,
                ),
                cellAlignments: const {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                  6: pw.Alignment.centerRight,
                },
                rowDecoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                oddRowDecoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                data: List<List<dynamic>>.generate(
                  transactions.length,
                  (index) {
                    final tx = transactions[index];
                    final isExp = tx.isExpense;
                    final prefix = isExp ? '-' : '+';
                    final timeLabel = tx.timeStr.trim().isNotEmpty
                        ? tx.timeStr.trim()
                        : '${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}';
                    return [
                      '${index + 1}',
                      tx.dateKey,
                      timeLabel,
                      isExp ? 'PENGELUARAN' : 'PEMASUKAN',
                      tx.categoryName,
                      tx.notes.isEmpty ? '-' : tx.notes,
                      '$prefix${_formatRupiah(tx.amount)}',
                    ];
                  },
                ),
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Membangun metrik ringkasan tunggal di dalam box horizontal
  static pw.Widget _buildMetricItem(String label, String value, PdfColor valueColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFF64748B),
              fontSize: 7,
            ),
          ),
          pw.SizedBox(height: 2.5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Garis pemisah vertikal tipis antar metrik
  static pw.Widget _buildVerticalDivider(PdfColor color) {
    return pw.Container(
      width: 0.6,
      height: 22,
      color: color,
    );
  }

  static String _formatRupiah(int number) {
    final absVal = number.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    final prefix = number < 0 ? '-Rp' : 'Rp';
    return '$prefix$absVal';
  }

  static String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }
}
