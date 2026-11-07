import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';

/// Modal Bottom Sheet untuk Pemilihan Waktu (Jam & Menit) pada Tambah/Edit Transaksi.
/// Mengadopsi dual-wheel scroller picker (Jam & Menit) yang konsisten
/// dengan scroller pada halaman Laporan, Ekspor/Impor, dan Date Picker:
/// tipografi jernih tanpa distorsi, masker gradasi fade, lensa seleksi tengah,
/// preset waktu cepat, serta tombol Batal dan tombol tactile CTA 'Terapkan'.
class TransactionTimePickerModal extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onConfirm;
  final String title;

  const TransactionTimePickerModal({
    super.key,
    required this.initialTime,
    required this.onConfirm,
    this.title = 'Pilih Waktu',
  });

  static Future<void> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onConfirm,
    String title = 'Pilih Waktu',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73131B2E), // on-surface/45
      builder: (context) => TransactionTimePickerModal(
        initialTime: initialTime,
        onConfirm: onConfirm,
        title: title,
      ),
    );
  }

  @override
  State<TransactionTimePickerModal> createState() =>
      _TransactionTimePickerModalState();
}

class _TransactionTimePickerModalState
    extends State<TransactionTimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour.clamp(0, 23);
    _selectedMinute = widget.initialTime.minute.clamp(0, 59);

    _hourController =
        FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _handleSelectHour(int hour) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedHour = hour;
    });
    if (_hourController.hasClients && _hourController.selectedItem != hour) {
      _hourController.animateToItem(
        hour,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSelectMinute(int minute) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMinute = minute;
    });
    if (_minuteController.hasClients &&
        _minuteController.selectedItem != minute) {
      _minuteController.animateToItem(
        minute,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleApply() {
    HapticFeedback.mediumImpact();
    widget.onConfirm(TimeOfDay(hour: _selectedHour, minute: _selectedMinute));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Indicator Handle
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. Header Bar: Ikon + Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 19,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Wheel Scroller Picker (Jam & Menit)
          _buildTimeScroller(),

          const SizedBox(height: 20),

          // 4. Action Buttons: Batal & Terapkan
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Dual-Wheel Scroller Picker (Jam & Menit)
  Widget _buildTimeScroller() {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kolom Header Label & Roda Scroller
          Column(
            children: [
              // Header Label Kolom (JAM & MENIT)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'JAM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24), // Ruang pemisah titik dua
                    Expanded(
                      child: Center(
                        child: Text(
                          'MENIT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Roda Scroller (Jam & Menit)
              Expanded(
                child: Row(
                  children: [
                    // Kolom Roda Jam (00 - 23)
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _hourController,
                        itemExtent: 46,
                        diameterRatio: 2.2,
                        squeeze: 1.0,
                        useMagnifier: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedHour = index;
                          });
                        },
                        children: List.generate(24, (index) {
                          final isSelected = index == _selectedHour;
                          final hourStr = index.toString().padLeft(2, '0');
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleSelectHour(index),
                            child: Center(
                              child: Text(
                                hourStr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSelected ? 24 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: isSelected ? -0.3 : -0.1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Pemisah Titik Dua ":"
                    SizedBox(
                      width: 24,
                      child: Center(
                        child: Text(
                          ':',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),

                    // Kolom Roda Menit (00 - 59)
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _minuteController,
                        itemExtent: 46,
                        diameterRatio: 2.2,
                        squeeze: 1.0,
                        useMagnifier: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedMinute = index;
                          });
                        },
                        children: List.generate(60, (index) {
                          final isSelected = index == _selectedMinute;
                          final minuteStr = index.toString().padLeft(2, '0');
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleSelectMinute(index),
                            child: Center(
                              child: Text(
                                minuteStr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSelected ? 24 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: isSelected ? -0.3 : -0.1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Masker Gradasi Atas (Top Fade)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            height: 38,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Masker Gradasi Bawah (Bottom Fade)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 38,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.0),
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

  /// Tombol Aksi: Batal & Terapkan
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Batal
        Expanded(
          flex: 2,
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            scaleFactor: 0.95,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Batal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Tombol Terapkan (Tactile Gradient Blue)
        Expanded(
          flex: 3,
          child: PressableScale(
            onTap: _handleApply,
            scaleFactor: 0.95,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x402563EB),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terapkan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
