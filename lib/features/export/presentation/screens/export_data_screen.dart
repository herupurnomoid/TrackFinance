import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../widgets/export_data_skeleton.dart';
import '../widgets/export_format_selector.dart';
import '../widgets/export_period_selector.dart';
import '../widgets/export_preview_table.dart';
import '../widgets/import_data_section.dart';
import '../widgets/period_picker_modal.dart';

class ExportDataScreen extends StatefulWidget {
  final UserProfile? user;
  final bool initialIsExport;
  final bool initialIsLoading;

  const ExportDataScreen({
    super.key,
    this.user,
    this.initialIsExport = true,
    this.initialIsLoading = false,
  });

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  late bool _isExport;
  late bool _isLoading;

  String _selectedMonth = 'Mei';
  String _selectedYear = '2025';
  ExportFileFormat _selectedFormat = ExportFileFormat.csv;

  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _isExport = widget.initialIsExport;
    _isLoading = widget.initialIsLoading;
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

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSkeletonPreview() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _openPeriodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PeriodPickerModal(
          initialMonth: _selectedMonth,
          initialYear: _selectedYear,
          onApply: (month, year) {
            setState(() {
              _selectedMonth = month;
              _selectedYear = year;
            });
            _showSuccessToast('Periode laporan diubah ke $month $year');
          },
        );
      },
    );
  }

  Future<void> _handleDownload() async {
    if (_isDownloading || _isDownloaded) return;

    setState(() {
      _isDownloading = true;
    });

    // Simulate preparation & export delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isDownloading = false;
      _isDownloaded = true;
    });

    final formatName = _selectedFormat == ExportFileFormat.csv ? 'CSV' : 'PDF';
    _showSuccessToast('File $formatName ($_selectedMonth $_selectedYear) berhasil disiapkan & diunduh!');

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        _isDownloaded = false;
      });
    }
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F4FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodText = '$_selectedMonth $_selectedYear';
    final formatLabel = _selectedFormat == ExportFileFormat.csv
        ? 'Unduh File Ekspor (.CSV)'
        : 'Unduh Dokumen Ekspor (.PDF)';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Main Scrollable Body
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerLowest,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 76.0, // Space for top frosted glass app bar
                  bottom: 40.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: _isLoading
                      ? ExportDataSkeleton(
                          key: const ValueKey('skeleton'),
                          isExport: _isExport,
                        )
                      : Column(
                          key: const ValueKey('content'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Header: Pusat Cadangan & Sinkron (hanya di mode Ekspor sesuai referensi)
                            if (_isExport) ...[
                              StaggeredEntrance(
                                index: 0,
                                child: _buildSectionHeader(),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // 2. Segmented Switcher Mode: Ekspor Data vs Impor Data
                            StaggeredEntrance(
                              index: 1,
                              child: _buildSegmentedSwitcher(),
                            ),

                            const SizedBox(height: 18),

                            // 3. Conditional Content: Ekspor Data vs Impor Data
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: _isExport
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Periode Laporan Card
                                  StaggeredEntrance(
                                    index: 2,
                                    child: ExportPeriodSelector(
                                      periodText: periodText,
                                      onChangeTap: _openPeriodPicker,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // Format File Selector (CSV vs PDF)
                                  StaggeredEntrance(
                                    index: 3,
                                    child: ExportFormatSelector(
                                      selectedFormat: _selectedFormat,
                                      onFormatSelected: (format) {
                                        setState(() {
                                          _selectedFormat = format;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // Pratinjau Data (6 Kolom Table)
                                  StaggeredEntrance(
                                    index: 4,
                                    child: ExportPreviewTable(
                                      periodText: periodText,
                                      totalCount: 28,
                                    ),
                                  ),

                                  const SizedBox(height: 26),

                                  // Primary Floating Clay CTA Button: Unduh File Ekspor
                                  StaggeredEntrance(
                                    index: 5,
                                    child: _buildDownloadButton(formatLabel),
                                  ),
                                ],
                              ),
                              secondChild: ImportDataSection(
                                onCancel: () {
                                  setState(() => _isExport = true);
                                },
                                onShowToast: (message) {
                                  _showSuccessToast(message);
                                },
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // Floating Frosted Glass Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingAppBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PUSAT CADANGAN & SINKRON',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola Data Anda',
                style: AppTextStyles.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right Icon Pod
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF65D0F4).withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.95),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.swap_vertical_circle_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedSwitcher() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab 1: Ekspor Data
          Expanded(
            child: PressableScale(
              onTap: () {
                if (!_isExport) setState(() => _isExport = true);
              },
              scaleFactor: 0.96,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExport ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _isExport
                      ? [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: -2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload_rounded,
                      size: 18,
                      color: _isExport ? Colors.white : AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Ekspor Data',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(
                          color: _isExport ? Colors.white : AppColors.secondary,
                          fontWeight: _isExport ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab 2: Impor Data
          Expanded(
            child: PressableScale(
              onTap: () {
                if (_isExport) setState(() => _isExport = false);
              },
              scaleFactor: 0.96,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExport ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !_isExport
                      ? [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: -2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_download_rounded,
                      size: 19,
                      color: !_isExport ? Colors.white : AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Impor Data',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(
                          color: !_isExport ? Colors.white : AppColors.secondary,
                          fontWeight: !_isExport ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String label) {
    return PressableScale(
      onTap: _handleDownload,
      scaleFactor: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isDownloaded ? const Color(0xFF10B981) : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: (_isDownloaded ? const Color(0xFF10B981) : const Color(0xFF65D0F4))
                  .withValues(alpha: 0.50),
              blurRadius: 28,
              spreadRadius: -3,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.7),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isDownloading
                ? Row(
                    key: const ValueKey('downloading'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Menyiapkan File...',
                        style: AppTextStyles.labelLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                : _isDownloaded
                    ? Row(
                        key: const ValueKey('downloaded'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Berhasil Diunduh!',
                            style: AppTextStyles.labelLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              label,
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
    );
  }

  Widget _buildFloatingAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  PressableScale(
                    onTap: () => Navigator.of(context).maybePop(),
                    scaleFactor: 0.92,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.9),
                            blurRadius: 3,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      'Cadangan & Sinkronisasi',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.5,
                      ),
                    ),
                  ),

                  // Skeleton Loading Toggle Button
                  PressableScale(
                    onTap: _toggleSkeletonPreview,
                    scaleFactor: 0.92,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isLoading
                              ? Icons.visibility_rounded
                              : Icons.auto_awesome_rounded,
                          size: 18,
                          color: _isLoading ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
