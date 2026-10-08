import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExportPreviewRow {
  final String no;
  final String date;
  final bool isIncome;
  final String category;
  final String amount;
  final String note;

  const ExportPreviewRow({
    required this.no,
    required this.date,
    required this.isIncome,
    required this.category,
    required this.amount,
    required this.note,
  });
}

class ExportPreviewTable extends StatelessWidget {
  final int totalCount;
  final String periodText;

  const ExportPreviewTable({
    super.key,
    this.totalCount = 28,
    this.periodText = 'Mei 2025',
  });

  static const List<ExportPreviewRow> defaultRows = [
    ExportPreviewRow(
      no: '1',
      date: '25/05/2025',
      isIncome: true,
      category: 'Gaji',
      amount: 'Rp 5.000.000',
      note: 'Gaji Bulanan',
    ),
    ExportPreviewRow(
      no: '2',
      date: '26/05/2025',
      isIncome: false,
      category: 'Makanan',
      amount: 'Rp 45.000',
      note: 'Makan Siang',
    ),
    ExportPreviewRow(
      no: '3',
      date: '27/05/2025',
      isIncome: false,
      category: 'Transport',
      amount: 'Rp 25.000',
      note: 'Ojek Kantor',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.preview_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pratinjau Data (6 Kolom)',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '6 Kolom Sesuai',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Total Data Info Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2C3A).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixedDim,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      children: [
                        TextSpan(
                          text: '$totalCount Transaksi ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(text: 'siap diekspor untuk periode $periodText.'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Scrollable Mini Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2C3A).withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 480),
                child: DataTable(
                  horizontalMargin: 8,
                  columnSpacing: 16,
                  headingRowHeight: 34,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 42,
                  headingTextStyle: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Tipe')),
                    DataColumn(label: Text('Kategori')),
                    DataColumn(label: Text('Jumlah (IDR)')),
                    DataColumn(label: Text('Catatan')),
                  ],
                  rows: defaultRows.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            row.no,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(row.date)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: row.isIncome
                                  ? AppColors.tertiaryFixed
                                  : AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              row.isIncome ? 'Pemasukan' : 'Pengeluaran',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: row.isIncome
                                    ? const Color(0xFF004D64)
                                    : AppColors.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(row.category)),
                        DataCell(
                          Text(
                            row.amount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: row.isIncome
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              row.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.secondary),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Geser tabel untuk memeriksa kolom lengkap',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
