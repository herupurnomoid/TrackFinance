import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/import_data_model.dart';

/// Komponen Seksi Pratinjau Data Transaksi
/// Menampilkan daftar kartu pratinjau transaksi hasil parsing file CSV
/// dengan penanda pengeluaran (merah) dan pemasukan (hijau).
class ImportDataPreviewSection extends StatelessWidget {
  final List<ImportTransactionPreview> previews;
  final int totalValid;

  const ImportDataPreviewSection({
    super.key,
    required this.previews,
    required this.totalValid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Seksi Pratinjau
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Pratinjau Data',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF131B2E),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Menampilkan ${previews.length} dari $totalValid',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF737686),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Daftar Kartu Transaksi Pratinjau
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: previews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = previews[index];
            return _buildPreviewCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildPreviewCard(ImportTransactionPreview item) {
    final bool isExpense = item.isExpense;
    final Color iconBg = isExpense ? const Color(0xFFFFDAD6) : const Color(0xFFDCFCE7);
    final Color iconColor = isExpense ? const Color(0xFFBA1A1A) : const Color(0xFF006329);
    final Color amountColor = isExpense ? const Color(0xFFBA1A1A) : const Color(0xFF006329);
    final IconData icon = isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF2F3FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF131B2E).withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Ikon Transaksi + Kategori & Tanggal
          Expanded(
            child: Row(
              children: [
                // Circular Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 18,
                      color: iconColor,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Kategori & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF131B2E),
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.date,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF434655),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Kanan: Nominal Transaksi
          Text(
            item.formattedAmount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amountColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
