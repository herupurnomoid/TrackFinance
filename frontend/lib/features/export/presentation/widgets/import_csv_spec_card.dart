import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen Tabel Format CSV Preview
/// Menampilkan struktur format file CSV yang diterima oleh sistem
/// dengan scroll horizontal dan tactile card styling.
class ImportCsvSpecCard extends StatelessWidget {
  const ImportCsvSpecCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Format CSV',
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
            Row(
              children: [
                Icon(
                  Icons.swipe_left_rounded,
                  size: 14,
                  color: const Color(0xFF64748B).withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Geser tabel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Elevated Outer Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF2F3FF),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2FD).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC3C6D7).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 44,
                horizontalMargin: 12,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFEAEDFF)),
                columns: [
                  _buildHeaderColumn('NO'),
                  _buildHeaderColumn('TANGGAL'),
                  _buildHeaderColumn('TIPE'),
                  _buildHeaderColumn('KATEGORI'),
                  _buildHeaderColumn('JUMLAH (IDR)', isNumeric: true),
                  _buildHeaderColumn('CATATAN'),
                ],
                rows: [
                  // Row 1: Pengeluaran (Sesuai Mockup Referensi)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '1',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: const Color(0xFF434655),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '2026-10-01',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: const Color(0xFF131B2E),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PENGELUARAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF93000A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'Makanan & Minuman',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF131B2E),
                          ),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '21.000',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF131B2E),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'kantin lck',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF434655),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Row 2: Pemasukan (Pelengkap Spec)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '2',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: const Color(0xFF434655),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '2026-10-02',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: const Color(0xFF131B2E),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PEMASUKAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'Gaji & Penghasilan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF131B2E),
                          ),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '5.000.000',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF131B2E),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'gaji bulanan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF434655),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataColumn _buildHeaderColumn(String title, {bool isNumeric = false}) {
    return DataColumn(
      numeric: isNumeric,
      label: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF434655),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
