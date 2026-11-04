import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Layout pergeseran vertikal presisi untuk overlap antar layer di dalam Column / ScrollView.
///
/// Berbeda dengan [Transform.translate] murni yang menggeser tampilan visual tetapi
/// tetap menyisakan ruang layout kosong di bagian bawah Column, [DashboardOverlapLayout]
/// menyesuaikan ukuran layout yang dilaporkan ke parent ([child.height - topOverlap]).
///
/// Hal ini menjamin:
/// 1. Tampilan content panel naik menimpa header sesuai [topOverlap].
/// 2. Dasar content panel menutup sempurna hingga akhir scroll view tanpa celah/jarak
///    kosong di bagian bawah, menghilangkan efek "belang" atau layer belakang yang bocor.
class DashboardOverlapLayout extends SingleChildRenderObjectWidget {
  final double topOverlap;

  const DashboardOverlapLayout({
    super.key,
    required this.topOverlap,
    required super.child,
  });

  @override
  RenderDashboardOverlapLayout createRenderObject(BuildContext context) {
    return RenderDashboardOverlapLayout(topOverlap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDashboardOverlapLayout renderObject,
  ) {
    renderObject.topOverlap = topOverlap;
  }
}

class RenderDashboardOverlapLayout extends RenderShiftedBox {
  double _topOverlap;

  RenderDashboardOverlapLayout(
    this._topOverlap, {
    RenderBox? child,
  }) : super(child);

  double get topOverlap => _topOverlap;
  set topOverlap(double value) {
    if (_topOverlap == value) return;
    _topOverlap = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
      return;
    }
    child!.layout(constraints, parentUsesSize: true);
    final adjustedHeight =
        (child!.size.height - _topOverlap).clamp(0.0, double.infinity);
    size = Size(child!.size.width, adjustedHeight);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset(0, -_topOverlap);
  }
}

/// Clipper yang memotong bayangan (shadow) di bagian bawah kontainer (y >= height),
/// sementara bayangan tepi atas dan samping (offset negatif dan blur) dibiarkan
/// meluap bebas ke atas menimpa layer header.
///
/// Ini mencegah timbulnya garis bayangan horizontal melintang di dasar halaman
/// yang membuat latar belakang tampak bergaris atau belang.
class TopOnlyShadowClipper extends CustomClipper<Rect> {
  final double shadowBleed;

  const TopOnlyShadowClipper({this.shadowBleed = 40.0});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      -shadowBleed,
      -shadowBleed,
      size.width + shadowBleed,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant TopOnlyShadowClipper oldClipper) =>
      oldClipper.shadowBleed != shadowBleed;
}
