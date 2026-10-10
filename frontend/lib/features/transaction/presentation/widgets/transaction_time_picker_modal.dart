import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

/// Modal Bottom Sheet Khusus Pemilihan Waktu.
/// Mengadopsi Soft Skeuomorphism dengan physical steppers dan preset cepat.
class TransactionTimePickerModal extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onConfirm;

  const TransactionTimePickerModal({
    super.key,
    required this.initialTime,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (context) => TransactionTimePickerModal(
        initialTime: initialTime,
        onConfirm: onConfirm,
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

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  void _changeHour(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedHour = (_selectedHour + delta) % 24;
      if (_selectedHour < 0) _selectedHour += 24;
    });
  }

  void _changeMinute(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMinute = (_selectedMinute + delta) % 60;
      if (_selectedMinute < 0) _selectedMinute += 60;
    });
  }

  void _setExactTime(int hour, int minute) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedHour = hour;
      _selectedMinute = minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x300F172A),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                'Pilih Waktu',
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.tactileTextPrimary,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              // Time Stepper Box Inset
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // surface-container-low
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'WAKTU TRANSAKSI (WIB)',
                      style: AppTextStyles.labelSm.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepperUnit(
                            value: _selectedHour.toString().padLeft(2, '0'),
                            label: 'Jam',
                            onDecrement: () => _changeHour(-1),
                            onIncrement: () => _changeHour(1),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.tactileTextPrimary,
                              ),
                            ),
                          ),
                          _buildStepperUnit(
                            value: _selectedMinute.toString().padLeft(2, '0'),
                            label: 'Menit',
                            onDecrement: () => _changeMinute(-1),
                            onIncrement: () => _changeMinute(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Time Presets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPresetChip(
                      label: 'Sekarang',
                      onTap: () {
                        final now = TimeOfDay.now();
                        _setExactTime(now.hour, now.minute);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Pagi (08:00)',
                      onTap: () => _setExactTime(8, 0),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Siang (12:30)',
                      onTap: () => _setExactTime(12, 30),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Sore (17:00)',
                      onTap: () => _setExactTime(17, 0),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Malam (20:00)',
                      onTap: () => _setExactTime(20, 0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons: Batal & Pilih Waktu
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: PressableScale(
                      onTap: () => Navigator.of(context).pop(),
                      scaleFactor: 0.95,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0xFFF8FAFC),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 0,
                              offset: Offset(0, -1),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.tactileTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol Pilih Waktu
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        widget.onConfirm(
                          TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                        );
                        Navigator.of(context).pop();
                      },
                      scaleFactor: 0.95,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF1E40AF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Pilih',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperUnit({
    required String value,
    required String label,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          PressableScale(
            onTap: onDecrement,
            scaleFactor: 0.88,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.remove_rounded,
                size: 20,
                color: AppColors.tactileTextPrimary,
              ),
            ),
          ),

          SizedBox(
            width: 48,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.tactileTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Increment button
          PressableScale(
            onTap: onIncrement,
            scaleFactor: 0.88,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: AppColors.tactileTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: const Color(0xFF434655),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
