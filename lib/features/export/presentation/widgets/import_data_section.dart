import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

class ImportDataSection extends StatefulWidget {
  final VoidCallback? onCancel;
  final void Function(String message)? onShowToast;

  const ImportDataSection({
    super.key,
    this.onCancel,
    this.onShowToast,
  });

  @override
  State<ImportDataSection> createState() => _ImportDataSectionState();
}

class _ImportDataSectionState extends State<ImportDataSection> {
  // Whether an active file is selected/uploaded
  bool _hasFile = true;
  String _fileName = 'transaksi_keuangan_mei_2025.csv';
  String _fileSize = '142 KB';
  int _transactionCount = 24;

  // Import state
  bool _isImporting = false;
  bool _isImported = false;

  void _pickSampleFile() {
    setState(() {
      _hasFile = true;
      _fileName = 'transaksi_keuangan_mei_2025.csv';
      _fileSize = '142 KB';
      _transactionCount = 24;
      _isImported = false;
    });
    widget.onShowToast?.call('Berkas $_fileName terverifikasi 6 kolom!');
  }

  void _clearFile() {
    setState(() {
      _hasFile = false;
      _isImported = false;
    });
    widget.onShowToast?.call('Berkas CSV dihapus. Silakan pilih berkas baru.');
  }

  void _handleDownloadTemplate() {
    widget.onShowToast?.call('Contoh template CSV (12 KB) berhasil diunduh!');
  }

  Future<void> _handleStartImport() async {
    if (_isImporting || !_hasFile) return;

    setState(() {
      _isImporting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    setState(() {
      _isImporting = false;
      _isImported = true;
    });

    widget.onShowToast?.call('$_transactionCount transaksi berhasil diimpor ke sistem!');

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() {
        _isImported = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header & Format Guidance
        _buildHeaderGuidance(),

        const SizedBox(height: 14),

        // 2. Template Download Pill Card
        _buildTemplateDownloadCard(),

        const SizedBox(height: 18),

        // 3. Upload Area (Dropzone Box)
        _buildDropzoneBox(),

        if (_hasFile) ...[
          const SizedBox(height: 12),
          // 4. Active Uploaded File Card
          _buildActiveUploadedFileCard(),

          const SizedBox(height: 20),

          // 5. Data Import Preview (6 Kolom Terdeteksi)
          _buildImportPreviewCard(),

          const SizedBox(height: 24),

          // 6. Primary CTA Actions (Mulai Impor & Batal)
          _buildActionButtons(),
        ] else ...[
          const SizedBox(height: 20),
          _buildEmptyFileHintCard(),
        ],
      ],
    );
  }

  // Header & Format Guidance
  Widget _buildHeaderGuidance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'UNGGAH CATATAN KEUANGAN',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Impor File Transaksi',
          style: AppTextStyles.headlineLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Sistem memproses file ',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
              fontSize: 13.5,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '.CSV',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: ' terstruktur dengan 6 kolom standar: ',
              ),
              TextSpan(
                text: 'No, Tanggal, Tipe, Kategori, Jumlah (IDR), Catatan.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Template Download Pill Card
  Widget _buildTemplateDownloadCard() {
    return PressableScale(
      onTap: _handleDownloadTemplate,
      scaleFactor: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF65D0F4).withValues(alpha: 0.18),
              blurRadius: 18,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF0D2C3A).withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.95),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with inner specular reflection
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.table_view_rounded,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unduh Contoh Template .CSV',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Format tabel siap pakai (12 KB)',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF65D0F4).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropzone Box
  Widget _buildDropzoneBox() {
    return PressableScale(
      onTap: _pickSampleFile,
      scaleFactor: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFD8E5EA).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2C3A).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Circular 3D Clay Disc
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.60),
                    blurRadius: 22,
                    spreadRadius: -3,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.7),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00586D).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.upload_file_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Pilih atau Tarik File .CSV ke Sini',
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Maksimal ukuran file 10MB',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.secondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Active Uploaded File Card
  Widget _buildActiveUploadedFileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.description_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // File Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _fileName,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$_fileSize • Siap diverifikasi',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.secondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Dismiss / Remove File Button
          PressableScale(
            onTap: _clearFile,
            scaleFactor: 0.92,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E5EA).withValues(alpha: 0.40),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D2C3A).withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Data Import Preview Card
  Widget _buildImportPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF65D0F4).withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pratinjau Berkas',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '6 Kolom Terdeteksi',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Scrollable Mini Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD8E5EA).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2C3A).withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 540),
                child: DataTable(
                  horizontalMargin: 10,
                  columnSpacing: 16,
                  headingRowHeight: 38,
                  dataRowMinHeight: 44,
                  dataRowMaxHeight: 44,
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                  ),
                  headingTextStyle: AppTextStyles.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Tipe')),
                    DataColumn(label: Text('Kategori')),
                    DataColumn(
                      numeric: true,
                      label: Text('Jumlah (IDR)'),
                    ),
                    DataColumn(label: Text('Catatan')),
                  ],
                  rows: [
                    _buildDataRow(
                      no: '1',
                      date: '25 Mei 2025',
                      type: 'Pemasukan',
                      isIncome: true,
                      category: 'Gaji',
                      amount: 'Rp 8.500.000',
                      notes: 'Gaji Bulanan',
                    ),
                    _buildDataRow(
                      no: '2',
                      date: '26 Mei 2025',
                      type: 'Pengeluaran',
                      isIncome: false,
                      category: 'Makanan',
                      amount: 'Rp 45.000',
                      notes: 'Makan Siang',
                    ),
                    _buildDataRow(
                      no: '3',
                      date: '27 Mei 2025',
                      type: 'Pengeluaran',
                      isIncome: false,
                      category: 'Transportasi',
                      amount: 'Rp 30.000',
                      notes: 'Bensin Motor',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Match Indicator
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Semua kolom sesuai dengan format sistem',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow({
    required String no,
    required String date,
    required String type,
    required bool isIncome,
    required String category,
    required String amount,
    required String notes,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            no,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        DataCell(
          Text(
            date,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF65D0F4).withValues(alpha: 0.20)
                  : AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              type,
              style: AppTextStyles.labelSm.copyWith(
                color: isIncome ? AppColors.primary : AppColors.onSecondaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            category,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Text(
            amount,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Text(
            notes,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.secondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Primary CTA Actions
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 1. Main Import CTA Button
        PressableScale(
          onTap: _handleStartImport,
          scaleFactor: 0.98,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF65D0F4).withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: const Color(0xFF006780).withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.70),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: const Color(0xFF00586D).withValues(alpha: 0.30),
                  blurRadius: 6,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isImporting
                  ? Row(
                      key: const ValueKey('importing'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Mengimpor $_transactionCount Transaksi...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _isImported
                      ? Row(
                          key: const ValueKey('imported'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Berhasil Diimpor!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('idle_import'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Mulai Impor $_transactionCount Transaksi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Secondary Cancel Button
        PressableScale(
          onTap: widget.onCancel ?? _clearFile,
          scaleFactor: 0.98,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2C3A).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.90),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Batal',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Fallback card if file is removed
  Widget _buildEmptyFileHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Silakan pilih berkas CSV di atas untuk melihat pratinjau data dan memulai impor.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.secondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
