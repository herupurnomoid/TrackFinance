import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../../../transaction/presentation/widgets/transaction_date_picker_modal.dart';
import '../../data/import_data_model.dart';
import '../widgets/export_format_selector.dart';
import '../widgets/export_import_segmented_control.dart';
import '../widgets/export_import_success_dialog.dart';
import '../widgets/export_range_filter_section.dart';
import '../widgets/export_skeleton.dart';
import '../widgets/import_csv_spec_card.dart';
import '../widgets/import_data_preview_section.dart';
import '../widgets/import_drop_zone.dart';
import '../widgets/import_skeleton.dart';
import '../widgets/import_uploaded_file_card.dart';
import '../widgets/import_validation_stats_row.dart';
import '../widgets/month_picker_modal.dart';
import '../widgets/problematic_rows_modal.dart';
import '../widgets/year_picker_modal.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';

/// Halaman Ekspor & Impor Data Transaksi
/// Menerapkan estetika Modern Tactile Finance, animasi transisi lembut,
/// serta mendukung filter rentang tanggal, filter bulan, pemilihan format (PDF & CSV),
/// dan alur impor file interaktif.
class ExportDataScreen extends StatefulWidget {
  final UserProfile? user;
  final bool initialIsExport;
  final bool initialIsLoading;
  final bool initialHasFile;
  final String initialExportPeriod;
  final String initialExportFormat;

  const ExportDataScreen({
    super.key,
    this.user,
    this.initialIsExport = false,
    this.initialIsLoading = false,
    this.initialHasFile = true,
    this.initialExportPeriod = 'Bulan',
    this.initialExportFormat = 'PDF',
  });

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLoading;
  late bool _isImportTab;
  ImportFileModel? _uploadedFile;
  String? _toastMessage;
  Timer? _toastTimer;
  bool _isProcessing = false;
  bool _isButtonHolding = false;

  // State untuk Tab Ekspor (Rentang, Bulan, Tahun & Format)
  late String _exportPeriod; // 'Rentang', 'Bulan', 'Tahun'
  DateTime _exportStartDate = DateTime(2026, 10, 1);
  DateTime _exportEndDate = DateTime(2026, 10, 9);
  DateTime _selectedMonth = DateTime(2026, 10, 1);
  late String _exportFormat; // 'PDF' atau 'CSV'
  late int _transactionCount;
  double _estimatedTotal = 3840000;

  // Controller untuk animasi entrance staggered
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialIsLoading;
    _isImportTab = !widget.initialIsExport;
    _exportPeriod = widget.initialExportPeriod;
    _exportFormat = widget.initialExportFormat;

    if (_exportPeriod == 'Bulan') {
      _transactionCount = 24;
    } else if (_exportPeriod == 'Rentang') {
      _transactionCount = 9;
    } else {
      _transactionCount = 288;
      _estimatedTotal = 45600000;
    }

    if (widget.initialHasFile) {
      _uploadedFile = ImportFileModel.defaultMock();
    }

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
  }

  @override
  void didUpdateWidget(covariant ExportDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsLoading != oldWidget.initialIsLoading) {
      setState(() {
        _isLoading = widget.initialIsLoading;
      });
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });

    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _toastMessage == message) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      _entranceController.forward(from: 0.0);
    }
  }

  // --- HANDLER TAB IMPOR ---
  Future<void> _handlePickFile() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _uploadedFile = ImportFileModel.defaultMock();
      });
      _showToast('File ${_uploadedFile!.fileName} berhasil dimuat');
    }
  }

  void _handleRemoveFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus File Terpilih?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'File ${_uploadedFile?.fileName} akan dibatalkan dari proses impor.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF434655),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _uploadedFile = null;
              });
              _showToast('File berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleViewProblematicRows() {
    HapticFeedback.lightImpact();
    if (_uploadedFile != null) {
      ProblematicRowsModal.show(
        context,
        rows: _uploadedFile!.problematicRows,
      );
    }
  }

  void _handleDownloadTemplate() {
    HapticFeedback.mediumImpact();
    _showToast('Template CSV berhasil diunduh');
  }

  void _handleDisabledImportTap() {
    HapticFeedback.vibrate();
    _showToast('Pilih file CSV terlebih dahulu untuk mengimpor');
  }

  Future<void> _handleExecuteImport() async {
    if (_uploadedFile == null || _isProcessing) return;

    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showImportSuccessModal();
    }
  }

  void _showImportSuccessModal() {
    final count = _uploadedFile?.validCount ?? 120;
    ExportImportSuccessDialog.show(
      context,
      message: '$count transaksi diimpor',
      onDone: () {
        Navigator.of(context).pop();
        Navigator.of(context).maybePop();
      },
    );
  }

  // --- HANDLER TAB EKSPOR ---
  void _openPickStartDate() {
    TransactionDatePickerModal.show(
      context,
      initialDate: _exportStartDate,
      onConfirm: (picked) {
        setState(() {
          _exportStartDate = picked;
          if (_exportStartDate.isAfter(_exportEndDate)) {
            _exportEndDate = _exportStartDate.add(const Duration(days: 7));
          }
          final days = _exportEndDate.difference(_exportStartDate).inDays + 1;
          _transactionCount = (days * 1.2).clamp(1, 100).toInt();
          _estimatedTotal = _transactionCount * 426000;
        });
      },
    );
  }

  void _openPickEndDate() {
    TransactionDatePickerModal.show(
      context,
      initialDate: _exportEndDate,
      onConfirm: (picked) {
        setState(() {
          _exportEndDate = picked;
          if (_exportEndDate.isBefore(_exportStartDate)) {
            _exportStartDate = _exportEndDate.subtract(const Duration(days: 7));
          }
          final days = _exportEndDate.difference(_exportStartDate).inDays + 1;
          _transactionCount = (days * 1.2).clamp(1, 100).toInt();
          _estimatedTotal = _transactionCount * 426000;
        });
      },
    );
  }

  void _openPickMonth() {
    MonthPickerModal.show(
      context,
      initialDate: _selectedMonth,
      onMonthSelected: (month) {
        setState(() {
          _selectedMonth = month;
          _transactionCount = (month.month * 2).clamp(14, 38);
        });
      },
    );
  }

  void _openPickYear() {
    YearPickerModal.show(
      context,
      initialYear: _selectedMonth.year,
      onYearSelected: (year) {
        setState(() {
          _selectedMonth = DateTime(year, _selectedMonth.month, 1);
          _transactionCount = 288;
          _estimatedTotal = 45600000;
        });
      },
    );
  }

  Future<void> _handleExecuteExport() async {
    if (_isProcessing) return;

    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showExportSuccessModal();
    }
  }

  void _showExportSuccessModal() {
    final String extension = _exportFormat.toLowerCase();
    final String filename = _exportPeriod == 'Bulan'
        ? 'transaksi_${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}.$extension'
        : (_exportPeriod == 'Tahun'
            ? 'transaksi_${_selectedMonth.year}.$extension'
            : 'transaksi_${_exportStartDate.year}-${_exportStartDate.month.toString().padLeft(2, '0')}-${_exportStartDate.day.toString().padLeft(2, '0')}_sd_${_exportEndDate.year}-${_exportEndDate.month.toString().padLeft(2, '0')}-${_exportEndDate.day.toString().padLeft(2, '0')}.$extension');

    ExportImportSuccessDialog.show(
      context,
      message: '$_transactionCount transaksi diekspor',
      onDone: () {
        Navigator.of(context).pop();
        _showToast('Berkas $filename disimpan ke folder Unduhan');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          // Background Gradient Canvas
          Container(
            color: const Color(0xFFFAF8FF),
          ),

            Column(
              children: [
                // 1. Tactile Header with Glassmorphic Back Button (Fixed Top Header)
                _buildHeader(context),

                // 2. Raised Content Panel (Menimpa Header sebesar 20px seperti Halaman Tambah Transaksi & Kategori)
                Expanded(
                  child: Container(
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF8FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: const Color(0xFF2563EB),
                        backgroundColor: Colors.white,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _isLoading
                                ? (_isImportTab
                                    ? ImportSkeleton(
                                        key: const ValueKey('skeleton_import'),
                                        isUploadedState: _uploadedFile != null,
                                      )
                                    : const ExportSkeleton(
                                        key: ValueKey('skeleton_export'),
                                      ))
                                : FadeTransition(
                                    key: const ValueKey('content'),
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 1. Segmented Toggle Control (Impor vs Ekspor)
                                          ExportImportSegmentedControl(
                                            isImportSelected: _isImportTab,
                                            onSelectionChanged: (isImport) {
                                              setState(() => _isImportTab = isImport);
                                            },
                                          ),

                                          const SizedBox(height: 20),

                                          // Konten Tab (Impor atau Ekspor)
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 250),
                                            child: _isImportTab
                                                ? _buildImportContent()
                                                : _buildExportContent(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Primary Bottom Action Dock (Sticky with Gradient Fade)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionDock(),
          ),

          // Floating Toast Notification Pill
          if (_toastMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: 20,
              right: 20,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _toastMessage != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFF7FFC97),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _toastMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Top Header Bar dengan Glassmorphic Back Button dan Gradient Waktu Dinamis
  Widget _buildHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular Glass Tactile Back Button (44x44)
              PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
                scaleFactor: 0.92,
                translateY: 2.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Title "Ekspor & Impor"
              Text(
                'Ekspor & Impor',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              // Spacer seimbang 44x44
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  /// Konten Tab Impor (Mendukung State Belum Ada File vs File Sudah Diunggah)
  Widget _buildImportContent() {
    if (_uploadedFile != null) {
      return Column(
        key: const ValueKey('uploaded_state'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImportUploadedFileCard(
            fileName: _uploadedFile!.fileName,
            totalRows: _uploadedFile!.totalRows,
            onRemove: _handleRemoveFile,
          ),
          const SizedBox(height: 14),
          ImportValidationStatsRow(
            validCount: _uploadedFile!.validCount,
            duplicateCount: _uploadedFile!.duplicateCount,
            errorCount: _uploadedFile!.errorCount,
            onViewProblematicRows: _handleViewProblematicRows,
          ),
          const SizedBox(height: 8),
          ImportDataPreviewSection(
            previews: _uploadedFile!.previews,
            totalValid: _uploadedFile!.validCount,
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey('empty_import_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImportDropZone(
          onTap: _handlePickFile,
        ),
        const SizedBox(height: 14),
        Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleDownloadTemplate,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: Color(0xFF004AC6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Unduh template',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF004AC6),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const ImportCsvSpecCard(),
      ],
    );
  }

  /// Konten Tab Ekspor Sesuai Referensi Desain
  Widget _buildExportContent() {
    return Column(
      key: const ValueKey('export_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Seksi Periode & Filter Tanggal (Rentang / Bulan / Tahun)
        ExportRangeFilterSection(
          activePeriod: _exportPeriod,
          onPeriodChanged: (period) {
            setState(() {
              _exportPeriod = period;
              if (period == 'Bulan') {
                _transactionCount = 24;
                _exportFormat = 'PDF';
              } else if (period == 'Tahun') {
                _transactionCount = 288;
                _estimatedTotal = 45600000;
                _exportFormat = 'PDF';
              } else {
                _transactionCount = 9;
                _exportFormat = 'CSV';
                _estimatedTotal = 3840000;
              }
            });
          },
          startDate: _exportStartDate,
          endDate: _exportEndDate,
          selectedMonth: _selectedMonth,
          onPickStartDate: _openPickStartDate,
          onPickEndDate: _openPickEndDate,
          onPickMonth: _openPickMonth,
          onPickYear: _openPickYear,
          transactionCount: _transactionCount,
          estimatedTotal: _estimatedTotal,
        ),

        const SizedBox(height: 20),

        // 2. Seksi Pemilihan Format Berkas (PDF / CSV)
        ExportFormatSelector(
          selectedFormat: _exportFormat,
          onFormatChanged: (format) {
            setState(() => _exportFormat = format);
          },
          showSubtitle: _exportPeriod == 'Rentang',
          showNoteCard: _exportPeriod == 'Rentang',
        ),
      ],
    );
  }

  /// Sticky Bottom Action Dock
  Widget _buildBottomActionDock() {
    final bool hasFile = _uploadedFile != null;
    final bool isEnabled = _isImportTab ? (hasFile && !_isProcessing) : !_isProcessing;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFAF8FF),
            const Color(0xFFFAF8FF).withValues(alpha: 0.95),
            const Color(0xFFFAF8FF).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTapDown: isEnabled
                    ? (_) {
                        HapticFeedback.lightImpact();
                        setState(() => _isButtonHolding = true);
                      }
                    : null,
                onTapUp: isEnabled ? (_) => setState(() => _isButtonHolding = false) : null,
                onTapCancel: isEnabled ? () => setState(() => _isButtonHolding = false) : null,
                onTap: () {
                  if (_isImportTab) {
                    if (isEnabled) {
                      _handleExecuteImport();
                    } else if (!hasFile) {
                      _handleDisabledImportTap();
                    }
                  } else {
                    _handleExecuteExport();
                  }
                },
                child: AnimatedSlide(
                  offset: _isButtonHolding ? const Offset(0, 0.035) : Offset.zero,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    scale: _isButtonHolding ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isEnabled
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF2563EB), // primary-container
                                  Color(0xFF004AC6), // primary
                                ],
                              )
                            : null,
                        color: isEnabled ? null : const Color(0xFFC3C6D7).withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isEnabled
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: _isButtonHolding ? 0.14 : 0.32),
                                  blurRadius: _isButtonHolding ? 6 : 20,
                                  offset: Offset(0, _isButtonHolding ? 2 : 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF1E40AF).withValues(alpha: _isButtonHolding ? 0.08 : 0.20),
                                  blurRadius: _isButtonHolding ? 2 : 4,
                                  offset: Offset(0, _isButtonHolding ? 1 : 2),
                                ),
                              ]
                            : const [
                                BoxShadow(
                                  color: Color(0x14131B2E),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isImportTab) ...[
                                  if (isEnabled) ...[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    hasFile
                                        ? 'Impor ${_uploadedFile!.validCount} Transaksi'
                                        : 'Impor',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.file_download_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ekspor $_exportFormat',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

              // Subteks Keterangan untuk Tab Ekspor (hanya di mode Rentang)
              if (!_isImportTab && _exportPeriod == 'Rentang') ...[
                const SizedBox(height: 8),
                Text(
                  _exportFormat == 'CSV'
                      ? 'Ukuran file diperkirakan ~14 KB'
                      : 'Ukuran file diperkirakan ~280 KB',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF737686),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
