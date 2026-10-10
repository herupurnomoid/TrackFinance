import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'header_time_theme.dart';

/// Komponen latar belakang animasi dinamis untuk Dashboard Tactile Header
/// yang beradaptasi secara otomatis atau manual sesuai 4 waktu:
/// - Pagi  🌅 : Fajar keemasan, matahari terbit, awan fajar & kicau burung
/// - Siang ☀️ : Langit biru cerah, kilau matahari, sunbeam & awan berarak
/// - Sore  🌇 : Golden hour senja, matahari terbenam, embun bara & kawanan burung pulang
/// - Malam 🌙 : Langit malam berbintang, bulan sabit, bintang jatuh & aurora misterius
class HeaderTimeBackground extends StatefulWidget {
  final DashboardTimeOfDay timeOfDay;

  const HeaderTimeBackground({
    super.key,
    required this.timeOfDay,
  });

  @override
  State<HeaderTimeBackground> createState() => _HeaderTimeBackgroundState();
}

class _HeaderTimeBackgroundState extends State<HeaderTimeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Loop animasi kontinu berdurasi 12 detik untuk menggerakkan seluruh elemen
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    if (!kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST')) {
      _animController.value = 0.5;
    } else {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: RepaintBoundary(
        key: ValueKey(widget.timeOfDay),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: _TimeSkyPainter(
                timeOfDay: widget.timeOfDay,
                progress: _animController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter utama yang menggambar langit dan animasi elemen spesifik waktu
class _TimeSkyPainter extends CustomPainter {
  final DashboardTimeOfDay timeOfDay;
  final double progress; // 0.0 .. 1.0 continuously

  _TimeSkyPainter({
    required this.timeOfDay,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Gambar Gradient Langit Sesuai Waktu
    _paintSkyGradient(canvas, size);

    // 2. Gambar Elemen Spesifik Berdasarkan Waktu
    switch (timeOfDay) {
      case DashboardTimeOfDay.pagi:
        _paintPagi(canvas, size);
        break;
      case DashboardTimeOfDay.siang:
        _paintSiang(canvas, size);
        break;
      case DashboardTimeOfDay.sore:
        _paintSore(canvas, size);
        break;
      case DashboardTimeOfDay.malam:
        _paintMalam(canvas, size);
        break;
    }
  }

  /// -------------------------------------------------------------
  /// 1. SKY GRADIENT DASAR
  /// -------------------------------------------------------------
  void _paintSkyGradient(Canvas canvas, Size size) {
    final colors = timeOfDay.skyGradientColors;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );

    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  /// -------------------------------------------------------------
  /// 2. ANIMASI PAGI HARI 🌅
  /// Fajar menyingsing, matahari terbit, awan fajar pastel,
  /// partikel embun keemasan, dan burung pagi melayang.
  /// -------------------------------------------------------------
  void _paintPagi(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A. Pendaran Fajar Keemasan (Horizon Dawn Glow)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.75, 0.85),
        radius: 1.0,
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: 0.26),
          const Color(0xFFF59E0B).withValues(alpha: 0.14),
          const Color(0xFFFB923C).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glowPaint);

    // B. Matahari Terbit di Langit Atas dengan Denyut Corona
    final sunCenter = Offset(w * 0.82, h * 0.26);
    final sunBreath = math.sin(progress * 2 * math.pi) * 2.5;
    final sunRadius = 24.0 + sunBreath;

    // Sinar Matahari Pagi yang Berputar Halus
    final rayRotation = progress * 2 * math.pi * 0.35;
    _drawSunRays(
      canvas: canvas,
      center: sunCenter,
      innerRadius: sunRadius + 4,
      outerRadius: sunRadius + 28,
      rotation: rayRotation,
      rayCount: 8,
      color: const Color(0xFFFEF08A).withValues(alpha: 0.16),
    );

    // Corona Matahari Lembut
    final sunCoronaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.60),
          const Color(0xFFFBBF24).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius * 2.2));
    canvas.drawCircle(sunCenter, sunRadius * 2.2, sunCoronaPaint);

    // Bola Matahari Inti
    final sunCorePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFBEB),
          Color(0xFFFEF08A),
          Color(0xFFF59E0B),
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
    canvas.drawCircle(sunCenter, sunRadius, sunCorePaint);

    // C. Awan Fajar Berarak (Pastel Pink-Peach & White rim)
    // Awan 1 (Lapis Belakang)
    final cloud1X = ((progress * 0.55) % 1.3 - 0.2) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud1X, h * 0.32),
      scale: 0.85,
      bodyColor: Colors.white.withValues(alpha: 0.14),
      rimColor: const Color(0xFFFDE68A).withValues(alpha: 0.22),
    );

    // Awan 2 (Lapis Depan Dekat Horizon)
    final cloud2X = (((progress * 0.40) + 0.45) % 1.4 - 0.25) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud2X, h * 0.68),
      scale: 1.05,
      bodyColor: Colors.white.withValues(alpha: 0.18),
      rimColor: const Color(0xFFFED7AA).withValues(alpha: 0.26),
    );

    // D. Partikel Kilau Embun Pagi (Golden Dew Sparkles)
    final sparklePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 14; i++) {
      final seed = (i * 73 + 19) % 100 / 100.0;
      final seed2 = (i * 37 + 51) % 100 / 100.0;
      final pProgress = (progress + seed) % 1.0;

      final px = (seed2 * w + math.sin(pProgress * 2 * math.pi + i) * 16) % w;
      final py = (1.0 - pProgress) * h * 0.9 + h * 0.05;
      final alpha = math.sin(pProgress * math.pi) * 0.55;
      final r = 1.2 + (i % 3) * 0.7;

      sparklePaint.color = const Color(0xFFFEF3C7).withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), r, sparklePaint);
    }

    // E. Burung Pagi Melayang (Siluet Burung Fajar)
    final bird1Progress = (progress * 0.90) % 1.2 - 0.1;
    final bird1X = bird1Progress * w;
    final bird1Y = h * 0.22 + math.sin(progress * 4 * math.pi) * 6;
    final bird1Wing = math.sin(progress * 14 * math.pi);
    _drawBird(
      canvas: canvas,
      center: Offset(bird1X, bird1Y),
      scale: 0.75,
      wingAngle: bird1Wing,
      color: Colors.white.withValues(alpha: 0.38),
    );

    final bird2Progress = (progress * 0.82 + 0.5) % 1.25 - 0.15;
    final bird2X = bird2Progress * w;
    final bird2Y = h * 0.28 + math.sin(progress * 4 * math.pi + 1.2) * 5;
    final bird2Wing = math.sin(progress * 13 * math.pi + 0.8);
    _drawBird(
      canvas: canvas,
      center: Offset(bird2X, bird2Y),
      scale: 0.58,
      wingAngle: bird2Wing,
      color: Colors.white.withValues(alpha: 0.28),
    );
  }

  /// -------------------------------------------------------------
  /// 3. ANIMASI SIANG HARI ☀️
  /// Langit biru jernih, matahari menyilaukan di atas,
  /// diagonal god rays (sunbeams) berdenyut, dan awan putih mengembang.
  /// -------------------------------------------------------------
  void _paintSiang(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sunCenter = Offset(w * 0.82, h * 0.24);

    // A. Diagonal Sunbeams / God Rays
    final rayPulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final rayOpacity = 0.045 + (0.040 * rayPulse);

    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withValues(alpha: rayOpacity * 1.5),
          Colors.white.withValues(alpha: rayOpacity * 0.8),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

    // Tiga berkas sinar diagonal luas
    final rayPath = Path();
    // Berkas 1
    rayPath.moveTo(sunCenter.dx - 10, sunCenter.dy);
    rayPath.lineTo(0, h * 0.85);
    rayPath.lineTo(0, h * 1.15);
    rayPath.lineTo(sunCenter.dx + 25, sunCenter.dy);
    rayPath.close();

    // Berkas 2
    rayPath.moveTo(sunCenter.dx - 40, sunCenter.dy + 10);
    rayPath.lineTo(w * 0.2, h * 1.1);
    rayPath.lineTo(w * 0.4, h * 1.1);
    rayPath.lineTo(sunCenter.dx + 15, sunCenter.dy + 30);
    rayPath.close();

    canvas.drawPath(rayPath, rayPaint);

    // B. Pendaran Matahari Terik (High Sun Corona & Core)
    final sunCoreRadius = 26.0;

    // Sinar Bintang Matahari (12 Point Star Rays)
    final sunRaysAngle = progress * 2 * math.pi * 0.25;
    _drawSunRays(
      canvas: canvas,
      center: sunCenter,
      innerRadius: sunCoreRadius + 2,
      outerRadius: sunCoreRadius + 32,
      rotation: sunRaysAngle,
      rayCount: 12,
      color: Colors.white.withValues(alpha: 0.20),
    );

    // Outer Solar Corona Halo
    final outerHaloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          const Color(0xFF93C5FD).withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: sunCenter, radius: sunCoreRadius * 3.0),
      );
    canvas.drawCircle(sunCenter, sunCoreRadius * 3.0, outerHaloPaint);

    // Matahari Putih Terang
    final brightSunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFFFEF08A),
          Color(0xFF60A5FA),
        ],
        stops: [0.0, 0.70, 1.0],
      ).createShader(
        Rect.fromCircle(center: sunCenter, radius: sunCoreRadius),
      );
    canvas.drawCircle(sunCenter, sunCoreRadius, brightSunPaint);

    // Diamond Lens Flare Glint di Pusat Matahari
    _drawStar4Point(
      canvas: canvas,
      center: sunCenter,
      radius: 42.0 + math.sin(progress * 4 * math.pi) * 6,
      color: Colors.white.withValues(alpha: 0.40),
    );

    // C. Awan Putih Mengembang (Cumulus Daytime Clouds)
    // Awan Latar 1
    final cloud1X = (((progress * 0.45) + 0.1) % 1.4 - 0.2) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud1X, h * 0.45),
      scale: 0.90,
      bodyColor: Colors.white.withValues(alpha: 0.18),
      rimColor: Colors.white.withValues(alpha: 0.30),
    );

    // Awan Latar 2
    final cloud2X = (((progress * 0.32) + 0.65) % 1.45 - 0.25) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud2X, h * 0.75),
      scale: 1.15,
      bodyColor: Colors.white.withValues(alpha: 0.22),
      rimColor: Colors.white.withValues(alpha: 0.35),
    );

    // D. Partikel Cahaya Siang (Bokeh Float & Daylight Sparkle)
    final bokehPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final seedX = (i * 89 + 17) % 100 / 100.0;
      final seedY = (i * 43 + 31) % 100 / 100.0;
      final bProgress = (progress + seedX) % 1.0;

      final bx = (seedX * w + math.sin(bProgress * 2 * math.pi + i) * 14) % w;
      final by = (seedY * h + math.cos(bProgress * 2 * math.pi + i) * 12) % h;
      final bAlpha = (math.sin(bProgress * math.pi) * 0.22).clamp(0.0, 1.0);
      final bRadius = 2.5 + (i % 4) * 1.5;

      bokehPaint.color = Colors.white.withValues(alpha: bAlpha);
      canvas.drawCircle(Offset(bx, by), bRadius, bokehPaint);
    }
  }

  /// -------------------------------------------------------------
  /// 4. ANIMASI SORE HARI 🌇
  /// Senja jingga tembaga (Golden Hour), matahari tenggelam rendah,
  /// awan senja bertepi magenta-emas, bara senja, dan kawanan burung pulang.
  /// -------------------------------------------------------------
  void _paintSore(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A. Pendaran Hangat Senja (Golden Sunset Horizon Glow)
    final sunsetHorizonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.70, 0.90),
        radius: 1.1,
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.28),
          const Color(0xFFEA580C).withValues(alpha: 0.16),
          const Color(0xFFC026D3).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sunsetHorizonPaint);

    // B. Matahari Senja di Langit Kanan Atas (Dusk Sunset Orb)
    final sunCenter = Offset(w * 0.82, h * 0.25);
    final sunRadius = 26.0;

    // Gelombang Resonansi Panas Senja (Concentric Ripple Rings)
    for (int rIdx = 1; rIdx <= 3; rIdx++) {
      final ringProgress = (progress + (rIdx * 0.33)) % 1.0;
      final ringRadius = sunRadius + (ringProgress * 38);
      final ringAlpha = (1.0 - ringProgress) * 0.18;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFBBF24).withValues(alpha: ringAlpha);
      canvas.drawCircle(sunCenter, ringRadius, ringPaint);
    }

    // Pendaran Hangat di Sekitar Matahari
    final sunAuraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.65),
          const Color(0xFFF97316).withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: sunCenter, radius: sunRadius * 2.3),
      );
    canvas.drawCircle(sunCenter, sunRadius * 2.3, sunAuraPaint);

    // Inti Matahari Merah Jingga Keemasan
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFEF3C7),
          Color(0xFFF59E0B),
          Color(0xFFEA580C),
          Color(0xFFBE123C),
        ],
        stops: [0.0, 0.45, 0.80, 1.0],
      ).createShader(
        Rect.fromCircle(center: sunCenter, radius: sunRadius),
      );
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // C. Awan Senja Bertabur Sinar Jingga (Dusk Clouds)
    // Awan 1 Atas
    final cloud1X = (((progress * 0.38) + 0.2) % 1.4 - 0.2) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud1X, h * 0.38),
      scale: 0.88,
      bodyColor: const Color(0xFF581C87).withValues(alpha: 0.22),
      rimColor: const Color(0xFFF59E0B).withValues(alpha: 0.30),
    );

    // Awan 2 Rendah
    final cloud2X = (((progress * 0.28) + 0.6) % 1.45 - 0.25) * w;
    _drawCloud(
      canvas: canvas,
      center: Offset(cloud2X, h * 0.62),
      scale: 1.10,
      bodyColor: const Color(0xFF701A75).withValues(alpha: 0.22),
      rimColor: const Color(0xFFF97316).withValues(alpha: 0.30),
    );

    // D. Bara / Kunang-kunang Senja (Golden Floating Embers)
    final emberPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 16; i++) {
      final seedX = (i * 61 + 23) % 100 / 100.0;
      final eProgress = (progress + seedX) % 1.0;

      final ex = (seedX * w + math.sin(eProgress * 3 * math.pi + i) * 18) % w;
      final ey = (1.0 - eProgress) * h * 0.85 + h * 0.1;
      final eAlpha = (math.sin(eProgress * math.pi) * 0.65).clamp(0.0, 1.0);
      final eRadius = 1.3 + (i % 3) * 0.7;

      emberPaint.color = const Color(0xFFFDE047).withValues(alpha: eAlpha);
      canvas.drawCircle(Offset(ex, ey), eRadius, emberPaint);
    }

    // E. Kawanan Burung Pulang Menuju Senja (V-formation returning swallows)
    final flockBaseProg = (progress * 0.75) % 1.35 - 0.2;
    final flockBaseX = flockBaseProg * w;
    final flockBaseY = h * 0.35 + math.sin(progress * 2 * math.pi) * 8;

    final birdOffsets = [
      const Offset(0, 0),
      const Offset(-16, 8),
      const Offset(-32, 16),
      const Offset(-14, -7),
      const Offset(-28, -13),
    ];

    for (int bIdx = 0; bIdx < birdOffsets.length; bIdx++) {
      final bOffset = birdOffsets[bIdx];
      final bPos = Offset(flockBaseX + bOffset.dx, flockBaseY + bOffset.dy);
      final wingAngle = math.sin(progress * 16 * math.pi + (bIdx * 0.6));
      _drawBird(
        canvas: canvas,
        center: bPos,
        scale: 0.62 - (bIdx * 0.05),
        wingAngle: wingAngle,
        color: Colors.white.withValues(alpha: 0.45 - (bIdx * 0.04)),
      );
    }
  }

  /// -------------------------------------------------------------
  /// 5. ANIMASI MALAM HARI 🌙
  /// Langit gelap berbintang kristal, bulan sabit bercahaya anggun,
  /// meteor bintang jatuh periodik, dan pita lembut nebula aurora.
  /// -------------------------------------------------------------
  void _paintMalam(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A. Pita Lembut Aurora / Nebula Gelombang Malam
    final auroraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.08),
          const Color(0xFFA855F7).withValues(alpha: 0.07),
          const Color(0xFF1E1B4B).withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

    final auroraPath = Path();
    final auroraWave = math.sin(progress * 2 * math.pi) * 12;
    auroraPath.moveTo(0, h * 0.25 + auroraWave);
    auroraPath.cubicTo(
      w * 0.35,
      h * 0.10 - auroraWave,
      w * 0.65,
      h * 0.40 + auroraWave,
      w,
      h * 0.20 - auroraWave,
    );
    auroraPath.lineTo(w, 0);
    auroraPath.lineTo(0, 0);
    auroraPath.close();
    canvas.drawPath(auroraPath, auroraPaint);

    // B. Taburan Bintang Berkelap-Kelip (36 Starfield Positions)
    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 36; i++) {
      final sx = _pseudoRandom(i * 17 + 3) * w;
      final sy = _pseudoRandom(i * 31 + 7) * (h * 0.90) + (h * 0.05);

      final twinkleSpeed = 3.0 + (i % 4) * 2.0;
      final phase = _pseudoRandom(i * 13 + 5) * 2 * math.pi;
      final twinkle = 0.30 + 0.70 * (0.5 + 0.5 * math.sin(progress * twinkleSpeed * 2 * math.pi + phase));

      final baseRadius = 0.9 + (i % 3) * 0.6;
      final radius = baseRadius * (0.8 + 0.4 * twinkle);

      // Beberapa bintang spesial berwarna emas lembut atau biru kristal
      final starColor = (i % 5 == 0)
          ? const Color(0xFFFEF08A)
          : (i % 7 == 0)
              ? const Color(0xFF93C5FD)
              : Colors.white;

      starPaint.color = starColor.withValues(alpha: (twinkle * 0.85).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(sx, sy), radius, starPaint);

      // 4 Bintang Berlian 4-Sudut Menonjol
      if (i % 9 == 0) {
        _drawStar4Point(
          canvas: canvas,
          center: Offset(sx, sy),
          radius: (baseRadius * 3.8) * twinkle,
          color: starColor.withValues(alpha: (twinkle * 0.65).clamp(0.0, 1.0)),
        );
      }
    }

    // C. Bintang Jatuh (Periodic Shooting Star / Meteor Streak)
    // Meteor muncul tiap 50% siklus secara bergantian (2 kali per 12 detik)
    final meteorCycle = (progress * 2.0) % 1.0;
    if (meteorCycle < 0.24) {
      // Meteor aktif dalam fase 0.0 .. 0.24
      final mProg = meteorCycle / 0.24; // 0.0 .. 1.0
      final startX = w * 0.92;
      final startY = h * 0.08;
      final distance = w * 0.48;

      final currentHeadX = startX - (mProg * distance);
      final currentHeadY = startY + (mProg * distance * 0.55);

      final tailLength = 48.0;
      final tailStartX = currentHeadX + tailLength;
      final tailStartY = currentHeadY - (tailLength * 0.55);

      final meteorAlpha = (math.sin(mProg * math.pi) * 0.95).clamp(0.0, 1.0);

      final meteorPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.white.withValues(alpha: meteorAlpha),
            const Color(0xFF93C5FD).withValues(alpha: meteorAlpha * 0.65),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(
          Rect.fromPoints(
            Offset(currentHeadX, currentHeadY),
            Offset(tailStartX, tailStartY),
          ),
        )
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(currentHeadX, currentHeadY),
        Offset(tailStartX, tailStartY),
        meteorPaint,
      );

      // Kilau Kepala Meteor
      canvas.drawCircle(
        Offset(currentHeadX, currentHeadY),
        1.8,
        Paint()..color = Colors.white.withValues(alpha: meteorAlpha),
      );
    }

    // D. Bulan Sabit Bercahaya Anggun (Luminous Crescent Moon)
    final moonCenter = Offset(w * 0.82, h * 0.26);
    final moonRadius = 22.0;

    // Halo Cahaya Biru Perak Bulan
    final moonHaloPulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final moonHaloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF93C5FD).withValues(alpha: 0.32 + (moonHaloPulse * 0.12)),
          const Color(0xFF38BDF8).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.8),
      );
    canvas.drawCircle(moonCenter, moonRadius * 2.8, moonHaloPaint);

    // Bulan Sabit Presisi dengan Path Difference
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));

    // Lingkaran pemotong untuk membentuk sabit
    final cutterCenter = Offset(moonCenter.dx + 8.5, moonCenter.dy - 5.5);
    final cutterPath = Path()
      ..addOval(Rect.fromCircle(center: cutterCenter, radius: moonRadius * 0.95));

    final crescentPath = Path.combine(
      PathOperation.difference,
      moonPath,
      cutterPath,
    );

    final crescentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF1F5F9),
          Color(0xFFCBD5E1),
          Color(0xFF94A3B8),
        ],
      ).createShader(
        Rect.fromCircle(center: moonCenter, radius: moonRadius),
      );

    canvas.drawPath(crescentPath, crescentPaint);

    // Kilau Halus di Ujung Bulan Sabit
    _drawStar4Point(
      canvas: canvas,
      center: Offset(moonCenter.dx - 12, moonCenter.dy + 8),
      radius: 8.0,
      color: Colors.white.withValues(alpha: 0.55),
    );
  }

  /// -------------------------------------------------------------
  /// HELPER SHAPES & CANVAS DRAWING
  /// -------------------------------------------------------------

  /// Menggambar awan organik dengan 3 lingkaran bertumpuk & alas rata
  void _drawCloud({
    required Canvas canvas,
    required Offset center,
    required double scale,
    required Color bodyColor,
    Color? rimColor,
  }) {
    final cloudPath = Path();
    final r = 18.0 * scale;

    // Tiga puncak kubah awan
    final leftCircle = Offset(center.dx - (r * 1.3), center.dy + (r * 0.25));
    final midCircle = Offset(center.dx, center.dy - (r * 0.3));
    final rightCircle = Offset(center.dx + (r * 1.35), center.dy + (r * 0.2));

    cloudPath.addOval(Rect.fromCircle(center: leftCircle, radius: r * 0.85));
    cloudPath.addOval(Rect.fromCircle(center: midCircle, radius: r * 1.15));
    cloudPath.addOval(Rect.fromCircle(center: rightCircle, radius: r * 0.9));

    // Sambungan badan awan
    final bottomRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + (r * 0.35)),
      width: r * 3.6,
      height: r * 1.1,
    );
    cloudPath.addRRect(RRect.fromRectAndRadius(bottomRect, Radius.circular(r * 0.5)));

    // Gambar bayangan / rim keemasan atas jika ada
    if (rimColor != null) {
      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * scale
        ..color = rimColor;
      canvas.drawPath(cloudPath, rimPaint);
    }

    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = bodyColor;
    canvas.drawPath(cloudPath, bodyPaint);
  }

  /// Menggambar siluet burung terbang dengan sudut kepakan sayap dinamis
  void _drawBird({
    required Canvas canvas,
    required Offset center,
    required double scale,
    required double wingAngle, // -1.0 .. 1.0 (sinusoidal flap)
    required Color color,
  }) {
    final wingDip = wingAngle * 7.0 * scale;
    final birdPath = Path();

    // Sayap Kiri
    birdPath.moveTo(center.dx, center.dy);
    birdPath.quadraticBezierTo(
      center.dx - (9 * scale),
      center.dy - (9 * scale) + wingDip,
      center.dx - (18 * scale),
      center.dy - (3 * scale) + (wingDip * 1.4),
    );

    // Sayap Kanan
    birdPath.moveTo(center.dx, center.dy);
    birdPath.quadraticBezierTo(
      center.dx + (9 * scale),
      center.dy - (9 * scale) + wingDip,
      center.dx + (18 * scale),
      center.dy - (3 * scale) + (wingDip * 1.4),
    );

    final birdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawPath(birdPath, birdPaint);
  }

  /// Menggambar berkas sinar radial matahari
  void _drawSunRays({
    required Canvas canvas,
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double rotation,
    required int rayCount,
    required Color color,
  }) {
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;

    final angleStep = (2 * math.pi) / rayCount;

    for (int i = 0; i < rayCount; i++) {
      final angle = rotation + (i * angleStep);
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      final p1 = Offset(
        center.dx + (cosA * innerRadius),
        center.dy + (sinA * innerRadius),
      );
      final p2 = Offset(
        center.dx + (cosA * outerRadius),
        center.dy + (sinA * outerRadius),
      );

      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  /// Menggambar bintang 4-sudut (diamond cross sparkle)
  void _drawStar4Point({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final path = Path();
    final arm = radius;
    final pinch = radius * 0.16;

    path.moveTo(center.dx, center.dy - arm);
    path.quadraticBezierTo(center.dx, center.dy - pinch, center.dx + pinch, center.dy);
    path.quadraticBezierTo(center.dx + pinch, center.dy, center.dx + arm, center.dy);
    path.quadraticBezierTo(center.dx + pinch, center.dy, center.dx, center.dy + pinch);
    path.quadraticBezierTo(center.dx, center.dy + pinch, center.dx, center.dy + arm);
    path.quadraticBezierTo(center.dx, center.dy + pinch, center.dx - pinch, center.dy);
    path.quadraticBezierTo(center.dx - pinch, center.dy, center.dx - arm, center.dy);
    path.quadraticBezierTo(center.dx - pinch, center.dy, center.dx, center.dy - pinch);
    path.close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, paint);
  }

  /// Generator bilangan acak deterministik berbasis seed
  double _pseudoRandom(int seed) {
    final x = math.sin(seed.toDouble()) * 10000;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _TimeSkyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.timeOfDay != timeOfDay;
  }
}
