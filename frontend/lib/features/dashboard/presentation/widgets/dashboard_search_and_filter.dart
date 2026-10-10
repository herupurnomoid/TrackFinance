import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum DashboardPeriod { hari, minggu, bulan, tahun }

/// Input pencarian sunken / recessed dan 4 filter pills rentang waktu (Hari, Minggu, Bulan, Tahun)
class DashboardSearchAndFilter extends StatefulWidget {
  final DashboardPeriod activePeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController searchController;

  const DashboardSearchAndFilter({
    super.key,
    required this.activePeriod,
    required this.onPeriodChanged,
    required this.onSearchChanged,
    required this.searchController,
  });

  @override
  State<DashboardSearchAndFilter> createState() =>
      _DashboardSearchAndFilterState();
}

class _DashboardSearchAndFilterState extends State<DashboardSearchAndFilter> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Sunken Search Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFCBD5E1),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.search_rounded,
                size: 20,
                color: _isFocused
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  focusNode: _focusNode,
                  onChanged: widget.onSearchChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onSearchChanged('');
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Period Filter Pills (Hari, Minggu, Bulan, Tahun)
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildFilterPill('Hari', DashboardPeriod.hari),
              const SizedBox(width: 6),
              _buildFilterPill('Minggu', DashboardPeriod.minggu),
              const SizedBox(width: 6),
              _buildFilterPill('Bulan', DashboardPeriod.bulan),
              const SizedBox(width: 6),
              _buildFilterPill('Tahun', DashboardPeriod.tahun),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, DashboardPeriod period) {
    return Expanded(
      child: _FilterPillButton(
        label: label,
        isActive: widget.activePeriod == period,
        onTap: () => widget.onPeriodChanged(period),
      ),
    );
  }
}

class _FilterPillButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPillButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_FilterPillButton> createState() => _FilterPillButtonState();
}

class _FilterPillButtonState extends State<_FilterPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedSlide(
        offset: _isPressed ? const Offset(0, 0.04) : Offset.zero,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: widget.isActive
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF2563EB),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFF8FAFC),
                      ],
                    ),
              border: Border.all(
                color: widget.isActive
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB)
                            .withValues(alpha: _isPressed ? 0.18 : 0.35),
                        blurRadius: _isPressed ? 3 : 6,
                        offset: Offset(0, _isPressed ? 1 : 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
